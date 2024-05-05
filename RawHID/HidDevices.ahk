#Include <WinApi\Dll\Kernel32>
#Include <WinApi\Dll\SetupAPI>
#Include <WinApi\Dll\Hid>
#Include <WinApi\Constants>
#Include <WinApi\Structs>

#Include <RawHID\HidDevice>
#Include <RawHID\Helpers>

class HidDevices {
	
	; TODO: add docs
	static Find(vendorId, productId, usageId, usagePage, &err) {
		if !IsSet(err) {
			err := ""
		}
		
		devicePaths := this._ListDevicePaths(&err)
		if err {
			return ""
		}
		
		if devicePaths.Length == 0 {
			err := Error("No device is present.")
			return ""
		}
		
		hidModule := Kernel32.LoadLibraryW(Hid.Name)
		if not hidModule {
			errorCode := A_LastError
			err := OSErrorC("Failed to load " Hid.Name " library: " GetErrorMessage(), errorCode)
			return ""
		}
		
		try {
			for devicePath in devicePaths {
				secAttributes := SECURITY_ATTRIBUTES(0, true)
				shareMode := FILE_SHARE_READ | FILE_SHARE_WRITE
				
				hDevice := Kernel32.CreateFileW(devicePath, ACCESS_NONE, shareMode, secAttributes, OPEN_EXISTING, 0, 0)
				if hDevice == INVALID_HANDLE_VALUE {
					; TODO: to log
					continue
				}
				
				try {
					hidAttributes := HIDD_ATTRIBUTES()
					succeeded := Hid.HidD_GetAttributes(hDevice, hidAttributes)
					if not succeeded {
						; TODO: to log
						continue
					}
					
					if vendorId != hidAttributes.GetVendorID() || productId != hidAttributes.GetProductID() {
						continue
					}
					
					succeeded := Hid.HidD_GetPreparsedData(hDevice, &preparsedData)
					if not succeeded {
						; TODO: to log
						continue
					}
					
					try {
						caps := HIDP_CAPS()
						
						succeeded := Hid.HidP_GetCaps(preparsedData, caps)
						if not succeeded {
							; TODO: to log
							continue
						}
						
						if caps.GetUsageID() != usageId || caps.GetUsagePage() != usagePage {
							continue
						}
						
						return HidDevice(devicePath, caps.GetInputReportByteLength(), caps.GetOutputReportByteLength())
						
					} finally {
						if not Hid.HidD_FreePreparsedData(preparsedData) {
							; TODO: to log
						}
					}
				} finally {
					if not Kernel32.CloseHandle(hDevice) {
						; TODO: to log
					}
				}
			}
			
			err := Error("Device not found.")
			return ""
			
		} finally {
			if not Kernel32.FreeLibrary(hidModule) {
				; TODO: to log
			}
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
		if not hModule {
			errorCode := A_LastError
			err := OSErrorC("Failed to load " SetupApi.Name " library: " GetErrorMessage(), errorCode)
			return ""
		}
		
		try {
			hDevInfoSet := SetupApi.SetupDiGetClassDevsW(hidGuid, 0, 0, DIGCF_DEVICEINTERFACE | DIGCF_PRESENT)
			if hDevInfoSet == INVALID_HANDLE_VALUE {
				errorCode := A_LastError
				err := OSErrorC("Failed to get Device Information Set: " GetErrorMessage(), errorCode)
				return ""
			}
			
			try {
				devInterfaceData := SP_DEVICE_INTERFACE_DATA()
				devicePathList := []
				
				mIndex := 0
				while SetupApi.SetupDiEnumDeviceInterfaces(hDevInfoSet, 0, hidGuid, mIndex, devInterfaceData) {
					
					_ := SetupApi.SetupDiGetDeviceInterfaceDetailW(hDevInfoSet, devInterfaceData, 0, 0, &requiredSize, 0)
					
					if A_LastError != ERROR_INSUFFICIENT_BUFFER {
						; TODO: to log
						continue
					}
					
					devInterfaceDetailData := SP_DEVICE_INTERFACE_DETAIL_DATA(requiredSize)
					
					succeeded := SetupApi.SetupDiGetDeviceInterfaceDetailW(
						hDevInfoSet,
						devInterfaceData,
						devInterfaceDetailData,
						requiredSize,
						&requiredSize, 0)
					
					if not succeeded {
						; TODO: to log
					} else {
						devicePathList.Push(devInterfaceDetailData.GetDevicePath())
					}
					
					mIndex++
				}
				
				return devicePathList
				
			} finally {
				if not SetupApi.SetupDiDestroyDeviceInfoList(hDevInfoSet) {
					; TODO: to log
				}
			}
		} finally {
			if not Kernel32.FreeLibrary(hModule) {
				; TODO: to log
			}
		}
	}
}