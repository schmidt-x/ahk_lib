class SP_DEVICE_INTERFACE_DATA extends Buffer {
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

class SP_DEVICE_INTERFACE_DETAIL_DATA extends Buffer {
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

class SECURITY_ATTRIBUTES extends Buffer {
	
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

class HIDD_ATTRIBUTES extends Buffer {
	
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

class HIDP_CAPS extends Buffer {
	_usage := unset
	_usagePage := unset
	
	_inputReportByteLength  := unset
	_outputReportByteLength := unset
	
	; TODO: add other fields (do I need them ?)
	
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

class OVERLAPPED extends Buffer {
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