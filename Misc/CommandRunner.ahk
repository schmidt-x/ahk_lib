#Include <Common\Disposition>
#Include <Common\Helpers>

class CommandRunner {
	
	static _console := Gui()
	
	static _commands := Map()
	
	/**
	 * @type {Gui.Control}
	 */
	static _consoleEdit     := unset
	
	static _xPos := A_ScreenWidth / 2
	static _yPos := A_ScreenHeight / 100 * 20
	
	static _xDisposition := Disposition.Centered
	static _yDisposition := Disposition.Centered
	
	static _width  := 800
	static _height := 32
	
	/**
	 * @type {Gui.Control}
	 */
	static _outputEdit       := unset
	static _outputEditHeight := 350
	static _outputEditPaddY  := 15
	
	static _escaped := false
	static _prevWinHwnd := 0
	static _isRunning := false
	
	
	static IsActive => WinActive(this._console.Hwnd)
	
	static __New() {
		this._InitCommands()
		this._InitConsole()
		
		WM_ACTIVATE               := 0x0006
		WM_INPUTLANGCHANGEREQUEST := 0x0050
		WM_KEYDOWN                := 0x0100
		
		OnMessage(WM_KEYDOWN, this._OnKEYDOWN.Bind(this))
		OnMessage(WM_ACTIVATE, this._OnACTIVATE.Bind(this))
		OnMessage(WM_INPUTLANGCHANGEREQUEST, this._OnINPUTLANGCHANGEREQUEST.Bind(this))
	}
	
	
	static Open() {
		this._prevWinHwnd := WinExist("A")
		this._consoleEdit.Visible := true
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
			height + this._outputEditHeight + this._outputEditPaddY)

		this._consoleEdit.Move(, , width, height)
		this._outputEdit.Move(, height + this._outputEditPaddY, width)
		
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
		isEdit   := hwnd == this._consoleEdit.Hwnd
		isOutput := hwnd == this._outputEdit.Hwnd
		
		if !isEdit && !isOutput {
			return
		}
		
		VK_BACK   := 0x08
		VK_RETURN := 0x0D
		VK_ESCAPE := 0x1B
		
		switch wParam {
		case VK_ESCAPE:
			this._escaped := true
			this._Close()
		case VK_RETURN:
			if !isEdit {
				return
			}
			this._Execute()
		case VK_BACK:
			if !IsEdit || !GetKeyState("LCtrl", "P") {
				return
			} 
			SendInput("{Blind}+{Left}{Del}")
		default: return
		}
		
		return 0
	}
	
	static _OnACTIVATE(wParam, lParam, msg, hwnd) {
		static WA_INACTIVE := 0
		
		if hwnd != this._console.Hwnd || wParam != WA_INACTIVE {
			return
		}
		
		if this._escaped {
			; If a focus was lost by pressing Escape, the console is already cleared and hidden.
			this._escaped := false
		} else {
			; Otherwise, just minimize the console without clearing.
			
			; Without clearing - unless an executing command has stolen the focus.
			if this._isRunning {
				this._ClearAndSetInvisible()
			}
			
			this._console.Hide()
		}
	}
	
	static _OnINPUTLANGCHANGEREQUEST(wParam, lParam, msg, hwnd) {
		static INPUTLANGCHANGE_SYSCHARSET := 0x01
		static INPUTLANGCHANGE_FORWARD    := 0x02
		static INPUTLANGCHANGE_BACKWARD   := 0x04
		static HKL_PREV := 0
		static HKL_NEXT := 1
		
		if hwnd != this._console.Hwnd {
			return
		}
		
		switch wParam {
			case INPUTLANGCHANGE_BACKWARD:   hkl := HKL_PREV
			case INPUTLANGCHANGE_FORWARD:    hkl := HKL_NEXT
			case INPUTLANGCHANGE_SYSCHARSET: hkl := lParam
			default: return 0
		}
		
		DllCall("ActivateKeyboardLayout", "Ptr", hkl, "UInt", 0)
	}
	
	; TODO: add docs
	static _Close() {
		this._ClearAndSetInvisible()
		
		if this._prevWinHwnd && WinExist(this._prevWinHwnd) {
			WinActivate(this._prevWinHwnd)
			this._prevWinHwnd := 0
		}
		
		this._console.Hide()
	}
	
	; TODO: add docs
	static _Execute() {
		input := this._consoleEdit.Value
		this._consoleEdit.Value := ""
		
		if StrIsEmptyOrWhiteSpace(input) {
			this._ShowOutput("Empty input.")
			return
		}
		
		SplitInput(&input, &command, &args)
		
		func := this._commands.Get(command)
		if not func {
			this._ShowOutput(Format("Command «{}» not found.", command))
			return
		}
		
		this._isRunning := true
		try {
			func(&args, this._prevWinHwnd, &output)
		} finally {
			this._isRunning := false
		}
		
		if IsSet(output) {
			this._ShowOutput(output)
		} else if this._outputEdit.Visible {
			this._HideOutput()
		}
		
		
		SplitInput(&input, &command, &args) {
			; Divide it into just 2 parts and return the arguments (if any) as a single string,
			; allowing further functions to handle those arguments the way they need to.
			parts := StrSplit(input, A_Space, , 2)
			
			command := parts[1]
			args := parts.Length == 2 ? parts[2] : ""
		}
	}
	
	static _ClearAndSetInvisible() {
		this._consoleEdit.Value := ""
		this._consoleEdit.Visible := false
		
		if this._outputEdit.Visible {
			this._outputEdit.Value := ""
			this._outputEdit.Visible := false
		}
	}
	
	static _ShowOutput(output) {
		this._outputEdit.Visible := true
		this._outputEdit.Value := output
		ControlShow(this._outputEdit.Hwnd)
	}
	
	static _HideOutput() {
		this._outputEdit.Value := ""
		this._outputEdit.Visible := false
		ControlHide(this._outputEdit.Hwnd)
	}
	
	static _InitCommands() {
		this._commands.CaseSense := false
		this._commands.Set("this", this._HandleCommand.Bind(this))
		this._commands.Default := ""
	}
	
	static _HandleCommand(&args, _, &output) {
		output := "TODO"
	}
	
	static _InitConsole() {
		this._console.Opt("-Caption ToolWindow AlwaysOnTop")
		
		this._console.BackColor := "000000"
		WinSetTransColor(this._console.BackColor . " 250", this._console.Hwnd)
		this._console.MarginX := this._console.MarginY := 0
		
		this._console.SetFont("s18 c0xbdbdbd", "JetBrains Mono Regular")
		
		editOpts := Format("Background171717 -E0x200 Center w{1} h{2}", this._width, this._height)
		this._consoleEdit := this._console.AddEdit(editOpts)
		
		editOpts := Format(
			"Background171717 -E0x200 xP yP+{1} wP h{2} -VScroll ReadOnly Hidden", 
			this._height + this._outputEditPaddY,
			this._outputEditHeight)
			
		this._outputEdit := this._console.AddEdit(editOpts)
		
		this._console.Show("Hide")
		
		this._console.Move(
			this._xPos + Disposition.GetShift(this._xDisposition, this._width),
			this._yPos + Disposition.GetShift(this._yDisposition, this._height)
		)
	}
}