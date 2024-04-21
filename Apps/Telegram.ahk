#Include <Misc\CommandRunner>

class Telegram {
	static _processName     := "Telegram.exe"
	static _winProcessName  := "ahk_exe " this._processName
	static _fullProcessName := A_AppData . "\Telegram Desktop\" this._processName
	
	
	static ProcessName => this._processName
	static IsActive => WinActive(this._winProcessName)
	
	static __New() {
		CommandRunner.AddCommands(
			"tg",  this.Open.Bind(this),
			"tg-", this.Close.Bind(this),
		)
	}
	
	
	static Open(*) {
		if tgHwnd := WinExist(this._winProcessName) {
			WinActivate(tgHwnd)
		} else {
			Run(this._fullProcessName)
		}
	}
	
	static Close(*) {
		if tgPID := ProcessExist(this._processName) {
			ProcessClose(tgPID)
		}
	}
	
	
	static StartNewLine() => SendInput("+{Enter}")
		
	static SendMessage() =>	SendInput("{Enter}")
}