/************************************************************************
 * @description Robust, Modular Menu (No-Crash Dependency Checking)
 * @author Melo (melo@meloprofessional.com)
 * @date 2026/06/08
 * @version 1.3.1
 ***********************************************************************/

#Requires AutoHotkey v2.0

Menu_Custom() {

    TrayMenu := A_TrayMenu

    PlayerMenu := Menu()
    for name, exe in Players.OwnProps() {
        PlayerMenu.Add(name, PlayerHandler)
    }
;    A_TrayMenu.Add("Select Player", PlayerMenu)
    TrayMenu.Insert("More", "Select Player", PlayerMenu)
    PlayerMenu.Check(General.CurrentPlayerName)

    PlayerHandler(ItemName, ItemPos, MyMenu) {
        MyMenu.Uncheck(General.CurrentPlayerName)
        General.CurrentPlayerName := ItemName
        General.CurrentPlayerExe := Players.%ItemName%
        MyMenu.Check(General.CurrentPlayerName)
        SaveINI()
;        ReloadWithArgs("Player")
;        ReloadWithArgs("Volume")
;        ReloadWithArgs()
        Spotify_UWP.ClearCache()
        Spotify_UWP.targetHwnd := ""
        Spotify_UWP.targetWindow := ""
        Spotify_UWP.winExe := "ahk_exe " . Players.%ItemName%
        ReloadWithArgs("TogglePlay")
    }



    MoreMenu := TrayMenu.HasProp("MoreMenu") ? TrayMenu.MoreMenu : ""
    ;TrayMenu.Insert("More", "Hotkeys`tWin + H", (*) => ShowHelpGUI())
;    TrayMenu.Disable("Hotkeys`tWin + H")
;    TrayMenu.Insert("More", "")

    try MoreMenu.Delete("Pause")

    Item := "Show OSD"
    TrayMenu.Insert("More", Item, HandlerShowOSD)
    TrayMenu.Insert("More", "Hotkeys`tWin + H", (*) => ShowHelpGUI())
    TrayMenu.Insert("More", "")

    if (Settings.UseOSD){
        TrayMenu.Check(Item)
    }

    HandlerShowOSD(ItemName, ItemPos, MyMenu){
        global OSDSettings
        Settings.UseOSD := !Settings.UseOSD
        Settings.UseOSD? TrayMenu.Check(ItemName) : TrayMenu.Uncheck(ItemName)
        SaveINI()
    }

    SpotifyLanguage := Menu()
    A_TrayMenu.SpotifyLanguage := SpotifyLanguage

    for LangCode in LanguagePack {
        SpotifyLanguage.Add(LangCode, Handler_SetLanguage)
    }
    SpotifyLanguage.Check(General.CurrentLang)
    A_TrayMenu.Insert("Show OSD", "Spotify Language", SpotifyLanguage)
   
    Handler_SetLanguage(ItemName, ItemPos, MyMenu) {
        global General

        MyMenu.Uncheck(General.CurrentLang)
        General.CurrentLang := ItemName
        SaveINI()
        MyMenu.Check(General.CurrentLang)
    }


    A_TrayMenu.Default := "" 

    ; Listen for tray icon notifications
    OnMessage(0x404, TrayIconHandler)

    TrayIconHandler(wParam, lParam, msg, hwnd) {
        static clickCounter := 0

    ; 0x201 = WM_LBUTTONDOWN
    if (lParam = 0x201) {
        clickCounter++
        if (clickCounter = 1) {
            ; Wait 250ms to see if a second click arrives
            SetTimer(HandleClicks, -250)
        }
        return 1
    }
    
    ; 0x203 = WM_LBUTTONDBLCLK (Windows explicitly tells us it's a double click)
    else if (lParam = 0x203) {
        clickCounter := 2
        return 1
    }

    ; Inner function to process the action after the 250ms timeout
    HandleClicks() {
        if (clickCounter = 1) {
            ; --- 1 CLICK ---
            Spotify_UWP.TogglePlay()
;        CoordMode("Mouse", "Screen")
;        MouseGetPos(&mouseX, &mouseY)
;        TrayControllerGUI.Show("X" . (mouseX - 57) . " Y" . (mouseY - 150) . " NoActivate")
;        global LeaveCount := 0 
;        SetTimer(HideGuiWhenMouseLeaves, 400)

        } else if (clickCounter >= 2) {
            ; --- 2 CLICKS ---
            Spotify_UWP.ToggleFullscreen()
        }
        clickCounter := 0 ; Reset counter
    }
    
    ; Any other event (like 0x205 for Right-Click) passes through to show the menu normally!
}

    IsFunctionDefined(Name) {
        try return HasMethod(%Name%)
        return false
    }
}