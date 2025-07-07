#Include <Collections\LinkedList>
#Include <Common\Disposition>
#Include <Common\Helpers>

class CommandRunner {
	
	static _console := Gui()
	
	static _commands := Map()
	
	/**
	 * @type {Gui.Control}
	 */
	static _consoleEdit := unset
	
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

	static _OnKEYDOWN(wParam, lParam, msg, hwnd) {
		isEdit := hwnd == this._consoleEdit.Hwnd
		
		if !isEdit && hwnd != this._outputEdit.Hwnd {
			return
		}
		
		VK_BACK   := 0x08
		VK_RETURN := 0x0D
		VK_ESCAPE := 0x1B
		VK_UP     := 0x26
		VK_DOWN   := 0x28
		
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
		case VK_UP:
			if !isEdit {
				return
			}
			this.History.Up(this._consoleEdit)
		case VK_DOWN:
			if !isEdit {
				return
			}
			this.History.Down(this._consoleEdit)
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
				this.History.Reset()
			}
			
			this._console.Hide()
		}
	}
	
	static _OnINPUTLANGCHANGEREQUEST(wParam, lParam, msg, hwnd) {
		if hwnd == this._console.Hwnd {
			return DllCall("user32\DefWindowProc", "Ptr", hwnd, "UInt", msg, "Ptr", wParam, "Ptr", lParam)
		}
	}
	
	; TODO: add docs
	static _Close() {
		this._ClearAndSetInvisible()
		
		if this._prevWinHwnd && WinExist(this._prevWinHwnd) {
			WinActivate(this._prevWinHwnd)
			this._prevWinHwnd := 0
		}
		
		this._console.Hide()
		this.History.Reset()
	}
	
	; TODO: add docs
	static _Execute() {
		input := Trim(this._consoleEdit.Value)
		this._consoleEdit.Value := ""
		
		if not input {
			this._ShowOutput("Empty input.")
			return
		}
		
		this.History.Add(input)
		SplitInput(input, &command, &rawArgs)
		
		if not func := this._commands.Get(command) {
			this._ShowOutput(Format("Command «{}» not found.", command))
			return
		}
		
		if not args := ParseArgs(rawArgs, &errorMessage) {
			this._ShowOutput(errorMessage)
			return
		}
		
		this._isRunning := true
		try {
			func(args, this._prevWinHwnd, &output)
		} finally {
			this._isRunning := false
		}
		
		if IsSet(output) {
			this._ShowOutput(output)
		} else if this._outputEdit.Visible {
			this._HideOutput()
		}
		
		return
		
		static SplitInput(input, &command, &rawArgs) {
			parts := StrSplit(input, A_Space, , 2)
			command := parts[1]
			rawArgs := parts.Length == 2 ? parts[2] : ""
		}
		
		static ParseArgs(args, &errorMessage) {
			if not len := StrLen(args) {
				return CommandRunner.ArgsIter([])
			}
			
			normalizedArgs := []
			
			isSQuoted := isDQuoted := false
			start := 1, i := 0

			while ++i <= len {
				switch SubStr(args, i, 1) {
				case '"':
					if not isDQuoted {
						if isSQuoted
							continue
						
						if start < i {
							AddArgument(normalizedArgs, SubStr(args, start, i-start))
						}
						
						isDQuoted := true
						start := i+1
						continue
					}
					
					isDQuoted := false
					
					if start == i {
						start++
						continue
					}
				
				case "'":
					if not isSQuoted {
						if isDQuoted
							continue
						
						if start < i {
							AddArgument(normalizedArgs, SubStr(args, start, i-start))
						}
						
						isSQuoted := true
						start := i+1
						continue
					}
					
					isSQuoted := false
					
					if start == i {
						start++
						continue
					}
					
				case A_Space:
					if isSQuoted || isDQuoted {
						if start == i { ; trim the beginning
							start++
						}
						continue
					}
					
					if start == i { ; trim the beginning
						start++
						continue
					}
				
				default: continue
				}
				
				AddArgument(normalizedArgs, RTrim(SubStr(args, start, i-start)))
				start := i+1
			}

			if isSQuoted || isDQuoted {
				errorMessage := "Missing closing quote."
				return ""
			}

			if start < i {
				AddArgument(normalizedArgs, SubStr(args, start))
			}
			
			return CommandRunner.ArgsIter(normalizedArgs)
			
			static AddArgument(list, arg) {
				if SubStr(arg, 1, 2) == "--" {
					HandleLong(list, arg)
				} else if SubStr(arg, 1, 1) == "-" {
					HandleShort(list, arg)
				} else {
					list.Push(Argument(arg))
				}
			}
			
			static HandleLong(list, arg) {
				if i := InStr(arg, "=") {
					AddCombinedKeyValue(arg, i, list)
				} else {
					list.Push(OptArgument(arg))
				}
			}
			
			static HandleShort(list, arg) {
				if i := InStr(arg, "=") {
					AddCombinedKeyValue(arg, i, list)
					return
				}
				if (len := StrLen(arg)) < 3 {
					list.Push(OptArgument(arg))
					return
				}
				i := 1
				while ++i <= len {
					list.Push(OptArgument("-" SubStr(arg, i, 1)))
				}
			}
			
			static AddCombinedKeyValue(list, arg, i) => list.Push(OptArgument(SubStr(arg, 1, i-1)), Argument(SubStr(arg, i+1)))
			
			static OptArgument(value) => CommandRunner.Argument(value, true)
			
			static Argument(value) => CommandRunner.Argument(value, false)
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
	
	/**
	 * @param {CommandRunner.ArgsIter} args
	 */
	static _HandleCommand(args, _, &output) {
		if not args.Next(&arg) {
			output := GetUsage()
			return
		}
		
		if arg.IsOption {
			switch option := arg.Value {
				case "-h", "--help":
					output := GetUsage()
				default:
					output := Format("Unknown option '{}'.", option)
			}
			return
		}
		
		switch command := arg.Value {
			case "ch":
				this.History.ClearHistory()
				output := "History cleared."
			
			default:
				output := Format("Unknown command '{}'.", command)
		}
		
		
		GetUsage() => "
		(
			Usage: this [OPTIONS] COMMAND
			
			Options:
			--help, -h:  Get usage
			
			Commands:
			ch:  Clear history
		)"
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
			this._height + this._outputEditPaddY, this._outputEditHeight)
			
		this._outputEdit := this._console.AddEdit(editOpts)
		this._outputEdit.SetFont("s14 c0xbdbdbd")
		
		this._console.Show("Hide")
		
		this._console.Move(
			this._xPos + Disposition.GetShift(this._xDisposition, this._width),
			this._yPos + Disposition.GetShift(this._yDisposition, this._height)
		)
	}
	
	class ArgsIter {
		_args  := unset
		_index := 0
		
		__New(args) {
			if !(args is Array) {
				throw Error(Format("Invalid type for 'args'. Expected: 'Array'; got: '{}'.", Type(args)))
			}
			this._args := args
		}
		
		Next(&arg) {
			if this._index >= this._args.Length {
				arg := ""
				return false
			}
			
			arg := this._args[++this._index]
			return true
		}
		
		IsEmpty => this._args.Length == 0
	}
	
	class Argument {
		Value    := unset
		IsOption := unset
		
		__New(val, isOption) => (this.Value := val, this.IsOption := isOption)
	}
	
	class History {
		static _commands    := LinkedList()
		static _commandsMap := Map()
		
		/** 
		 * @type {LinkedListNode}
		 */
		static _current := ""
		static _maxSize := 32
		static _tempCommand := ""
		
		static __New() {
			this._commandsMap.Default := ""
		}
		
		/**
		 * @param {Gui.Edit} edit
		 */
		static Up(edit) {
			if this._commands.Size == 0 {
				return
			}
			
			if this._current == "" {
				SetLastAndDisplay(edit)
				return
			}
			
			if this.IsContentUpdated(edit) {
				this.Reset()
				SetLastAndDisplay(edit)
				return
			}
			
			if (prev := this._current.Prev) == "" {
				return
			}
			
			this.Display(edit, prev.Value)
			this._current := prev
			
			
			SetLastAndDisplay(edit) {
				this._current := this._commands.Last
				this._tempCommand := edit.Value ; don't trim
				this.Display(edit, this._current.Value)
			}
		}
		
		/**
		 * @param {Gui.Edit} edit 
		 */
		static Down(edit) {
			if this._commands.Size == 0 || this._current == "" {
				return
			} 
			
			if (next := this._current.Next) == "" {
				if not this.IsContentUpdated(edit) {
					this.Display(edit, this._tempCommand)
				}
				this.Reset()
				return
			}
			
			if this.IsContentUpdated(edit) {
				this.Reset()
				return
			}
			
			this.Display(edit, next.Value)
			this._current := next
		}
		
		static Add(command) {
			this.Reset()
			
			if node := this._commandsMap[command] {
				this._commands.MoveToEnd(node)
				return
			}
			
			if this._commands.Size == this._maxSize {
				this._commands.RemoveFirst(&deletedCommand)
				this._commandsMap.Delete(deletedCommand)
			}
			
			node := LinkedListNode(command)
			this._commandsMap.Set(node.Value, node)
			this._commands.AddLast(node)
		}
		
		static Reset() {
			this._current := ""
			this._tempCommand := ""
		}
		
		static ClearHistory() {
			this._commandsMap.Clear()
			this._commands.Clear()
		}
		
		static IsContentUpdated(edit) => this._current.Value != Trim(edit.Value)
		
		/**
		 * @param {Gui.Edit} edit
		 */
		static Display(edit, value) {
			edit.Value := value	
			PostMessage(0x00B1, len := StrLen(value), len, edit.Hwnd) ; EM_SETSEL
		}
	}
}