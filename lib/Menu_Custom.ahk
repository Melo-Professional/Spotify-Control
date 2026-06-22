/************************************************************************
 * @description Robust, Modular Menu (No-Crash Dependency Checking)
 * @author Melo (melo@meloprofessional.com)
 * @date 2026/06/08
 * @version 1.3.1
 ***********************************************************************/

#Requires AutoHotkey v2.0

Menu_Custom() {

    TrayMenu := A_TrayMenu
    MoreMenu := TrayMenu.HasProp("MoreMenu") ? TrayMenu.MoreMenu : ""
    TrayMenu.Insert("More", "Hotkeys`tWin + H", (*) => ShowHelpGUI())
;    TrayMenu.Disable("Hotkeys`tWin + H")
;    TrayMenu.Insert("More", "")

    try MoreMenu.Delete("Pause")

    Item := "Show OSD"
    TrayMenu.Insert("More", Item, HandlerShowOSD)
    TrayMenu.Insert("More", "")

    if (OSDSettings.UseOSD){
        TrayMenu.Check(Item)
    }

    HandlerShowOSD(ItemName, ItemPos, MyMenu){
        global OSDSettings
        OSDSettings.UseOSD := !OSDSettings.UseOSD
        OSDSettings.UseOSD? TrayMenu.Check(ItemName) : TrayMenu.Uncheck(ItemName)
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

    A_TrayMenu.ClickCount := 2
 
    OnMessage(0x404, TrayIconClick)

    TrayIconClick(wParam, lParam, msg, hwnd) {
        ; 0x202 = WM_LBUTTONUP (Left mouse button released)
        if (lParam = 0x202) { 
            Spotify_UWP.TogglePlay()
            return 1
        }
    }

    IsFunctionDefined(Name) {
        try return HasMethod(%Name%)
        return false
    }
}