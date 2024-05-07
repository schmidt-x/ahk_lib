# Raw HID

## Introduction

This is not a complete HID communication library. It's key, and only, functionalities are simply writing to and reading from a HID device.

It's been written to use with the devices that natively support handling raw input/output data. As an example of those, any keyboard that's powered by [QMK Firmware](https://github.com/qmk/qmk_firmware) can handle (send and receive) raw data using [RawHID Feature](https://docs.qmk.fm/#/feature_rawhid).

[Introduction to Human Interface Devices (HID)](https://learn.microsoft.com/en-us/windows-hardware/drivers/hid/)

As an example, you can take a look at the communication between the host (my PC) and the device (my keyboard):
- [PC](https://github.com/schmidt-x/Ahk_Lib/tree/main/Keyboards/I44.ahk)
- [Keyboard]() TODO


## How to use

### Including Lib

First of all, copy and paste `RawHID` and `WinApi` folders to your [AHK Script Library Folders](https://www.autohotkey.com/docs/v2/Scripts.htm#lib).

Then, include `HidDevices` and `HidDevice` files to your main script:

```ahk
#Requires AutoHotkey v2.0

#Include <RawHID\HidDevices>
#Include <RawHID\HidDevice>


; your hotkeys

^i:: {
  ; ...
}
```

### Finding Device

To find your device, call `HidDevices.Find(...)`. 

This method returns `HidDeviceInfo` object, that contains the device specific information:

```ahk
#Requires AutoHotkey v2.0

#Include <RawHID\HidDevices>
#Include <RawHID\HidDevice>

; both are keyboard specific
VendorID  := 0xFEED
ProductID := 0x0003

; default values for QMK Firmware
UsageID   := 0x61   ; The usage ID of the Raw HID interface
UsagePage := 0xFF60 ; The usage page of the Raw HID interface

DeviceInfo := HidDevices.Find(VendorID, ProductID, UsageID, UsagePage, &err)
if err {
  MsgBox("Error at finding the device: " err.Message)
  ExitApp()
}


^i:: { ; Ctrl + i
  MsgBox("DevicePath: " DeviceInfo.DevicePath)
}
```
> [!NOTE]
> If your keyboard is powered by QMK, `VendorID` and `ProductID` can easily be found in your keyboard's `info.json` file, under the `usb` object at: `...\qmk_firmware\keyboards\<keyboard>\info.json`.<br>
> Alternatively, you can use Device Manager on Windows.


### Writing Data

To communicate with the device, you need to instantiate a `HidDevice` class, passing `DeviceInfo`:

```ahk
device := HidDevice(DeviceInfo)

```

To simply send data to a device, call `.Write(...)` method:

```ahk
^i:: {
  device := HidDevice(DeviceInfo)
	
  ; Max Length of an output buffer is device.OutputBufferSize (32, if it's QMK device)
  outputBuffer := [1, 2, 3, 4, 5]
	
  device.Write(outputBuffer, &err)
  if err {
    MsgBox("Error at writing: " err.Message)
    return
  }
}
```

> [!NOTE]
> In this simple case, there is no need to manually open or close the device.
> It's automatically opened before writing, and closed after.<br>
> However, when writing multiple output data in a row, it's better to once manually open it, send the data, and close.


### Reading Data

To read data from a device, use `.Read(...)` method:

> [!IMPORTANT]
> When writing data and reading the response, the device **must** be manually opened and closed after.

```ahk
^i:: {
  device := HidDevice(DeviceInfo)
	
  device.Open(&err)
  if err {
    MsgBox("Error at opening: " err.Message)
    return
  }
	
  response := unset
	
  try {
    device.Write([1, 2, 3, 4, 5], &err)
    if err {
      MsgBox("Error at writing: " err.Message)
      return
    }

    timeout := 1000 ; ms

    ; The return type is an Array and its Length is always device.InputBufferSize (32, if it's QMK device)
    response := device.Read(timeout, &err)
    if err {
      if err is TimeoutError { ; true if it's timed out
        MsgBox("Timed out")
        return
      }

      MsgBox("Error at reading: " err.Message)
      return
    }
  } finally {
    device.Close()
  }
	
  msg := ""
  for i, v in response {
    msg .= Format("data[{1}] == {2}`n", i-1, v)
  }
	
  MsgBox(msg)
}
```
> [!NOTE]
> Usage of `MsgBox()` is for demonstration purposes only.<br>
> Personally, I do not recommend to use it for simply displaying errors, while there is a handle (or anythig that should be closed/released/freed) waiting for it to close, since `MsgBox()` blocks the executing thread until you close the dialog window.