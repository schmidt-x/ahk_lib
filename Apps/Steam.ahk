#Include <Misc\CommandRunner>

class Steam {
	static _processName     := "steam.exe"
	static _winProcessName  := "ahk_exe steamwebhelper.exe"
	static _fullProcessName := "C:\Program Files (x86)\Steam\" this._processName
	
	
	static __New() {
		CommandRunner.AddCommands(
			"stm",  this.Run.Bind(this),
			"stm-", this.Close.Bind(this),
		)
	}
	
	static Run(*) => Run(this._fullProcessName)
	
	static Close(*) {
		if steamPID := ProcessExist(this._processName) {
			ProcessClose(steamPID)
		}
	}
}