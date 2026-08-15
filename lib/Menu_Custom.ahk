/************************************************************************
 * @description Robust, Modular Menu (No-Crash Dependency Checking)
 * @author Melo (melo@meloprofessional.com)
 * @date 2026/06/08
 * @version 1.3.1
 ***********************************************************************/

#Requires AutoHotkey v2.0

Menu_Custom() {

	A_IconTip := ""
    TrayMenu := A_TrayMenu

    ; SC Reload fix
    TrayMenu.Delete("Restart")
    TrayMenu.Insert("Exit", "Restart", (*) => Reload())

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
    TrayMenu.Insert("More", "Hotkeys...", (*) => ShowMainGUI())
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

    IsFunctionDefined(Name) {
        try return HasMethod(%Name%)
        return false
    }
}