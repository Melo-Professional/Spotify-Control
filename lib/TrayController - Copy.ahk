#Requires AutoHotkey v2.0
#SingleInstance Force

global LeaveCount := 0 

;global TrayControllerGUI := Gui("+AlwaysOnTop -Caption -SysMenu +ToolWindow")
global TrayControllerGUI := Gui("+AlwaysOnTop -Caption -SysMenu +ToolWindow +Owner")

;TrayControllerGUI.MarginY := 35
TrayControllerGUI.MarginX := 20
TrayControllerGUI.MarginY := 20
fontSize := IsSet(Settings) && HasProp(Settings, "GuiFontSizeMedium") ? Settings.GuiFontSizeMedium : 10
fontName := IsSet(Settings) && HasProp(Settings, "GuiFontName") ? Settings.GuiFontName : "Segoe UI"
TrayControllerGUI.SetFont("s" fontSize, fontName)

global TrayControllerGUIHwnd := TrayControllerGUI.Hwnd

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

pAdd.OnEvent("Click",  (ctrl, *) => OnImageClick(ctrl, AddFunction))
pFull.OnEvent("Click", (ctrl, *) => OnImageClick(ctrl, FullscreenFunction))
pPrev.OnEvent("Click", (ctrl, *) => OnImageClick(ctrl, PreviousFunction))
pNext.OnEvent("Click", (ctrl, *) => OnImageClick(ctrl, NextFunction))

; Toggle clicks handle both execution and visual swapping
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
    ;TrayControllerGUI.Destroy()
    TrayControllerGUI.Hide()
}

IsFunctionDefined(Name) {
    try return HasMethod(%Name%)
    return false
}

OnImageClick(ctrlObj, actionFunc) {
    ctrlObj.GetPos(&cX, &cY, &cW, &cH)
    ctrlObj.Move(cX + 2, cY + 2, 26)
    actionFunc()
    SetTimer(() => ctrlObj.Move(cX, cY, 30), -150)
}

OnToggleClick(clickedCtrl, targetCtrl, actionFunc) {
    clickedCtrl.GetPos(&cX, &cY, &cW, &cH)
    clickedCtrl.Move(cX + 2, cY + 2, 26)
    actionFunc()
    SetTimer(() => ToggleSwap(clickedCtrl, targetCtrl, cX, cY), -150)
}

ToggleSwap(clickedCtrl, targetCtrl, originalX, originalY) {
    clickedCtrl.Visible := false
    clickedCtrl.Move(originalX, originalY, 30) 
    targetCtrl.Move(originalX, originalY, 30)
    targetCtrl.Visible := true
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

OnMessage(0x404, OnTrayMessage)
OnMessage(0x020A, OnGuiMouseWheel) ; 0x020A corresponds to WM_MOUSEWHEEL
; 0x0006 is WM_ACTIVATE. It triggers when the GUI gains or loses focus.
OnMessage(0x0006, WM_ACTIVATE)

WM_ACTIVATE(wParam, lParam, msg, hwnd) {
    ; wParam == 0 means the window is losing focus (Deactivated)
    if (wParam == 0 && hwnd == TrayControllerGUI.Hwnd) {
        TrayControllerGUI.Hide() ; Or TrayControllerGUI.Destroy()
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
    Sleep(100) ; Wait to see if they are actually lingering
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
    ;TrayControllerGUI.Show("X" . (mouseX - 57) . " Y" . (mouseY - 150))
    ;TrayControllerGUI.Show("X" . (mouseX - 57) . " Y" . (mouseY - 150) "NoActivate")
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
            TrayControllerGUI.Hide()
            SetTimer(HideGuiWhenMouseLeaves, 0) 
            A_IconTip := App.Name 
        }
    } else {
        LeaveCount := 0 
    }
}