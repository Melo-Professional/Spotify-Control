#Requires AutoHotkey v2.0

; --- INITIALIZATION ---
InitTrayController()

InitTrayController() {
    ; Static state map encapsulates configuration and state locally
    static State := Map(
        "Gui", 0, "Tracker", 0, "TrayHandler", 0,
        "BaseSize", 30, "HoverSize", 36, "ShrinkSize", 28,
        "AnimDuration", 80, "FrameRate", 10,
        "ActiveHoverCtrl", 0, "OrigCoords", Map(), "CurrentSizes", Map(), "ClickableCtrls", []
    )

    A_IconTip := ""

    ; 1. Build GUI Container
    TrayGui := Gui("+AlwaysOnTop -Caption -SysMenu +ToolWindow +Owner")
    TrayGui.MarginX := 20
    TrayGui.MarginY := 20
    State["Gui"] := TrayGui

    fontSize := IsSet(Settings) && HasProp(Settings, "GuiFontSizeMedium") ? Settings.GuiFontSizeMedium : 10
    fontName := IsSet(Settings) && HasProp(Settings, "GuiFontName") ? Settings.GuiFontName : "Segoe UI"
    TrayGui.SetFont("s" . fontSize, fontName)

    ; 2. Add Controls
    pAdd    := TrayGui.AddPicture("w30 h-1 xm ym", imageAdd ?? "")
    pMute   := TrayGui.AddPicture("w30 h-1 x+10 ym", imageUnmute ?? "")
    pUnmute := TrayGui.AddPicture("w30 h-1 xp yp Hidden", imageUnmute ?? "")
    pFull   := TrayGui.AddPicture("w30 h-1 x+10 ym", imageFullscreen ?? "")

    pPrev   := TrayGui.AddPicture("w30 h-1 xm y+10", imagePrevious ?? "")
    pPlay   := TrayGui.AddPicture("w30 h-1 x+10 yp", imagePlay ?? "")
    pPause  := TrayGui.AddPicture("w30 h-1 xp yp Hidden", imagePlay ?? "")
    pNext   := TrayGui.AddPicture("w30 h-1 x+10 yp", imageNext ?? "")

    State["ClickableCtrls"] := [pAdd, pMute, pUnmute, pFull, pPrev, pPlay, pPause, pNext]

    ; 3. Map Default Geometries
    for ctrl in State["ClickableCtrls"] {
        ctrl.GetPos(&cX, &cY)
        State["OrigCoords"][ctrl.Hwnd] := {X: cX, Y: cY}
        State["CurrentSizes"][ctrl.Hwnd] := State["BaseSize"]
    }

    ; 4. Setup GuiTracker
    Tracker := GuiTracker()
    State["Tracker"] := Tracker

    ; Hides GUI 300ms after mouse leaves GUI bounds
    Tracker.SetAutoDismiss("Hide", 300)

    Tracker.RegisterGui(Map(
        "OnWheelUp",   (*) => ModifySpotifyVolume(100 / 15),
        "OnWheelDown", (*) => ModifySpotifyVolume(-(100 / 15)),
        "OnLeave",     (*) => ResetHoveredControl(State)
    ))

    ; Register Control Actions & Wheel Binds
    RegisterControlEvents(Tracker, State, pAdd,  () => Spotify_UWP.AddToList())
    RegisterControlEvents(Tracker, State, pFull, () => Spotify_UWP.ToggleFullscreen())
    RegisterControlEvents(Tracker, State, pPrev, () => Spotify_UWP.PreviousSong())
    RegisterControlEvents(Tracker, State, pNext, () => Spotify_UWP.NextSong())

    RegisterToggleEvents(Tracker, State, pPlay, pPause, () => Spotify_UWP.TogglePlay())
    RegisterToggleEvents(Tracker, State, pPause, pPlay, () => Spotify_UWP.TogglePlay())
    RegisterToggleEvents(Tracker, State, pMute, pUnmute, () => Spotify_UWP.ToggleMute())
    RegisterToggleEvents(Tracker, State, pUnmute, pMute, () => Spotify_UWP.ToggleMute())

    Tracker.AddGui := TrayGui

    ; 5. Instantiate TrayIconHandler
    TrayHandler := TrayIconHandler()
    TrayHandler.HoverDelay := 400
    State["TrayHandler"] := TrayHandler

    TrayHandler.OnRightClick    := (*) => A_TrayMenu.Show()
    TrayHandler.OnLeftClick     := (*) => Spotify_UWP.TogglePlay()
    TrayHandler.OnDoubleClick   := (*) => Spotify_UWP.ToggleFullscreen()
    TrayHandler.OnHover         := (t) => ShowTrayGui(State, t)
    TrayHandler.OnLeave         := (t) => OnTrayIconLeave(State, t)
    TrayHandler.OnWheelUp       := (*) => ModifySpotifyVolume(100 / 15)
    TrayHandler.OnWheelDown     := (*) => ModifySpotifyVolume(-(100 / 15))

    ; System Event Handlers
    TrayGui.OnEvent("Close", (*) => CleanDestroyTC(State))
    TrayGui.OnEvent("Escape", (*) => CleanDestroyTC(State))

    if HasMethod(IsSet(ApplyThemeToGui) ? ApplyThemeToGui : 0) {
        ApplyThemeToGui(TrayGui)
        if IsSet(WatchedGUIs) && HasMethod(WatchedGUIs.Push)
            WatchedGUIs.Push(TrayGui)
    }
}

; --- SHOW / HIDE LOGIC ---

ShowTrayGui(State, trayObj) {
    TrayGui := State["Gui"]

    if WinExist(TrayGui.Hwnd) && DllCall("IsWindowVisible", "Ptr", TrayGui.Hwnd)
        return

    if IsFunctionDefined("FrostedTheme") && IsFunctionDefined("ApplyThemeToGui") {
        %"ApplyThemeToGui"%(TrayGui, "Dark")
        %"FrostedTheme"%.Apply(TrayGui)
    } else if IsFunctionDefined("ApplyThemeToGui") {
        %"ApplyThemeToGui"%(TrayGui)
    }

    ; Re-bind GUI and reset internal Tracker state prior to display
    ResetHoveredControl(State)
    Tracker := State["Tracker"]
    Tracker.hoveredCtrlHwnd := 0
    Tracker.isMouseOverGui := false
    Tracker.leaveStartTime := 0
    Tracker.AddGui := TrayGui

    ; Force layout calculation to acquire accurate GUI dimensions
    TrayGui.Show("Hide")
    TrayGui.GetPos(,, &guiWidth, &guiHeight)
    if (!guiWidth) {
        guiWidth := 150
        guiHeight := 100
    }

    ; Fetch raw coordinates of the Tray Icon
    tbInfo := trayObj.GetTaskbarPosition()
    iconX := tbInfo.X
    iconY := tbInfo.Y

    ; Determine target monitor geometrically based on icon location
    monIndex := 1
    loop MonitorGetCount() {
        MonitorGet(A_Index, &L, &T, &R, &B)
        if (iconX >= L && iconX <= R && iconY >= T && iconY <= B) {
            monIndex := A_Index
            break
        }
    }

    MonitorGet(monIndex, &mL, &mT, &mR, &mB)
    offsetGap := DPIScale(1)

    ; Get physical taskbar dimensions (works even in auto-hide mode)
    tbHwnd := WinExist("ahk_class Shell_TrayWnd")
    if tbHwnd {
        WinGetPos(&tbX, &tbY, &tbW, &tbH, tbHwnd)
    } else {
        tbX := mL, tbY := mB - 48, tbW := mR - mL, tbH := 48 ; Fallback
    }

    ; Determine true orientation by comparing icon proximity to physical monitor edges
    distTop    := Abs(iconY - mT)
    distBottom := Abs(iconY - mB)
    distLeft   := Abs(iconX - mL)
    distRight  := Abs(iconX - mR)

    minDist := Min(distTop, distBottom, distLeft, distRight)

    if (minDist == distTop) {
        ; Taskbar at Top -> Spawn below taskbar edge
        spawnX := iconX - (guiWidth / 2)
        spawnY := (tbY + tbH) + offsetGap
    } else if (minDist == distBottom) {
        ; Taskbar at Bottom -> Spawn above taskbar edge
        spawnX := iconX - (guiWidth / 2)
        spawnY := tbY - guiHeight - offsetGap
    } else if (minDist == distLeft) {
        ; Taskbar on Left -> Spawn right of taskbar edge
        spawnX := (tbX + tbW) + offsetGap
        spawnY := iconY - (guiHeight / 2)
    } else {
        ; Taskbar on Right -> Spawn left of taskbar edge
        spawnX := tbX - guiWidth - offsetGap
        spawnY := iconY - (guiHeight / 2)
    }

    ; Safeguard: Clamp GUI within the target monitor's bounds
    spawnX := Clamp(spawnX, mL + 8, mR - guiWidth - 8)
    spawnY := Clamp(spawnY, mT + 8, mB - guiHeight - 8)

    TrayGui.Show("X" . Round(spawnX) . " Y" . Round(spawnY) . " NoActivate")

    DllCall("SetWindowPos", "Ptr", TrayGui.Hwnd, "Ptr", -1, "Int", 0, "Int", 0, "Int", 0, "Int", 0, "UInt", 0x0043)
    DllCall("dwmapi\DwmSetWindowAttribute", "Ptr", TrayGui.Hwnd, "UInt", 33, "Int*", 2, "UInt", 4)
}

Clamp(val, minVal, maxVal) {
    return Max(minVal, Min(val, maxVal))
}

OnTrayIconLeave(State, trayObj) {
    ; Mouse left the tray icon. If it didn't enter the GUI, hide after a short delay
    SetTimer(() => EvaluateMousePresence(State), -150)
}

EvaluateMousePresence(State) {
    TrayGui := State["Gui"]
    TrayHandler := State["TrayHandler"]

    if (!WinExist(TrayGui.Hwnd) || !DllCall("IsWindowVisible", "Ptr", TrayGui.Hwnd))
        return

    ; Check if mouse is inside the GUI window boundaries
    CoordMode("Mouse", "Screen")
    MouseGetPos(&mX, &mY, &hoverWin)

    isOverGui := (hoverWin == TrayGui.Hwnd)
    isOverIcon := TrayHandler.IsHovering

    ; Hide if mouse is neither over the tray icon nor inside the GUI
    if (!isOverGui && !isOverIcon) {
        ResetHoveredControl(State)
        TrayGui.Hide()
    }
}

; --- TRACKER REGISTRATION HELPERS ---

RegisterControlEvents(Tracker, State, ctrlObj, actionFunc) {
    Tracker.RegisterControl(ctrlObj, Map(
        "OnEnter",     (c) => SetControlHovered(State, c),
        "OnLeave",     (c) => SetControlUnhovered(State, c),
        "OnLClick",    (c) => OnImageClick(State, c, actionFunc),
        "OnWheelUp",   (*) => ModifySpotifyVolume(100 / 15),
        "OnWheelDown", (*) => ModifySpotifyVolume(-(100 / 15))
    ))
}

RegisterToggleEvents(Tracker, State, clickedCtrl, targetCtrl, actionFunc) {
    Tracker.RegisterControl(clickedCtrl, Map(
        "OnEnter",     (c) => SetControlHovered(State, c),
        "OnLeave",     (c) => SetControlUnhovered(State, c),
        "OnLClick",    (c) => OnToggleClick(State, clickedCtrl, targetCtrl, actionFunc),
        "OnWheelUp",   (*) => ModifySpotifyVolume(100 / 15),
        "OnWheelDown", (*) => ModifySpotifyVolume(-(100 / 15))
    ))
}

; --- ANIMATION LOGIC ---

AnimateControl(State, ctrlObj, targetSize) {
    if !State["OrigCoords"].Has(ctrlObj.Hwnd)
        return

    orig := State["OrigCoords"][ctrlObj.Hwnd]
    startSize := State["CurrentSizes"][ctrlObj.Hwnd]
    if (startSize == targetSize)
        return

    startTime := A_TickCount
    if ctrlObj.HasProp("AnimTimer")
        SetTimer(ctrlObj.AnimTimer, 0)

    AnimLoop() {
        elapsed := A_TickCount - startTime
        if (elapsed >= State["AnimDuration"]) {
            SetTimer(ctrlObj.AnimTimer, 0)
            State["CurrentSizes"][ctrlObj.Hwnd] := targetSize
            offset := (State["BaseSize"] - targetSize) // 2
            ctrlObj.Move(orig.X + offset, orig.Y + offset, targetSize, targetSize)
        } else {
            progress := elapsed / State["AnimDuration"]
            currentSize := Round(startSize + (targetSize - startSize) * progress)
            State["CurrentSizes"][ctrlObj.Hwnd] := currentSize
            offset := (State["BaseSize"] - currentSize) // 2
            ctrlObj.Move(orig.X + offset, orig.Y + offset, currentSize, currentSize)
        }
        DllCall("RedrawWindow", "Ptr", State["Gui"].Hwnd, "Ptr", 0, "Ptr", 0, "UInt", 0x0105)
    }

    ctrlObj.AnimTimer := AnimLoop
    SetTimer(ctrlObj.AnimTimer, State["FrameRate"])
}

SetControlHovered(State, ctrlObj) {
    State["ActiveHoverCtrl"] := ctrlObj.Hwnd
    AnimateControl(State, ctrlObj, State["HoverSize"])
}

SetControlUnhovered(State, ctrlObj) {
    if (State["ActiveHoverCtrl"] == ctrlObj.Hwnd)
        State["ActiveHoverCtrl"] := 0
    AnimateControl(State, ctrlObj, State["BaseSize"])
}

ResetHoveredControl(State) {
    if (State["ActiveHoverCtrl"] != 0) {
        for ctrl in State["ClickableCtrls"] {
            if (ctrl.Hwnd == State["ActiveHoverCtrl"]) {
                AnimateControl(State, ctrl, State["BaseSize"])
                break
            }
        }
        State["ActiveHoverCtrl"] := 0
    }
}

OnImageClick(State, ctrlObj, actionFunc) {
    AnimateControl(State, ctrlObj, State["ShrinkSize"])
    actionFunc()
    SetTimer(() => (
        State["ActiveHoverCtrl"] == ctrlObj.Hwnd ? AnimateControl(State, ctrlObj, State["HoverSize"]) : AnimateControl(State, ctrlObj, State["BaseSize"])
    ), -100)
}

OnToggleClick(State, clickedCtrl, targetCtrl, actionFunc) {
    AnimateControl(State, clickedCtrl, State["ShrinkSize"])
    actionFunc()
    SetTimer(() => ToggleSwap(State, clickedCtrl, targetCtrl), -100)
}

ToggleSwap(State, clickedCtrl, targetCtrl) {
    orig := State["OrigCoords"][clickedCtrl.Hwnd]
    clickedCtrl.Visible := false

    State["CurrentSizes"][clickedCtrl.Hwnd] := State["BaseSize"]
    State["CurrentSizes"][targetCtrl.Hwnd] := State["BaseSize"]

    clickedCtrl.Move(orig.X, orig.Y, State["BaseSize"], State["BaseSize"])
    targetCtrl.Move(orig.X, orig.Y, State["BaseSize"], State["BaseSize"])
    targetCtrl.Visible := true

    DllCall("RedrawWindow", "Ptr", State["Gui"].Hwnd, "Ptr", 0, "Ptr", 0, "UInt", 0x0105)

    State["ActiveHoverCtrl"] := targetCtrl.Hwnd
    AnimateControl(State, targetCtrl, State["HoverSize"])
}

; --- HELPERS & ACTIONS ---

ModifySpotifyVolume(amount) {
    if IsSet(Spotify_UWP) && HasProp(Spotify_UWP, "Volume") {
        Spotify_UWP.Volume += amount
    }
}

CleanDestroyTC(State) {
    if HasMethod(IsSet(RemoveGuiFromArray) ? RemoveGuiFromArray : 0)
        RemoveGuiFromArray(State["Gui"])
    ResetHoveredControl(State)
    State["Gui"].Hide()
}