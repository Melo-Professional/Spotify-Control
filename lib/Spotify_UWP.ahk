/**
 * @description Windows Store Spotify 2026/06 - Scoped Name Matching with Self-Healing Cache & Spam Key Protection
 * @credits Descolada https://github.com/Descolada/UIA-v2
 */

UIA.AutoSetFocus := False

class Spotify_UWP {
    static winExe := "ahk_exe Spotify.exe"
    static winTitle => WinGetTitle(this.winExe)
    static exePath := A_AppData "\Spotify\Spotify.exe"

    ; --- Cache Store ---
    static _cache := Map(
        "Doc", "",
        "NPBar", "",
        "Controls", ""
    )

    static GetDocumentElement(forceRefresh := false, caller := "", parameter := "") {
        if (forceRefresh || !this._cache["Doc"]) {
            if (!parameter)
                this._DisplayOsd("connecting...")
            targetWindow := "ahk_class Chrome_WidgetWin_1 ahk_exe " this.winExe
            oldSetting := DetectHiddenWindows(true)
            try {
                this._cache["Doc"] := UIA.ElementFromHandle(hwnd).FindElement({ AutomationId: "RootWebArea" })
            } catch {
                DetectHiddenWindows(oldSetting)
                this.OpenSpotify()
                DetectHiddenWindows(true)
                try {
                    if (hwnd := WinExist(targetWindow)) {
                        this._cache["Doc"] := UIA.ElementFromHandle(hwnd, , 5000).FindElement({ AutomationId: "RootWebArea" })
                    }
                } catch {
                    DetectHiddenWindows(oldSetting)
                    ReloadWithArgs(caller, parameter)
                    Exit()
                }
            }
            DetectHiddenWindows(oldSetting)
        }
        return this._cache["Doc"]
    }

    static GetNowPlayingBar(forceRefresh := false, caller := "", parameter := "") {
        if (forceRefresh || !this._cache["NPBar"]) {
            try {
                doc := this.GetDocumentElement(forceRefresh, caller, parameter)
                this._cache["NPBar"] := doc.FindElement({ Type: "Group", Name: LanguagePack[General.CurrentLang]["Now playing bar"] })
            } catch {
                MsgBoxCustom(
                    "'Now playing bar' not found.`n`n"
                    "1 - Open Spotify App and set language`n"
                    "2 - Click " App.Name " tray icon and set language`n`n`n"
                    "Current " App.Name " Language selected: "
                    General.CurrentLang "."
                , App.Name)

                Exit()
                this._cache["NPBar"] := ""
            }
        }
        return this._cache["NPBar"]
    }

    static GetPlayerControls(forceRefresh := false, caller := "", parameter := "") {
        if (forceRefresh || !this._cache["Controls"]) {
            try {
                npBar := this.GetNowPlayingBar(forceRefresh, caller, parameter)
                this._cache["Controls"] := npBar.FindElement({ Type: "Group", Name: LanguagePack[General.CurrentLang]["Player controls"] })
            } catch {
                MsgBoxCustom(
                    "'Player controls' not found.`n`n"
                    "1 - Open Spotify App and set language`n"
                    "2 - Click " App.Name " tray icon and set language`n`n`n"
                    "Current " App.Name " Language selected: "
                    General.CurrentLang "."
                , App.Name)

                Exit()
                this._cache["Controls"] := ""
            }
        }
        return this._cache["Controls"]
    }

    static ClearCache() {
        for key, value in this._cache
            this._cache[key] := ""
    }

    ; --- Play / Pause ---
    static TogglePlay() {
        loop 2 {
            try {
                btn := this.GetPlayerControls(A_Index == 2, "TogglePlay").FindElement([{ Name: LanguagePack[General.CurrentLang]["Play"], Type: "Button" }, { Name: LanguagePack[General.CurrentLang]["Pause"], Type: "Button" }
                ])
                btn.Invoke()
                break
            } catch {
                if (A_Index == 2) {
                    try {
                        btn := this.GetDocumentElement(true, "TogglePlay").FindElement([{ Name: LanguagePack[General.CurrentLang]["Play"], Type: "Button" }, { Name: LanguagePack[General.CurrentLang]["Pause"], Type: "Button" }
                        ])
                        btn.Invoke()
                    } catch {
                        return
                    }
                }
            }
        }
        state := this._CheckTitle() ? LanguagePack[General.CurrentLang]["Play"] : LanguagePack[General.CurrentLang]["Pause"]
        this._DisplayOsd(state)
    }

    static ToggleLike() {
        loop 2 {
            try {
                npBar := this.GetNowPlayingBar(A_Index == 2)
                el := npBar.FindElement([{ Name: LanguagePack[General.CurrentLang]["Save to Your Library"] }, { Name: LanguagePack[General.CurrentLang]["Add to Your Episodes"] }
                ])
                el.Click()
                return
            } catch {
                if (A_Index == 2) {
                    try this.GetDocumentElement(true).FindElement([{ Name: LanguagePack[General.CurrentLang]["Save to Your Library"] }, { Name: LanguagePack[General.CurrentLang]["Add to Your Episodes"] }
                    ]).Click()
                }
            }
        }
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

    static NextSong() {
        loop 2 {
            try {
                this.GetPlayerControls(A_Index == 2, "NextSong").FindElement({ Name: LanguagePack[General.CurrentLang]["Next"], Type: "Button" }).Invoke()
                return
            } catch {
                if (A_Index == 2) {
                    try this.GetDocumentElement(true, "NextSong").FindElement({ Name: LanguagePack[General.CurrentLang]["Next"], Type: "Button" }).Invoke()
                }
            }
        }
        this._DisplayOsd(LanguagePack[General.CurrentLang]["Next"])
    }

    static PreviousSong() {
        loop 2 {
            try {
                this.GetPlayerControls(A_Index == 2, "NextSong").FindElement({ Name: LanguagePack[General.CurrentLang]["Previous"], Type: "Button" }).Invoke()
                return
            } catch {
                if (A_Index == 2) {
                    try this.GetDocumentElement(true, "NextSong").FindElement({ Name: LanguagePack[General.CurrentLang]["Previous"], Type: "Button" }).Invoke()
                }
            }
        }
        this._DisplayOsd(LanguagePack[General.CurrentLang]["Previous"])
    }

    static ToggleFullscreen() {
        this.OpenSpotify()

        loop 2 {
            try {
                this.GetNowPlayingBar(A_Index == 2, "ToggleFullscreen").FindElement([{ Name: LanguagePack[General.CurrentLang]["Enter Full screen"], Type: "Button" }, { Name: LanguagePack[General.CurrentLang]["Exit full screen"], Type: "Button" }
                ]).Toggle()
                this._DisplayOsd("Full screen")
                return
            } catch {
                if (A_Index == 2) {
                    try this.GetDocumentElement(true, "ToggleFullscreen").FindElement([{ Name: LanguagePack[General.CurrentLang]["Enter Full screen"], Type: "Button" }, { Name: LanguagePack[General.CurrentLang]["Exit full screen"], Type: "Button" }
                    ]).Toggle()
                    this._DisplayOsd("Full screen")
                }
            }
        }
    }

    static ToggleMute() {
        isMutedState := false
        btn := ""

        loop 2 {
            try {
                btn := this.GetNowPlayingBar(A_Index == 2, "ToggleMute").FindElement([{ Name: LanguagePack[General.CurrentLang]["Mute"], Type: "Button" }, { Name: LanguagePack[General.CurrentLang]["Unmute"], Type: "Button" }
                ])
                ;                isMutedState := (btn.Name == LanguagePack[General.CurrentLang]["Mute"])
                btn.Invoke()
                break
            } catch {
                if (A_Index == 2) {
                    try {
                        btn := this.GetDocumentElement(true, "ToggleMute").FindElement([{ Name: LanguagePack[General.CurrentLang]["Mute"], Type: "Button" }, { Name: LanguagePack[General.CurrentLang]["Unmute"], Type: "Button" }
                        ])
                        ;                        isMutedState := (btn.Name == LanguagePack[General.CurrentLang]["Mute"])
                        btn.Invoke()
                    } catch {
                        return
                    }
                }
            }
        }
        ;        state := isMutedState ? LanguagePack[General.CurrentLang]["Mute"] : LanguagePack[General.CurrentLang]["Unmute"]
        state := LanguagePack[General.CurrentLang]["Mute"] . "/" . LanguagePack[General.CurrentLang]["Unmute"]

        this._DisplayOsd(state)
    }

    ; --- Volume Controls ---
    static _cachedVolumeSlider := ""
    static _currentVol := -1

    static Volume {
        get {
            if (this._currentVol != -1)
                return this._currentVol

            sliderEl := ""
            loop 2 {
                try {
                    sliderEl := this.GetNowPlayingBar(A_Index == 2).FindElement({
                        Name: LanguagePack[General.CurrentLang]["Change volume"],
                        Type: "Slider"
                    })
                    break
                } catch {
                    if (A_Index == 2) {
                        try {
                            sliderEl := this.GetDocumentElement(true).FindElement({
                                Name: LanguagePack[General.CurrentLang]["Change volume"],
                                Type: "Slider"
                            })
                        } catch {
                            return 0
                        }
                    }
                }
            }

            this._cachedVolumeSlider := sliderEl
            this._currentVol := Round(sliderEl.RangeValuePattern.Value * 100)
            return this._currentVol
        }
        set {
            sliderEl := ""
            if (this._cachedVolumeSlider) {
                sliderEl := this._cachedVolumeSlider
            } else {
                loop 2 {
                    try {
                        sliderEl := this.GetNowPlayingBar(A_Index == 2).FindElement({
                            Name: LanguagePack[General.CurrentLang]["Change volume"],
                            Type: "Slider"
                        })
                        break
                    } catch {
                        if (A_Index == 2) {
                            try {
                                sliderEl := this.GetDocumentElement(true).FindElement({
                                    Name: LanguagePack[General.CurrentLang]["Change volume"],
                                    Type: "Slider"
                                })
                            } catch {
                                return
                            }
                        }
                    }
                }
                this._cachedVolumeSlider := sliderEl
            }

            try {
                this._currentVol := Max(0, Min(100, value))
                targetRaw := this._currentVol / 100
                sliderEl.RangeValuePattern.Value := targetRaw

                this._DisplayOsd(this._currentVol "%")

            } catch {
                this._cachedVolumeSlider := ""
                this._currentVol := -1
            }
        }
    }

    static _CheckTitle(string := "Spotify") {
        oldSetting := DetectHiddenWindows(true)
        targetWindow := "ahk_class Chrome_WidgetWin_1 ahk_exe " this.winExe

        if WinExist(targetWindow) {
            title := WinGetTitle(targetWindow)
            DetectHiddenWindows(oldSetting)
            return !!InStr(title, string)
        }
        DetectHiddenWindows(oldSetting)
        return false
    }

    static _CheckPlayingState() {
        try {
            element := UIA.ElementFromHandle(this.winExe).FindElement({ Type: "Pane", ClassName: "RootView" }, 3)
            return !!InStr(element.Name, "Spotify")
        } catch {
            return -1
        }
    }

    static _DisplayOsd(message) {
        if (OSDSettings.UseOSD) {
            if OSD.IsVisible
                OSD.UpdateText("Spotify " message)
            else
                OSD.Show("Spotify " message)
        }
    }

    static Toast(message) {
        TrayTip
        TrayTip(message, "Spotify info", "Mute " 16)
    }

    static OpenSpotify() {
        targetWindow := "ahk_class Chrome_WidgetWin_1 ahk_exe " this.winExe
        oldSetting := DetectHiddenWindows(false)
        if !WinExist(targetWindow) {
            try {
                Run("spotify")
                if WinWait(targetWindow, , 1) {
                    WinActivate(targetWindow)
                    WinWaitActive(targetWindow, , 2)
                }
            } catch {
                MsgBoxCustom("Could not start Spotify.", App.Name)
            }
        }
        DetectHiddenWindows(oldSetting)
    }
}