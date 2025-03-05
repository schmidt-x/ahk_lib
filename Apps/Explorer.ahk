class Explorer {
	static _processName     := "explorer.exe"
	static _winProcessName  := "ahk_exe " this._processName
	static _fullProcessName := "C:\Windows\" this._processName
	
	static ProcessName => this._processName
	static IsActive => WinActive(this._winProcessName)
	
	
	; --- Shortcuts ---
	
	static FocusOnAddressBar() => SendInput("!d")
	
	static CloseTab() => SendInput("^w")
	
	static NextTab() => SendInput("^{tab}")
	
	static PreviousTab() => SendInput("^+{tab}")
	
	static NewTab() => SendInput("^t")
	
	static CreateFolder() => SendInput("+^n")
	
	static OpenContextMenu() => SendInput("+{F10}")
}