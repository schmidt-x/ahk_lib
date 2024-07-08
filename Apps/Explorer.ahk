#Include <System\Paths>
#Include <Common\Helpers>
#Include <Misc\CommandRunner>

class Explorer {
	static _processName     := "explorer.exe"
	static _winProcessName  := "ahk_exe " this._processName
	static _fullProcessName := "C:\Windows\" this._processName
	
	static ProcessName => this._processName
	static IsActive => WinActive(this._winProcessName)
	
	static __New() {
		CommandRunner.AddCommands("exp", this.Open.Bind(this))
	}
	
	static Open(&folder, _, &output) {
		if StrIsEmptyOrWhiteSpace(folder) {
			SendInput("#e")
			return
		}
	
		if !Paths.TryGetFolderPath(folder, &path) {
			output := Format("Folder «{1}» not found", folder)
			return
		}
		
		Run(Format('"{1}" "{2}"', this._fullProcessName, path))
	}
	
	
	; --- Shortcuts ---
	
	static FocusOnAddressBar() => SendInput("!d")
	
	static CloseTab() => SendInput("^w")
	
	static NextTab() => SendInput("^{tab}")
	
	static PreviousTab() => SendInput("^+{tab}")
	
	static NewTab() => SendInput("^t")
	
	static CreateFolder() => SendInput("+^n")
	
	static OpenContextMenu() => SendInput("+{F10}")
}