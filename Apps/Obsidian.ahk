#Include <System\Paths>

class Obsidian {
	static _processName     := "Obsidian.exe"
	static _winProcessName  := "ahk_exe " this._processName
	static _fullProcessName := Paths.ProgramFiles "\Obsidian\" this._processName
	
	static ProcessName => this._processName
	static IsActive => WinActive(this._winProcessName)
	
	
	; --- Shortcuts ---
	
	static OpenSettings() => SendInput("^,")
	
	static FoldMore() => SendInput("+^[")
	
	static FoldLess() => SendInput("+^]")
	
	static FoldAllHeadingsAndLists() => SendInput("+!^[")
	
	static UnfoldAllHeadingsAndLists() => SendInput("+!^]")
	
	static CloseCurrentTab() => SendInput("^w")
	
	static UndoCloseTab() => SendInput("+^t")
	
	static ToggleReadingView() => SendInput("^e")
	
	static NextTab() => SendInput("^{PgDn}")
	
	static PreviousTab() => SendInput("^{PgUp}")
	
	static ExplorerFocus() => SendInput("!1")
	
	static ShowOutline() => SendInput("!3") ; show outline (focus on the right side bar)
	
	; --- Text paste ---
	
	static PasteBoldLink() => SendInput("[****]({left 4}")
	
	static PasteSpoilerBlock() => SendInput("``````spoiler-block`n")
	
	; --- 
	
	static FindPrevious() => SendInput("+{F3}")
	
	static FindNext() => SendInput("{F3}")
	
	static NavigateBack() => SendInput("!{Left}")
	
	static NavigateForward() => SendInput("!{Right}")
	
	static MoveLineUp() => SendInput("+!{Up}")
	
	static MoveLineDown() => SendInput("+!{Down}")
}