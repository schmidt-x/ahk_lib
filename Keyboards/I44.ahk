#Include <RawHID\HidDevices>
#Include <RawHID\HidDevice>
#Include <Common\Stopwatch>
#Include <Keyboards\HidConstants>

class I44 {
	static _vendorID  := 0xFEED
	static _productID := 0x0003
	
	static _usagePage := 0xFF60
	static _usageID   := 0x61
	
	/**
	 * @type {HidDeviceInfo}
	 */
	static _deviceInfo := unset
	
	static __New() {
		deviceInfo := HidDevices.Find(this._vendorID, this._productID, this._usagePage, this._usageID, &err)
		if err {
			throw err
		}
		
		this._deviceInfo := deviceInfo
	}
	
	static NewDevice() => HidDevice(this._deviceInfo)
	
	static EnableAhk(&err) {
		this.NewDevice().Write([HID_AHK, 1], &err)
	}
	
	static DisableAhk(&err) {
		this.NewDevice().Write([HID_AHK, 0], &err)
	}
	
	/**
	 * Checks if a keyboard is resposive and measures the ReadWrite time by simply sending `HID_PING`
	 * output (with the current time) to the keyboard and waiting for the response.
	 * @param {&Integer} ms On success, the measured time (in milliseconds) is stored. -1 otherwise.
	 * @returns {Boolean} `True` if the keyboard is responsive. `False` if not or timed out.
	 */
	static Ping(&ms) {
		ms := -1
		
		sw := Stopwatch.StartNew()
		
		device := this.NewDevice()
		
		device.Open(&err)
		if err {
			return false
		}
		
		try {
			timeParts := StrSplit(FormatTime(, "hh tt"), A_Space)
			
			hours   := timeParts[1]
			minutes := A_Min
			seconds := A_Sec
			isPM    := timeParts[2] == "PM"
			
			device.Write([HID_PING, hours, minutes, seconds, isPM], &err)
			if err {
				return false
			}
			
			_ := device.Read(200, &err)
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
	
}