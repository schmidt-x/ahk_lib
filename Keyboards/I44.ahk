#Include <RawHID\HidDevices>
#Include <RawHID\HidDevice>
#Include <Common\StopWatch>

class I44 {
	static _vendorID  := 0xFEED
	static _productID := 0x0003
	
	static _usageID   := 0x61
	static _usagePage := 0xFF60
	
	/**
	 * @type {HidDeviceInfo}
	 */
	static _deviceInfo := unset
	
	static __New() {
		deviceInfo := HidDevices.Find(this._vendorID, this._productID, this._usageID, this._usagePage, &err)
		if err {
			throw err
		}
		
		this._deviceInfo := deviceInfo
	}
	
	static EnableAhk(&err) {
		this._NewDevice().Write([1, 1], &err)
	}
	
	static DisableAhk(&err) {
		this._NewDevice().Write([1, 0], &err)
	}
	
	static Ping(&ms) {
		if !IsSet(ms) {
			ms := -1
		}
		
		sw := StopWatch()
		sw.Start()
		
		device := this._NewDevice()
		
		device.Open(&err)
		if err {
			return false
		}
		
		try {
			device.Write([255], &err)
			if err {
				return false
			}
			
			_ := device.Read(1000, &err)
			if err {
				return false
			}
		} finally {
			device.Close()
		}
		
		sw.Stop()
		
		ms := sw.ElapsedMilliseconds
		return true
	}
	
	
	static _NewDevice() => HidDevice(this._deviceInfo)
}