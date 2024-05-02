#Include <WinApi\Dll\Kernel32>
#Include <WinApi\Constants>
#Include <WinApi\Structs>

class HidDevice {
	_inputReportByteLength  := unset
	_outputReportByteLength := unset
	_devicePath := unset
	
	_hDevice := -1
	_isOpen := false
	
	__New(devicePath, inputReportByteLength, outputReportByteLength) {
		this._devicePath := devicePath
		this._inputReportByteLength := inputReportByteLength
		this._outputReportByteLength := outputReportByteLength
	}
	
	__Delete() {
		if this._isOpen && this._hDevice {
			Kernel32.CloseHandle(this._hDevice)
		}
	}
	
	InputBufferSize  => this._inputReportByteLength-1
	OutputBufferSize => this._outputReportByteLength-1
	DevicePath => this._devicePath
	IsOpen => this._isOpen
	
	
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
			err := "Invalid parameter 'arr'.`nExpected: Array, got: " Type(arr)
			return
		}
		
		if arr.Length == 0 || arr.Length >= this._outputReportByteLength {
			err := "Invalid array size. Max Length is: " this.OutputBufferSize
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
				err := "Failed to create a writing event. Error code: " A_LastError
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
					err := "Failed to write into the device. Error code: " A_LastError
					return
				}
				
				waitResult := Kernel32.WaitForSingleObject(hWriteEvent, 1000)
				
				switch waitResult {
					case WAIT_OBJECT_0:
						return
					case WAIT_TIMEOUT:
						Kernel32.CancelIoEx(this._hDevice, writeOl)
						err := "Timed out"
					case WAIT_ABANDONED:
						err := "Asynchronous write operation has been abandoned"
					case WAIT_FAILED:
						err := "Failed at waiting for the asynchronously writing operation. Error code: " A_LastError
				}
			} finally {
				Kernel32.CloseHandle(hWriteEvent)
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
			err := "Invalid timeout"
			return
		}
		
		if !this._isOpen {
			this._Open(GENERIC_READ, &err)
			if err {
				return
			}
			shouldClose := true
		} else {
			shouldClose := false
		}
		
		try {
			hReadEvent := Kernel32.CreateEventW(0, true, false, 0)
			if not hReadEvent {
				err := "Failed to create a reading event. Error code: " A_LastError
				return
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
					err := "Failed to read from the device. Error code: " A_LastError
					return
				}
				
				waitResult := Kernel32.WaitForSingleObject(hReadEvent, timeout)
					
				switch waitResult {
					case WAIT_OBJECT_0:
						return this._ToArray(input)
					case WAIT_TIMEOUT:
						Kernel32.CancelIoEx(this._hDevice, readOl)
						err := "Timed out"
					case WAIT_ABANDONED:
						err := "Asynchronous read operation has been abandoned"
					case WAIT_FAILED:
						err := "Failed at waiting for the asynchronously reading operation. Error code: " A_LastError
				}
			} finally {
				Kernel32.CloseHandle(hReadEvent)
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
		
		_ := Kernel32.CloseHandle(this._hDevice)
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
			err := "Failed to open the device: " A_LastError
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