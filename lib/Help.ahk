/************************************************************************
 * @description Help GUI
 * @author Melo (melo@meloprofessional.com)
 * @date 2026/06/22
 * @version 1.5.2
 ***********************************************************************/

#Requires AutoHotkey v2.0

ShowHelpGUI() {
    static MyGui := ""
    static ShowTime := 0
    
    if IsObject(MyGui) {
        CleanDestroy()
        return
    }

    MyGuiTitle := "Help"
    MyGuiOptions := "-Caption +AlwaysOnTop +ToolWindow +E0x08000000" ; WS_EX_NOACTIVATE initially to prevent focus fights
    MyGui := Gui(MyGuiOptions, MyGuiTitle)
    MyGui.BackColor := "141313"
    
    WinSetTransparent(243, MyGui)

    ; Setting structural grid coordinates
    GuiWidth     := 760  
    MyGui.MarginX := 85
    MyGui.MarginY := 35
    ContentWidth := GuiWidth - (MyGui.MarginX * 2)

    Col1_X := MyGui.MarginX
    Col2_X := MyGui.MarginX + 130
    Col3_X := MyGui.MarginX + 370
    Col4_X := MyGui.MarginX + 500

    ; 1. Header Section
    try {
        MyGui.Add("Picture", "w48 h-1 xm ym", App.Icon)
    } catch {
        MyGui.SetFont("s16 w700 cWhite", Settings.GuiFontName)
        MyGui.Add("Text", "w32 h32 xm ym", "[i]")
    }
    
    MyGui.SetFont("s16 w700 cWhite", Settings.GuiFontName)
    MyGui.Add("Text", "x+25 y" (MyGui.MarginY + 8), "Hotkeys")

    ; Divider Line
    MyGui.Add("Text", "xm y+32 w" ContentWidth " h1 Background333333")

    ; --- 2. Four-Column Layout ---
    
    ; Row 1
    MyGui.SetFont("s12 w400 cWhite", Settings.GuiFontName)
    MyGui.Add("Text", "x" Col1_X " y+60", "Now Playing")
    MyGui.SetFont("c888888")
    MyGui.Add("Text", "x" Col2_X " yp", "Win + F6")
    MyGui.SetFont("cWhite")
    MyGui.Add("Text", "x" Col3_X " yp", "Mute")
    MyGui.SetFont("c888888")
    MyGui.Add("Text", "x" Col4_X " yp", "Win + F10")

    ; Row 2
    MyGui.SetFont("cWhite")
    MyGui.Add("Text", "x" Col1_X " y+60", "Previous")
    MyGui.SetFont("c888888")
    MyGui.Add("Text", "x" Col2_X " yp", "Win + F7")
    MyGui.SetFont("cWhite")
    MyGui.Add("Text", "x" Col3_X " yp", "Vol -")
    MyGui.SetFont("c888888")
    MyGui.Add("Text", "x" Col4_X " yp", "Win + F11")

    ; Row 3
    MyGui.SetFont("cWhite")
    MyGui.Add("Text", "x" Col1_X " y+60", "Next")
    MyGui.SetFont("c888888")
    MyGui.Add("Text", "x" Col2_X " yp", "Win + F8")
    MyGui.SetFont("cWhite")
    MyGui.Add("Text", "x" Col3_X " yp", "Vol +")
    MyGui.SetFont("c888888")
    MyGui.Add("Text", "x" Col4_X " yp", "Win + F12")

    ; Row 4
    MyGui.SetFont("cWhite")
    MyGui.Add("Text", "x" Col1_X " y+60", "Play/Pause")
    MyGui.SetFont("c888888")
    MyGui.Add("Text", "x" Col2_X " yp", "Win + F9")
    MyGui.SetFont("cWhite")
    MyGui.Add("Text", "x" Col3_X " yp", "Full screen")
    MyGui.SetFont("c888888")
    MyGui.Add("Text", "x" Col4_X " yp", "Win + F")

    MyGui.SetFont("s11 Italic")
    MyGui.SetFont("c888888")
    MyGui.Add("Text", "xm y+60", "*click the tray icon to play/pause")

    ; Bottom spacing cushion
    MyGui.Add("Text", "xm y+40 h0 w0")

    ; --- Auto-Dismiss Event Triggers ---
    MyGui.OnEvent("Close", CleanDestroy)
    MyGui.OnEvent("Escape", CleanDestroy)
    
    ; Display and force direct keyboard focus onto the GUI window
    MyGui.Show("w" GuiWidth)
    WinActivate("ahk_id " MyGui.Hwnd)
    ShowTime := A_TickCount

    ; Apply Rounded Corners
    MyGui.GetPos(,, &RealWidth, &RealHeight)
    hRgn := DllCall("CreateRoundRectRgn", "Int", 0, "Int", 0, "Int", RealWidth, "Int", RealHeight, "Int", 15, "Int", 15)
    DllCall("SetWindowRgn", "Ptr", MyGui.Hwnd, "Ptr", hRgn, "UInt", true)

    if GetKeyState("LWin") || GetKeyState("RWin") {
        KeyWait("h")
        KeyWait("LWin")
        KeyWait("RWin")
    }

    ; Click Outside / Alt+Tab / Losing Focus (WM_ACTIVATE)
    OnMessage(0x0006, OnActivateChange)
    ; Keypress Dismissal (WM_KEYDOWN)
    OnMessage(0x0100, CleanDestroy)
    ; Click Inside GUI Background (WM_LBUTTONDOWN)
    OnMessage(0x0201, OnLeftClick)

    OnActivateChange(wParam, lParam, msg, hwnd) {
        ; Check if deactivated and confirm a brief grace window has passed
        if (hwnd == MyGui.Hwnd && wParam == 0 && (A_TickCount - ShowTime > 250)) {
            CleanDestroy()
        }
    }

    OnLeftClick(wParam, lParam, msg, hwnd) {
        if (hwnd == MyGui.Hwnd) {
            CleanDestroy()
        }
    }

    CleanDestroy(*) {
        OnMessage(0x0006, OnActivateChange, 0)
        OnMessage(0x0100, CleanDestroy, 0)
        OnMessage(0x0201, OnLeftClick, 0)
        
        if IsObject(MyGui) {
            MyGui.Destroy()
            MyGui := ""
        }
    }
}