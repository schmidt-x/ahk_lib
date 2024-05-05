#Include <WinApi\Dll\Kernel32>
#Include <WinApi\Constants>

GetErrorMessage(errorCode := A_LastError) {
	flags := FORMAT_MESSAGE_ALLOCATE_BUFFER | FORMAT_MESSAGE_FROM_SYSTEM | FORMAT_MESSAGE_IGNORE_INSERTS
	
	charsStored := Kernel32.FormatMessageW(flags, 0, errorCode, 0, &lpBuffer, 0, 0)
	if charsStored == 0 {
		; TODO: to log
		
		return OSError(errorCode).Message
	}
	
	try {
		return Format("({1}) {2}", errorCode, StrGet(lpBuffer))
	} finally {
		failed := Kernel32.LocalFree(lpBuffer)
		if failed {
			; TODO: to log
		}
	}
}