#Include <Misc\CommandRunner>
#Include <Common\Disposition>

class ModeType {
	static Normal => 1
	static Insert => 2
	static Symbol => 4
	static Mouse  => 8
	static Select => 16
}

class Mode {
	static _current := 0
	static _display := Gui()
	
	/**
	 * @type {Gui.Control}
	 */
	static _displayText := unset
	
	static _enabled := false
	
	static _xDisposition := Disposition.None
	static _yDisposition := Disposition.Inverted
	
	static _xPos := 0
	static _yPos := A_ScreenHeight - 50
	
	static _width  := 90
	static _height := 27
	
	static _xGuiPadd := 0
	static _yGuiPadd := 0
	
	
	static IsNormal  => this._current == ModeType.Normal
	static IsInsert  => this._current == ModeType.Insert
	static IsMouse   => this._current == ModeType.Mouse
	static IsSelect  => this._current == ModeType.Select
	static IsNSymbol => this._current == (ModeType.Normal | ModeType.Symbol)
	static IsISymbol => this._current == (ModeType.Insert | ModeType.Symbol)
	static IsSSymbol => this._current == (ModeType.Select | ModeType.Symbol)
	
	static __New() {
		this._InitDisplay()
		
		CommandRunner.AddCommands("mode", this._HandleCommand.Bind(this))
		
		if this._enabled {
			this.Show()
		}
	}
	
	
	static Show() {
		this._enabled := true
		this._display.Show("NoActivate")
	}
	
	static Hide() {
		this._enabled := false
		this._display.Hide()
	}
	
	static ToggleDisplay() {
		if this._enabled {
			this.Hide()
		} else {
			this.Show()
		}
	}
	
	static Move(
		x := this._xPos,
		y := this._yPos, 
		width := this._width, 
		height := this._height,
		xDisposition := this._xDisposition,
		yDisposition := this._yDisposition) 
	{
		this._display.Move(
			x - this._xGuiPadd + Disposition.GetShift(xDisposition, width),
			y - this._yGuiPadd + Disposition.GetShift(yDisposition, height),
			width + this._xGuiPadd * 2,
			height + this._yGuiPadd * 2)

		this._displayText.Move(, , width, height)
		
		this._xPos := x
		this._yPos := y
		this._width := width
		this._height := height
		this._xDisposition := xDisposition
		this._yDisposition := yDisposition
		
		this._displayText.Redraw()
	}
	
	static SetDefault() => this.SetNormal()
	
	static SetNormal() {
		if this._current == ModeType.Normal {
			return
		}
		
		this._current := ModeType.Normal
		this._DisplayNormal()
	}
	
	static SetInsert() {
		if this._current == ModeType.Insert {
			return
		}
		
		this._current := ModeType.Insert
		this._DisplayInsert()
	}
	
	static SetMouse() {
		if this._current == ModeType.Mouse {
			return
		}
		
		this._current := ModeType.Mouse
		this._DisplayMouse()
	}
	
	static SetSelect() {
		if this._current == ModeType.Select {
			return
		}
		
		this._current := ModeType.Select
		this._DisplaySelect()
	}
	
	static SetSymbol() {
		if this._current & ModeType.Symbol {
			return
		}
		
		prevMode := this._current
		this._current |= ModeType.Symbol
		
		switch prevMode {
		case ModeType.Normal: this._DisplayNSymbol()
		case ModeType.Insert: this._DisplayISymbol()
		case ModeType.Select: this._DisplaySSymbol()
		default: this._DisplayUndef()
		}
	}
	
	static UnsetSybmol() {
		if not (this._current & ModeType.Symbol) {
			return
		}
		
		this._current &= ~ModeType.Symbol
		
		switch this._current {
		case ModeType.Normal: this._DisplayNormal()
		case ModeType.Insert: this._DisplayInsert()
		case ModeType.Select: this._DisplaySelect()
		default: this._DisplayUndef()
		}
	}

	
	; --- private ---
	
	static _HandleCommand(&args, &err) {
		; TODO:
		
		if args == "-t" {
			this.ToggleDisplay()
			return
		}
		
		err := "
			(
			Wrong option.
			Supported list of options:
			-t `t Toggle Mode displaying
			)"
	}
	
	static _InitDisplay() {
		this._display.Opt("AlwaysOnTop -Caption +ToolWindow")
		this._display.BackColor := "000000" ; any color (since we're gonna make it transparent)
		WinSetTransColor(this._display.BackColor . " 240", this._display.Hwnd)
		this._display.SetFont("s16 c0x5c5c5c", "JetBrains Mono Regular")
		
		textOpts := Format("Background171717 -E0x200 w{1} h{2} Center", this._width, this._height)
		this._displayText  := this._display.AddText(textOpts)
		
		; get the actual size of the window, including its title bar, menu and borders
		this._display.Show("Hide")
		this._display.GetPos(, , &width, &height)
		
		; calculate padding added by Gui
		this._xGuiPadd := (width - this._width) / 2
		this._yGuiPadd := (height - this._height) / 2
		
		this._display.Move(
			this._xPos - this._xGuiPadd + Disposition.GetShift(this._xDisposition, this._width),
			this._yPos - this._yGuiPadd + Disposition.GetShift(this._yDisposition, this._height)
		)
		
		this.SetDefault()
	}
	
	static _DisplayNormal() => this._DisplayMode("Normal")
	static _DisplayInsert() => this._DisplayMode("Insert")
	static _DisplaySymbol() => this._DisplayMode("Symbol")
	static _DisplayMouse()  => this._DisplayMode("Mouse")
	static _DisplaySelect() => this._DisplayMode("Select")
	
	static _DisplayNSymbol() => this._DisplayMode("N_Symb")
	static _DisplayISymbol() => this._DisplayMode("I_Symb")
	static _DisplaySSymbol() => this._DisplayMode("S_Symb")
	
	static _DisplayUndef() => this._DisplayMode("Undef")
	
	static _DisplayMode(mode) {
		this._displayText.Value := mode
	}
	
}