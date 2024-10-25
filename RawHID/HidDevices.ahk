#Include HidDeviceInfo.ahk
#Include Helpers.ahk
#Include Errors.ahk
#Include WinApi.ahk

class HidDevices {
	
	; TODO: add docs
	static Find(vendorId, productId, usageId, usagePage, &err) {
		err := ""
		
		devicePaths := this._ListDevicePaths(&err)
		if err {
			return ""
		}
		
		if devicePaths.Length == 0 {
			err := DeviceNotFoundError()
			return ""
		}
		
		hModule := DllCall("kernel32\LoadLibraryW", "Str", "Hid.dll", "Ptr")
		if not hModule {
			errorCode := A_LastError
			err := OSErrorC("Failed to load Hid.dll library: " _GetErrorMessage(), errorCode)
			return ""
		}
		
		try {
			for devicePath in devicePaths {
				secAttributes := _SECURITY_ATTRIBUTES(0, true)
				
				hDevice := DllCall("CreateFileW", 
					"Ptr",  StrPtr(devicePath),
					"UInt", ACCESS_NONE,
					"UInt", FILE_SHARE_READ | FILE_SHARE_WRITE,
					"Ptr",  secAttributes,
					"UInt", OPEN_EXISTING,
					"UInt", 0,
					"Ptr",  0,
					"Ptr")
				
				if hDevice == INVALID_HANDLE_VALUE {
					; TODO: to log
					continue
				}
				
				try {
					hidAttributes := _HIDD_ATTRIBUTES()
					
					succeeded := DllCall("hid\HidD_GetAttributes", "Ptr", hDevice, "Ptr", hidAttributes)
					if not succeeded {
						; TODO: to log
						continue
					}
					
					if vendorId != hidAttributes.GetVendorID() || productId != hidAttributes.GetProductID() {
						continue
					}
					
					succeeded := DllCall("hid\HidD_GetPreparsedData", "Ptr", hDevice, "Ptr*", &preparsedData:=0)
					if not succeeded {
						; TODO: to log
						continue
					}
					
					try {
						caps := _HIDP_CAPS()
						
						succeeded := DllCall("hid\HidP_GetCaps", "Ptr", preparsedData, "Ptr", caps)
						if not succeeded {
							; TODO: to log
							continue
						}
						
						if caps.GetUsageID() != usageId || caps.GetUsagePage() != usagePage {
							continue
						}
						
						stringBuff := Buffer(254, 0)
						
						succeeded := DllCall("hid\HidD_GetManufacturerString",
							"Ptr",  hDevice,
							"Ptr",  stringBuff,
							"UInt", stringBuff.Size)
						
						if succeeded {
							manufacturerString := StrGet(stringBuff)
						} else {
							manufacturerString := "Unknown"
							; TODO: to log
						}
						
						succeeded := DllCall("hid\HidD_GetProductString", 
							"Ptr",  hDevice, 
							"Ptr",  stringBuff, 
							"UInt", stringBuff.Size)
						
						if succeeded {
							productString := StrGet(stringBuff)
						} else {
							productString := "Unknown"
							; TODO: to log
						}
						
						return HidDeviceInfo(
							devicePath,
							manufacturerString,
							productString,
							caps.GetInputReportByteLength(),
							caps.GetOutputReportByteLength(),
							vendorId,
							productId,
							usageId,
							usagePage)
						
					} finally {
						if not DllCall("hid\HidD_FreePreparsedData", "Ptr", preparsedData) {
							; TODO: to log
						}
					}
				} finally {
					if not DllCall("kernel32\CloseHandle", "Ptr", hDevice) {
						; TODO: to log
					}
				}
			}
			
			err := DeviceNotFoundError()
			return ""
			
		} finally {
			if not DllCall("kernel32\FreeLibrary", "Ptr", hModule) {
				; TODO: to log
			}
		}
	}
	
	; TODO: add docs
	static _ListDevicePaths(&err) {
		hidGuid := Buffer(16)
		DllCall("hid\HidD_GetHidGuid", "Ptr", hidGuid)
		
		hModule := DllCall("kernel32\LoadLibraryW", "Str", "SetupApi.dll", "Ptr")
		if not hModule {
			errorCode := A_LastError
			err := OSErrorC("Failed to load SetupApi.dll library: " _GetErrorMessage(), errorCode)
			return ""
		}
		
		try {
			hDevInfoSet := DllCall("setupapi\SetupDiGetClassDevsW", 
				"Ptr",  hidGuid,
				"Ptr",  0,
				"Ptr",  0,
				"UInt", DIGCF_DEVICEINTERFACE | DIGCF_PRESENT, "Ptr")
				
			if hDevInfoSet == INVALID_HANDLE_VALUE {
				errorCode := A_LastError
				err := OSErrorC("Failed to get Device Information Set: " _GetErrorMessage(), errorCode)
				return ""
			}
			
			try {
				devInterfaceData := _SP_DEVICE_INTERFACE_DATA()
				devicePathList := []
				
				mIndex := 0
				while DllCall("setupapi\SetupDiEnumDeviceInterfaces",
					"Ptr",  hDevInfoSet,
					"Ptr",  0,
					"Ptr",  hidGuid,
					"UInt", mIndex++,
					"Ptr",  devInterfaceData)
				{
					_ := DllCall("setupapi\SetupDiGetDeviceInterfaceDetailW",
						"Ptr",   hDevInfoSet,
						"Ptr",   devInterfaceData,
						"Ptr",   0,
						"UInt",  0,
						"UInt*", &requiredSize:=0,
						"Ptr",   0)
					
					if A_LastError != ERROR_INSUFFICIENT_BUFFER {
						; TODO: to log
						continue
					}
					
					devInterfaceDetailData := _SP_DEVICE_INTERFACE_DETAIL_DATA(requiredSize)
					
					succeeded := DllCall("setupapi\SetupDiGetDeviceInterfaceDetailW",
						"Ptr",  hDevInfoSet,
						"Ptr",  devInterfaceData,
						"Ptr",  devInterfaceDetailData,
						"UInt", requiredSize,
						"Ptr",  0,
						"Ptr",  0)
					
					if not succeeded {
						; TODO: to log
					} else {
						devicePathList.Push(devInterfaceDetailData.GetDevicePath())
					}
				}
				
				return devicePathList
				
			} finally {
				if not DllCall("setupapi\SetupDiDestroyDeviceInfoList", "Ptr", hDevInfoSet) {
					; TODO: to log
				}
			}
		} finally {
			if not DllCall("kernel32\FreeLibrary", "Ptr", hModule) {
				; TODO: to log
			}
		}
	}
}