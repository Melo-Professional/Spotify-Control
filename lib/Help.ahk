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
    MyGui.MarginY := 40
    ContentWidth := GuiWidth - (MyGui.MarginX * 2)


	Col1_W := 130
	Col2_W := 180
    Col1_X := MyGui.MarginX
    Col2_X := MyGui.MarginX + Col1_W
    Col3_X := GuiWidth - MyGui.MarginX - Col1_W - Col2_W
    Col4_X := Col3_X + Col1_W
	Rows_Gap := 26

	; 1. Header Section
	MyGui.Add("Picture", "w32 h-1 x" GuiWidth - MyGui.MarginX - 32 " ym+8", App.Icon)

    MyGui.SetFont("s16 w800", Settings.GuiFontName)
    MyGui.Add("Text", "xm5 y" (MyGui.MarginY + 8), "Edit Hotkeys")

    ; Divider Line
    MyGui.Add("Text", "xm y+24 w" ContentWidth " h1 Background333333")

    ; --- 2. Four-Column Layout ---
     ; Row 0
    MyGui.SetFont("s11 w100", Settings.GuiFontName)
    MyGui.Add("Text", "x" Col1_X " y+" Rows_Gap " vSmooth_01 h32 0x0200", "Save to Library ")
    MyGui.SetFont("s8 w700")
	btnAddToList := MyGui.Add("Text", "vStrong_01 x" Col2_X " yp h32 w" Col2_W " Center 0x0200 +Border")
	HotkeyManager.BindControl(btnAddToList, General.HK_AddToList, AddToList)

    MyGui.SetFont("s11 w100")
    MyGui.Add("Text", "x" Col3_X " yp vSmooth_02 h32 0x0200", "Mute")
    MyGui.SetFont("s8 w700")
	btnToggleMute := MyGui.Add("Text", "vStrong_02 x" Col4_X " yp h32 w" Col2_W " Center 0x0200 +Border")
	HotkeyManager.BindControl(btnToggleMute, General.HK_ToggleMute, ToggleMute)

    ; Row 1
    MyGui.SetFont("s11 w100", Settings.GuiFontName)
    MyGui.Add("Text", "x" Col1_X " y+" Rows_Gap " vSmooth_03 h32 0x0200", "Now Playing")
    MyGui.SetFont("s8 w700")
	btnOSD_CP := MyGui.Add("Text", "vStrong_03 x" Col2_X " yp h32 w" Col2_W " Center 0x0200 +Border")
	HotkeyManager.BindControl(btnOSD_CP, General.HK_OSD_CP, HK_OSD_CP)

    MyGui.SetFont("s11 w100")
    MyGui.Add("Text", "x" Col3_X " yp vSmooth_04 h32 0x0200", "Vol -")
    MyGui.SetFont("s8 w700")
	btnHK_VolumeDown := MyGui.Add("Text", "vStrong_04 x" Col4_X " yp h32 w" Col2_W " Center 0x0200 +Border")
	HotkeyManager.BindControl(btnHK_VolumeDown, General.HK_VolumeDown, VolumeDown)

    ; Row 2
    MyGui.SetFont("s11 w100")
    MyGui.Add("Text", "x" Col1_X " y+" Rows_Gap " vSmooth_05 h32 0x0200", "Previous")
    MyGui.SetFont("s8 w700")
	btnHK_PreviousSong := MyGui.Add("Text", "vStrong_05 x" Col2_X " yp h32 w" Col2_W " Center 0x0200 +Border")
	HotkeyManager.BindControl(btnHK_PreviousSong, General.HK_PreviousSong, PreviousSong)

    MyGui.SetFont("s11 w100")
    MyGui.Add("Text", "x" Col3_X " yp vSmooth_06 h32 0x0200", "Vol +")
    MyGui.SetFont("s8 w700")
	btnHK_VolumeUp := MyGui.Add("Text", "vStrong_06 x" Col4_X " yp h32 w" Col2_W " Center 0x0200 +Border")
	HotkeyManager.BindControl(btnHK_VolumeUp, General.HK_VolumeUp, VolumeUp)

    ; Row 3
    MyGui.SetFont("s11 w100")
    MyGui.Add("Text", "x" Col1_X " y+" Rows_Gap " vSmooth_07 h32 0x0200", "Next")
    MyGui.SetFont("s8 w700")
	btnHK_NextSong := MyGui.Add("Text", "vStrong_07 x" Col2_X " yp h32 w" Col2_W " Center 0x0200 +Border")
	HotkeyManager.BindControl(btnHK_NextSong, General.HK_NextSong, NextSong)

    MyGui.SetFont("s11 w100")
    MyGui.Add("Text", "x" Col3_X " yp vSmooth_08 h32 0x0200", "Full screen")
    MyGui.SetFont("s8 w700")
	btnHK_ToggleFullscreen := MyGui.Add("Text", "vStrong_08 x" Col4_X " yp h32 w" Col2_W " Center 0x0200 +Border")
	HotkeyManager.BindControl(btnHK_ToggleFullscreen, General.HK_ToggleFullscreen, ToggleFullscreen)

    ; Row 4
    MyGui.SetFont("s11 w100")
    MyGui.Add("Text", "x" Col1_X " y+" Rows_Gap " vSmooth_09 h32 0x0200", "Play/Pause")
    MyGui.SetFont("s8 w700")
	btnHK_TogglePlay := MyGui.Add("Text", "vStrong_09 x" Col2_X " yp h32 w" Col2_W " Center 0x0200 +Border")
	HotkeyManager.BindControl(btnHK_TogglePlay, General.HK_TogglePlay, TogglePlay)

    MyGui.SetFont("s11 w100")
    MyGui.Add("Text", "x" Col3_X " yp vSmooth_10 h32 0x0200", "Show Help")
    MyGui.SetFont("s8 w700")
	btnHK_ShowHelpGUI := MyGui.Add("Text", "vStrong_10 x" Col4_X " yp h32 w" Col2_W " Center 0x0200 +Border")
	HotkeyManager.BindControl(btnHK_ShowHelpGUI, General.HK_ShowHelpGUI, ShowGUI)


    MyGui.SetFont("s16 w800", Settings.GuiFontName)
    MyGui.Add("Text", "xm y+60", "Tray Icon Actions")

    ; Divider Line
    MyGui.Add("Text", "xm y+24 w" ContentWidth " h1 Background333333")

    MyGui.SetFont("w100 s11 Italic")
    MyGui.Add("Text", "x" Col1_X " y+20 vSmooth_12", "Left click = Play/ Pause")
    MyGui.Add("Text", "x" Col3_X " yp vSmooth_13", "Double click = Full Screen")
    MyGui.Add("Text", "x" Col1_X " y+10 vSmooth_14", "Mouse Wheel click = Volume Up/ Down")
    MyGui.Add("Text", "x" Col3_X " yp vSmooth_15", "Right click = Show Menu")


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

    if UseAcrylicGUI  && IsFunctionDefined("ApplyThemeToGui") {
		%"ApplyThemeToGui"%(MyGui, "Dark")
		%"FrostedTheme"%.Apply(MyGui)
    } else if IsFunctionDefined("ApplyThemeToGui") {
		%"ApplyThemeToGui"%(MyGui)
		%"WatchedGUIs"%.Push(MyGui)
    }


	Tracker := GuiTracker()
	Tracker.AddGui := MyGui
	Tracker.SetAutoDismiss("Destroy", 1000)

    MyGui.Show("w" GuiWidth)
    WinActivate("ahk_id " MyGui.Hwnd)
    ShowTime := A_TickCount

    ; Click Outside / Alt+Tab / Losing Focus (WM_ACTIVATE)
    OnMessage(0x0006, OnActivateChange)
    OnActivateChange(wParam, lParam, msg, hwnd) {
		try {
			; Check if deactivated and confirm a brief grace window has passed
			if (hwnd == MyGui.Hwnd && wParam == 0 && (A_TickCount - ShowTime > 250)) {
				CleanDestroy()
			}
		}
    }

	; --- TRACKER REGISTRATION HELPERS ---
	RegisterControlEvents( btnAddToList)
	RegisterControlEvents( btnToggleMute)
	RegisterControlEvents( btnOSD_CP)
	RegisterControlEvents( btnHK_VolumeDown)
	RegisterControlEvents( btnHK_PreviousSong)
	RegisterControlEvents( btnHK_VolumeUp)
	RegisterControlEvents( btnHK_NextSong)
	RegisterControlEvents( btnHK_ToggleFullscreen)
	RegisterControlEvents( btnHK_TogglePlay)
	RegisterControlEvents( btnHK_ShowHelpGUI)

	RegisterControlEvents(ctrlObj) {
		Tracker.RegisterControl(ctrlObj, Map(
			"OnEnter", (ctrlObj) => (ctrlObj.SetFont("c" TextHoverColor), ctrlObj.Opt("+Background" BGroundHoverColor)),
			"OnLeave", (ctrlObj) => (ctrlObj.SetFont("c" TextNormalColor), ctrlObj.Opt("+Background" BGroundNormalColor))
		))
	}

    ; --- Auto-Dismiss Event Triggers ---
    MyGui.OnEvent("Close", CleanDestroy)
    MyGui.OnEvent("Escape", CleanDestroy)

    CleanDestroy(*) {
		try MyGui.Destroy()
		try MyGui := ""
		try OnMessage(0x0006, OnActivateChange, 0)
    }
}
