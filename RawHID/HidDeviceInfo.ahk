class HidDeviceInfo {
	DevicePath := unset
	
	ManufacturerString := unset
	ProductString := unset
	
	InputReportByteLength  := unset
	OutputReportByteLength := unset
	
	VendorID  := unset
	ProductID := unset
	
	UsageID   := unset
	UsagePage := unset
	
	__New(
		devicePath,
		manufacturerString,
		productString,
		inputReportByteLength,
		outputReportByteLength,
		venrodID,
		productID,
		usageID,
		usagePage) 
	{
		this.DevicePath := devicePath
		this.ManufacturerString := manufacturerString
		this.ProductString := productString
		this.InputReportByteLength := inputReportByteLength
		this.OutputReportByteLength := outputReportByteLength
		this.VendorID := venrodID
		this.ProductID := productID
		this.UsageID := usageID
		this.UsagePage := usagePage
	}
}