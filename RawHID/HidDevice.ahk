#Include HidDeviceInfo.ahk
#Include Helpers.ahk
#Include Errors.ahk
#Include WinApi.ahk

HID_READ  := GENERIC_READ
HID_WRITE := GENERIC_WRITE

class HidDevice {
	_inputReportByteLength  := unset
	_outputReportByteLength := unset
	_devicePath := unset
	
	_hDevice := -1
	_isOpen := false
	
	/**
	 * @param {HidDeviceInfo} deviceInfo
	 */
	__New(deviceInfo) {
		this._devicePath := deviceInfo.DevicePath
		this._inputReportByteLength := deviceInfo.InputReportByteLength
		this._outputReportByteLength := deviceInfo.OutputReportByteLength
	}
	
	__Delete() {
		if this._isOpen && this._hDevice {
			DllCall("kernel32\CloseHandle", "Ptr", this._hDevice)
		}
	}
	
	InputBufferSize  => this._inputReportByteLength-1
	OutputBufferSize => this._outputReportByteLength-1
	
	InputRawBufferSize  => this._inputReportByteLength
	OutputRawBufferSize => this._outputReportByteLength
	
	
	; TODO: add docs
	Open(&err, desiredAccess := HID_READ | HID_WRITE) {
		invalidFlags := ~(HID_READ | HID_WRITE)
		
		if desiredAccess & invalidFlags {
			err := ValueError("At least one invalid flag is set for parameter 'desiredAccess'.")
			return
		}
		
		err := ""
		
		if this._isOpen {
			return
		}
		
		this._Open(desiredAccess, &err)
	}
	
	; TODO: add docs
	Write(arr, &err) {
		if !(arr is Array) {
			err := TypeError("Invalid parameter type for 'arr'. Expected: Array, got: " Type(arr) ".")
			return
		}
		
		if arr.Length > this.OutputBufferSize {
			err := ValueError(Format("Invalid array size. Max Length is: {1}, got: {2}.", this.OutputBufferSize, arr.Length))
			return
		}
		
		this._Write(this._ToBuffer(arr), &err:="")
	}
	
	; TODO: add docs
	WriteRaw(buff, &err) {
		if !(buff is Buffer) {
			err := TypeError("Invalid parameter type for 'buff'. Expected: Buffer, got: " Type(buff) ".")
			return
		}
		
		if buff.Size != this._outputReportByteLength {
			err := ValueError(Format("Invalid buffer size. Expected: {}, got: {}.", this._outputReportByteLength, buff.Size))
			return
		}
		
		this._Write(buff, &err:="")
	}
	
	; TODO: add docs
	Read(timeout, &err) {
		input := this.ReadRaw(timeout, &err)
		if err {
			return ""
		}
		
		return this._ToArray(input)
	}
	
	; TODO: add docs
	ReadRaw(timeout, &err) {
		if timeout < 0 {
			err := ValueError("Parameter 'timeout' must not have a negative value.")
			return ""
		}
		
		return this._Read(timeout, &err:="")
	}
	
	; TODO: add docs
	Close() {
		if !this._isOpen {
			return
		}
		
		if not DllCall("kernel32\CloseHandle", "Ptr", this._hDevice) {
			; TODO: to log
		}
		
		this._isOpen := false
		this._hDevice := -1
	}
	
	
	_Write(output, &err) {
		if !this._isOpen {
			this._Open(GENERIC_WRITE, &err)
			if err {
				return
			}
			shouldClose := true
		} else {
			shouldClose := false
		}
		
		try {
			hWriteEvent := DllCall("kernel32\CreateEventW", "Ptr", 0, "Int", true, "Int", false, "Ptr", 0, "Ptr")
			if not hWriteEvent {
				errorCode := A_LastError
				err := OSErrorC("Failed to create WriteEvent: " _GetErrorMessage(), errorCode)
				return
			}
			
			try {
				writeOl := _OVERLAPPED(hWriteEvent)
				
				finished := DllCall("kernel32\WriteFile", 
					"Ptr",  this._hDevice,
					"Ptr",  output,
					"UInt", output.Size,
					"Ptr",  0,
					"Ptr",  writeOl)
				
				if finished { ; finished synchronously
					return
				}
				
				if A_LastError != ERROR_IO_PENDING {
					errorCode := A_LastError
					
					switch errorCode {
						case ERROR_DEVICE_NOT_CONNECTED:
							shouldClose := true
							err := DeviceNotConnectedError()
						
						default:
							err := OSErrorC("Failed to write: " _GetErrorMessage(), errorCode)
					}
					
					return
				}
				
				succeeded := DllCall("kernel32\GetOverlappedResultEx",
					"Ptr",   this._hDevice,
					"Ptr",   writeOl,
					"UInt*", &bytesWritten:=0,
					"UInt",  200,
					"Int",   false)
				
				if succeeded && bytesWritten == this._outputReportByteLength {
					return
				}
				
				errorCode := A_LastError
				
				switch (errorCode) {
					case ERROR_IO_INCOMPLETE, WAIT_TIMEOUT:
						if not DllCall("kernel32\CancelIoEx", "Ptr", this._hDevice, "Ptr", writeOl) {
							; TODO: to log
						}
						err := TimeoutError("Writing timed out.")
					
					case ERROR_DEVICE_NOT_CONNECTED:
						shouldClose := true
						err := DeviceNotConnectedError()
					
					default:
						err := OSErrorC("Failed to wait for writing: " _GetErrorMessage(), errorCode)
				}
				
				return
				
			} finally {
				if not DllCall("kernel32\CloseHandle", "Ptr", hWriteEvent) {
					; TODO: to log
				}
			}
		} finally {
			if shouldClose {
				this.Close()
			}
		}
	}
	
	_Read(timeout, &err) {
		if !this._isOpen {
			this._Open(GENERIC_READ, &err)
			if err {
				return ""
			}
			shouldClose := true
		} else {
			shouldClose := false
		}
		
		try {
			hReadEvent := DllCall("CreateEventW", "Ptr", 0, "Int", true, "Int", false, "Ptr", 0, "Ptr")
			if not hReadEvent {
				errorCode := A_LastError
				err := OSErrorC("Failed to create ReadEvent: " _GetErrorMessage(), errorCode)
				return ""
			}
			
			try {
				readOl := _OVERLAPPED(hReadEvent)
				input := Buffer(this._inputReportByteLength, 0)
				
				finished := DllCall("kernel32\ReadFile", 
					"Ptr",  this._hDevice,
					"Ptr",  input,
					"UInt", input.Size,
					"Ptr",  0,
					"Ptr",  readOl)
				
				if finished { ; finished synchronously
					return input
				}
				
				if A_LastError != ERROR_IO_PENDING {
					errorCode := A_LastError
					
					switch errorCode {
						case ERROR_DEVICE_NOT_CONNECTED:
							shouldClose := true
							err := DeviceNotConnectedError()
						
						default:
							err := OSErrorC("Failed to read: " _GetErrorMessage(), errorCode)
					}
					
					return ""
				}
				
				succeeded := DllCall("kernel32\GetOverlappedResultEx",
					"Ptr",   this._hDevice,
					"Ptr",   readOl,
					"UInt*", &bytesRead:=0,
					"UInt",  timeout,
					"Int",   false)
				
				if succeeded && bytesRead == this._inputReportByteLength {
					return input
				}
				
				errorCode := A_LastError
				
				switch (errorCode) {
					case ERROR_IO_INCOMPLETE, WAIT_TIMEOUT:
						if not DllCall("kernel32\CancelIoEx", "Ptr", this._hDevice, "Ptr", readOl) {
							; TODO: to log
						}
						err := TimeoutError("Reading timed out.")
					
					case ERROR_DEVICE_NOT_CONNECTED:
						shouldClose := true
						err := DeviceNotConnectedError()
						
					default:
						err := OSErrorC("Failed to wait for reading: " _GetErrorMessage(), errorCode)
				}
				
				return ""
				
			} finally {
				if not DllCall("kernel32\CloseHandle", "Ptr", hReadEvent) {
					; TODO: to log
				}
			}
		} finally {
			if shouldClose {
				this.Close()
			}
		}
	}
	
	_Open(desiredAccess, &err) {
		secAttributes := _SECURITY_ATTRIBUTES(0, true)
		
		hDevice := DllCall("kernel32\CreateFileW",
			"Ptr",  StrPtr(this._devicePath),
			"UInt", desiredAccess,
			"UInt", FILE_SHARE_READ | FILE_SHARE_WRITE,
			"Ptr",  secAttributes,
			"UInt", OPEN_EXISTING,
			"UInt", FILE_FLAG_OVERLAPPED,
			"Ptr",  0,
			"Ptr")
		
		if hDevice == INVALID_HANDLE_VALUE {
			errorCode := A_LastError
			
			err := errorCode == ERROR_FILE_NOT_FOUND
				? DeviceNotConnectedError()
				: OSErrorC(_GetErrorMessage(), errorCode)
			
			return
		}
		
		this._hDevice := hDevice
		this._isOpen := true
	}
	
	_ToArray(buffer) {
		arr := []
		arr.Length := this._inputReportByteLength - 1
		
		i := 1
		while i <= arr.Length {
			arr[i] := NumGet(buffer, i, "UChar")
			i++
		}
		
		return arr
	}
	
	_ToBuffer(array) {
		buff := Buffer(this._outputReportByteLength, 0)
		
		for i, v in array {
			NumPut("UChar", v, buff, i)
		}
		
		return buff
	}
}