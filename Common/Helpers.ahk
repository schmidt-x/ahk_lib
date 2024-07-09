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

DragWindow() {
	MouseGetPos(&prevMouseX, &prevMouseY, &winHWND)
	
	if WinGetMinMax(winHWND) { ; Only if the window isn't maximized
		return
	}
	
	WinGetPos(&prevWinX, &prevWinY,,, winHWND)
	
	prevWinDelay := A_WinDelay
	SetWinDelay(-1)
	
	loop {
		MouseGetPos(&mouseX, &mouseY)
		newWinX := prevWinX + mouseX - prevMouseX
		newWinY := prevWinY + mouseY - prevMouseY
		
		WinMove(newWinX, newWinY, , , winHWND)
		
		prevMouseX := mouseX
		prevMouseY := mouseY
		
		prevWinX := newWinX
		prevWinY := newWinY
		
		if !GetKeyState("LButton", "P") {
			break
		}
	}
	
	SetWinDelay(prevWinDelay)
}

NewGuidStr(upperCase := false) {
	guidBuff := Buffer(16)
	DllCall("ole32\CoCreateGuid", "Ptr", guidBuff)
	
	cchMax := 39 ; {7E88ABC9-EECF-4C2D-A783-44D1A0F83B0F}\n == 39
	lpsz := Buffer(cchMax*2)
	DllCall("ole32\StringFromGUID2", "Ptr", guidBuff, "Ptr", lpsz, "Int", cchMax)
	
	guidStr := StrGet(lpsz.Ptr+2, 36) ; Get rid of curly braces
	return upperCase ? guidStr : StrLower(guidStr)
}

; --- Blind Input ---
	
SendBlindUp() => SendInput("{Blind}{Up}")

SendBlindDown() => SendInput("{Blind}{Down}")

SendBlindEnter() => SendInput("{Blind}{Enter}")

SendBlindLeft() => SendInput("{Blind}{Left}")

SendBlindRight() => SendInput("{Blind}{Right}")