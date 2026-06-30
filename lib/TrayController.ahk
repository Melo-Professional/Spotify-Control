#Requires AutoHotkey v2.0
#SingleInstance Force

global MyTrayController := TrayControllerClass()
A_IconTip := ""

Class TrayControllerClass {
    ; --- Internal Properties ---
    guiObj := 0
    hwnd := 0
    leaveCount := 0
    mouseX := 0
    mouseY := 0
    activeHoverCtrl := 0
    isGuiVisible := false
    isTimerActive := false
    
    ; Animation & Layout
    baseSize := 30
    hoverSize := 36 
    shrinkSize := 28
    animationDuration := 80  
    frameRate := 10          
    
    ; State Tracking Objects
    hoverTimerObj := 0
    startX := 0
    startY := 0
    
    hCursorHand := 0
    origCoords := Map()
    currentSizes := Map()
    clickableCtrls := []

    __New() {
        ; 1. Load Windows Resources
        this.hCursorHand := DllCall("LoadCursor", "Ptr", 0, "Ptr", 32649, "Ptr")

        ; Create standard bound object for v2.0 safe debouncing
        this.hoverTimerObj := this.CheckIfStillHovered.Bind(this)

        ; 2. Build the GUI container
        this.guiObj := Gui("+AlwaysOnTop -Caption -SysMenu +ToolWindow +Owner")
        this.guiObj.MarginX := 20
        this.guiObj.MarginY := 20
        
        fontSize := IsSet(Settings) && HasProp(Settings, "GuiFontSizeMedium") ? Settings.GuiFontSizeMedium : 10
        fontName := IsSet(Settings) && HasProp(Settings, "GuiFontName") ? Settings.GuiFontName : "Segoe UI"
        this.guiObj.SetFont("s" fontSize, fontName)
        this.hwnd := this.guiObj.Hwnd

        ; 3. Add UI Elements (Assuming variables imageAdd, etc. exist in scope or are passed)
        pAdd       := this.guiObj.AddPicture("w30 h-1 xm ym", imageAdd ?? "")
        pMute      := this.guiObj.AddPicture("w30 h-1 x+10 ym", imageUnmute ?? "")
        pUnmute    := this.guiObj.AddPicture("w30 h-1 xp yp Hidden", imageUnmute ?? "")
        pFull      := this.guiObj.AddPicture("w30 h-1 x+10 ym", imageFullscreen ?? "")

        pPrev      := this.guiObj.AddPicture("w30 h-1 xm y+10", imagePrevious ?? "")
        pPlay      := this.guiObj.AddPicture("w30 h-1 x+10 yp", imagePlay ?? "")
        pPause     := this.guiObj.AddPicture("w30 h-1 xp yp Hidden", imagePlay ?? "")
        pNext      := this.guiObj.AddPicture("w30 h-1 x+10 yp", imageNext ?? "")

        this.clickableCtrls := [pAdd, pMute, pUnmute, pFull, pPrev, pPlay, pPause, pNext]

        ; Map default geometries
        for ctrl in this.clickableCtrls {
            ctrl.GetPos(&cX, &cY)
            this.origCoords[ctrl.Hwnd] := {X: cX, Y: cY}
            this.currentSizes[ctrl.Hwnd] := this.baseSize
        }

        ; 4. Bind Interactions
        pAdd.OnEvent("Click",  (ctrl, *) => this.OnImageClick(ctrl, () => Spotify_UWP.AddToList()))
        pFull.OnEvent("Click", (ctrl, *) => this.OnImageClick(ctrl, () => Spotify_UWP.ToggleFullscreen()))
        pPrev.OnEvent("Click", (ctrl, *) => this.OnImageClick(ctrl, () => Spotify_UWP.PreviousSong()))
        pNext.OnEvent("Click", (ctrl, *) => this.OnImageClick(ctrl, () => Spotify_UWP.NextSong()))

        pPlay.OnEvent("Click",  (ctrl, *) => this.OnToggleClick(pPlay, pPause, () => Spotify_UWP.TogglePlay()))
        pPause.OnEvent("Click", (ctrl, *) => this.OnToggleClick(pPause, pPlay, () => Spotify_UWP.TogglePlay()))
        pMute.OnEvent("Click",  (ctrl, *) => this.OnToggleClick(pMute, pUnmute, () => Spotify_UWP.ToggleMute()))
        pUnmute.OnEvent("Click",(ctrl, *) => this.OnToggleClick(pUnmute, pMute, () => Spotify_UWP.ToggleMute()))

        this.guiObj.OnEvent("Close", (gui) => this.CleanDestroyTC())
        this.guiObj.OnEvent("Escape", (gui) => this.CleanDestroyTC())

        if HasMethod(IsSet(ApplyThemeToGui) ? ApplyThemeToGui : 0) {
            ApplyThemeToGui(this.guiObj)
            if IsSet(WatchedGUIs) && HasMethod(WatchedGUIs.Push)
                WatchedGUIs.Push(this.guiObj)
        }

        ; 5. Route Windows Hook Messages to Class Instances
        OnMessage(0x0200, (w, l, m, h) => this.WM_MOUSEMOVE(w, l, m, h))
        OnMessage(0x0020, (w, l, m, h) => this.WM_SETCURSOR(w, l, m, h))
        OnMessage(0x404,  (w, l, m, h) => this.OnTrayMessage(w, l, m, h))
        OnMessage(0x020A, (w, l, m, h) => this.OnGuiMouseWheel(w, l, m, h))
        OnMessage(0x0006, (w, l, m, h) => this.WM_ACTIVATE(w, l, m, h))
    }

    CleanDestroyTC() {
        if HasMethod(IsSet(RemoveGuiFromArray) ? RemoveGuiFromArray : 0)
            RemoveGuiFromArray(this.guiObj)
        this.ResetHoveredCtrl()
        this.guiObj.Hide()
    }

    ; --- ANIMATION HANDLING ---
    AnimateControl(ctrlObj, targetSize) {
        if !this.origCoords.Has(ctrlObj.Hwnd)
            return
        
        orig := this.origCoords[ctrlObj.Hwnd]
        startSize := this.currentSizes[ctrlObj.Hwnd]
        if (startSize == targetSize)
            return

        startTime := A_TickCount
        if ctrlObj.HasProp("AnimTimer")
            SetTimer(ctrlObj.AnimTimer, 0)

        AnimLoop() {
            elapsed := A_TickCount - startTime
            if (elapsed >= this.animationDuration) {
                SetTimer(ctrlObj.AnimTimer, 0)
                this.currentSizes[ctrlObj.Hwnd] := targetSize
                offset := (this.baseSize - targetSize) // 2
                ctrlObj.Move(orig.X + offset, orig.Y + offset, targetSize, targetSize)
            } else {
                progress := elapsed / this.animationDuration
                currentSize := Round(startSize + (targetSize - startSize) * progress)
                this.currentSizes[ctrlObj.Hwnd] := currentSize
                offset := (this.baseSize - currentSize) // 2
                ctrlObj.Move(orig.X + offset, orig.Y + offset, currentSize, currentSize)
            }
            DllCall("RedrawWindow", "Ptr", this.hwnd, "Ptr", 0, "Ptr", 0, "UInt", 0x0105)
        }

        ctrlObj.AnimTimer := AnimLoop
        SetTimer(ctrlObj.AnimTimer, this.frameRate)
    }

    OnImageClick(ctrlObj, actionFunc) {
        this.AnimateControl(ctrlObj, this.shrinkSize)
        actionFunc()
        SetTimer(() => (
            this.activeHoverCtrl == ctrlObj.Hwnd ? this.AnimateControl(ctrlObj, this.hoverSize) : this.AnimateControl(ctrlObj, this.baseSize)
        ), -100)
    }

    OnToggleClick(clickedCtrl, targetCtrl, actionFunc) {
        this.AnimateControl(clickedCtrl, this.shrinkSize)
        actionFunc()
        SetTimer(() => this.ToggleSwap(clickedCtrl, targetCtrl), -100)
    }

    ToggleSwap(clickedCtrl, targetCtrl) {
        orig := this.origCoords[clickedCtrl.Hwnd]
        clickedCtrl.Visible := false
        
        this.currentSizes[clickedCtrl.Hwnd] := this.baseSize
        this.currentSizes[targetCtrl.Hwnd] := this.baseSize
        
        clickedCtrl.Move(orig.X, orig.Y, this.baseSize, this.baseSize) 
        targetCtrl.Move(orig.X, orig.Y, this.baseSize, this.baseSize)
        targetCtrl.Visible := true
        
        DllCall("RedrawWindow", "Ptr", this.hwnd, "Ptr", 0, "Ptr", 0, "UInt", 0x0105)
        
        this.activeHoverCtrl := targetCtrl.Hwnd
        this.AnimateControl(targetCtrl, this.hoverSize)
    }

    ; --- INTENT SYSTEM MONITOR HOOKS ---
    WM_SETCURSOR(wParam, lParam, msg, hwnd) {
        for ctrl in this.clickableCtrls {
            if (ctrl.Hwnd == wParam && ctrl.Visible) {
                DllCall("SetCursor", "Ptr", this.hCursorHand)
                return 1
            }
        }
    }

    WM_MOUSEMOVE(wParam, lParam, msg, hwnd) {
        isValidControl := false
        targetCtrlObj := 0
        for ctrl in this.clickableCtrls {
            if (ctrl.Hwnd == hwnd) {
                isValidControl := true
                targetCtrlObj := ctrl
                break
            }
        }
        
        if (isValidControl && targetCtrlObj.Visible) {
            if (this.activeHoverCtrl != hwnd) {
                this.ResetHoveredCtrl() 
                this.activeHoverCtrl := hwnd
                this.AnimateControl(targetCtrlObj, this.hoverSize)
                SetTimer(() => this.TrackMouseDeparture(), 50) 
            }
        }
    }

    TrackMouseDeparture() {
        if (this.activeHoverCtrl == 0) {
            SetTimer(() => this.TrackMouseDeparture(), 0)
            return
        }
        
        MouseGetPos ,,, &currentHwnd, 2
        if (currentHwnd != this.activeHoverCtrl) {
            this.ResetHoveredCtrl()
            SetTimer(() => this.TrackMouseDeparture(), 0)
        }
    }

    ResetHoveredCtrl() {
        if (this.activeHoverCtrl != 0) {
            for ctrl in this.clickableCtrls {
                if (ctrl.Hwnd == this.activeHoverCtrl) {
                    this.AnimateControl(ctrl, this.baseSize)
                    break
                }
            }
            this.activeHoverCtrl := 0
        }
    }

    WM_ACTIVATE(wParam, lParam, msg, hwnd) {
        if (wParam == 0 && hwnd == this.hwnd) {
            this.ResetHoveredCtrl()
            this.guiObj.Hide()
            
            ; --- FIX: Clear state tracking ---
            this.isGuiVisible := false
            this.mouseX := 0
            this.mouseY := 0
        }
    }

    OnGuiMouseWheel(wParam, lParam, msg, hwnd) {
        if (hwnd == this.hwnd || DllCall("GetParent", "Ptr", hwnd) == this.hwnd) {
            delta := (wParam >> 16) & 0xFFFF
            if (delta > 0x7FFF) 
                delta -= 0x10000
            
            if (delta > 0) 
                Spotify_UWP.Volume += (100 / 15)
            else 
                Spotify_UWP.Volume -= (100 / 15)
            return 0
        }
    }

    OnTrayMessage(wParam, lParam, msg, hwnd) {
        if (lParam == 0x200) { ; WM_MOUSEMOVE
            if (this.isGuiVisible)
                return

            A_IconTip := ""

            CoordMode("Mouse", "Screen")
            MouseGetPos(&sX, &sY)
            this.startX := sX
            this.startY := sY

            SetTimer(this.hoverTimerObj, 0)

            hoverTime := 400 
            if !DllCall("SystemParametersInfo", "UInt", 0x0066, "UInt", 0, "Int*", &hoverTime, "UInt", 0)
                hoverTime := 400

            targetDelay := Max(100, hoverTime - 220)

            SetTimer(this.hoverTimerObj, -targetDelay)
        }
    }

    CheckIfStillHovered() {
        CoordMode("Mouse", "Screen")
        MouseGetPos(&currentX, &currentY, &targetHwnd)
        
        sX := this.startX
        sY := this.startY
        this.startX := 0
        this.startY := 0

        if (Abs(currentX - sX) > 5 || Abs(currentY - sY) > 5)
            return

        if (!targetHwnd)
            return

        this.mouseX := currentX
        this.mouseY := currentY
        
        this.guiObj.Show("X" . (this.mouseX - 72) . " Y" . (this.mouseY - 130) . " NoActivate")
        this.isGuiVisible := true 
        
        DllCall("SetWindowPos", "Ptr", this.hwnd, "Ptr", -1, "Int", 0, "Int", 0, "Int", 0, "Int", 0, "UInt", 0x0043)
        DllCall("dwmapi\DwmSetWindowAttribute", "Ptr", this.hwnd, "UInt", 33, "Int*", 2, "UInt", 4)
        
        this.leaveCount := 0 
        SetTimer(() => this.HideGuiWhenMouseLeaves(), 400)
    }

    HideGuiWhenMouseLeaves() {
        CoordMode("Mouse", "Screen")
        MouseGetPos(&mx, &my)
        this.guiObj.GetPos(&gx, &gy, &gw, &gh)
        
        mouseInsideGui := (mx >= gx && mx <= gx + gw && my >= gy && my <= gy + gh)
        padding := 20 
        mouseOverIconEstimate := (mx >= this.mouseX - padding && mx <= this.mouseX + padding && my >= this.mouseY - padding && my <= this.mouseY + padding)
        
        if (!mouseInsideGui && !mouseOverIconEstimate) {
            this.leaveCount++ 
            if (this.leaveCount >= 2) { 
                this.ResetHoveredCtrl()
                this.guiObj.Hide()
                
                ; --- FIX: Clear state tracking ---
                this.isGuiVisible := false
                this.isTimerActive := false
                this.mouseX := 0
                this.mouseY := 0
                
                SetTimer(() => this.HideGuiWhenMouseLeaves(), 0)
            }
        } else {
            this.leaveCount := 0 
        }
    }
}