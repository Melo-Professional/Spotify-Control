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


/*
    A_TrayMenu.ClickCount := 2
;    OnMessage(0x404, TrayIconClick)
     TrayIconClick(wParam, lParam, msg, hwnd) {
        ; 0x202 = WM_LBUTTONUP (Left mouse button released)
        if (lParam = 0x202) { 
            Spotify_UWP.TogglePlay()
            return 1
        }
    } */



/*
    A_TrayMenu.ClickCount := 2
    OnMessage(0x404, TrayIconHandler)

TrayIconHandler(wParam, lParam, msg, hwnd) {
    ; 0x201 = WM_LBUTTONDOWN (Left mouse button pressed)
    ; Using ButtonDown is generally more reliable for multi-click timers than ButtonUp
    if (lParam = 0x201) {
        static clickCounter := 0
        clickCounter++
        
        if (clickCounter = 1) {
            ; Wait 250ms to see if a second click arrives. 
            ; Adjust 250 higher if you click slowly, or lower for snappier response.
            SetTimer(HandleClicks, -250)
        }
        
        HandleClicks() {
            if (clickCounter = 1) {
                ; --- SINGLE CLICK ACTION ---
                Spotify_UWP.TogglePlay()
            } else if (clickCounter >= 2) {
                ; --- DOUBLE CLICK ACTION ---
                Spotify_UWP.ToggleFullscreen() ; Or whatever your fullscreen function is named
            }
            clickCounter := 0 ; Reset the counter for next time
        }
        return 1
    }
    
    ; Note: We don't intercept 0x205 (WM_RBUTTONUP), 
    ; so AHK's default right-click tray menu behavior stays perfectly intact!
}

*/



; Disable the default menu action when double-clicking the icon
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