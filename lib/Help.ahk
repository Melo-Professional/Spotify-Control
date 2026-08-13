/************************************************************************
 * @description Help GUI
 * @author Melo (melo@meloprofessional.com)
 * @date 2026/08/12
 * @version 1.6.0
 ***********************************************************************/

#Requires AutoHotkey v2.0

ShowMainGUI() {
    static MyGui := ""
    static ShowTime := 0
 
    if IsObject(MyGui) {
        CleanDestroy()
        return
    }

    MyGuiTitle := "Help"
    ;MyGuiOptions := "-Caption +AlwaysOnTop +ToolWindow +E0x08000000" ; WS_EX_NOACTIVATE initially to prevent focus fights
    MyGuiOptions := "-Caption +AlwaysOnTop +ToolWindow"
    MyGui := Gui(MyGuiOptions, MyGuiTitle)
    MyGui.SetFont("s" Settings.GuiFontSizeMedium, Settings.GuiFontName)
    offset := 10

	UseAcrylicGUI := false
	if IsFunctionDefined("FrostedTheme") {
		UseAcrylicGUI := true
		offset := 60
	}

	DllCall("dwmapi\DwmSetWindowAttribute", "Ptr", MyGui.Hwnd, "UInt", 33, "Int*", 2, "UInt", 4)

    TextNormalColor := "CCCCCC"
    TextHoverColor  := "FFFFFF"
    BGroundNormalColor  := "1b1b1b"
    BGroundHoverColor  := "313131"


    GuiWidth     := 760
    GuiWidth     := 920
    MyGui.MarginX := 85
    MyGui.MarginY := 25
    ContentWidth := GuiWidth - (MyGui.MarginX * 2)


	Col1_W := 130
	Col2_W := 180
    Col1_X := MyGui.MarginX
    Col2_X := MyGui.MarginX + Col1_W
    Col3_X := GuiWidth - MyGui.MarginX - Col1_W - Col2_W
    Col4_X := Col3_X + Col1_W
	Rows_Gap := 35

	; 1. Header Section
	try {
		;MyGui.Add("Picture", "w48 h-1 xm ym", App.Icon)
		MyGui.Add("Picture", "w32 h-1 xm ym+8", App.Icon)
	} catch {
		MyGui.SetFont("s16 w100", Settings.GuiFontName)
		MyGui.Add("Text", "w32 h32 xm ym", "[i]")
	}

    MyGui.SetFont("s16 w800", Settings.GuiFontName)
    MyGui.Add("Text", "x+25 y" (MyGui.MarginY + 8), "Edit Hotkeys")

    ; Divider Line
    MyGui.Add("Text", "xm y+32 w" ContentWidth " h1 Background333333")

    ; --- 2. Four-Column Layout ---
     ; Row 0
    MyGui.SetFont("s12 w100", Settings.GuiFontName)
    MyGui.Add("Text", "x" Col1_X " y+" Rows_Gap " vSmooth_01 h32 0x0200", "Save to Library ")
    MyGui.SetFont("s8 w700")
	btnAddToList := MyGui.Add("Text", "vStrong_01 x" Col2_X " yp h32 w" Col2_W " Center 0x0200 +Border")
	HotkeyManager.BindControl(btnAddToList, General.HK_AddToList, HK_AddToList)

    MyGui.SetFont("s12 w100")
    MyGui.Add("Text", "x" Col3_X " yp vSmooth_02 h32 0x0200", "Mute")
    MyGui.SetFont("s8 w700")
	btnToggleMute := MyGui.Add("Text", "vStrong_02 x" Col4_X " yp h32 w" Col2_W " Center 0x0200 +Border")
	HotkeyManager.BindControl(btnToggleMute, General.HK_ToggleMute, HK_ToggleMute)

    ; Row 1
    MyGui.SetFont("s12 w100", Settings.GuiFontName)
    MyGui.Add("Text", "x" Col1_X " y+" Rows_Gap " vSmooth_03 h32 0x0200", "Now Playing")
    MyGui.SetFont("s8 w700")
	btnOSD_CP := MyGui.Add("Text", "vStrong_03 x" Col2_X " yp h32 w" Col2_W " Center 0x0200 +Border")
	HotkeyManager.BindControl(btnOSD_CP, General.HK_OSD_CP, HK_OSD_CP)

    MyGui.SetFont("s12 w100")
    MyGui.Add("Text", "x" Col3_X " yp vSmooth_04 h32 0x0200", "Vol -")
    MyGui.SetFont("s8 w700")
	btnHK_VolumeDown := MyGui.Add("Text", "vStrong_04 x" Col4_X " yp h32 w" Col2_W " Center 0x0200 +Border")
	HotkeyManager.BindControl(btnHK_VolumeDown, General.HK_VolumeDown, HK_VolumeDown)

    ; Row 2
    MyGui.SetFont("s12 w100")
    MyGui.Add("Text", "x" Col1_X " y+" Rows_Gap " vSmooth_05 h32 0x0200", "Previous")
    MyGui.SetFont("s8 w700")
	btnHK_PreviousSong := MyGui.Add("Text", "vStrong_05 x" Col2_X " yp h32 w" Col2_W " Center 0x0200 +Border")
	HotkeyManager.BindControl(btnHK_PreviousSong, General.HK_PreviousSong, HK_PreviousSong)

    MyGui.SetFont("s12 w100")
    MyGui.Add("Text", "x" Col3_X " yp vSmooth_06 h32 0x0200", "Vol +")
    MyGui.SetFont("s8 w700")
	btnHK_VolumeUp := MyGui.Add("Text", "vStrong_06 x" Col4_X " yp h32 w" Col2_W " Center 0x0200 +Border")
	HotkeyManager.BindControl(btnHK_VolumeUp, General.HK_VolumeUp, HK_VolumeUp)

    ; Row 3
    MyGui.SetFont("s12 w100")
    MyGui.Add("Text", "x" Col1_X " y+" Rows_Gap " vSmooth_07 h32 0x0200", "Next")
    MyGui.SetFont("s8 w700")
	btnHK_NextSong := MyGui.Add("Text", "vStrong_07 x" Col2_X " yp h32 w" Col2_W " Center 0x0200 +Border")
	HotkeyManager.BindControl(btnHK_NextSong, General.HK_NextSong, HK_NextSong)

    MyGui.SetFont("s12 w100")
    MyGui.Add("Text", "x" Col3_X " yp vSmooth_08 h32 0x0200", "Full screen")
    MyGui.SetFont("s8 w700")
	btnHK_ToggleFullscreen := MyGui.Add("Text", "vStrong_08 x" Col4_X " yp h32 w" Col2_W " Center 0x0200 +Border")
	HotkeyManager.BindControl(btnHK_ToggleFullscreen, General.HK_ToggleFullscreen, HK_ToggleFullscreen)

    ; Row 4
    MyGui.SetFont("s12 w100")
    MyGui.Add("Text", "x" Col1_X " y+" Rows_Gap " vSmooth_09 h32 0x0200", "Play/Pause")
    MyGui.SetFont("s8 w700")
	btnHK_TogglePlay := MyGui.Add("Text", "vStrong_09 x" Col2_X " yp h32 w" Col2_W " Center 0x0200 +Border")
	HotkeyManager.BindControl(btnHK_TogglePlay, General.HK_TogglePlay, HK_TogglePlay)

    MyGui.SetFont("s12 w100")
    MyGui.Add("Text", "x" Col3_X " yp vSmooth_10 h32 0x0200", "Show Help")
    MyGui.SetFont("s8 w700")
	btnHK_ShowHelpGUI := MyGui.Add("Text", "vStrong_10 x" Col4_X " yp h32 w" Col2_W " Center 0x0200 +Border")
	HotkeyManager.BindControl(btnHK_ShowHelpGUI, General.HK_ShowHelpGUI, ShowGUI)

    MyGui.SetFont("w100 s9 Italic")
    MyGui.Add("Text", "xm y+" Rows_Gap " vSmooth_11", "*click the tray icon to play/pause`n*double click the tray icon to fullscreen")

    ; Bottom spacing cushion
;    MyGui.Add("Text", "xm y+40 h0 w0")

    if UseAcrylicGUI {
btnAddToList.Opt("+Background" BGroundNormalColor)
btnToggleMute.Opt("+Background" BGroundNormalColor)
btnOSD_CP.Opt("+Background" BGroundNormalColor)
btnHK_VolumeDown.Opt("+Background" BGroundNormalColor)
btnHK_PreviousSong.Opt("+Background" BGroundNormalColor)
btnHK_VolumeUp.Opt("+Background" BGroundNormalColor)
btnHK_NextSong.Opt("+Background" BGroundNormalColor)
btnHK_ToggleFullscreen.Opt("+Background" BGroundNormalColor)
btnHK_TogglePlay.Opt("+Background" BGroundNormalColor)
btnHK_ShowHelpGUI.Opt("+Background" BGroundNormalColor)
	}

    if UseAcrylicGUI {
        if IsFunctionDefined("ApplyThemeToGui")
            %"ApplyThemeToGui"%(MyGui, "Dark")
        if IsFunctionDefined("FrostedTheme")
            %"FrostedTheme"%.Apply(MyGui)
    } else {
        if IsFunctionDefined("ApplyThemeToGui") {
    	    %"ApplyThemeToGui"%(MyGui)
        	%"WatchedGUIs"%.Push(MyGui)
	    }
    }

    ; Display and force direct keyboard focus onto the GUI window
    MyGui.Show("w" GuiWidth)
    WinActivate("ahk_id " MyGui.Hwnd)
    ShowTime := A_TickCount
				/* 
					; Apply Rounded Corners
					MyGui.GetPos(,, &RealWidth, &RealHeight)
					hRgn := DllCall("CreateRoundRectRgn", "Int", 0, "Int", 0, "Int", RealWidth, "Int", RealHeight, "Int", 15, "Int", 15)
					DllCall("SetWindowRgn", "Ptr", MyGui.Hwnd, "Ptr", hRgn, "UInt", true)

 */
;    if GetKeyState("LWin") || GetKeyState("RWin") {
;        KeyWait("h")
;        KeyWait("LWin")
;        KeyWait("RWin")
;    }

/* 
    ; Keypress Dismissal (WM_KEYDOWN)
    OnMessage(0x0100, CleanDestroy)
    ; Click Inside GUI Background (WM_LBUTTONDOWN)
    OnMessage(0x0201, OnLeftClick)

*/

    ; Click Outside / Alt+Tab / Losing Focus (WM_ACTIVATE)
    OnMessage(0x0006, OnActivateChange)
    OnActivateChange(wParam, lParam, msg, hwnd) {
        ; Check if deactivated and confirm a brief grace window has passed
        if (hwnd == MyGui.Hwnd && wParam == 0 && (A_TickCount - ShowTime > 250)) {
            CleanDestroy()
        }
    }



/* 
    OnLeftClick(wParam, lParam, msg, hwnd) {
        if (hwnd == MyGui.Hwnd) {
            CleanDestroy()
        }
    }
 */

    ; --- Auto-Dismiss Event Triggers ---
    MyGui.OnEvent("Close", CleanDestroy)
    MyGui.OnEvent("Escape", CleanDestroy)

    CleanDestroy(*) {
            try MyGui.Destroy()
            try MyGui := ""

try        OnMessage(0x0006, OnActivateChange, 0)
;        OnMessage(0x0100, CleanDestroy, 0)
;        OnMessage(0x0201, OnLeftClick, 0)
    }
}
