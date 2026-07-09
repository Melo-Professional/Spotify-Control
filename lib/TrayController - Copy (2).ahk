#Requires AutoHotkey v2.0
#SingleInstance Force

global LeaveCount := 0 

global TrayControllerGUI := Gui("+AlwaysOnTop -Caption -SysMenu +ToolWindow +Owner")

TrayControllerGUI.MarginX := 20
TrayControllerGUI.MarginY := 20
fontSize := IsSet(Settings) && HasProp(Settings, "GuiFontSizeMedium") ? Settings.GuiFontSizeMedium : 10
fontName := IsSet(Settings) && HasProp(Settings, "GuiFontName") ? Settings.GuiFontName : "Segoe UI"
TrayControllerGUI.SetFont("s" fontSize, fontName)

global TrayControllerGUIHwnd := TrayControllerGUI.Hwnd

; --- HOVER & ANIMATION CONFIGURATION ---
global BaseSize := 30
global HoverSize := 36 
global ShrinkSize := 28
global ActiveHoverCtrl := 0

; --- ANIMATION SPEED CONFIG (In Milliseconds) ---
global AnimationDuration := 80  ; Total time the animation should take
global FrameRate := 10          ; How often it updates (10ms = ~100fps for smoothness)

; Store baseline grid coordinates and current runtime sizes
global OrigCoords := Map()
global CurrentSizes := Map()

; --- TOP ROW ---
pAdd       := TrayControllerGUI.AddPicture("w30 h-1 xm ym", imageAdd)
pMute      := TrayControllerGUI.AddPicture("w30 h-1 x+10 ym", imageUnmute)
pUnmute    := TrayControllerGUI.AddPicture("w30 h-1 xp yp Hidden", imageUnmute)
pFull      := TrayControllerGUI.AddPicture("w30 h-1 x+10 ym", imageFullscreen)

; --- BOTTOM ROW ---
pPrev      := TrayControllerGUI.AddPicture("w30 h-1 xm y+10", imagePrevious)
pPlay      := TrayControllerGUI.AddPicture("w30 h-1 x+10 yp", imagePlay)
pPause     := TrayControllerGUI.AddPicture("w30 h-1 xp yp Hidden", imagePlay)
pNext      := TrayControllerGUI.AddPicture("w30 h-1 x+10 yp", imageNext)

global ClickableCtrls := [pAdd, pMute, pUnmute, pFull, pPrev, pPlay, pPause, pNext]

for ctrl in ClickableCtrls {
    ctrl.GetPos(&cX, &cY, &cW, &cH)
    OrigCoords[ctrl.Hwnd] := {X: cX, Y: cY}
    CurrentSizes[ctrl.Hwnd] := BaseSize
}

pAdd.OnEvent("Click",  (ctrl, *) => OnImageClick(ctrl, AddFunction))
pFull.OnEvent("Click", (ctrl, *) => OnImageClick(ctrl, FullscreenFunction))
pPrev.OnEvent("Click", (ctrl, *) => OnImageClick(ctrl, PreviousFunction))
pNext.OnEvent("Click", (ctrl, *) => OnImageClick(ctrl, NextFunction))

pPlay.OnEvent("Click",  (ctrl, *) => OnToggleClick(pPlay, pPause, PlayFunction))
pPause.OnEvent("Click", (ctrl, *) => OnToggleClick(pPause, pPlay, PauseFunction))
pMute.OnEvent("Click",  (ctrl, *) => OnToggleClick(pMute, pUnmute, MuteFunction))
pUnmute.OnEvent("Click",(ctrl, *) => OnToggleClick(pUnmute, pMute, UnmuteFunction))

TrayControllerGUI.OnEvent("Close", CleanDestroyTC)
TrayControllerGUI.OnEvent("Escape", CleanDestroyTC)

if IsFunctionDefined("ApplyThemeToGui") {
    %"ApplyThemeToGui"%(TrayControllerGUI)
    %"WatchedGUIs"%.Push(TrayControllerGUI)
}

CleanDestroyTC(*) {
    if IsFunctionDefined("RemoveGuiFromArray")
        %"RemoveGuiFromArray"%(TrayControllerGUI)
    if (IsSet(CurrentActualTheme) && CurrentActualTheme == "Dark") {
        %"RemoveGuiFromArray"%(TrayControllerGUI)
    }
    ResetHoveredCtrl()
    TrayControllerGUI.Hide()
}

IsFunctionDefined(Name) {
    try return HasMethod(%Name%)
    return false
}

; --- ANIMATION ENGINE CORE ---
AnimateControl(ctrlObj, targetSize) {
    if !OrigCoords.Has(ctrlObj.Hwnd)
        return
    
    orig := OrigCoords[ctrlObj.Hwnd]
    startSize := CurrentSizes[ctrlObj.Hwnd]
    DllCall("SetCursor", "Ptr", DllCall("LoadCursor", "Ptr", 0, "Ptr", 32649, "Ptr"))
    
    if (startSize == targetSize)
        return

    startTime := A_TickCount
    
    ; Clear any previous running animations on this control
    if ctrlObj.HasProp("AnimTimer") {
        SetTimer(ctrlObj.AnimTimer, 0)
    }

    ; Define the step frame loop
    AnimLoop() {
        elapsed := A_TickCount - startTime
        if (elapsed >= AnimationDuration) {
            ; Animation finished, snap to exact target size
            SetTimer(ctrlObj.AnimTimer, 0)
            CurrentSizes[ctrlObj.Hwnd] := targetSize
            offset := (BaseSize - targetSize) // 2
            ctrlObj.Move(orig.X + offset, orig.Y + offset, targetSize, targetSize)
        } else {
            ; Progress ratio (0.0 to 1.0)
            progress := elapsed / AnimationDuration
            currentSize := Round(startSize + (targetSize - startSize) * progress)
            CurrentSizes[ctrlObj.Hwnd] := currentSize
            
            offset := (BaseSize - currentSize) // 2
            ctrlObj.Move(orig.X + offset, orig.Y + offset, currentSize, currentSize)
        }
        DllCall("RedrawWindow", "Ptr", TrayControllerGUI.Hwnd, "Ptr", 0, "Ptr", 0, "UInt", 0x0105)
    }

    ctrlObj.AnimTimer := AnimLoop
    SetTimer(ctrlObj.AnimTimer, FrameRate)
}

OnImageClick(ctrlObj, actionFunc) {
    global ActiveHoverCtrl
    AnimateControl(ctrlObj, ShrinkSize)
    actionFunc()
    
    ; Hold the shrunk frame briefly, then bounce back up smoothly
    SetTimer(() => (
        ActiveHoverCtrl == ctrlObj.Hwnd ? AnimateControl(ctrlObj, HoverSize) : AnimateControl(ctrlObj, BaseSize)
    ), -100)
}

OnToggleClick(clickedCtrl, targetCtrl, actionFunc) {
    AnimateControl(clickedCtrl, ShrinkSize)
    actionFunc()
    SetTimer(() => ToggleSwap(clickedCtrl, targetCtrl), -100)
}

ToggleSwap(clickedCtrl, targetCtrl) {
    orig := OrigCoords[clickedCtrl.Hwnd]
    clickedCtrl.Visible := false
    
    ; Reset the sizes variables in our map
    CurrentSizes[clickedCtrl.Hwnd] := BaseSize
    CurrentSizes[targetCtrl.Hwnd] := BaseSize
    
    clickedCtrl.Move(orig.X, orig.Y, BaseSize, BaseSize) 
    targetCtrl.Move(orig.X, orig.Y, BaseSize, BaseSize)
    targetCtrl.Visible := true
    
    DllCall("RedrawWindow", "Ptr", TrayControllerGUI.Hwnd, "Ptr", 0, "Ptr", 0, "UInt", 0x0105)
    
    global ActiveHoverCtrl := targetCtrl.Hwnd
    AnimateControl(targetCtrl, HoverSize)
}

ScaleUp(ctrlObj) => AnimateControl(ctrlObj, HoverSize)
ScaleDown(ctrlObj) => AnimateControl(ctrlObj, BaseSize)

; --- HOVER MONITORING ---
OnMessage(0x0200, WM_MOUSEMOVE)
OnMessage(0x404, OnTrayMessage)
OnMessage(0x020A, OnGuiMouseWheel) 
OnMessage(0x0006, WM_ACTIVATE)

WM_MOUSEMOVE(wParam, lParam, msg, hwnd) {
    global ActiveHoverCtrl
    
    isValidControl := false
    targetCtrlObj := 0
    for ctrl in ClickableCtrls {
        if (ctrl.Hwnd == hwnd) {
            isValidControl := true
            targetCtrlObj := ctrl
            break
        }
    }
    
    if (isValidControl && targetCtrlObj.Visible) {
        if (ActiveHoverCtrl != hwnd) {
            ResetHoveredCtrl() 
            ActiveHoverCtrl := hwnd
            ScaleUp(targetCtrlObj)
            SetTimer(TrackMouseDeparture, 50) 
        }
    }
}

TrackMouseDeparture() {
    if (ActiveHoverCtrl == 0) {
        SetTimer(TrackMouseDeparture, 0)
        return
    }
    
    MouseGetPos ,,, &currentHwnd, 2
    if (currentHwnd != ActiveHoverCtrl) {
        ResetHoveredCtrl()
        SetTimer(TrackMouseDeparture, 0)
    }
}

ResetHoveredCtrl() {
    global ActiveHoverCtrl
    if (ActiveHoverCtrl != 0) {
        for ctrl in ClickableCtrls {
            if (ctrl.Hwnd == ActiveHoverCtrl) {
                ScaleDown(ctrl)
                break
            }
        }
        ActiveHoverCtrl := 0
    }
}

; --- YOUR CUSTOM BUTTON FUNCTIONS ---
PlayFunction()       => Spotify_UWP.TogglePlay()
PauseFunction()      => Spotify_UWP.TogglePlay()
AddFunction()        => Spotify_UWP.AddToList()
FullscreenFunction() => Spotify_UWP.ToggleFullscreen()
NextSong()           => Spotify_UWP.NextSong()
NextFunction()       => Spotify_UWP.NextSong()
PreviousFunction()   => Spotify_UWP.PreviousSong()
MuteFunction()       => Spotify_UWP.ToggleMute()
UnmuteFunction()     => Spotify_UWP.ToggleMute()

WM_ACTIVATE(wParam, lParam, msg, hwnd) {
    if (wParam == 0 && hwnd == TrayControllerGUI.Hwnd) {
        ResetHoveredCtrl()
        TrayControllerGUI.Hide() 
    }
}

OnGuiMouseWheel(wParam, lParam, msg, hwnd) {
    if (hwnd == TrayControllerGUIHwnd || DllCall("GetParent", "Ptr", hwnd) == TrayControllerGUIHwnd) {
        delta := (wParam >> 16) & 0xFFFF
        if (delta > 0x7FFF) {
            delta -= 0x10000
        }
        if (delta > 0) {
            Spotify_UWP.Volume += (100 / 15)
        } else {
            Spotify_UWP.Volume -= (100 / 15)
        }
        return 0
    }
}

OnTrayMessage(wParam, lParam, msg, hwnd) {
    if (lParam == 0x200) { 
        SetTimer(CheckIfStillHovered, -300)
    }
}

CheckIfStillHovered() {
    CoordMode("Mouse", "Screen")
    MouseGetPos &startX, &startY
    Sleep(100) 
    MouseGetPos &currentX, &currentY
    if (Abs(currentX - startX) > 5 || Abs(currentY - startY) > 5) {
        return
    }
    A_IconTip := "" 
    global mouseX, mouseY

    style := WinExist("ahk_id " TrayControllerGUI.Hwnd) ? WinGetStyle("ahk_id " TrayControllerGUI.Hwnd) : 0

    if (!IsSet(mouseX) || !(style & 0x10000000)) {
        mouseX := currentX
        mouseY := currentY
    }
    TrayControllerGUI.Show("X" . (mouseX - 57) . " Y" . (mouseY - 130) "NoActivate")
    DllCall("SetWindowPos", "Ptr", TrayControllerGUI.Hwnd, "Ptr", -1, "Int", 0, "Int", 0, "Int", 0, "Int", 0, "UInt", 0x0043)
    global LeaveCount := 0 
    SetTimer(HideGuiWhenMouseLeaves, 400)
}

HideGuiWhenMouseLeaves() {
    global LeaveCount
    global mouseX, mouseY

    CoordMode("Mouse", "Screen")
    MouseGetPos(&mx, &my)
    TrayControllerGUI.GetPos(&gx, &gy, &gw, &gh)
    mouseInsideGui := (mx >= gx && mx <= gx + gw && my >= gy && my <= gy + gh)
    padding := 20 
    mouseOverIconEstimate := (mx >= mouseX - padding && mx <= mouseX + padding && my >= mouseY - padding && my <= mouseY + padding)
    if (!mouseInsideGui && !mouseOverIconEstimate) {
        LeaveCount++ 
        
        if (LeaveCount >= 2) { 
            ResetHoveredCtrl()
            TrayControllerGUI.Hide()
            SetTimer(HideGuiWhenMouseLeaves, 0) 
            A_IconTip := App.Name 
        }
    } else {
        LeaveCount := 0 
    }
}