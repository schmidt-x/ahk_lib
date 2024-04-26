; TODO

#Include <Misc\CommandRunner>

class WindowsTerminal {
	static _processName     := "WindowsTerminal.exe"
	static _winProcessName  := "ahk_exe " this._processName
	static _FullProcessName := "??"
	
	static __New() {
		CommandRunner.AddCommands("term", this.Run.Bind(this))
	}
	
	static Run(&args, &err) {
		MsgBox("TODO")
	}
}