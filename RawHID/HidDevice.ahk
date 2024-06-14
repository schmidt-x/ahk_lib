#Include <WinApi\Errors\OSErrorC>
#Include <WinApi\Dll\Kernel32>
#Include <WinApi\Constants>
#Include <WinApi\Structs>

#Include <RawHID\HidDeviceInfo>
#Include <RawHID\Helpers>


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
			Kernel32.CloseHandle(this._hDevice)
		}
	}
	
	InputBufferSize  => this._inputReportByteLength-1
	OutputBufferSize => this._outputReportByteLength-1
	
	
	; TODO: add docs
	Open(&err) {
		if !IsSet(err) {
			err := ""
		}
		
		if this._isOpen {
			return
		}
		
		this._Open(GENERIC_READ | GENERIC_WRITE, &err)
	}
	
	; TODO: add docs
	Write(arr, &err) {
		if !IsSet(err) {
			err := ""
		}
		
		if !(arr is Array) {
			err := TypeError("Invalid parameter type for 'arr'. Expected: Array, got: " Type(arr) ".")
			return
		}
		
		if arr.Length == 0 {
			err := ValueError("Empty array.")
			return
		}
		
		if arr.Length >= this._outputReportByteLength {
			err := ValueError(Format("Invalid array size. Max Length is: {1}, got: {2}.", this.OutputBufferSize, arr.Length))
			return
		}
		
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
			hWriteEvent := Kernel32.CreateEventW(0, true, false, 0)
			if not hWriteEvent {
				errorCode := A_LastError
				err := OSErrorC("Failed to create WriteEvent: " GetErrorMessage(), errorCode)
				return
			}
			
			try {
				writeOl := OVERLAPPED(hWriteEvent)
				output := this._ToBuffer(arr)
				
				finished := Kernel32.WriteFile(this._hDevice, output, output.Size, &_, writeOl)
				if finished {
					; finished synchronously
					return
				}
				
				if A_LastError != ERROR_IO_PENDING {
					errorCode := A_LastError
					err := OSErrorC("Failed to write: " GetErrorMessage(), errorCode)
					return
				}
				
				waitResult := Kernel32.WaitForSingleObject(hWriteEvent, 1000)
				
				switch waitResult {
					case WAIT_OBJECT_0:
						return
					
					case WAIT_TIMEOUT:
						if not Kernel32.CancelIoEx(this._hDevice, writeOl) {
							; TODO: to log
						}
						err := TimeoutError("Writing timed out.")
						
					case WAIT_FAILED:
						errorCode := A_LastError
						err := OSErrorC("Failed to wait for writing: " GetErrorMessage(), errorCode)
					
					default:
						throw Error("Shouldn't reach here.")
				}
				
				return
				
			} finally {
				if not Kernel32.CloseHandle(hWriteEvent) {
					; TODO: to log
				}
			}
		} finally {
			if shouldClose {
				this.Close()
			}
		}
	}
	
	; TODO: add docs
	Read(timeout, &err) {
		if !IsSet(err) {
			err := ""
		}
		
		if timeout < 0 {
			err := ValueError("Parameter 'timeout' must not have a negative value.")
			return ""
		}
		
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
			hReadEvent := Kernel32.CreateEventW(0, true, false, 0)
			if not hReadEvent {
				errorCode := A_LastError
				err := OSErrorC("Failed to create ReadEvent: " GetErrorMessage(), errorCode)
				return ""
			}
			
			try {
				readOl := OVERLAPPED(hReadEvent)
				input := Buffer(this._inputReportByteLength, 0)
				
				finished := Kernel32.ReadFile(this._hDevice, input, input.Size, &_, readOl)
				if finished {
					; finished synchronously
					return this._ToArray(input)
				}
				
				if A_LastError != ERROR_IO_PENDING {
					errorCode := A_LastError
					err := OSErrorC("Failed to read: " GetErrorMessage(), errorCode)
					return ""
				}
				
				waitResult := Kernel32.WaitForSingleObject(hReadEvent, timeout)
					
				switch waitResult {
					case WAIT_OBJECT_0:
						return this._ToArray(input)
					
					case WAIT_TIMEOUT:
						if not Kernel32.CancelIoEx(this._hDevice, readOl) {
							; TODO: to log
						}
						err := TimeoutError("Reading timed out.")
					
					case WAIT_FAILED:
						errorCode := A_LastError
						err := OSErrorC("Failed to wait for reading: " GetErrorMessage(), errorCode)
					
					default:
						throw Error("Shouldn't reach here.")
				}
				
				return ""
				
			} finally {
				if not Kernel32.CloseHandle(hReadEvent) {
					; TODO: to log
				}
			}
		} finally {
			if shouldClose {
				this.Close()
			}
		}
	}
	
	; TODO: add docs
	Close() {
		if !this._isOpen {
			return
		}
		
		if not Kernel32.CloseHandle(this._hDevice) {
			; TODO: to log
		}
		
		this._isOpen := false
		this._hDevice := -1
	}
	
	
	_Open(desiredAccess, &err) {
		secAttributes := SECURITY_ATTRIBUTES(0, true)
		
		hDevice := Kernel32.CreateFileW(
			this._devicePath,
			desiredAccess,
			FILE_SHARE_READ | FILE_SHARE_WRITE,
			secAttributes,
			OPEN_EXISTING,
			FILE_FLAG_OVERLAPPED, 0)
		
		if hDevice == INVALID_HANDLE_VALUE {
			errorCode := A_LastError
			
			err := OSErrorC("Failed to open a device: " (errorCode == ERROR_FILE_NOT_FOUND 
				? "Device not found."
				: GetErrorMessage()), errorCode)
				
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