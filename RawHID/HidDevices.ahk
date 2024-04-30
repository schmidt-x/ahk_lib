#Include <WinApi\Dll\Kernel32>
#Include <WinApi\Dll\SetupAPI>
#Include <WinApi\Dll\Hid>
#Include <WinApi\Constants>
#Include <WinApi\Structs>
#Include <RawHID\HidDevice>

class HidDevices {
	
	; TODO: add docs
	static FindDevice(vendorId, productId, usageId, usagePage, &err) {
		if !IsSet(err) {
			err := ""
		}
		
		devicePaths := this._ListDevicePaths(&pathErr)
		if pathErr {
			err := "Failed at listing devices: " pathErr
			return ""
		}
		
		if devicePaths.Length == 0 {
			err := "No device is present"
			return ""
		}
		
		hidModule := Kernel32.LoadLibraryW(Hid.Name)
		
		try {
			for devicePath in devicePaths {
				secAttributes := SECURITY_ATTRIBUTES(0, true)
				shareMode := FILE_SHARE_READ | FILE_SHARE_WRITE
				
				hDevice := Kernel32.CreateFileW(devicePath, ACCESS_NONE, shareMode, secAttributes, OPEN_EXISTING, 0, 0)
				if hDevice == INVALID_HANDLE_VALUE {
					err := Format("Failed at opening device: {1}.`nError code: {2}", devicePath, A_LastError)
					return "" ; should I return or ignore and continue?
				}
				
				try {
					hidAttributes := HIDD_ATTRIBUTES()
					_ := Hid.HidD_GetAttributes(hDevice, hidAttributes)
					
					if vendorId != hidAttributes.GetVendorID() || productId != hidAttributes.GetProductID() {
						continue
					}
					
					_ := Hid.HidD_GetPreparsedData(hDevice, &preparsedData)
					
					try {
						caps := HIDP_CAPS()
						_ := Hid.HidP_GetCaps(preparsedData, caps)
						
						if caps.GetUsageID() != usageId || caps.GetUsagePage() != usagePage {
							continue
						}
						
						return HidDevice(devicePath, caps.GetInputReportByteLength(), caps.GetOutputReportByteLength())
						
					} finally {
						Hid.HidD_FreePreparsedData(preparsedData)
					}
				} finally {
					Kernel32.CloseHandle(hDevice)
				}
			}
			
			err := "Device not found"
			return ""
			
		} finally {
			Kernel32.FreeLibrary(hidModule)
		}
	}
	
	; TODO: add docs
	static _ListDevicePaths(&err) {
		if !IsSet(err) {
			err := ""
		}
		
		hidGuid := Buffer(16)
		Hid.HidD_GetHidGuid(hidGuid)
		
		hModule := Kernel32.LoadLibraryW(SetupApi.Name)
		
		try {
			hDevInfoSet := SetupApi.SetupDiGetClassDevsW(hidGuid, 0, 0, DIGCF_DEVICEINTERFACE | DIGCF_PRESENT)
			if hDevInfoSet == INVALID_HANDLE_VALUE {
				err := "Failed to get Device Information Set. Error code: " A_LastError
				return ""
			}
			
			try {
				devInterfaceData := SP_DEVICE_INTERFACE_DATA()
				devicePathList := []
				
				mIndex := 0
				while SetupApi.SetupDiEnumDeviceInterfaces(hDevInfoSet, 0, hidGuid, mIndex, devInterfaceData) {
					
					_ := SetupApi.SetupDiGetDeviceInterfaceDetailW(hDevInfoSet, devInterfaceData, 0, 0, &requiredSize, 0)
					
					devInterfaceDetailData := SP_DEVICE_INTERFACE_DETAIL_DATA(requiredSize)
					
					_ := SetupApi.SetupDiGetDeviceInterfaceDetailW(
						hDevInfoSet,
						devInterfaceData,
						devInterfaceDetailData,
						requiredSize,
						&requiredSize, 0)
					
					devicePathList.Push(devInterfaceDetailData.GetDevicePath())
					mIndex++
				}
				
				return devicePathList
				
			} finally {
				SetupApi.SetupDiDestroyDeviceInfoList(hDevInfoSet)
			}
		} finally {
			Kernel32.FreeLibrary(hModule)
		}
	}
}