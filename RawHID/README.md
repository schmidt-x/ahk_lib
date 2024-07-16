# Raw HID

## Introduction

This is not a complete HID communication library. It's key, and only, functionalities are simply writing to and reading from a HID device.

It's been written to use with the devices that natively support handling raw input/output data. As an example of those, any keyboard that's powered by [QMK Firmware](https://github.com/qmk/qmk_firmware) can handle (send and receive) raw data using [RawHID Feature](https://docs.qmk.fm/#/feature_rawhid).

[Introduction to Human Interface Devices (HID)](https://learn.microsoft.com/en-us/windows-hardware/drivers/hid/)

As an example, you can take a look at the communication between the host (my PC) and the device (my keyboard):
- [PC](https://github.com/schmidt-x/Ahk_Lib/tree/main/Keyboards/I44.ahk)
- Keyboard: [keymap.c](https://github.com/schmidt-x/qmk_firmware/blob/schmidt-x/keyboards/ergohaven/imperial44/keymaps/schmidt-x/keymap.c#L344) and [hid.c](https://github.com/schmidt-x/qmk_firmware/blob/schmidt-x/users/schmidt-x/hid.c)


## How to use

### Including Lib

First of all, copy and paste `RawHID` folder to your [AHK Script Library Folders](https://www.autohotkey.com/docs/v2/Scripts.htm#lib).

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


### Communication

To communicate with the device, you need to instantiate a `HidDevice` class, passing `HidDeviceInfo` object, that is returned by `.Find(...)`:

```ahk
device := HidDevice(DeviceInfo)
```
`HidDevice` class has 4 methods:
- `Open(err: &Error[, desiredAccess: Integer])`
- `Write(output: Array, err: &Error)`
- `Read(timeout: Integer, err: &Error) -> Array`
- `Close()`

> [!NOTE]
> Both `Write` and `Read` open the device and close it after, if the device was not initially opened.<br>
> However, for repetitive calls, it's recommended to once manually open the device, read/write, and close it after.

> [!IMPORTANT]
> When writing the data and reading the immediate response, the device **should** be manually opened before (and closed after).

### Writing Data

To simply send data to a device, call `.Write(...)` method:

```ahk
^i:: {
  device := HidDevice(DeviceInfo)
	
  ; Max Length of an output buffer is device.OutputBufferSize (32, if it's QMK device)
  output := [1, 2, 3, 4, 5]
	
  device.Write(output, &err)
  if err {
    MsgBox("Error at writing: " err.Message)
    return
  }
}
```

### Reading Data

To read data from a device, use `.Read(...)` method:

```ahk
^i:: {
  device := HidDevice(DeviceInfo)

  ; By default, .Open() opens the device with both reading and writing access rights.
  ; If you need it for only reading or only writing, pass one of the following flags as an optional parameter:
  ; - HID_READ
  ; - HID_WRITE
	
  ; Since, in this case, we're going to only read from the device, it's opened with the reading rights.
  device.Open(&err, HID_READ)
  if err {
    MsgBox("Error at opening: " err.Message)
    return
  }
	
  try {
    timeout := 1000 ; ms

    loop {
      ; The Length of an input buffer is always device.InputBufferSize (32, if it's QMK device)
      input := device.Read(timeout, &err)
      if err {
        if err is TimeoutError { ; true if it's timed out
          continue
        }
        
        MsgBox("Error at reading: " err.Message)
        return
      }

      ; Do something with the data
  
    }
  } finally {
    device.Close()
  }
}
```

### Measuring Write-Read time in milliseconds

```ahk
DllCall("QueryPerformanceFrequency", "Int64*", &Frequency:=0)

^i:: {
  DllCall("QueryPerformanceCounter", "Int64*", &startingTime:=0)
	
  device := HidDevice(DeviceInfo)
	
  device.Open(&err)
  if err {
    MsgBox("Error at opening: " err.Message)
    return
  }
	
  try {
    device.Write([255], &err)
    if err {
      MsgBox("Error at writing: " err.Message)
      return
    }
		
    _ := device.Read(1000, &err)
    if err {
      MsgBox("Error at reading: " err.Message)
      return
    }
		
  } finally {
    device.Close()
  }
	
  DllCall("QueryPerformanceCounter", "Int64*", &endingTime:=0)
	
  elapsedMilliseconds := Round((endingTime - startingTime) * 1000 / Frequency)
  MsgBox(elapsedMilliseconds " ms")
}

```


> [!NOTE]
> Usage of `MsgBox()` is for demonstration purposes only.<br>
> Personally, I do not recommend to use it for simply displaying errors, while there is a handle (or anythig that should be closed/released/freed) waiting for it to close, since `MsgBox()` blocks the executing thread until you close the dialog window.