;@region Setup
;@region Description
/************************************************************************
 * @description A snippet to control Spotify.
 * @author Melo (melo@meloprofessional.com)
 * @date 2026/08/21
 * @releasedate 2026/09/19
 * @version 2.7.4.0
 ***********************************************************************/

AppName := "Spotify Control"
;@Ahk2Exe-Let U_AppName = %A_PriorLine%
AppVersion := "2.7.4.0"
;@Ahk2Exe-Let U_Version = %A_PriorLine%
AppDescription := "A snippet to control Spotify."
;@endregion

;_bkpMode := "AppVersionAndMinutes"
;_bkpMinutesThreshold := 5

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
#Include *i <_Backup>
#Include *i <_SaveSettings>
#Include *i <_Config&Vars>
#Include *i <_HelperFuncs>
;#Include *i <_MessageManager>
#Include *i <_TrayIconHandler>
#Include *i <_Theme>
#Include *i <_FrostedTheme>
#Include *i <_TitleBar>
#Include *i <_GuiTracker>
;#Include *i <_ModernSlider>
;#Include *i <_Color_Picker_Dialog>
#Include *i <_HotkeysRecorder>
;#Include *i <_ODColors>
#Include *i <_OSDCustom>
#Include *i <_AutoUpdater>
#Include *i <_SplashScreen>
#Include *i <_About>
;#Include *i <_Help>
#Include *i <_Menu>

#Include <Translations>
#Include <Vars_Custom>
#Include <UIA>
#Include <Spotify_UWP>
#Include <Menu_Custom>
#Include <Help>
#Include <TrayController>
;@endregion


;@region Startup
if !A_Args.Length {
	if IsSet(SplashScreen) {
	    SplashScreen()
	} else if isSet(SplashScreenOSD) {
		SplashScreenOSD()
	}
}

IsSet(StartMenu) ? StartMenu() : 0
IsSet(Menu_Custom) ? Menu_Custom() : 0
IsSet(StartAutoUpdater) ? StartAutoUpdater() : 0
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

    try OSDVolume.Destroy()
    try OSD_CP.Destroy()

    OSDGeneral.ClearCells()
    OSDGeneral.SetCellImage( 1, 1, App.Icon, "Left", 12)
    OSDGeneral.SetCellText( 1, 1, App.Name, "Center", {FontSize: 7, FontWeight: 300},2)
    try Global generalimage := OSDGeneral.SetCellImage( 1, 2, image, "Center", 60, 2, 1)
    Global generallabel := OSDGeneral.SetCellText( 1, 3, label, "Center", {FontWeight: 800}, 2, 2)
    OSDGeneral.SetCellText( 2, 4, " ", "Center", {FontSize: 1})

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
    try OSD_CP.Destroy()


    OSDVolume.ClearCells()
    OSDVolume.SetCellImage( 1, 1, App.Icon, "Left", 12)
    OSDVolume.SetCellText( 1, 1, App.Name, "Center", {FontSize: 7, FontWeight: 300},2)
    Global volumevalue := OSDVolume.SetCellText( 1, 2, value, "Center", {FontSize: 24, FontWeight: 700}, 2, 1)
    Global volumeprogress := OSDVolume.SetCellProgress( 1, 3, value, "Center",, 2, 1)
    Global volumelabel := OSDVolume.SetCellText( 1, 4, label, "Center", {FontWeight: 800}, 2, 2)
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
    displayTrack := (StrLen(track) > 27) ? SubStr(track, 1, 30) "..." : track

    OSDCP.SetCellImage( 1, 1, App.Icon, "Left", 20, 1, 1)
    OSDCP.SetCellText( 2, 1, App.Name, "Center",, 99, 1)
    OSDCP.SetCellText( 1, 2, "Playing: ", "Left", {FontSize: 8, FontWeight: 300}, 1, 2)
    Global cpplaying := OSDCP.SetCellText(2, 2, displayTrack, "Right", {FontSize: 11, FontWeight: 700}, 1, 2)
    OSDCP.SetCellText( 2, 3, " ", "Center", {FontSize: 1})
    OSDCP.SetCellText( 1, 4, "Artist: ", "Left", {FontSize: 8, FontWeight: 300})
    Global cpartist := OSDCP.SetCellText( 2, 4, artist, "Right", {FontSize: 10, FontWeight: 300}, 1)
    OSDCP.SetCellText( 1, 5, "Time: ", "Left", {FontSize: 8, FontWeight: 300})
    Global cpplaytime := OSDCP.SetCellText( 2, 5, time, "Right", {FontSize: 10, FontWeight: 300})
    Global cpprogress := OSDCP.SetCellProgress( 1, 6, percent, "Center",,,)
    OSDCP.SetCellText( 2, 7, " ", "Center", {FontSize: 1})

    OSDCP.Show()
}



;@endregion

;@region Hotkeys
; --- Add to List ---
try Hotkey("$" . General.HK_AddToList, (*) => AddToList())
AddToList(newHotkey := "", isGuiUpdate := false) {
	if (isGuiUpdate) {
		global General
		General.HK_AddToList := newHotkey
		SaveINI()
		return
	}
	Spotify_UWP.AddToList()
}

; --- Song Info Toast ---
try Hotkey("$" . General.HK_OSD_CP, (*) => HK_OSD_CP())
HK_OSD_CP(newHotkey := "", isGuiUpdate := false) {
	if (isGuiUpdate) {
		global General
		General.HK_OSD_CP := newHotkey
		SaveINI()
		return
	}
	OSD_CP( (song := Spotify_UWP.NowPlaying).Name, song.Artist, song.Time " / " song.Length , GetPlayPercentage(song.Time, song.Length))
}

; --- Previous ---
try Hotkey("$" . General.HK_PreviousSong, (*) => PreviousSong())
PreviousSong(newHotkey := "", isGuiUpdate := false) {
	if (isGuiUpdate) {
		global General
		General.HK_PreviousSong := newHotkey
		SaveINI()
		return
	}
	Spotify_UWP.PreviousSong()
}

; --- Next ---
try Hotkey("$" . General.HK_NextSong, (*) => NextSong())
NextSong(newHotkey := "", isGuiUpdate := false) {
	if (isGuiUpdate) {
		global General
		General.HK_NextSong := newHotkey
		SaveINI()
		return
	}
	Spotify_UWP.NextSong()
}

; --- Play / Pause ---
try Hotkey("$" . General.HK_TogglePlay, (*) => TogglePlay())
TogglePlay(newHotkey := "", isGuiUpdate := false) {
	if (isGuiUpdate) {
		global General
		General.HK_TogglePlay := newHotkey
		SaveINI()
		return
	}
	Spotify_UWP.TogglePlay()
}

; --- Mute ---
try Hotkey("$" . General.HK_ToggleMute, (*) => ToggleMute())
ToggleMute(newHotkey := "", isGuiUpdate := false) {
	if (isGuiUpdate) {
		global General
		General.HK_ToggleMute := newHotkey
		SaveINI()
		return
	}
	Spotify_UWP.ToggleMute()
}

; --- Volume Down (-10%) ---
try Hotkey("$" . General.HK_VolumeDown, (*) => VolumeDown())
VolumeDown(newHotkey := "", isGuiUpdate := false) {
	if (isGuiUpdate) {
		global General
		General.HK_VolumeDown := newHotkey
		SaveINI()
		return
	}
	Spotify_UWP.Volume -= (100 / 15)
}

; --- Volume Up (+10%) ---
try Hotkey("$" . General.HK_VolumeUp, (*) => VolumeUp())
VolumeUp(newHotkey := "", isGuiUpdate := false) {
	if (isGuiUpdate) {
		global General
		General.HK_VolumeUp := newHotkey
		SaveINI()
		return
	}
	Spotify_UWP.Volume += (100 / 15)
}

; --- Full Screen ---
try Hotkey("$" . General.HK_ToggleFullscreen, (*) => ToggleFullscreen())
ToggleFullscreen(newHotkey := "", isGuiUpdate := false) {
	if (isGuiUpdate) {
		global General
		General.HK_ToggleFullscreen := newHotkey
		SaveINI()
		return
	}
	Spotify_UWP.ToggleFullscreen()
}

; --- Help GUI ---
try Hotkey("$" . General.HK_ShowHelpGUI, (*) => ShowGUI())
ShowGUI(newHotkey := "", isGuiUpdate := false) {
	if (isGuiUpdate) {
		global General
		General.HK_ShowHelpGUI := newHotkey
		SaveINI()
		return
	}
	ShowMainGUI()
}

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


#HotIf !A_IsCompiled
^p::ReloadClean()
#HotIf 
;@endregion

;@region Reload
IsSet(CheckReloadArgs) ? CheckReloadArgs() : 0
;@endregion
;@endregion
