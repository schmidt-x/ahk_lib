class HidDeviceInfo {
	DevicePath := unset
	
	InputReportByteLength  := unset
	OutputReportByteLength := unset
	
	VendorID  := unset
	ProductID := unset
	
	UsageID   := unset
	UsagePage := unset
	
	__New(
		devicePath,
		inputReportByteLength,
		outputReportByteLength,
		venrodID,
		productID,
		usageID,
		usagePage) 
	{
		this.DevicePath := devicePath
		this.InputReportByteLength := inputReportByteLength
		this.OutputReportByteLength := outputReportByteLength
		this.VendorID := venrodID
		this.ProductID := productID
		this.UsageID := usageID
		this.UsagePage := usagePage
	}
}