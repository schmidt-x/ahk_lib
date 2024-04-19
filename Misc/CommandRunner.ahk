#Include <System\Constants>
#Include <Common\Disposition>
#Include <Common\Helpers>

class CommandRunner {
	
	static _console := Gui()
	
	/**
	 * @type {Gui.Console}
	 */
	static _consoleEdit := unset
	
	static _commands  := Map()
	static _prevWinId := 0
	
	static _xGuiPadd := 0
	static _yGuiPadd := 0
	
	static _xDisposition := Disposition.Centered
	static _yDisposition := Disposition.Centered
	
	static _xPos := A_ScreenWidth / 2
	static _yPos := A_ScreenHeight / 100 * 20
	
	static _width  := 800
	static _height := 32
	
	static IsActive => WinActive(this._console.Hwnd)
	
	static __New() {
		this._InitCommands()
		this._InitConsole()
		
		OnMessage(WM_KEYDOWN, this._OnKEYDOWN.Bind(this))
	}
	
	
	static Open() {
		this._prevWinId := WinExist("A")
		this._console.Show()
	}
	
	static Move(
		x := this._xPos,
		y := this._yPos, 
		width := this._width, 
		height := this._height,
		xDisposition := this._xDisposition,
		yDisposition := this._yDisposition) 
	{
		this._console.Move(
			x - this._xGuiPadd + Disposition.GetShift(xDisposition, width),
			y - this._yGuiPadd + Disposition.GetShift(yDisposition, height),
			width + this._xGuiPadd * 2,
			height + this._yGuiPadd * 2)

		this._consoleEdit.Move(, , width, height)
		
		this._xPos := x
		this._yPos := y
		this._width := width
		this._height := height
		this._xDisposition := xDisposition
		this._yDisposition := yDisposition
	}
	
	; TODO: add docs
	static AddCommands(command, callback, params*) {
		if Mod(params.Length, 2) != 0 {
			throw ValueError("Error adding commands: invalid number of commands", params)
		}
		
		ThrowIfDuplicate(command)
		this._commands.Set(command, callback)
		
		i := 1
		while i < params.Length {
			ThrowIfDuplicate(params[i])
			
			this._commands.Set(params[i], params[i+1])
			i += 2
		}
		
		
		ThrowIfDuplicate(key) {
			if this._commands.Has(key) {
				throw ValueError(Format("Error adding commands: command «{1}» already exists", key))
			}
		}
	}
	
	
	; --- private ---

	; TODO: probably should redo using dynamic hotkeys
	static _OnKEYDOWN(wParam, lParam, msg, hwnd) {
		if not this.IsActive {
			return
		}
		
		switch wParam {
		case VK_ESCAPE: this._Close()
		case VK_RETURN: this._Execute()
		case VK_BACK:
			if not GetKeyState("LCtrl", "P") {
				return
			} 
			SendInput("{Blind}+{Left}{Del}")
		default: return
		}
		
		return 0
	}
	
	; TODO: add docs
	static _Close() {
		this._consoleEdit.Value := ""
		Sleep(1)
		this._console.Hide()
		
		; Sometimes, the focus might be stolen by FileExplorer. Or if we were
		; focused on the desktop before opening the terminal, focus will not 
		; be returned back to the desktop, if we have any window opened.
		; Hence, we explicitly activate the previous window (if any).
		if this._prevWinId && WinExist(this._prevWinId) {
			WinActivate(this._prevWinId)
			this._prevWinId := 0
		}
	}
	
	; TODO: add docs
	static _Execute() {
		input := this._consoleEdit.Value
		this._Close()
		
		if StrIsEmptyOrWhiteSpace(input) {
			this._DisplayError("Empty input")
			return
		}
		
		SplitInput(&input, &command, &args)
		
		func := this._commands.Get(command)
		if not func {
			this._DisplayError(Format("Command «{1}» not found", command))
			return
		}
		
		func(&args, &(err := ""))
		if err {
			this._DisplayError(Format('Error on processing command «{1}»: "{2}"', command, err))
		}
		
		SplitInput(&input, &command, &args) {
			; Divide it into just 2 parts and return the arguments (if any) as a single string,
			; allowing further functions to handle those arguments the way they need to.
			parts := StrSplit(input, A_Space, , 2)
			
			command := parts[1]
			args := parts.Length == 2 ? parts[2] : ""
		}
	}
	
	; TODO:
	static _DisplayError(err) {
		Display(err, 3000, 2)
	}
	
	static _InitCommands() {
		this._commands.Set("this", this._HandleCommand.Bind(this))
		this._commands.Default := ""
	}
	
	; TODO:
	static _HandleCommand(&args, &err) {
		MsgBox("TODO")
	}
	
	static _InitConsole() {
		this._console.Opt("+AlwaysOnTop -Caption +ToolWindow")
		this._console.BackColor := "000000"
		WinSetTransColor(this._console.BackColor . " 250", this._console.Hwnd)
		this._console.SetFont("s18 c0xbdbdbd", "JetBrains Mono Regular")
		
		editOpts := Format("Background171717 -E0x200 Center w{1} h{2}", this._width, this._height)
		this._consoleEdit := this._console.AddEdit(editOpts)
		
		this._console.Show("Hide")
		this._console.GetPos(, , &actualWidth, &actualHeight)
		
		this._xGuiPadd := (actualWidth - this._width) / 2
		this._yGuiPadd := (actualHeight - this._height) / 2
		
		this._console.Move(
			this._xPos - this._xGuiPadd + Disposition.GetShift(this._xDisposition, this._width),
			this._yPos - this._yGuiPadd + Disposition.GetShift(this._yDisposition, this._height)
		)
	}
}