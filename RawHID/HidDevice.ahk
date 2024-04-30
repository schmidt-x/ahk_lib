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
	
	InputBufferSize  => this._inputReportByteLength
	OutputBufferSize => this._outputReportByteLength
	DevicePath => this._devicePath
	IsOpen => this._isOpen
	
	Open(&err) {
		if !IsSet(err) {
			err := ""
		}
		
		if this._isOpen {
			return
		}
		
		this._Open(GENERIC_READ | GENERIC_WRITE, &err)
	}
	
	Write(buffer, &err) {
		if !IsSet(err) {
			err := ""
		}
		
		if buffer.Size != this._outputReportByteLength {
			err := "Invalid buffer size"
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
			if not Kernel32.WriteFile(this._hDevice, buffer, this._outputReportByteLength, &bytesWritten, 0) {
				err := "Couldn't write. Error code: " A_LastError
				return
			}
		} finally {
			if shouldClose {
				this.Close()
			}
		}
	}
	
	; TODO
	; Read(&err) {
		
	; }
	
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
		shareMode := FILE_SHARE_READ | FILE_SHARE_WRITE
		
		hDevice := Kernel32.CreateFileW(this._devicePath, desiredAccess, shareMode, secAttributes, OPEN_EXISTING, 0, 0)
		if hDevice == INVALID_HANDLE_VALUE {
			err := "Failed to open device: " A_LastError
			return
		}
		
		this._hDevice := hDevice
		this._isOpen := true
	}
}