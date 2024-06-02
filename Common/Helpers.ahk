ScrollUp() {
	MoveMouseToCenter()
	SendInput("{WheelUp 2}")
}

ScrollDown() {
	MoveMouseToCenter()
	SendInput("{WheelDown 2}")
}

Display(text, removeAfter := 1000, whichTooltip := 1, X := 0, Y := 0) {
	ToolTip(text, X, Y, whichTooltip)
	SetTimer(() => ToolTip(, , , whichTooltip), -removeAfter)
}

MoveMouseToCenter() {
	WinGetPos(&x, &y, &width, &height, "A")
	MouseMove(x + width/2, y + height/2)
}

ClipSend(str) {
	prevClip := ClipboardAll()
	A_Clipboard := str
	SendInput("^v")
	SetTimer(() => A_Clipboard := prevClip, -50)
}

StrIsEmptyOrWhiteSpace(str) {
	len := StrLen(str)
	
	if !len {
		return true
	}
	
	Loop len {
		if SubStr(str, A_Index, 1) != A_Space {
			return false
		}
	}
	
	return true
}

MoveCursorToFileBeginning() => SendInput("^{Home}")

MoveCursorToFileEnd() => SendInput("^{End}")

ThrowIfError(err) {
	if err {
		throw err
	}
}


; --- Blind Input ---
	
SendBlindUp() => SendInput("{Blind}{Up}")

SendBlindDown() => SendInput("{Blind}{Down}")

SendBlindEnter() => SendInput("{Blind}{Enter}")

SendBlindLeft() => SendInput("{Blind}{Left}")

SendBlindRight() => SendInput("{Blind}{Right}")