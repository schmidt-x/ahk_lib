#Include <WinApi\Constants>
#Include <Common\Disposition>
#Include <Common\Helpers>

class CommandRunner {
	
	static _console := Gui()
	
	/**
	 * @type {Gui.Control}
	 */
	static _consoleEdit     := unset
	static _consoleEditHwnd := unset
	
	/**
	 * @type {Gui.Control}
	 */
	static _errorEdit       := unset
	static _errorEditHwnd   := unset
	static _errorEditHeight := 350
	static _errorEditPaddY  := 15
	
	static _commands := Map()
	static _prevWinHwnd := 0
	
	static _xDisposition := Disposition.Centered
	static _yDisposition := Disposition.Centered
	
	static _xPos := A_ScreenWidth / 2
	static _yPos := A_ScreenHeight / 100 * 20
	
	static _width  := 800
	static _height := 32
	
	static _escaped := false
	
	
	static IsActive => WinActive(this._console.Hwnd)
	
	static __New() {
		this._InitCommands()
		this._InitConsole()
		
		OnMessage(WM_KEYDOWN, this._OnKEYDOWN.Bind(this))
		OnMessage(WM_ACTIVATE, this._OnACTIVATE.Bind(this))
	}
	
	
	static Open() {
		this._prevWinHwnd := WinExist("A")
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
			x + Disposition.GetShift(xDisposition, width),
			y + Disposition.GetShift(yDisposition, height),
			width,
			height + this._errorEditHeight + this._errorEditPaddY)

		this._consoleEdit.Move(, , width, height)
		this._errorEdit.Move(, height + this._errorEditPaddY, width)
		
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
		if hwnd != this._consoleEditHwnd {
			return
		}
		
		switch wParam {
		case VK_ESCAPE:
			this._escaped := true
			this._Close()
		case VK_RETURN:
			this._Execute()
		case VK_BACK:
			if not GetKeyState("LCtrl", "P") {
				return
			} 
			SendInput("{Blind}+{Left}{Del}")
		default: return
		}
		
		return 0
	}
	
	static _OnACTIVATE(wParam, lParam, msg, hwnd) {
		if wParam != WA_INACTIVE || hwnd != this._console.Hwnd {
			return
		}
		
		if not this._escaped {
			; If we just lost the focus of a console (didn't press Esc),
			; just minimize it without clearing.
			this._console.Hide()
		} else {
			this._escaped := false
		}
	}
	
	; TODO: add docs
	static _Close() {
		this._consoleEdit.Value := ""
		
		if this._errorEdit.Visible {
			this._errorEdit.Value := ""
			this._errorEdit.Visible := false
		}
		
		this._console.Hide()
		
		; Sometimes, the focus might be stolen by FileExplorer. Or if we were
		; focused on the desktop before opening the terminal, focus will not 
		; be returned back to the desktop, if we have any window opened.
		; Hence, we explicitly activate the previous window (if any).
		if this._prevWinHwnd && WinExist(this._prevWinHwnd) {
			WinActivate(this._prevWinHwnd)
			this._prevWinHwnd := 0
		}
	}
	
	; TODO: add docs
	static _Execute() {
		input := this._consoleEdit.Value
		
		if StrIsEmptyOrWhiteSpace(input) {
			this._DisplayError("Empty input")
			return
		}
		
		SplitInput(&input, &command, &args)
		
		func := this._commands.Get(command)
		if not func {
			this._DisplayErrorF("Command «{1}» not found", command)
			return
		}
		
		func(&args, this._prevWinHwnd, &(err := ""))
		if err {
			this._DisplayError(err)
			return
		}
		
		this._consoleEdit.Value := ""
		
		if (this._errorEdit.Visible) {
			this._HideError()
		}
		
		
		SplitInput(&input, &command, &args) {
			; Divide it into just 2 parts and return the arguments (if any) as a single string,
			; allowing further functions to handle those arguments the way they need to.
			parts := StrSplit(input, A_Space, , 2)
			
			command := parts[1]
			args := parts.Length == 2 ? parts[2] : ""
		}
	}
	
	static _DisplayErrorF(pattern, params*) {
		this._errorEdit.Visible := true
		this._errorEdit.Value := Format(pattern, params*)
		ControlShow(this._errorEditHwnd)
	}
	
	static _DisplayError(err) {
		this._errorEdit.Visible := true
		this._errorEdit.Value := err
		ControlShow(this._errorEditHwnd)
	}
	
	static _HideError() {
		this._errorEdit.Value := ""
		this._errorEdit.Visible := false
		ControlHide(this._errorEditHwnd)
	}
	
	static _InitCommands() {
		this._commands.CaseSense := false
		this._commands.Set("this", this._HandleCommand.Bind(this))
		this._commands.Default := ""
	}
	
	static _HandleCommand(&args, _, &err) {
		err := "TODO"
	}
	
	static _InitConsole() {
		this._console.Opt("-Caption ToolWindow AlwaysOnTop")
		
		this._console.BackColor := "000000"
		WinSetTransColor(this._console.BackColor . " 250", this._console.Hwnd)
		this._console.MarginX := 0
		this._console.MarginY := 0
		
		this._console.SetFont("s18 c0xbdbdbd", "JetBrains Mono Regular")
		
		editOpts := Format("Background171717 -E0x200 Center w{1} h{2}", this._width, this._height)
		this._consoleEdit := this._console.AddEdit(editOpts)
		this._consoleEditHwnd := ControlGetHwnd(this._consoleEdit)
		
		editOpts := Format(
			"Background171717 -E0x200 xP yP+{1} wP h{2} -VScroll ReadOnly Hidden", 
			this._height + this._errorEditPaddY,
			this._errorEditHeight)
			
		this._errorEdit := this._console.AddEdit(editOpts)
		this._errorEditHwnd := ControlGetHwnd(this._errorEdit)
		
		this._console.Show("Hide")
		
		this._console.Move(
			this._xPos + Disposition.GetShift(this._xDisposition, this._width),
			this._yPos + Disposition.GetShift(this._yDisposition, this._height)
		)
	}
}