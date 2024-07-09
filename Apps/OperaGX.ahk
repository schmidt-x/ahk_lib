#Include <System\Paths>

class OperaGX {
	static _processName     := "opera.exe"
	static _winProcessName  := "ahk_exe " this._processName
	static _fullProcessName := Paths.LocalPrograms "\Opera GX\" this._processName
	
	static ProcessName     => this._processName
	static WinProcessName  => this._winProcessName
	static FullProcessName => this._fullProcessName
	
	static IsActive => WinActive(this._winProcessName)
	
	
	static Run() {
		if hwnd := WinExist(this._winProcessName) {
			WinActivate(hwnd)
		} else {
			Run(this._fullProcessName)
		}
	}
	
	static IsYoutube(title) {
		len := StrLen(title)
		return len >= 15 && SubStr(title, len-14, 15) == "YouTube - Opera"
	}
	
	
	; --- Shortcuts ---
	
	/*
		Extensions used:
		- Enhancer for YouTube™ (https://www.mrfdev.com/enhancer-for-youtube)
	*/
	
	
	static OpenSettings() => SendInput("^{F12}")
	
	static CloseTab() => SendInput("^w")
	
	static ReopenLastClosedTabOrWindow() => SendInput("^+t")
	
	static ReloadTab() => SendInput("^r")
	
	static ReloadWithoutCache() => SendInput("^{F5}")
	
	static NextTab() => SendInput("^{PgDn}") ; switch right through tabs
	
	static PreviousTab() => SendInput("^{PgUp}") ; switch left through tabs
	
	static DuplicateTab() {
		; modified
		; name: _
		; default: none
		SendInput("{LAlt Down}1{LAlt Up}")
	}
	
	static ToWorkspace1() {
		; modified
		; name: Workspaces shortcuts (Main)
		; default: none
		SendInput("!2")
	}
	
	static ToWorkspace2() {
		; modified
		; name: Workspaces shortcuts (Chill)
		; default: none
		SendInput("!3")
	}
	
	static ToWorkspace3() {
		; modified
		; name: Workspaces shortcuts (HID)
		; default: none
		SendInput("!7")
	}
	
	static ForceDarkPage() {
		; modified
		; default: none
		SendInput("{LAlt Down}0{LAlt Up}")
	}
	
	static FocusOnAddressBar() => SendInput("^l")
	
	static SpeedDial() => SendInput("{Alt Down}{Home}{Alt Up}")
	
	static NewTab() => SendInput("^t")
	
	static ReloadAllTabs() {
		; modified
		; default: None
		SendInput("+^f")
	} 
	
	static FindPrevious() => SendInput("^+g")
	
	static FindNext() => SendInput("^g")
	
	static Forward() => SendInput("!{Right}")
	
	static Back() => SendInput("!{Left}")
	
	static SwitchToLastTab() {
		; modified
		; default: none
		SendInput("+!d")
	}
	
	static Extensions() => SendInput("+^e")
	
	static ToggleLoopMode() {
		; modified
		; default: none
		; extension: Enhancer for YouTube™
		
		SendInput("{LAlt Down}l{LCtrl Down}{LAlt Up}{LCtrl Up}")
	}
	
	static IncreasePlaybackSpeed() {
		; modified
		; default: none
		; extension: Enhancer for YouTube™
		
		SendInput("{Alt Down}4{Alt Up}")
	}
	
	static DecreasePlaybackSpeed() {
		; modified
		; default: none
		; extension: Enhancer for YouTube™
		
		SendInput("{Alt Down}5{Alt Up}")
	}
	
	static DefaultPlaybackSpeed() {
		; modified
		; default: none
		; extension: Enhancer for YouTube™
		
		SendInput("{Alt Down}6{Alt Up}")
	}
}