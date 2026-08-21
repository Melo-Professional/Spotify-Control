/************************************************************************
 * @description Vars_Custom
 * @author Melo (melo@meloprofessional.com)
 * @date 2026/06/21
 * @version 1.4.0
 ***********************************************************************/

;@region VARS
; CUSTOM VARIABLES
App.GitHubRepo := "https://github.com/Melo-Professional/Spotify-Control"
;App.NameCutted			:= "Template`nBigName"

General := {
    CurrentLang : "",
	HK_ToggleFullscreen : "#f",
	HK_ShowHelpGUI : "#h",
	HK_AddToList : "#F5",
	HK_OSD_CP : "#F6",
	HK_PreviousSong : "#F7",
	HK_NextSong : "#F8",
	HK_TogglePlay : "#F9",
	HK_ToggleMute : "#F10",
	HK_VolumeDown : "#F11",
	HK_VolumeUp : "#F12",
}

General.CurrentLang := GetSystemLangCode()

;ResetSettings       := Settings.Clone()
;ResetGeneral        := General.Clone()
;ResetOSDSettings    := OSDSettings.Clone()

;App.NameCutted := "Template`nBigName"
;Settings.SplashScreen := "Icon"
;Debug := true
Settings.UseOSD := true

Players := {
    Spotify:    "spotify.exe",
    Brave:      "brave.exe",
    Chrome:     "chrome.exe",
    Chromium:   "chromium.exe",
    Edge:       "msedge.exe",
    Opera:      "opera.exe",
    Vivaldi:    "vivaldi.exe",
}

;global CurrentPlayerExe := Players.Spotify
;global CurrentPlayerName := "Spotify"

General.CurrentPlayerName := "Spotify",
General.CurrentPlayerExe :=  "spotify.exe"

imagePlay :=            A_ScriptDir ".\assets\images\play.png"
imagePause :=           A_ScriptDir ".\assets\images\pause.png"
imageAdd :=             A_ScriptDir ".\assets\images\add.png"
imageConnect :=         A_ScriptDir ".\assets\images\connect.png"
imageFullscreen :=      A_ScriptDir ".\assets\images\fullscreen.png"
imageNext :=            A_ScriptDir ".\assets\images\next.png"
imagePrevious :=        A_ScriptDir ".\assets\images\previous.png"
imageMute :=            A_ScriptDir ".\assets\images\mute.png"
imageUnmute :=          A_ScriptDir ".\assets\images\unmute.png"
;imageUnmute :=          A_ScriptDir ".\images\unmute.svg"

Global OSDGeneral           := OSDCustom()
OSDGeneral.MinWidth         := 160
OSDGeneral.MarginX          := 8
OSDGeneral.MarginY          := 5
OSDGeneral.Position         := "x0.95 y0.90"
OSDGeneral.TimeOut          := 1800
OSDGeneral.FontSize         := 9
OSDGeneral.FontName         := "Segoe UI"

Global OSDVolume            := OSDCustom()
OSDVolume.MinWidth          := 160
OSDVolume.MarginX           := 8
OSDVolume.MarginY           := 5
OSDVolume.Position          := "x0.95 y0.90"
OSDVolume.TimeOut           := 1800
OSDVolume.FontSize          := 9
OSDVolume.FontName          := "Segoe UI"
OSDVolume.ProgressFgLight   := "465710"
OSDVolume.ProgressFgDark    := "748B15"


Global OSDCP            := OSDCustom()
OSDCP.MinWidth          := 360
OSDCP.MaxWidth          := 360
OSDCP.MarginX           := 20
OSDCP.MarginY           := 10
OSDCP.Position          := "x0.87 y0.90"
OSDCP.TimeOut           := 7000
OSDCP.FontSize          := 9
OSDCP.FontName          := "Segoe UI"
OSDCP.ProgressBarHeight := 9
OSDCP.ProgressFgLight   := "465710"
OSDCP.ProgressBgLight    := "aabb65"
OSDCP.ProgressFgDark    := "748B15"
OSDCP.ProgressBgDark   := "29330a"


;@endregion


;@region INI
SaveToINI := []
SaveToINI.Push("OSDSettings.UseOSD", "General.CurrentLang", "Settings.UseOSD", "General.CurrentPlayerExe",
				"General.CurrentPlayerName", "General.HK_ToggleFullscreen", "General.HK_ShowHelpGUI",
				"General.HK_AddToList", "General.HK_OSD_CP", "General.HK_PreviousSong",
				"General.HK_NextSong", "General.HK_TogglePlay", "General.HK_ToggleMute",
				"General.HK_VolumeDown", "General.HK_VolumeUp"
				)

if App.HasOwnProp("GitHubRepo")
	SaveToINI.Push("App.UpdateAuto", "App.UpdateFrequencyDays", "App.UpdateLastCheck")
if (IsSet(INIManager) && (SaveToINI != [])) {
	IsSet(RegisterArrayItems) ? RegisterArrayItems(SaveToINI) : 0
	IsSet(LoadINI) ? LoadINI() : 0
}
;@endregion

GetSystemLangCode() {
    if (A_Language = "0416") {
        return "PTBR"
    }

    ; Default fallback for English ("0409") and everything else
    return "EN"
}

DebugFunc() {
    global Debug
    if (!Debug || A_IsCompiled)
        return
        
    st := Error().Stack
    lines := StrSplit(st, "`n", "`r") 
    
    if lines.Length < 3
        return

    if RegExMatch(lines[3], "\\(?<File>[^\\]+)\s\((?<Line>\d+)\)\s:\s(?<Func>.*)$", &match) {

        timeStr := FormatTime(, "HH:mm:ss")
        msg := "`nTime: " . timeStr . "`n"
             . "Tick: " . A_TickCount . "`n"
             . "File: " . match.File . "`n"
             . "Line: " . match.Line . "`n"
             . "Func: " . match.Func . "`n `n"

        ToolTip(msg)
        A_Clipboard .= "****`n" . msg
    }
}

