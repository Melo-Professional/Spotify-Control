/**
 * @description Windows Store Spotify 2026/06 - Scoped Name Matching with Self-Healing Cache & Spam Key Protection
 * @credits Descolada https://github.com/Descolada/UIA-v2
 */

UIA.AutoSetFocus := False
Spotify_UWP.winExe := "ahk_exe " . General.CurrentPlayerExe

class Spotify_UWP {
    static winTitle => WinGetTitle(this.winExe)
    static exePath := A_AppData "\Spotify\Spotify.exe"

    ; --- Cache Store ---
    static _cache := Map(
        "Doc", false,
        "NPBar", false,
        "Controls", false
    )

    static GetDocumentElement(forceRefresh := false, caller := "", parameter := "") {
        if (forceRefresh || !this._cache["Doc"]) {
            ;this.OpenSpotify()
            this._cache["Doc"] := false
            ;this._DisplayOsd("connecting...")
            OSD_General( imageConnect, "connecting")

            if !(General.CurrentPlayerExe == "spotify.exe"){
                this.OpenSpotify()
                sleep(5000)
            }
                targetHwnd := this._GetCorrectHwnd()

            

            ;DebugFunc()
            try this._cache["Doc"] := UIA.ElementFromHandle(targetHwnd).FindElement({ AutomationId: "RootWebArea" })


;            if (this._cache["Doc"] != false){
;                try return this._cache["Doc"]
;            }
            if (this._cache["Doc"]){
                return this._cache["Doc"]
            }

            if (General.CurrentPlayerExe == "spotify.exe"){
                this.OpenSpotify()
            }

;            this.OpenSpotify()
            targetHwnd := this._GetCorrectHwnd()

            try{
                timeout := A_TickCount + 5000
                while (A_TickCount < timeout && !(this._cache["Doc"] := UIA.ElementFromHandle(targetHwnd).FindElement({ AutomationId: "RootWebArea" }))){
                    Sleep -1
                }
            }

            ;if (this._cache["Doc"] != false){
            if (this._cache["Doc"]){
                return this._cache["Doc"]
            }

            ReloadWithArgs(caller, parameter)
            Exit()
        }
        return this._cache["Doc"]
    }

    static GetNowPlayingBar(forceRefresh := false, caller := "", parameter := "") {
        if (forceRefresh || !this._cache["NPBar"]) {
            this._cache["NPBar"] := false
            doc := this.GetDocumentElement(forceRefresh, caller, parameter)
            this._cache["NPBar"] := doc.FindElement({ Type: "Group", Name: LanguagePack[General.CurrentLang]["Now playing bar"]})

            ;if (this._cache["NPBar"] != false){
            if (this._cache["NPBar"]){
                return this._cache["NPBar"]
            }

            MsgBoxCustom(
                "'Now playing bar' not found.`n`n"
                "1 - Open Spotify App and set language`n"
                "2 - Click " App.Name " tray icon and set language`n`n`n"
                "Current " App.Name " Language selected: "
                General.CurrentLang "."
            , App.Name)

            Exit()
;                this._cache["NPBar"] := ""
        }
        return this._cache["NPBar"]
    }

    static GetPlayerControls(forceRefresh := false, caller := "", parameter := "") {
        if (forceRefresh || !this._cache["Controls"]) {
            this._cache["Controls"] := false
            npBar := this.GetNowPlayingBar(forceRefresh, caller, parameter)
            this._cache["Controls"] := npBar.FindElement({ Type: "Group", Name: LanguagePack[General.CurrentLang]["Player controls"]})

            ;if (this._cache["Controls"] != false){
            if (this._cache["Controls"]){
                return this._cache["Controls"]
            }

            MsgBoxCustom(
                "'Player controls' not found.`n`n"
                "1 - Open Spotify App and set language`n"
                "2 - Click " App.Name " tray icon and set language`n`n`n"
                "Current " App.Name " Language selected: "
                General.CurrentLang "."
            , App.Name)

            Exit()
;            this._cache["Controls"] := ""
        }
        return this._cache["Controls"]
    }

    static ClearCache() {
        for key, value in this._cache
            this._cache[key] := false
    }

    static btnPlayPause := false
    ; --- Play / Pause ---
    static TogglePlay() {
        loop 5 {
            try {
                this.btnPlayPause.Invoke()
                break
            } catch {
                try {
                    this.btnPlayPause := this.GetPlayerControls(A_Index == 2, "TogglePlay").FindElement([{ Name: LanguagePack[General.CurrentLang]["Play"], Type: "Button" }, { Name: LanguagePack[General.CurrentLang]["Pause"], Type: "Button" }])
                } catch {
                    if (A_Index >= 4){
                    try this.btnPlayPause := this.GetDocumentElement(A_Index == 4, "TogglePlay").FindElement([{ Name: LanguagePack[General.CurrentLang]["Play"], Type: "Button" }, { Name: LanguagePack[General.CurrentLang]["Pause"], Type: "Button" }])
                    }
                }
            }
            if (A_Index == 2 || A_Index == 4)
                sleep(1000)
        }

        ;state := this._CheckPlayingStateAHKTitle() ? LanguagePack[General.CurrentLang]["Play"] : LanguagePack[General.CurrentLang]["Pause"]
        state := this._CheckPlayingStateAHKTitle() ? imagePlay : imagePause
        label := (state == imagePlay ) ? LanguagePack[General.CurrentLang]["Play"] : LanguagePack[General.CurrentLang]["Pause"]
        ;        state := this._CheckPlayingStateUIATitle() ? LanguagePack[General.CurrentLang]["Play"] : LanguagePack[General.CurrentLang]["Pause"]

        ;this._DisplayOsd(state)
        OSD_General( state, label)
    }

    static btnAddToList := false
    ; --- Add to Lib ---
    static AddToList() {
        OSD_General( imageAdd, LanguagePack[General.CurrentLang]["Save to Your Library"])
        loop 5 {
            try {
                this.btnAddToList.Click()
                break
            } catch {
                try {
                    this.btnAddToList := this.GetNowPlayingBar(A_Index == 2, "AddToList").FindElement([{ Name: LanguagePack[General.CurrentLang]["Save to Your Library"], Type: "Button" }, { Name: LanguagePack[General.CurrentLang]["Add to Your Episodes"], Type: "Button" }])
                } catch {
                    if (A_Index >= 4){
                    try this.btnAddToList := this.GetDocumentElement(A_Index == 4, "AddToList").FindElement([{ Name: LanguagePack[General.CurrentLang]["Save to Your Library"], Type: "Button"  }, { Name: LanguagePack[General.CurrentLang]["Add to Your Episodes"], Type: "Button"  }])
                    }
                }
            }
            if (A_Index == 2 || A_Index == 4)
                sleep(1000)
        }
        ;this._DisplayOsd("✚")
        
    }

    static NowPlaying {
        get {
            loop 2 {
                try {
                    npBar := this.GetNowPlayingBar(A_Index == 2)
                    links := npBar.FindElements({ Type: "Link" })

                    try {
                        progressSlider := npBar.FindElement({ Name: LanguagePack[General.CurrentLang]["Change progress"], Type: "Slider", casesense: false })
                    } catch {
                        progressSlider := this.GetDocumentElement(A_Index == 2).FindElement({ Name: LanguagePack[General.CurrentLang]["Change progress"], Type: "Slider" })
                    }

                    timeArray := StrSplit(progressSlider.Value, "/")

                    return {
                        Name: links.Length >= 1 ? links[1].Name : "Unknown Track",
                        Artist: links.Length >= 2 ? links[2].Name : "Unknown Artist",
                        Time: timeArray.Length >= 1 ? timeArray[1] : "0:00",
                        Length: timeArray.Length > 1 ? timeArray[2] : "0:00"
                    }
                } catch {
                    if (A_Index == 2)
                        return { Name: "Unknown", Artist: "Unknown", Time: "0:00", Length: "0:00" }
                }
            }
        }
    }

    static btnNext := false
    ; --- Next ---
    static NextSong() {
        OSD_General( imageNext, LanguagePack[General.CurrentLang]["Next"])
        loop 5 {
            try {
                this.btnNext.Invoke()
                break
            } catch {
                try {
                    this.btnNext := this.GetPlayerControls(A_Index == 2, "NextSong").FindElement({ Name: LanguagePack[General.CurrentLang]["Next"], Type: "Button" })
                } catch {
                    if (A_Index >= 4){
                    try this.btnNext := this.GetDocumentElement(A_Index == 4, "NextSong").FindElement({ Name: LanguagePack[General.CurrentLang]["Next"], Type: "Button" })
                    }
                }
            }
            if (A_Index == 2 || A_Index == 4)
                sleep(1000)
        }
;        this._DisplayOsd(LanguagePack[General.CurrentLang]["Next"])
        ;this._DisplayOsd("▶|")
        
    }


    static btnPrevious := false
    ; --- Next ---
    static PreviousSong() {
        OSD_General( imagePrevious, LanguagePack[General.CurrentLang]["Previous"])
        loop 5 {
            try {
                this.btnPrevious.Invoke()
                sleep(200)
                this.btnPrevious.Invoke()

                break
            } catch {
                try {
                    this.btnPrevious := this.GetPlayerControls(A_Index == 2, "PreviousSong").FindElement({ Name: LanguagePack[General.CurrentLang]["Previous"], Type: "Button" })
                } catch {
                    if (A_Index >= 4){
                    try this.btnPrevious := this.GetDocumentElement(A_Index == 4, "PreviousSong").FindElement({ Name: LanguagePack[General.CurrentLang]["Previous"], Type: "Button" })
                    }
                }
            }
            if (A_Index == 2 || A_Index == 4)
                sleep(1000)
        }
;        this._DisplayOsd(LanguagePack[General.CurrentLang]["Previous"])
        ;this._DisplayOsd("|◀")
        
    }

    static btnFullScreen := false
    ; --- Fullscreen ---
    static ToggleFullscreen() {
        OSD_General( imageFullscreen, "Full Screen")

        if (General.CurrentPlayerExe == "spotify.exe"){
            this.OpenSpotify()
            targetHwnd := this._GetCorrectHwnd()
            WinShow("ahk_id " targetHwnd)
            WinRestore("ahk_id " targetHwnd)
        }

        loop 5 {
            try {
                this.btnFullScreen.Toggle()
                break
            } catch {
                try {
                    this.btnFullScreen := this.GetNowPlayingBar(A_Index == 2, "ToggleFullscreen").FindElement([{ Name: LanguagePack[General.CurrentLang]["Enter Full screen"], Type: "Button" }, { Name: LanguagePack[General.CurrentLang]["Exit full screen"], Type: "Button" }])
                } catch {
                    if (A_Index >= 4){
                    try this.btnFullScreen := this.GetDocumentElement(A_Index == 4, "ToggleFullscreen").FindElement([{ Name: LanguagePack[General.CurrentLang]["Enter Full screen"], Type: "Button" }, { Name: LanguagePack[General.CurrentLang]["Exit full screen"], Type: "Button" }])
                    }
                }
            }
            if (A_Index == 2 || A_Index == 4)
                sleep(1000)
        }
        ;this._DisplayOsd("⛶")
        
    }
    

    static btnToggleMute := false
    ; --- Toggle Mute ---
    static ToggleMute() {
        static cachedMutedState := false
        static isInitialized := false

        strMute := LanguagePack[General.CurrentLang]["Mute"]
        strUnmute := LanguagePack[General.CurrentLang]["Unmute"]
        
        ; 1. Strict Dual-Monitor Visibility Check
        isSpotifyVisible := false
        oldDetect := A_DetectHiddenWindows
        DetectHiddenWindows False 
        
        spotifyHwnd := WinExist(this.winExe) ; executable
        if (spotifyHwnd) {
            try {
                style := WinGetStyle(spotifyHwnd)
                minMax := WinGetMinMax(spotifyHwnd)
                if (minMax != -1 && (style & 0x10000000)) {
                    isSpotifyVisible := true
                }
            } catch {
                isSpotifyVisible := false
            }
        }
        
        isSpotifyActive := WinActive(this.winExe) ; executable
        
        ; Default rule: Assume Cache Mode unless proven otherwise by live UI updates
        isCachedMode := true

        ; Capture the element name BEFORE the click
        nameBefore := ""
        if (isSpotifyVisible && this.btnToggleMute) {
            try {
                nameBefore := this.btnToggleMute.Name
            } catch {
                nameBefore := ""
            }
        }

        DetectHiddenWindows True

        ; 2. --- Find and/or Invoke Element ---
        loop 5 {
            try {
                this.btnToggleMute.Invoke()
                break
            } catch {
                try {
                    this.btnToggleMute := this.GetNowPlayingBar(A_Index == 2, "ToggleMute").FindElement([{ Name: strMute, Type: "Button" }, { Name: strUnmute, Type: "Button" }])
                } catch {
                    if (A_Index >= 4) {
                        try {
                            this.btnToggleMute := this.GetDocumentElement(A_Index == 4, "ToggleMute").FindElement([{ Name: strMute, Type: "Button" }, { Name: strUnmute, Type: "Button" }])
                        } catch {
                            ; Do nothing
                        }
                    }
                }
            }
            if (isSpotifyVisible && (A_Index == 2 || A_Index == 4)) {
                sleep(1000)
            }
        }
        DetectHiddenWindows oldDetect

        ; 3. --- State & Cache Management ---
        if (isSpotifyVisible) {
            ; --- SCENARIO A: SPOTIFY IS OPEN ON A MONITOR ---
            Sleep(150) 
            
            nameAfter := ""
            try {
                nameAfter := this.btnToggleMute.Name
            } catch {
                nameAfter := ""
            }

            if (nameBefore == "" && nameAfter != "") {
                cachedMutedState := (nameAfter == strUnmute)
                ; If it's active or we successfully read a fresh layout tree string on monitor 2
                isCachedMode := false 
                isInitialized := true
            }
            else if (nameBefore != "" && nameAfter != "" && nameBefore != nameAfter) {
                ; UI strings changed cleanly and instantly!
                if (isSpotifyActive) {
                    ; Case 1: Active Foreground window (Trust UI fully, hide '?')
                    cachedMutedState := (nameAfter == strUnmute)
                    isCachedMode := false
                } else {
                    ; Case 2: Visible on Monitor 2 but background (Trust state, hide '?')
                    cachedMutedState := !cachedMutedState
                    isCachedMode := false 
                }
                isInitialized := true
            } else {
                ; Case 3: Buried/Covered window or background lag (Force '?' and cache tracking)
                if (!isInitialized) {
                    try {
                        cachedMutedState := (this.btnToggleMute.Name == strUnmute)
                    } catch {
                        cachedMutedState := false
                    }
                    isInitialized := true
                }
                cachedMutedState := !cachedMutedState
                isCachedMode := true 
            }
        } else {
            ; --- SCENARIO B: SPOTIFY IS MINIMIZED/TRAY ---
            isCachedMode := true 
            
            if (!isInitialized) {
                try {
                    cachedMutedState := (this.btnToggleMute.Name == strUnmute)
                } catch {
                    cachedMutedState := false
                }
                isInitialized := true
            }
            
            cachedMutedState := !cachedMutedState
        }

        ; 4. --- Process OSD Display ---
        label := cachedMutedState ? strMute : strUnmute
        if (isCachedMode) {
            label .= " (guessing)"
        }

        iconstate := cachedMutedState ? imageMute : imageUnmute
        OSD_General(iconstate, label)
    }

    ; --- Volume Controls ---
    static _cachedVolumeSlider := ""
    static _currentVol := -1

    static Volume {
        get {
            if (this._currentVol != -1)
                return this._currentVol

            sliderVol := ""
            loop 5 {
                try {
                    sliderVol := this.GetNowPlayingBar(A_Index == 2, "Volume").FindElement({
                        Name: LanguagePack[General.CurrentLang]["Change volume"],
                        Type: "Slider"
                    })
                    break
                } catch {
                    if (A_Index >= 4) {
                        try {
                            sliderVol := this.GetDocumentElement(A_Index == 4, "Volume").FindElement({
                                Name: LanguagePack[General.CurrentLang]["Change volume"],
                                Type: "Slider"
                            })
                        } catch {
                            return 0
                        }
                    }
                }
                if (A_Index == 2 || A_Index == 4)
                    sleep(1000)
            }

            this._cachedVolumeSlider := sliderVol
            ;this._currentVol := Round(sliderVol.RangeValuePattern.Value * 100)
            this._currentVol := (sliderVol.RangeValuePattern.Value * 100)
            return this._currentVol
        }
        set {
            sliderEl := ""
            if (this._cachedVolumeSlider) {
                sliderEl := this._cachedVolumeSlider
            } else {
                loop 5 {
                    try {
                        sliderVol := this.GetNowPlayingBar(A_Index == 2, "Volume").FindElement({
                            Name: LanguagePack[General.CurrentLang]["Change volume"],
                            Type: "Slider"
                        })
                        break
                    } catch {
                        if (A_Index >= 4) {
                            try {
                                sliderVol := this.GetDocumentElement(A_Index == 4, "Volume").FindElement({
                                    Name: LanguagePack[General.CurrentLang]["Change volume"],
                                    Type: "Slider"
                                })
                            } catch {
                                return 0
                            }
                        }
                    }
                    if (A_Index == 2 || A_Index == 4)
                        sleep(1000)
                }
                this._cachedVolumeSlider := sliderEl
            }

            try {
                this._currentVol := Max(0, Min(100, value))
                targetRaw := this._currentVol / 100
                sliderEl.RangeValuePattern.Value := targetRaw

                totalSteps := 10
                dotPosition := Round((this._currentVol / 100) * totalSteps)
                leftBar := ""
                loop dotPosition
                    leftBar .= "─"
                rightBar := ""
                loop (totalSteps - dotPosition)
                    rightBar .= "─"
                ;this._DisplayOsd(Round(this._currentVol) . " %`n" . leftBar . "●" . rightBar)
                ;this._DisplayOsd(leftBar . "⦁━─●━─⬤━─⦿━─◉━─⚪️" . rightBar)
                ;this._DisplayOsd(leftBar . "●" . rightBar)
                OSD_Volume(Round(this._currentVol), LanguagePack[General.CurrentLang]["Change volume"])


            } catch {
                this._cachedVolumeSlider := ""
                this._currentVol := -1
            }
        }
    }

    static _CheckPlayingStateAHKTitle(string := "Spotify") {
        targetHwnd := this._GetCorrectHwnd()
        if WinExist(targetHwnd) {
            title := WinGetTitle(targetHwnd)
            return !!InStr(title, string)
        }
        return false
    }

    static _CheckPlayingStateUIATitle(string := "Spotify") {
        targetHwnd := this._GetCorrectHwnd()
        try {
            element := UIA.ElementFromHandle(targetHwnd).FindElement({ Type: "Pane", ClassName: "RootView" }, 3)
            return !!InStr(element.Name, string)
        } catch {
            return false
        }
    }

    static Toast(message) {
        TrayTip
        TrayTip(message, "Spotify info", "Mute " 16)
        ;TrayTip(message, "Spotify info", "Mute " 36)
    }

    static OpenSpotify() {
        ;DebugFunc()
        oldSetting := DetectHiddenWindows(false)
        oldMatchMode := SetTitleMatchMode("RegEx")
        ;targetWindow := "ahk_class ^Chrome_WidgetWin_[01]$ ahk_exe " this.winExe
        targetWindow := "ahk_class ^Chrome_WidgetWin_[01]$ " . this.winExe
        
        try {
                if (General.CurrentPlayerExe == "spotify.exe") {
                    Run("spotify")
                } else {
                    ; FIX 2: Wrapped the URL securely in double quotes using the dot concatenation style
                    ;Run(General.CurrentPlayerExe . ' "' . "https://spotify.com" . '"')
                    Run(General.CurrentPlayerExe . ' --new-window "https://spotify.com"')
                }

            ;if WinWait(targetWindow, , 1) {
            if WinWait(targetWindow, , 1) {
                targetHwnd := this._GetCorrectHwnd()
                WinShow("ahk_id " targetHwnd)
                WinRestore("ahk_id " targetHwnd)
                WinActivate("ahk_id " targetHwnd)
                WinWaitActive("ahk_id " targetHwnd, , 2)
            }
        } catch {
            MsgBoxCustom("Could not start Spotify.", App.Name)
        }
        
        DetectHiddenWindows(oldSetting)
        SetTitleMatchMode(oldMatchMode)
    }

    static _GetCorrectHwnd() {
        oldSetting := DetectHiddenWindows(false)
        oldMatchMode := SetTitleMatchMode("RegEx")
        ;targetWindow := "ahk_class ^Chrome_WidgetWin_[01]$ ahk_exe " this.winExe
        targetWindow := "ahk_class ^Chrome_WidgetWin_[01]$ " this.winExe
        
        hwndList := WinGetList(targetWindow)
        correctHwnd := 0
        
        for hwnd in hwndList {
            title := WinGetTitle("ahk_id " hwnd)
            if (title != "") {
                correctHwnd := hwnd
                break
            }
        }
        
        DetectHiddenWindows(oldSetting)
        SetTitleMatchMode(oldMatchMode)
        ;return correctHwnd ? correctHwnd : WinExist("ahk_exe " this.winExe) ; Fallback
        return correctHwnd ? correctHwnd : WinExist(this.winExe) ; Fallback
    }
}