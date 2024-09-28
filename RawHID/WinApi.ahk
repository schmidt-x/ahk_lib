; ========================= Constants =========================
	
; --- hidpi.h ---

HIDP_STATUS_SUCCESS := 0x00110000
HIDP_STATUS_INVALID_PREPARSED_DATA := 0xC0110001

; --- winnt.h ---

FILE_SHARE_NONE   := 0
FILE_SHARE_READ   := 0x00000001
FILE_SHARE_WRITE  := 0x00000002
FILE_SHARE_DELETE := 0x00000004

ACCESS_NONE   := 0
GENERIC_WRITE := 0x40000000
GENERIC_READ  := 0x80000000

; --- winbase.h ---

FILE_FLAG_OVERLAPPED := 0x40000000

WAIT_OBJECT_0  := 0
WAIT_FAILED    := 0xFFFFFFFF
WAIT_ABANDONED := 0x00000080

INFINITE := 0xFFFFFFFF ; Infinite timeout

FORMAT_MESSAGE_ALLOCATE_BUFFER := 0x00000100
FORMAT_MESSAGE_IGNORE_INSERTS  := 0x00000200
FORMAT_MESSAGE_FROM_SYSTEM     := 0x00001000

; --- fileapi.h ---

OPEN_EXISTING := 3

; --- ntrxdef.h ---

INVALID_HANDLE_VALUE := -1

; --- setupapi.h ---

; Flags controlling what is included in the device information set built
; by SetupDiGetClassDevs

DIGCF_DEFAULT         := 0x00000001 ; only valid with DIGCF_DEVICEINTERFACE
DIGCF_PRESENT         := 0x00000002
DIGCF_ALLCLASSES      := 0x00000004
DIGCF_PROFILE         := 0x00000008
DIGCF_DEVICEINTERFACE := 0x00000010

; --- winerror.h ---

ERROR_FILE_NOT_FOUND       := 2
ERROR_HANDLE_EOF           := 38
ERROR_INSUFFICIENT_BUFFER  := 122
WAIT_TIMEOUT               := 258
ERROR_IO_INCOMPLETE        := 996
ERROR_IO_PENDING           := 997
ERROR_DEVICE_NOT_CONNECTED := 1167


; ========================= Structs =========================
	
class _SP_DEVICE_INTERFACE_DATA extends Buffer {
	_flags := unset

	__New() {
		cbSize := 24 + A_PtrSize
		super.__New(cbSize)
		NumPut("UInt", cbSize, super.Ptr)
	}
	
	GetFlags(cached := false) {
		return cached ? this._flags : (this._flags := NumGet(super.Ptr, 20, "UInt"))
	}
}

class _SP_DEVICE_INTERFACE_DETAIL_DATA extends Buffer {
	_cbSize := 8
	_devicePath := unset
	
	__New(requiredSize) {
		super.__New(requiredSize)
		NumPut("UInt", this._cbSize, super.Ptr)
	}
	
	GetDevicePath(cached := false) {
		return cached ? this._devicePath : (this._devicePath := StrGet(super.Ptr + 4))
	}
}

class _SECURITY_ATTRIBUTES extends Buffer {
	__New(lpSecurityDescriptor := 0, bInheritHandle := false) {
		if A_PtrSize == 8 {
			nLength := 24
			super.__New(nLength, 0)
			
			NumPut(
				"UInt", nLength,
				"UInt", 0, ; padding
				"Ptr",  lpSecurityDescriptor,
				"Int",  bInheritHandle,
				super.Ptr)
		} else {
			nLength := 12
			super.__New(nLength, 0)
			
			NumPut(
				"UInt", nLength,
				"Ptr",  lpSecurityDescriptor,
				"Int",  bInheritHandle,
				super.Ptr)
		}
	}
}

class _HIDD_ATTRIBUTES extends Buffer {
	
	/**
	 * Specifies the size, in bytes, of a `HIDD_ATTRIBUTES` structure.
	 */
	_size := 12
	
	/**
	 * Specifies a HID device's vendor ID.
	 */
	_vendorID := unset
	
	/**
	 * Specifies a HID device's product ID.
	 */
	_productID := unset
	
	/**
	 * Specifies the manufacturer's revision number for a HIDClass device.
	 */
	_versionNumber := unset
	
	__New() {
		super.__New(this._size)
		NumPut("UInt", this._size, super.Ptr)
	}
	
	GetVendorID(cached := false) {
		return cached ? this._vendorID : (this._vendorID := NumGet(super.Ptr, 4, "UShort"))
	}
	
	GetProductID(cached := false) {
		return cached ? this._productID : (this._productID := NumGet(super.Ptr, 6, "UShort"))
	}
	
	GetVersionNumber(cached := false) {
		return cached ? this._versionNumber : (this._versionNumber := NumGet(super.Ptr, 8, "UShort"))
	}
}

class _HIDP_CAPS extends Buffer {
	_usage := unset
	_usagePage := unset
	
	_inputReportByteLength  := unset
	_outputReportByteLength := unset
	
	__New() {
		super.__New(64)
	}
	
	GetUsageID(cached := false) {
		return cached ? this._usage : (this._usage := NumGet(super.Ptr, 0, "UShort"))
	}
	
	GetUsagePage(cached := false) {
		return cached ? this._usagePage : (this._usagePage := NumGet(super.Ptr, 2, "UShort"))
	}
	
	GetInputReportByteLength(cached := false) {
		return cached ? this._inputReportByteLength : (this._inputReportByteLength := NumGet(super.Ptr, 4, "UShort"))
	}
	
	GetOutputReportByteLength(cached := false) {
		return cached ? this._outputReportByteLength : (this._outputReportByteLength := NumGet(super.Ptr, 6, "UShort"))
	}
}

class _OVERLAPPED extends Buffer {
	__New(hEvent) {
		if A_PtrSize == 8 {
			super.__New(32, 0)
			NumPut("Ptr", hEvent, super.Ptr, 24)
		} else {
			super.__New(16, 0)
			NumPut("Ptr", hEvent, super.Ptr, 12)
		}
	}
}
