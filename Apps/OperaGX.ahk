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
	
	
	; --- Shortcuts ---
	
	/*
		Sometimes, it triggers Context Menu on Alt release. Holding Shift helps to prevent it (so far).
		Make sure that the outer hotkey has Shift in it. 
		If it doesn't, manually register Shift Down before releasing Alt.
		
		Example:
			Instead of: SendInput("!1")
			Do: SendInput("{Alt Down}1{Shift Down}{Alt Up}{Shift Up}").
	
		
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
	
	static ToMainWorkspace() {
		; modified
		; name: Workspaces shortcuts (main)
		; default: none
		SendInput("!2")
	}
	
	static ToChillWorkspace() {
		; modified
		; name: Workspaces shortcuts (chill)
		; default: none
		SendInput("!3")
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
		
		SendInput("!l")
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