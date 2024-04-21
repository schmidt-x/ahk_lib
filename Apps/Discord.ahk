#Include <System\Paths>

class Discord {
	static _processName     := "Discord.exe"
	static _winProcessName  := "ahk_exe " this._processName
	static _fullProcessName :=  Paths.User "\AppData\Local\Discord\Update.exe --processStart " this._processName
	
	static ProcessName => this._processName
	static IsActive => WinActive(this._winProcessName)
	
	static Run() {
		if hwnd := WinExist(this._winProcessName) {
			WinActivate(hwnd)
		} else {
			Run(this._fullProcessName)
		}
	}
	
	
	; --- Shortcuts ---
	
	/*
		Apparently, custom keybindings are «wildcard».
		If you send '+!d', it'll catch all the following keybindings:
		'+!d', '+d', '!d', and even 'd'
	*/
	
	
	static EditMessage() => SendInput("e")
	
	static ReplyToMessage() => SendInput("r")
	
	static NextSection() => SendInput("{F6}")
	
	static PreviousSection() => SendInput("+{F6}")
	
	static Forward() => SendInput("!{Right}")
	
	static Backward() => SendInput("!{Left}")
	
	static NavigateToCurrentCall() => SendInput("+!^v")
	
	static UploadFile() => SendInput("+^u")
	
	static ToggleMemberListOrVoiceTextChat() => SendInput("^u")
	
	static DisconnectFromVoice() {
		; modified
		; default: none
		
		SendInput("{F22}")
	}
}