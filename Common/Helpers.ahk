ScrollUp() {
	MoveMouseToCenter()
	SendEvent("{WheelUp 2}")
}

ScrollDown() {
	MoveMouseToCenter()
	SendEvent("{WheelDown 2}")
}

MoveMouseToCenter() {
	WinGetPos(&x, &y, &width, &height, "A")
	MouseMove(x + width/2, y + height/2)
}

ClipSend(str, restore := true) {
	prevClip := restore ? ClipboardAll() : ""
	A_Clipboard := str
	SendInput("^v")
	if restore {
		SetTimer(() => A_Clipboard := prevClip, -50)
	}
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

ThrowIfError(err) {
	if err {
		throw err
	}
}

DragWindow(keyToHold) {
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
		
		if !GetKeyState(keyToHold, "P") {
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

Bin2Hex(input, paddingCount := 0, lowerCase := false) {
	res := Bin2Dec(input)
	if res == -1 {
		return ""
	}
	
	pattern := paddingCount
		? ("0x{:0" paddingCount (lowerCase ? "x}" : "X}"))
		: (lowerCase ? "0x{:x}" : "0x{:X}")
		
	return Format(pattern, res)
}

Bin2Dec(input) {
	len := StrLen(input)
	if !len {
		return -1
	}
	
	res := 0
	j := 0
	
	i := len+1
	while --i > 0 {
		switch SubStr(input, i, 1) {
			case "0": ; break
			case "1": res += 1 << j
			case "_": continue
			default:  return -1
		}
		j++
	}
	
	return res
}

SetLangEn() {
	En := 0x0409
	SetLang(En)
}

SetLangRu() {
	Ru := 0x0419
	SetLang(Ru)
}

SetLang(hkl) {
	; https://stackoverflow.com/questions/51117874/how-to-send-wm-inputlangchangerequest-to-app-with-modal-window
	
	if not hwnd := WinExist("A") {
		return
	}
	
	GA_ROOTOWNER := 3
	hwnd := DllCall("User32\GetAncestor", "Ptr", hwnd, "UInt", GA_ROOTOWNER)
	
	WM_INPUTLANGCHANGEREQUEST  := 0x0050
	INPUTLANGCHANGE_SYSCHARSET := 0x01
	PostMessage(WM_INPUTLANGCHANGEREQUEST, INPUTLANGCHANGE_SYSCHARSET, hkl, , hwnd)
	
	if WinGetClass(hwnd) == "#32770" {
		lpEnumFunc := CallbackCreate(PostToChildWindows, "Fast")
		try DllCall("User32\EnumChildWindows", "Ptr", hwnd, "Ptr", lpEnumFunc, "Ptr", hkl)
		finally CallbackFree(lpEnumFunc)
	}
	
	PostToChildWindows(hwnd, lParam) {
		PostMessage(WM_INPUTLANGCHANGEREQUEST, INPUTLANGCHANGE_SYSCHARSET, lParam, , hwnd)
		return true
	}
}

GetKeyboardLocaleID() {
	hwnd := DllCall("User32\GetForegroundWindow", "Ptr")
	threadId := DllCall("User32\GetWindowThreadProcessId", "Ptr", hwnd, "Ptr", 0)
	return DllCall("User32\GetKeyboardLayout", "UInt", threadId, "Ptr")
}

/**
 * Sets the values of the FilterKeys accessibility feature.
 * @param {Boolean} onOff Turn on/off the feature.
 * @param {Integer} waitMSec The length of time, in milliseconds, that the user must hold down a key 
 * before it is accepted by the computer.
 * @param {Integer} delayMSec The length of time, in milliseconds, that the user must hold down a key
 * before it begins to repeat.
 * @param {Integer} repeatMSec The length of time, in milliseconds, between each repetition of the
 * keystroke.
 * @param {Integer} bounceMSec The length of time, in milliseconds, that must elapse after releasing 
 * a key before the computer will accept a subsequent press of the same key.
 * @returns {Boolean} `true` if the function succeeded; `false` otherwise.
 */
SetFilterKeys(onOff?, waitMSec?, delayMSec?, repeatMSec?, bounceMSec?) {
	fKeys := GetFilterKeys()
	
	FKF_AVAILABLE    := 0x02
	FKF_FILTERKEYSON := 0x01
	
	cbSize := 24
	FILTERKEYS := Buffer(cbSize)
	
	NumPut(
		"UInt", cbSize,
		"UInt", IsSet(onOff) ? FKF_AVAILABLE | (onOff ? FKF_FILTERKEYSON : 0) : fKeys.Flags,
		"UInt", waitMSec   ?? fKeys.WaitMSec,
		"UInt", delayMSec  ?? fKeys.DelayMSec,
		"UInt", repeatMSec ?? fKeys.RepeatMSec,
		"UInt", bounceMSec ?? fKeys.BounceMSec,
		FILTERKEYS)
	
	SPI_SETFILTERKEYS  := 0x0033
	SPIF_UPDATEINIFILE := 0x01
	SPIF_SENDCHANGE    := 0x02
	
	fWinIni := SPIF_UPDATEINIFILE | SPIF_SENDCHANGE
	
	result := DllCall("User32\SystemParametersInfoA", 
		"UInt", SPI_SETFILTERKEYS, ; uiAction
		"UInt", cbSize,            ; uiParam
		"Ptr",  FILTERKEYS,        ; pvParam
		"UInt", fWinIni)           ; fWinIni
	
	return result != 0
}

/**
 * Gets the values of the FilterKeys accessibility feature.
 * @returns {Object} 
 * @member `.Flags`: `Integer` A set of bit flags that specify properties of the FilterKeys feature.
 * @member `.WaitMSec`: `Integer` The length of time, in milliseconds, that the user must hold down 
 * a key before it is accepted by the computer.
 * @member `.DelayMSec`: `Integer` The length of time, in milliseconds, that the user must hold down 
 * a key before it begins to repeat.
 * @member `.RepeatMSec`: `Integer` The length of time, in milliseconds, between each repetition
 * of the keystroke.
 * @member `.BounceMSec`: `Integer` The length of time, in milliseconds, that must elapse after 
 * releasing a key before the computer will accept a subsequent press of the same key.
 */
GetFilterKeys() {
	cbSize := 24
	FILTERKEYS := Buffer(cbSize, 0)
	NumPut("UInt", cbSize, FILTERKEYS)
	
	SPI_GETFILTERKEYS := 0x0032
	
	success := DllCall("User32\SystemParametersInfoA",
		"UInt", SPI_GETFILTERKEYS,
		"UInt", cbSize,
		"Ptr",  FILTERKEYS,
		"UInt", 0)
	
	dwFlags     := NumGet(FILTERKEYS, 4,  "UInt")
	iWaitMSec   := NumGet(FILTERKEYS, 8,  "UInt")
	iDelayMSec  := NumGet(FILTERKEYS, 12, "UInt")
	iRepeatMSec := NumGet(FILTERKEYS, 16, "UInt")
	iBounceMSec := NumGet(FILTERKEYS, 20, "UInt")
	
	return {
		Flags:      dwFlags,
		WaitMSec:   iWaitMSec,
		DelayMSec:  iDelayMSec,
		RepeatMSec: iRepeatMSec,
		BounceMSec: iBounceMSec
	}
}

ToggleTaskbar() {
	ABM_GETSTATE := 0x04
	ABM_SETSTATE := 0x0A
	
	ABS_AUTOHIDE := 0x01
	
	cbSize := 48
	abd := Buffer(cbSize, 0)
	NumPut("UInt", cbSize, abd)
	
	state := DllCall("shell32\SHAppBarMessage", "UInt", ABM_GETSTATE, "Ptr", abd)
	lParam := (state & ABS_AUTOHIDE) ? 0 : ABS_AUTOHIDE
	
	NumPut("Int64", lParam, abd, 40)
	DllCall("shell32\SHAppBarMessage", "UInt", ABM_SETSTATE, "Ptr", abd)
}


; --- Input Helpers ---
	
SendBlindUp() => SendInput("{Blind}{Up}")

SendBlindDown() => SendInput("{Blind}{Down}")

SendBlindEnter() => SendInput("{Blind}{Enter}")

SendBlindLeft() => SendInput("{Blind}{Left}")

SendBlindRight() => SendInput("{Blind}{Right}")

MoveCursorToFileBeginning() => SendInput("^{Home}")

MoveCursorToFileEnd() => SendInput("^{End}")