/************************************************************************
 * @description Vars_Custom
 * @author Melo (melo@meloprofessional.com)
 * @date 2026/06/08
 * @version 1.0.0
 ***********************************************************************/

;@region VARS
; CUSTOM VARIABLES
App.Github := "https://github.com/Melo-Professional/Spotify-Control"
General := {
    CurrentLang : ""
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

imagePlay :=            A_ScriptDir ".\images\play.png"
imagePause :=           A_ScriptDir ".\images\pause.png"
imageAdd :=             A_ScriptDir ".\images\add.png"
imageConnect :=         A_ScriptDir ".\images\connect.png"
imageFullscreen :=      A_ScriptDir ".\images\fullscreen.png"
imageNext :=            A_ScriptDir ".\images\next.png"
imagePrevious :=        A_ScriptDir ".\images\previous.png"
imageMute :=            A_ScriptDir ".\images\mute.png"
imageUnmute :=          A_ScriptDir ".\images\unmute.png"
;imageUnmute :=          A_ScriptDir ".\images\unmute.svg"

Global OSDGeneral           := OSDCustom("General")
OSDGeneral.MinWidth         := 160
OSDGeneral.MarginX          := 16
OSDGeneral.MarginY          := 5
OSDGeneral.Position         := "x0.90 y0.95"
OSDGeneral.TimeOut          := 1800
OSDGeneral.FontSize         := 9
OSDGeneral.FontName         := "Segoe UI"

Global OSDVolume            := OSDCustom("Volume")
OSDVolume.MinWidth          := 160
OSDVolume.MarginX           := 16
OSDVolume.MarginY           := 5
OSDVolume.Position          := "x0.90 y0.95"
OSDVolume.TimeOut           := 1800
OSDVolume.FontSize          := 9
OSDVolume.FontName          := "Segoe UI"
OSDVolume.ProgressFgLight   := "465710"
OSDVolume.ProgressFgDark    := "748B15"


Global OSDCP            := OSDCustom("Volume")
OSDCP.MinWidth          := 360
OSDCP.MarginX           := 20
OSDCP.MarginY           := 10
OSDCP.Position          := "x0.87 y0.90"
OSDCP.TimeOut           := 3000
OSDCP.FontSize          := 9
OSDCP.FontName          := "Segoe UI"
OSDCP.ProgressBarHeight := 9
OSDCP.ProgressFgLight   := "465710"
OSDCP.ProgressBgLight    := "aabb65"
OSDCP.ProgressFgDark    := "748B15"
OSDCP.ProgressBgDark   := "29330a"


;@endregion


;@region INI
SaveToINI.Push("OSDSettings.UseOSD", "General.CurrentLang", "Settings.UseOSD", "General.CurrentPlayerExe", "General.CurrentPlayerName")     ; add more to INI file
RegisterArrayItems(SaveToINI)
LoadINI()
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

