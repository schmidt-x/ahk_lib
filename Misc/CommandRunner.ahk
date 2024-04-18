#Include <System\Constants>
#Include <Common\Helpers>

class CommandRunner {
	
	static _console := Gui()
	
	/**
	 * @type {Gui.Console}
	 */
	static _consoleEdit := unset
	
	static _commands  := Map()
	static _prevWinId := 0
	
	static _guiPaddX := 0
	static _guiPaddY := 0
	
	static _xCenterRelative := true
	static _yCenterRelative := true
	static _posX := A_ScreenWidth / 2
	static _posY := A_ScreenHeight / 100 * 30
	static _width  := 800
	static _height := 32
	
	static IsActive => WinActive(this._console.Hwnd)
	
	static __New() {
		this._InitCommands()
		this._InitTerminal()
		
		OnMessage(WM_KEYDOWN, this._OnKEYDOWN.Bind(this))
	}
	
	
	static Open() {
		this._prevWinId := WinExist("A")
		this._console.Show()
	}
	
	; TODO: add docs
	static Move(
		x := this._posX,
		y := this._posY, 
		width := this._width, 
		height := this._height,
		xCenterRelative := this._xCenterRelative,
		yCenterRelative := this._yCenterRelative) 
	{
		this._console.Move(
			x - this._guiPaddX - (xCenterRelative ? width / 2 : 0),
			y - this._guiPaddY - (yCenterRelative ? height / 2 : 0), 
			width + this._guiPaddX * 2,
			height + this._guiPaddY * 2)

		this._consoleEdit.Move(, , width, height)
		
		this._posX := x
		this._posY := y
		this._width := width
		this._height := height
		this._xCenterRelative := xCenterRelative
		this._yCenterRelative := yCenterRelative
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

	; TODO: probably shoud redo using dynamic hotkeys
	static _OnKEYDOWN(wParam, lParam, msg, hwnd) {
		if not this.IsActive {
			return
		}
		
		switch wParam {
		case VK_ESCAPE: this._Close()
		case VK_RETURN: this._Execute()
		case VK_BACK, GetKeyState("LCtrl", "P"): SendInput("{Blind}+{Left}{Del}")
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
	
	static _InitTerminal() {
		this._console.Opt("+AlwaysOnTop -Caption +ToolWindow")
		this._console.BackColor := "000000"
		WinSetTransColor(this._console.BackColor . " 250", this._console.Hwnd)
		this._console.SetFont("s18 c0xbdbdbd", "JetBrains Mono Regular")
		
		editOpts := Format("Background171717 -E0x255 Center w{1} h{2}", this._width, this._height)
		this._consoleEdit := this._console.AddEdit(editOpts)
		
		this._console.Show("Hide")
		this._console.GetPos(, , &actualWidth, &actualHeight)
		
		this._guiPaddX := (actualWidth - this._width) / 2
		this._guiPaddY := (actualHeight - this._height) / 2
		
		this._console.Move(
			this._posX - this._guiPaddX - (this._xCenterRelative ? this._width / 2 : 0),
			this._posY - this._guiPaddY - (this._yCenterRelative ? this._height / 2 : 0)
		)
	}
}