class Paths {
	
	static Desktop   := A_Desktop
	static User      := "C:\Users\" A_UserName
	static Study     := this.User "\OneDrive\Study"
	static Torrent   := "D:\Torrent"
	static Radeon    := "D:\Radeon ReLive\unknown"
	static ScriptDir := A_ScriptDir
	
	static Projects        := "D:\Projects"
	static ProjectsCSharp  := this.Projects "\CSharp"
	static ProjectsRust    := this.Projects "\Rust"
	static RustTestProject := this.ProjectsRust "\test_proj"
	
	static Qmk          := this.User "\qmk_firmware"
	static QmkKeyboards := this.Qmk "\keyboards"
	static QmkUsers     := this.Qmk "\users"
	static QmkKbI44     := this.QmkKeyboards "\ergohaven\imperial44"
	static QmkKbK02     := this.QmkKeyboards "\ergohaven\k02"
	static QmkUsersMe   := this.QmkUsers "\schmidt-x"
	
	static VsCodeUser := A_AppData "\Code\User"
	static AhkLib     := A_MyDocuments "\AutoHotkey\Lib"
	
	
	static _paths := Map()
	
	static __New() {
		this._paths.Set(
			"desk",        this.Desktop,
			"std",         this.Study,
			"torr",        this.Torrent,
			"radeon",      this.Radeon,
			"proj",        this.Projects,
			"proj/c#",     this.ProjectsCSharp,
			"proj/r",      this.ProjectsRust,
			"proj/r/test", this.RustTestProject,
			"qmk",         this.Qmk,
			"qmk/i44",     this.QmkKbI44,
			"qmk/k02",     this.QmkKbK02,
			"qmk/usr",     this.QmkUsers,
			"qmk/usr/me",  this.QmkUsersMe,
			"ahk/i44",     this.ScriptDir,
			"ahk/lib",     this.AhkLib,
			"me",          this.User,
			"code/usr",    this.VsCodeUser,
		)
		
		this._paths.Default := ""
	}
	
	/**
	 * Tries to look up for the path by the specified `folderName`
	 * @param {String} folderName
	 * Folder's name (actually an alias, not the real name)
	 * @param {&String} path
	 * Path to the folder is assigned on `return` (if found)
	 * @returns {Boolean}
	 * `True` if path is found; `False` otherwise
	 */
	static TryGetFolderPath(folderName, &path) {
		path := this._paths[folderName]
		return path != ""
	}
	
	
	/**
	 * Tries to find the path of a selected tab in File Explorer
	 * @param {&String} path
	 * Path to the selected tab is assigned on `return` (if found)
	 * @param {Boolean} clsid
	 * Defines whether to return the path if it's CLSID path
	 * @returns {Boolean}
	 * `True` if path is found; `False` otherwise
	 */
	static TryGet(&path, clsid := false) {
		if !IsSet(path) {
			path := ""
		}
		
		explorerHwnd := WinActive("ahk_exe explorer.exe")
		if !explorerHwnd {
			return false
		}
	
		if explorerHwnd == DllCall("GetShellWindow") {
			path := this.Desktop
			return true
		}
		
		title := WinGetTitle(explorerHwnd)
		
		for window in ComObject("Shell.Application").Windows {
			if window.hwnd != explorerHwnd || window.Document.Folder.Self.Name != title {
				continue
			}
			
			p := window.Document.Folder.Self.Path
		
			if !clsid && SubStr(p, 1, 2) == "::" {
				return false
			}
		
			path := p
			return true
		}
		
		return false
	}
	
	/**
	 * Retrieves the path of the selected file/folder in File Explorer
	 * @param {&String} err
	 * Error message is assigned if no file/folder was selected
	 * @returns {String}
	 * A string containing the selected path. If no file/folder
	 * **was** selected, an empty string is returned
	 */
	static GetSelected(&err) {
		if !IsSet(err) {
			err := ""
		}
		
		prevClip := ClipboardAll()
		A_Clipboard := ""
		SendInput("+^c")
		
		if not ClipWait(0.5) {
			err := "timed out"
			path := ""
		} else {
			path := A_Clipboard
		}
		
		SetTimer(() => A_Clipboard := prevClip, -50)
		return path
	}
}