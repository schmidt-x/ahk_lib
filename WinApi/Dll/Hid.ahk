class Hid {
	
	static Name := "Hid.dll"
	
	/**
	 * The `HidD_GetHidGuid` routine returns the device interface `GUID` for HIDClass devices.
	 * 
	 * @param {[out] LPGUID} hidGuid
	 * Pointer to a caller-allocated `GUID` buffer that the routine uses to return the device
	 * interface `GUID` for HIDClass devices.
	 */
	static HidD_GetHidGuid(hidGuid) {
		DllCall("hid\HidD_GetHidGuid", "Ptr", hidGuid)
	}
	
	/**
	 * The `HidD_GetAttributes` routine returns the attributes of a specified top-level collection.
	 * 
	 * @param {[in] HANDLE} hidDeviceObject
	 * Specifies an open handle to a top-level collection.
	 * 
	 * @param {[out] PHIDD_ATTRIBUTES} attributes
	 * Pointer to a caller-allocated `HIDD_ATTRIBUTES` structure that returns the attributes of
	 * the collection specified by `hidDeviceObject`.
	 * 
	 * @returns {Boolean}
	 * `true` if succeeds; otherwise, it returns `false`.
	 */
	static HidD_GetAttributes(hidDeviceObject, attributes) {
		return DllCall("hid\HidD_GetAttributes", "Ptr", hidDeviceObject, "Ptr", attributes)
	}
	
	/**
	 * The `HidD_GetPreparsedData` routine returns a top-level collection's preparsed data.
	 * 
	 * @param {[in] HANDLE} hidDeviceObject
	 * Specifies an open handle to a top-level collection.
	 * 
	 * @param {[out] PHIDP_PREPARSED_DATA *} preparsedData
	 * Pointer to the address of a routine-allocated buffer that contains a collection's 
	 * preparsed data in a `_HIDP_PREPARSED_DATA` structure.
	 * 
	 * @returns {Boolean}
	 * `true` if succeeds; otherwise, it returns `false`.
	 */
	static HidD_GetPreparsedData(hidDeviceObject, &preparsedData) {
		return DllCall("hid\HidD_GetPreparsedData", "Ptr", hidDeviceObject, "Ptr*", &preparsedData:=0)
	}
	
	/**
	 * The `HidD_FreePreparsedData` routine releases the resources that the HID class driver allocated
	 * to hold a top-level collection's preparsed data.
	 * 
	 * @param {[in] PHIDP_PREPARSED_DATA} preparsedData
	 * Pointer to the buffer, returned by `HidD_GetPreparsedData`, that is freed.
	 * 
	 * @returns {Boolean}
	 * `true` if it succeeds. Otherwise, it returns `false` if the buffer was not a preparsed data buffer
	 */
	static HidD_FreePreparsedData(preparsedData) {
		return DllCall("hid\HidD_FreePreparsedData", "Ptr", preparsedData)
	}
	
	/**
	 * The HidP_GetCaps routine returns a top-level collection's HIDP_CAPS structure.
	 * 
	 * @param {[in] PHIDP_PREPARSED_DATA} preparsedData
	 * Pointer to a top-level collection's preparsed data.
	 * 
	 * @param {[out] PHIDP_CAPS} capabilities
	 * Pointer to a caller-allocated buffer that the routine uses to return a collection's 
	 * `HIDP_CAPS` structure.
	 * 
	 * @returns {Integer}
	 * Returns one of the following status values:
	 * - `HIDP_STATUS_SUCCESS`: The routine successfully returned the collection capability information.<br>
	 * - `HIDP_STATUS_INVALID_PREPARSED_DATA`: The specified preparsed data is invalid.
	 */
	static HidP_GetCaps(preparsedData, capabilities) {
		return DllCall("hid\HidP_GetCaps", "Ptr", preparsedData, "Ptr", capabilities)
	}
}