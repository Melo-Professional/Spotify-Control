;@region Setup
;@region Description
/************************************************************************
 * @description A snippet to control Spotify.
 * @author Melo (melo@meloprofessional.com)
 * @date 2026/06/22
 * @releasedate 2026/09/19
 * @version 1.5.4.0
 ***********************************************************************/

AppName := "Spotify Control"
;@Ahk2Exe-Let U_AppName = %A_PriorLine%
AppVersion := "1.5.4.0"
;@Ahk2Exe-Let U_Version = %A_PriorLine%
AppDescription := "A snippet to control Spotify."
;@endregion

;@region Directives
#Requires AutoHotkey v2.0
#SingleInstance Force
Persistent()
SetWorkingDir(A_ScriptDir)
A_AllowMainWindow := 0
A_IconHidden := true
; --- Optimization Settings ---
;ProcessSetPriority("High")
ListLines(False)
KeyHistory(0)
A_MaxHotkeysPerInterval := 5000
A_HotkeyInterval := 1000
;@endregion

;@region Includes
#Include *i <_CompilerDirectives>
#Include *i <_Config&Vars>
#Include *i <_MsgBoxCustom>
#Include *i <_SaveSettings>
#Include *i <_Theme>
#Include <_OSDCustom>
;#Include *i <_Color_Picker_Dialog>
#Include <_SplashScreen>
;#Include *i <_Help>
#Include *i <_Menu>

#Include <Translations>
#Include <Vars_Custom>
#Include <_About>
#Include <UIA>
#Include <Spotify_UWP>
#Include <Menu_Custom>
#Include <Help>
;@endregion

;@region Startup
; SPLASHSCREEN
if IsSet(SplashScreen){
    SplashScreen("Icon")
}

; TRAY ICON + MENU
StartMenu()
Menu_Custom()
;@endregion
;@endregion

;@region Main
DetectHiddenWindows(true)
OSD             :=      OSDCustom()
OSD.Position    := "x0.95 y0.95"
OSD.TimeOut     := 1800
OSD.FontSize    := 9
OSD.FontName    := "Segoe UI"
OSD.MinWidth    := 160
OSD.MarginX     := 10
;@endregion

;@region Hotkeys
; --- Song Info Toast ---
$#F6::Spotify_UWP.Toast("Playing: " (song := Spotify_UWP.NowPlaying).Name "`nArtist: " song.Artist "`nPlay time: " song.Time " / " song.Length)

; --- Previous ---
$#F7::Spotify_UWP.PreviousSong()

; --- Next ---
$#F8::Spotify_UWP.NextSong()

; --- Play / Pause ---
$#F9::Spotify_UWP.TogglePlay()

; --- Mute ---
$#F10::Spotify_UWP.ToggleMute()

; --- Volume Down (-10%) ---
$#F11::Spotify_UWP.Volume -= 10

; --- Volume Up (+10%) ---
$#F12::Spotify_UWP.Volume += 10

; --- Full Screen ---
$#f::Spotify_UWP.ToggleFullscreen()

; --- Help GUI ---
#h::ShowHelpGUI()

#HotIf !A_IsCompiled
^p::Reload()
#HotIf 
;@endregion


#Requires AutoHotkey v2.0

ReloadWithArgs(callerName := "", paramValue := "") {
    argString := ""
    if (callerName != "") {
        argString .= ' "' callerName '"'
        if (paramValue != "") {
            argString .= ' "' paramValue '"'
        }
    }

    if A_IsCompiled {
        Run('"' A_ScriptFullPath '" /restart' argString)
    } else {
        Run('"' A_AhkPath '" /restart "' A_ScriptFullPath '"' argString)
    }
    ExitApp()
}

; CHECK RELOAD ARGUMENTS
if (A_Args.Length > 0) {
    targetFuncName := A_Args[1]
    if (OSDSettings.UseOSD) {
        if OSD.IsVisible
            OSD.UpdateText("Spotify " targetFuncName)
        else 
            OSD.Show("Spotify " targetFuncName)
    }

    Spotify_UWP.GetDocumentElement(, ,"root")
    Sleep(1000)
    Spotify_UWP.GetPlayerControls()
    Sleep(2000)
    Spotify_UWP.GetNowPlayingBar()


    try {
        ; Check if the argument actually matches a valid method name in the class
        if (targetFuncName != "" && HasMethod(Spotify_UWP, targetFuncName)) {
            if (A_Args.Length >= 2) {
                Spotify_UWP.%targetFuncName%(A_Args[2])
            } else {
                Spotify_UWP.%targetFuncName%()
            }
        }
    } catch Any as err {
        MsgBoxCustom("Failed to execute dynamic call: " err.Message, App.Name)
    }
}
