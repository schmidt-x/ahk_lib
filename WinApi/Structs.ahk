class SP_DEVICE_INTERFACE_DATA extends Buffer {
	_cbSize := 24 + A_PtrSize
	_interfaceClassGuid := unset
	_flags := unset

	__New() {
		super.__New(this._cbSize)
		NumPut("UInt", this._cbSize, super.Ptr)
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
	/**
	 * The size, in bytes, of this structure.
	 */
	_nLength := (A_PtrSize == 8) ? 24 : 12
	
	/**
	 * A pointer to a `SECURITY_DESCRIPTOR` structure that controls access to the object.
	 */
	_lpSecurityDescriptor := unset
	
	/**
	 * A value that specifies whether the returned handle is inherited when a new process is created.
	 */
	_bInheritHandle := unset
	
	__New(lpSecurityDescriptor := 0, bInheritHandle := false) {
		this._lpSecurityDescriptor := lpSecurityDescriptor
		this._bInheritHandle := bInheritHandle
		
		super.__New(this._nLength)
		
		if A_PtrSize == 8 {
			NumPut(
				"UInt", this._nLength,
				"UInt", 0, ; padding
				"Ptr",  this._lpSecurityDescriptor,
				"Int",  this._bInheritHandle,
				super.Ptr)
		} else {
			NumPut(
				"UInt", this._nLength,
				"Ptr",  this._lpSecurityDescriptor,
				"Int",  this._bInheritHandle,
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
