class Chrome {
	static _processName     := "chrome.exe"
	static _winProcessName  := "ahk_exe chrome.exe"
	static _fullProcessName := A_ProgramFiles . "\Google\Chrome\Application\chrome.exe"
	
	static ProcessName => this._processName
	static IsActive => WinActive(this._winProcessName)
	
	
	static Run() {
		if winHwnd := WinExist(this._winProcessName) {
			WinActivate(winHwnd)
		} else {
			Run(this._fullProcessName)
		}
	}
	
	
	; --- Shortcuts ---
	
	static NewTab() => SendInput("^t")
	
	static CloseTab() => SendInput("^w")
	
	static ReopenLastClosedTab() => SendInput("+^t")
	
	static ReloadTab() => SendInput("^r")
	
	static NextTab() => SendInput("^{PgDn}")
	
	static PreviousTab() => SendInput("^{PgUp}")
	
	static MoveTabLeft() => SendInput("^+{PgUp}")
	
	static MoveTabRight() => SendInput("^+{PgDn}")
	
	static Forward() => SendInput("!{Right}")
	
	static Back() => SendInput("!{Left}")
	
	static FocusOnAddressBar() => SendInput("^l")
}