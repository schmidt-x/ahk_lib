#Include <System\Paths>
#Include <Common\Helpers>
#Include <Misc\CommandRunner>

class Rider {
	static _processName     := "rider64.exe"
	static _winProcessName  := "ahk_exe " this._processName
	static _fullProcessName := Paths.LocalPrograms "\Rider\bin\ " this._processName
	
	static _projects := Map()
	
	static ProcessName => this._processName
	static IsActive => WinActive(this._winProcessName)
	
	static __New() {
		this._InitProjects()
		CommandRunner.AddCommands("rider", this.Open.Bind(this))
	}
	
	static Open(&projName, _, &err) {
		if StrIsEmptyOrWhiteSpace(projName) {
			; It doesn't seem to have a way to open the Welcome page,
			; if at least one solution is already opened
			if !WinExist(this._winProcessName) {
				Run(this._fullProcessName)
			}
			return
		}
		
		proj := this._projects.Get(projName)
		
		if not proj {
			err := Format("Project «{1}» is not found", projName)
			return
		} 
		
		Run(Format('"{1}" "{2}"', this._fullProcessName, proj))
	}
	
	
	static _InitProjects() {
		this._projects.CaseSense := false
		
		this._projects.Set(
			"file",    Paths.ProjectsCSharp . "\FileStorageApi\FileStorageApi.sln",
			"console", Paths.ProjectsCSharp . "\TestConsole\TestConsole.sln",
			"web",     Paths.ProjectsCSharp . "\TestWeb\TestWeb.sln",
			"web2",    Paths.ProjectsCSharp . "\TestWeb2\TestWeb2.sln",
			"tgbot",   Paths.ProjectsCSharp . "\TestTgBot\TestTgBot.sln"
		)
		
		this._projects.Default := ""
	}
	
	
	; --- Shortcuts ---
	
	static OpenSettings() => SendInput("^,")
	
	static Collapse() => SendInput("+^[")
	
	static Expand() => SendInput("+^]")
	
	static CollapseAll() => SendInput("^k^0")
	
	static ExpandAll() => SendInput("^k^j")
	
	static MoveCaretToMatchingBrace() => SendInput("+^\")
	
	static ParameterInfo() => SendInput("+^{Space}")
	
	static CloseTab() => SendInput("^w")
	
	; Same shortcut for «Other/Refresh»
	; Database Explorer/Refresh is also derived 
	static ErrorDescription() => SendInput("^{F1}")
	
	static GoToDeclarationOrUsages() => SendInput("{F12}")
	
	static GoToImplementation() => SendInput("^{F12}")
	
	static QuickDocumentation() => SendInput("^k^i")
	
	static CommentLine() => SendInput("^/")
	
	static ContextActions() => SendInput("^.")
	
	static ToggleBreakpoint() => SendInput("{F9}")
	
	static NextTab() => SendInput("^{PgDn}")
	
	static PreviousTab() => SendInput("^{PgUp}")
	
	static ReopenLastClosedTab() => SendInput("+^t")
	
	static NewFile() {
		SendInput("{LAlt Down}{Ins}")
		SendInput("{Blind}{LAlt Up}")
	}
	
	static ExtendSelection() => SendInput("+!{Right}")
	
	static ShrinkSelection() {
		; modified
		; name:
		; default: +^w
		SendInput("+!{Left}")
	}
	
	static CloneCaretAboveWithVirtualSpace() {
		; modified
		; replaced instead: CloneCaretAbove
		; name: 
		; default: none
		SendInput("!^{Up}")
	}
	
	static CloneCaretBelowWithVirtualSpace() {
		; modified
		; replaced instead: CloneCaretBelow
		; name: 
		; default: none
		SendInput("!^{Down}")
	}
	
	static DuplicateLineOrSelection() => SendInput("^d")
	
	static StartNewLine() => SendInput("^{Enter}")
	
	static StartNewLineBeforeCurrent() => SendInput("+^{Enter}")
	
	; --- Tool Windows ---
	
	static Explorer() => SendInput("+^e")
	
	static Terminal() => SendInput("^``")
	
	static Debug() => SendInput("+^d")
	
	static Database() => SendInput("!1")
	
	static UnitTests() => SendInput("+!8")
	
	static Commit() => SendInput("!0")
	
	static Structure() => SendInput("!7")
	
	static ILViewer() => SendInput("!4")
	
	; --- ---
	
	static ToTabs() => SendInput("^{Numpad0}")
	
	static BuildSolution() => SendInput("^{Numpad1}")
	
	static ToggleToolbar() => SendInput("^{Numpad2}")
	
	static NugetRestore() => SendInput("^{Numpad3}")
	
	static ToggleInlayHints() => SendInput("^{Numpad4}")
	
	static MoveLineUp() => SendInput("{Blind+#^}!{Up}")
	
	static MoveLineDown() => SendInput("{Blind+#^}!{Down}")
	
	static Forward() => SendInput("{Blind+#^}!{Right}")
	
	static Back() => SendInput("{Blind+#^}!{Left}")
	
	static NextMethod() => SendInput("^{Down}")
	
	static PrevMethod() => SendInput("^{Up}")
	
	static ScrollTerminalUp() => SendInput("^{Up}")
	
	static ScrollTerminalDown() => SendInput("^{Down}")
	
	; --- Debugger ---
	
	static RerunDebugger() => SendInput("+^{F5}") ; Other/Touchbar/Debugger/Rerun
	
	static StopDebugger() => SendInput("+{F5}") ; Other/Touchbar/Debugger/Stop
	
	static StepOut() => SendInput("+{F11}") ; Main Menu/Run/Debugger Actions/Step Out
	
	static StepOver() => SendInput("{F10}") ; Main Menu/Run/Debugger Actions/Step Over
	
	static StepInto() => SendInput("{F11}") ; Main Menu/Run/Debugger Actions/Step Into
	
	; --- ---
}