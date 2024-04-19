#Include <System\Paths>
#Include <Common\Helpers>
#Include <Misc\CommandRunner>

class QmkMSys {
	static _fullProcessName         := "C:\QMK_MSYS\conemu\ConEmu64.exe"
	static _fullProcessNameWithArgs := 'C:\QMK_MSYS\conemu\ConEmu64.exe -NoSingle -NoUpdate -icon "C:\QMK_MSYS\icon.ico" -title "QMK MSYS" -run "C:\QMK_MSYS\usr\bin\bash.exe" -l -i -cur_console:m:""'
	
	static __New() {
		CommandRunner.AddCommands("msys", this.Open.Bind(this))
	}
	
	static Open(&folder, &err) {
		if StrIsEmptyOrWhiteSpace(folder) {
			Run(this._fullProcessNameWithArgs, Paths.Qmk)
			return
		}
		
		if folder == "." {
			if !Paths.TryGet(&path) {
				err := "path not found"
				return
			} 
			
			Run(this._fullProcessNameWithArgs, path)
			return
		}
		
		if !Paths.TryGetFolderPath(folder, &p) {
			err := "folder not found"
			return
		}
		
		Run(this._fullProcessNameWithArgs, p)
	}
	
}