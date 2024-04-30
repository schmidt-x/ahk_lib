class SetupApi {
	
	static Name := "SetupApi.dll"
	
	
	/**
	 * The `SetupDiGetClassDevs` function returns a handle to a device information set that contains
	 * requested device information elements for a local computer.
	 * 
	 * @param {[in, optional] GUID *} classGuid
	 * A pointer to the `GUID` for a device setup class or a device interface class.
	 * 
	 * @param {[in, optional] PCWSTR} enumerator
	 * A pointer to a NULL-terminated string that specifies:
	 * - An identifier (ID) of a Plug and Play (PnP) enumerator.
	 * - A PnP device instance ID.
	 * 
	 * @param {[in, optional] HWND} hwndParent
	 * A handle to the top-level window to be used for a user interface that is associated with
	 * installing a device instance in the device information set.
	 * 
	 * @param {[in] DWORD} flags
	 * A variable of type `DWORD` that specifies control options that filter the device information
	 * elements that are added to the device information set.
	 * 
	 * @returns {Integer}
	 * If the operation succeeds, `SetupDiGetClassDevs` returns a handle to a device information set
	 * that contains all installed devices that matched the supplied parameters.<br>
	 * If the operation fails, the function returns `INVALID_HANDLE_VALUE`.
	 */
	static SetupDiGetClassDevsW(classGuid, enumerator, hwndParent, flags) {
		return DllCall("setupapi\SetupDiGetClassDevsW", "Ptr", classGuid, "Ptr", enumerator, "Ptr", hwndParent, "UInt", flags, "Ptr")
	}
	
	
	/**
	 * The `SetupDiDestroyDeviceInfoList` function deletes a device information set and frees all
	 * associated memory.
	 * 
	 * @param {[in] HDEVINFO} deviceInfoSet
	 * A handle to the device information set to delete.
	 * 
	 * @returns {Boolean}
	 * The function returns `true` if it is successful. Otherwise, it returns `false`.
	 */
	static SetupDiDestroyDeviceInfoList(deviceInfoSet) {
		return DllCall("setupapi\SetupDiDestroyDeviceInfoList", "Ptr", deviceInfoSet)
	}
	
	
	/**
	 * The `SetupDiEnumDeviceInterfaces` function enumerates the device interfaces that are contained
	 * in a device information set.
	 * 
	 * @param {[in] HDEVINFO} deviceInfoSet
	 * A pointer to a device information set that contains the device interfaces for which to return
	 * information. This handle is typically returned by `SetupDiGetClassDevs`.
	 * 
	 * @param {[in, optional] PSP_DEVINFO_DATA} deviceInfoData
	 * A pointer to an `SP_DEVINFO_DATA` structure that specifies a device information element in 
	 * `deviceInfoSet`.
	 * 
	 * @param {[in] GUID *} interfaceClassGuid
	 * A pointer to a `GUID` that specifies the device interface class for the requested interface.
	 * 
	 * @param {[in] DWORD} memberIndex
	 * A zero-based index into the list of interfaces in the device information set.
	 * 
	 * @param {[out] PSP_DEVICE_INTERFACE_DATA} deviceInterfaceData
	 * A pointer to a caller-allocated buffer that contains, on successful return, a completed 
	 * `SP_DEVICE_INTERFACE_DATA` structure that identifies an interface that meets the search parameters.
	 * 
	 * @returns {Boolean}
	 * `true` if the function completed without error. `false` otherwise.
	 */
	static SetupDiEnumDeviceInterfaces(deviceInfoSet, deviceInfoData, interfaceClassGuid, memberIndex, deviceInterfaceData) {
		return DllCall("setupapi\SetupDiEnumDeviceInterfaces",
			"Ptr", deviceInfoSet,
			"Ptr", deviceInfoData,
			"Ptr", interfaceClassGuid,
			"UInt", memberIndex,
			"Ptr", deviceInterfaceData)
	}
	
	
	/**
	 * The `SetupDiGetDeviceInterfaceDetail` function returns details about a device interface.
	 * 
	 * @param {[in] HDEVINFO} deviceInfoSet
	 * A pointer to the device information set that contains the interface for which to retrieve
	 * details. This handle is typically returned by `SetupDiGetClassDevs`.
	 * 
	 * @param {[in] PSP_DEVICE_INTERFACE_DATA} deviceInterfaceData
	 * A pointer to an SP_DEVICE_INTERFACE_DATA structure that specifies the interface in
	 * `DeviceInfoSet` for which to retrieve details. A pointer of this type is typically returned 
	 * by `SetupDiEnumDeviceInterfaces`.
	 * 
	 * @param {[out, optional] PSP_DEVICE_INTERFACE_DETAIL_DATA_W} deviceInterfaceDetailData
	 * A pointer to an `SP_DEVICE_INTERFACE_DETAIL_DATA` structure to receive information about the
	 * specified interface.
	 * 
	 * @param {[in] DWORD} deviceInterfaceDetailDataSize
	 * The size of the `deviceInterfaceDetailData` buffer.
	 * 
	 * @param {[out, optional] PDWORD} requiredSize
	 * A pointer to a variable of type `DWORD` that receives the required size of the 
	 * `DeviceInterfaceDetailData` buffer.
	 * 
	 * @param {[out, optional] PSP_DEVINFO_DATA} deviceInfoData
	 * A pointer to a buffer that receives information about the device that supports the requested
	 * interface.
	 * 
	 * @returns {Boolean}
	 * `true` if the function completed without error. `false` otherwise.
	 */
	static SetupDiGetDeviceInterfaceDetailW(
		deviceInfoSet,
		deviceInterfaceData,
		deviceInterfaceDetailData,
		deviceInterfaceDetailDataSize,
		&requiredSize,
		deviceInfoData)
	{
		return DllCall("setupapi\SetupDiGetDeviceInterfaceDetailW",
			"Ptr",   deviceInfoSet,
			"Ptr",   deviceInterfaceData,
			"Ptr",   deviceInterfaceDetailData,
			"UInt",  deviceInterfaceDetailDataSize,
			"UInt*", &requiredSize:=0,
			"Ptr",   deviceInfoData)
	}
	
}