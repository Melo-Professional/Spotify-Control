;@region Setup
;@region Description
/************************************************************************
 * @description A snippet to control Spotify.
 * @author Melo (melo@meloprofessional.com)
 * @date 2026/06/29
 * @releasedate 2026/09/19
 * @version 2.2.0.0
 ***********************************************************************/

AppName := "Spotify Control"
;@Ahk2Exe-Let U_AppName = %A_PriorLine%
AppVersion := "2.2.0.0"
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
A_MenuMaskKey := "vkFF"
;DetectHiddenWindows(true)
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
#Include <About>
#Include <UIA>
#Include <Spotify_UWP>
#Include <Menu_Custom>
#Include <Help>
;@endregion

;@region Startup
; SPLASHSCREEN
if IsSet(SplashScreen) && (A_Args.Length == 0){
    SplashScreen("Icon")
}

; TRAY ICON + MENU
StartMenu()
Menu_Custom()
;@endregion
;@endregion

;@region Main
DetectHiddenWindows(true)

;@region OSD
OSD_General(image, label){
    if !(Settings.UseOSD)
        return

    Global OSD_General
    if OSDGeneral.IsVisible{
        try OSDGeneral.UpdateImageObject( generalimage, image)
        OSDGeneral.UpdateTextObject( generallabel, label, 2000)
        return
    }

;    if OSDVolume.IsVisible{
        try OSDVolume.Destroy()
;    }

    OSDGeneral.ClearCells()
    ; row 1
    OSDGeneral.SetCellImage( 1, 1, App.Icon, "Left", 12, 1, 1)
    OSDGeneral.SetCellText( 2, 1, App.Name, "Center", {FontSize: 7, FontWeight: 300})
    OSDGeneral.SetCellText( 3, 1, "      ", "Right", {FontSize: 8, FontWeight: 500})

    ; row 2
;    Global generalimage := OSD.SetCellText( 1, 2, image, "Center", {FontSize: 24, FontWeight: 700}, 3)
    try Global generalimage := OSDGeneral.SetCellImage( 1, 2, image, "Center", 50, 3, 2)

    ; row 3, 4, 5
    OSDVolume.SetCellText( 1, 3, " ", "Right", {FontSize: 20, FontWeight: 500})
    Global generallabel := OSDGeneral.SetCellText( 1, 4, label, "Center", {FontSize: 8, FontWeight: 100}, 3, 2)
    OSDGeneral.SetCellText( 1, 5, " ", "Center", {FontSize: 1, FontWeight: 300})

    OSDGeneral.Show()
}

OSD_Volume(value, label){
    if !(Settings.UseOSD)
        return

    Global OSDVolume
    if OSDVolume.IsVisible{
        OSDVolume.UpdateTextObject(volumelabel, label)
        OSDVolume.UpdateProgressObject(volumeprogress,value)
        OSDVolume.UpdateTextObject(volumevalue, value, 2000)
        return
    }

    try OSDGeneral.Destroy()

    OSDVolume.ClearCells()
    ; row 1
    OSDVolume.SetCellImage( 1, 1, App.Icon, "Left", 12, 1, 1)
    OSDVolume.SetCellText( 2, 1, App.Name, "Center", {FontSize: 7, FontWeight: 300})
    OSDVolume.SetCellText( 3, 1, "      ", "Right", {FontSize: 8, FontWeight: 500})

    ; row 2
    Global volumevalue := OSDVolume.SetCellText( 1, 2, value, "Center", {FontSize: 24, FontWeight: 700}, 3, 2)

    ; row 3, 4, 5
    Global volumeprogress := OSDVolume.SetCellProgress( 1, 3, value, "Center",, 3, 1)
    Global volumelabel := OSDVolume.SetCellText( 1, 4, label, "Center", {FontSize: 8, FontWeight: 100}, 3, 2)
    OSDVolume.SetCellText( 1, 5, " ", "Center", {FontSize: 1, FontWeight: 300})

    OSDVolume.Show()
}


OSD_CP(track, artist, time, percent){
    if !(Settings.UseOSD)
        return

    Global OSDVolume
    if OSDCP.IsVisible{
        OSDCP.UpdateTextObject(cpplaying, track)
        OSDCP.UpdateTextObject(cpartist, artist)
        OSDVolume.UpdateProgressObject(cpprogress,percent)
        OSDCP.UpdateTextObject(cpplaytime, time, 10000)
        return
    }

    try OSDGeneral.Destroy()

    try OSD_Volume.Destroy()

    OSDCP.ClearCells()
    ; row 1
    OSDCP.SetCellImage( 1, 1, App.Icon, "Left", 20, 1, 1)
    OSDCP.SetCellText( 2, 1, App.Name, "Center", {FontSize: 9, FontWeight: 300})
    OSDCP.SetCellText( 3, 1, "                   ", "Right", {FontSize: 8})
    OSDCP.SetCellText( 1, 2, " ", "Center", {FontSize: 1})

    ; row 2
    OSDCP.SetCellText( 1, 3, "Playing:", "Left", {FontSize: 10, FontWeight: 300}, 1, 2)
    Global cpplaying := OSDCP.SetCellText( 2, 3, track, "Left", {FontSize: 14, FontWeight: 500}, 1, 2)
    OSDCP.SetCellText( 2, 4, " ", "Center", {FontSize: 1})

    ; row 3, 4, 5
    OSDCP.SetCellText( 1, 5, "Artist:", "Left", {FontSize: 10, FontWeight: 300})
    Global cpartist := OSDCP.SetCellText( 2, 5, artist, "Left", {FontSize: 10, FontWeight: 300}, 2)

    OSDCP.SetCellText( 1, 6, "Play time:", "Left", {FontSize: 10, FontWeight: 300})
    Global cpplaytime := OSDCP.SetCellText( 2, 6, time, "Left", {FontSize: 10, FontWeight: 300})
    Global cpprogress := OSDCP.SetCellProgress( 1, 7, percent, "Center",,3,3)

    OSDCP.SetCellText( 1, 9, " ", "Center", {FontSize: 10})

    OSDCP.Show(,7000)
}



;@endregion

;@region Hotkeys
; --- Song Info Toast ---
; --- Add to List ---
$#F5::Spotify_UWP.AddToList()

$#F6::OSD_CP( (song := Spotify_UWP.NowPlaying).Name, song.Artist, song.Time " / " song.Length , GetPlayPercentage(song.Time, song.Length))

; --- Previous ---
$#F7::Spotify_UWP.PreviousSong()

; --- Next ---
$#F8::Spotify_UWP.NextSong()

; --- Play / Pause ---
$#F9::Spotify_UWP.TogglePlay()

; --- Mute ---
$#F10::Spotify_UWP.ToggleMute()

; --- Volume Down (-10%) ---
$#F11::Spotify_UWP.Volume -= (100 / 15) ; Spotify defaults minimum step at (100/15)

; --- Volume Up (+10%) ---
$#F12::Spotify_UWP.Volume += (100 / 15) ; Spotify defaults minimum step at (100/15)

; --- Full Screen ---
$#f::Spotify_UWP.ToggleFullscreen()

; --- Help GUI ---
$#h::ShowHelpGUI()


#HotIf !A_IsCompiled
$^p::Reload()
#HotIf 
;@endregion

;@region Reload
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
    if !A_IsCompiled && Debug
        ToolTip("reload with args " A_Args[1])
    if (Settings.UseOSD) {
        if (targetFuncName == "Volume") {
            OSD_Volume("", targetFuncName)
        } else {
            OSD_General(imageConnect, targetFuncName)
        }
    }

    Sleep(500)
    Spotify_UWP.GetDocumentElement(true, ,"root")
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
;@endregion

;@endregion



GetPlayPercentage(timeStr, lengthStr) {
    currentSec := 0
    totalSec := 0
    
    ; 1. Convert current time (Time) to seconds
    t := StrSplit(timeStr, ":")
    currentSec := (t.Length == 3) ? (Number(t[1]) * 3600) + (Number(t[2]) * 60) + Number(t[3]) 
                : (t.Length == 2) ? (Number(t[1]) * 60) + Number(t[2]) 
                : Number(t[1])

    ; 2. Convert total duration (Length) to seconds
    l := StrSplit(lengthStr, ":")
    totalSec := (l.Length == 3) ? (Number(l[1]) * 3600) + (Number(l[2]) * 60) + Number(l[3]) 
              : (l.Length == 2) ? (Number(l[1]) * 60) + Number(l[2]) 
              : Number(l[1])

    ; 3. Calculate percentage (prevents division by zero error if totalSec is 0)
    return (totalSec == 0) ? 0 : Round((currentSec / totalSec) * 100, 1)
}


#Include <TrayController>
