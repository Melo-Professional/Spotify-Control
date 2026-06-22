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
;@endregion


;@region INI
SaveToINI.Push("OSDSettings.UseOSD", "General.CurrentLang")     ; add more to INI file
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

