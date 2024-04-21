#Include <System\Paths>
#Include <Common\Helpers>
#Include <Misc\CommandRunner>

class VsCode {
	static _processName     := "Code.exe"
	static _winProcessName  := "ahk_exe " this._processName
	static _fullProcessName := Paths.LocalPrograms "\Microsoft VS Code\" this._processName
	
	static ProcessName => this._processName
	static IsActive => WinActive(this._winProcessName)
	
	static __New() {
		CommandRunner.AddCommands("code", this.Open.Bind(this))
	}
	
	
	; TODO: add docs and support different options (-p path, -f folder, etc)
	static Open(&args, hwnd, &err) {
		if StrIsEmptyOrWhiteSpace(args) {
			Run(this._fullProcessName)
			return
		}
		
		if args == "." {
			if !Paths.TryGet(&p, hwnd) {
				err := "Path not found"
				return
			}
			
			Run(Format('"{1}" "{2}"', this._fullProcessName, p))
			return
		}
		
		if !Paths.TryGetFolderPath(args, &p) {
			err := Format("Folder «{1}» not found", args)
			return
		}
		
		Run(Format('"{1}" "{2}"', this._fullProcessName, p))
	}
	
	static OpenSelected(&err) {
		path := Paths.GetSelected(&err)
		if err {
			return
		}
		
		Run(Format('"{1}" {2}', this._fullProcessName, path))
	}
	
	
	; --- Shortcuts ---
	
	static OpenSettings() => SendInput("^,")
	
	static Fold() => SendInput("+^[")
	
	static Unfold() => SendInput("+^]")
	
	static FoldAll() => SendInput("^k^0")
	
	static UnfoldAll() => SendInput("^k^j")
	
	static GotoBracket() => SendInput("+^\")
	
	static ParameterHints() => SendInput("+^{Space}")
	
	static CloseEditor() => SendInput("^{F4}")
	
	static GoToDefinition() => SendInput("{F12}")
	
	static GoToImplementation() => SendInput("^{F12}")
	
	; This shortcut does both: Quck documentation and Error description (if there's any)
	static ShowOrFocusHover() => SendInput("^k^i")
	
	static CommentLine() => SendInput("^/")
	
	static QuickFix() => SendInput("^.")
	
	static ToggleBreakpoint() => SendInput("{F9}") ; editor.debug.action.toggleBreakpoint
	
	static NextTab() => SendInput("^{PgDn}")
	
	static PreviousTab() => SendInput("^{PgUp}")
	
	static ReopenLastClosedTab() => SendInput("+^t")
	
	static NewFile() {
		; modified
		; name: explorer.newFile
		; default: none
		SendInput("!{Insert}")
	}
	
	static CopyCursorUp() => SendInput("^!{Up}") ; add cursor above
	
	static CopyCursorDown() => SendInput("^!{Down}") ; add cursor below
	
	static CopyLineDown() => SendInput("^d")
	
	; --- Tool Windows ---
	
	static ShowExplorer() => SendInput("^+e")
	
	static Debug() => SendInput("^+d")
	
	static Terminal() {
		; modified
		; name: «View: Toggle Terminal»
		; command: workbench.action.terminal.toggleTerminal
		; reason: focuses Qmk Msys instead
		; default: ^` (ctrl + `)
		SendInput("!1")
	}
	
	; --- ---
	
	static ExpandSelection() => SendInput("+!{Right}")
	
	static ShrinkSelection() => SendInput("+!{Left}")
	
	static MoveLineUp() => SendInput("!{Up}")
	
	static MoveLineDown() => SendInput("!{Down}")
	
	static GoForward() => SendInput("!{Right}")
	
	static GoBack() => SendInput("!{Left}")
	
	static NextMember() => SendInput("^{Down}")
	
	static PrevMember() => SendInput("^{Up}")
	
	static ToggleSourceControl() => SendInput("^+g")
	
	static InsertLineAbove() => SendInput("+^{Enter}")
	
	static InsertLineBelow() => SendInput("^{Enter}")
	
	static ToTabs() {
		; modified
		; default: None
		SendInput("+^4")
	}
	
	static ScrollTerminalUpByLine() => SendInput("!^{PgUp}")
	
	static ScrollTerminalDownByLine() => SendInput("!^{PgDn}")
	
	static ScrollTerminalUpByPage() => SendInput("+{PgUp}")
	
	static ScrollTerminalDownByPage() => SendInput("+{PgDn}")
}
