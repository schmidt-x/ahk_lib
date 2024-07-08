#Include <System\Paths>
#Include <Misc\CommandRunner>
#Include <Common\Helpers>

class WindowsTerminal {
	static _processName     := "WindowsTerminal.exe"
	static _winProcessName  := "ahk_exe " this._processName
	static _fullProcessName := Paths.Local "\Microsoft\WindowsApps\wt.exe"
	
	static __New() {
		CommandRunner.AddCommands("wt", this.Open.Bind(this))
	}
	
	static IsActive => WinActive(this._winProcessName)
	
	static Open(&args, hwnd, &output) {
		if StrIsEmptyOrWhiteSpace(args) {
			Run(this._fullProcessName)
			return
		}
		
		if args == "." {
			if !Paths.TryGet(&path, hwnd) {
				output := "Path not found."
				return
			}
			
			Run(Format('{} -d "{}"', this._fullProcessName, path))
			return
		}
		
		if !Paths.TryGetFolderPath(args, &path) {
			output := Format("Folder «{}» not found.", args)
			return
		}
		
		Run(Format('{} -d "{}"', this._fullProcessName, path))
	}
	
	
	; --- Shortcuts ---
	
	static DuplicateTab() => SendInput("+^d")
	
	static NewTab() => SendInput("+^t")
	
	static ClosePane() => SendInput("+^w")
	
	static NextTab() => SendInput("^{Tab}")
	
	static PreviousTab() => SendInput("+^{Tab}")
	
	static OpenSettings() => SendInput("^,")
	
	static SwitchToTab0() => SendInput("!^1")
	
	static SwitchToTab1() => SendInput("!^2")
	
	static SwitchToTab2() => SendInput("!^3")
	
	static SwitchToTab3() => SendInput("!^4")
	
	static SwitchToTab4() => SendInput("!^5")
	
	static SwitchToTab5() => SendInput("!^6")
	
	static SwitchToLastTab() => SendInput("!^9")
	
	static ScrollUp() => SendInput("+^{Up}")
	
	static ScrollDown() => SendInput("+^{Down}")
	
	static ScrollPageUp() => SendInput("+^{PgUp}")
	
	static ScrollPageDown() => SendInput("+^{PgDn}")
	
}