#Include WinApi.ahk

_GetErrorMessage(errorCode := A_LastError) {
	flags := FORMAT_MESSAGE_ALLOCATE_BUFFER | FORMAT_MESSAGE_FROM_SYSTEM | FORMAT_MESSAGE_IGNORE_INSERTS
	
	charsStored := DllCall("kernel32\FormatMessageW",
		"UInt", flags, 
		"Ptr",  0, 
		"UInt", errorCode,
		"UInt", 0,
		"Ptr*", &lpBuffer:=0,
		"UInt", 0,
		"Ptr",  0)
	
	if charsStored == 0 {
		; TODO: to log
		return OSError(errorCode).Message
	}
	
	try {
		return Format("({1}) {2}", errorCode, StrGet(lpBuffer))
	} finally {
		failed := DllCall("kernel32\LocalFree", "Ptr", lpBuffer)
		if failed {
			; TODO: to log
		}
	}
}