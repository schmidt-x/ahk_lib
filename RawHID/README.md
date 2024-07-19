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

`HidDevice` class has 6 methods:

```ahk
Open(err: &Error[, desiredAccess: Integer])

Write(arr: Array, err: &Error)

WriteRaw(buff: Buffer, err: &Error)

Read(timeout: Integer, err: &Error) -> Array

ReadRaw(timeout: Integer, err: &Error) -> Buffer

Close()
```

and 4 properties:

```ahk
; Length of an array that is returned by .Read method
InputBufferSize

; Max length of an array that is passed to .Write method
OutputBufferSize

; Size of a buffer that is returned by .ReadRaw method
InputRawBufferSize

; Size of a buffer that is passed to .WriteRaw method
OutputRawBufferSize
```

> [!NOTE]
> Both `Write` and `Read` methods open the device and close it after, if the device was not initially opened.
> Same rule is applied to their `Raw` versions as well.<br>
> However, for repetitive calls, it's recommended to once manually open the device, read/write, and close it after.

> [!IMPORTANT]
> When writing the data and reading the immediate response, the device **should** be manually opened before (and closed after).

### Writing Data

To simply send data to a device, call `.Write(...)` method:

```ahk
^i:: {
  device := HidDevice(DeviceInfo)
	
  output := [1, 2, 3, 4, 5]
	
  device.Write(output, &err)
  if err {
    MsgBox("Error at writing: " err.Message)
    return
  }
}
```

Raw version:

```ahk
^i:: {
  device := HidDevice(DeviceInfo)

  output := Buffer(device.OutputRawBufferSize, 0)

  ; Note that the first byte is Report ID and should be ignored.
  ; Hence, we specify 1 as an Offset to skip it:
  NumPut(
    "UChar", 1,
    "UChar", 2,
    "UChar", 3,
    "UChar", 4,
    "UChar", 5,
    output, 1)

  device.WriteRaw(output, &err)
  if err {
    MsgBox("Error at writing: " err.Message)
    return
  }
}
```

### Reading Data

To read data from a device, use `.Read(...)` method:

> [!NOTE]
> By default, `.Open(...)` opens the device with both reading and writing access rights.<br>
> If you need it for only reading or only writing, pass one of the following flags as an optional parameter:
> - `HID_READ`
> - `HID_WRITE`

```ahk
^i:: {
  device := HidDevice(DeviceInfo)
	
  ; Since, in this case, we're going to only read from the device, it's opened with the reading rights.
  device.Open(&err, HID_READ)
  if err {
    MsgBox("Error at opening: " err.Message)
    return
  }
	
  try {
    timeout := 1000 ; ms

    loop {
      input := device.Read(timeout, &err)
      if err {
        if err is TimeoutError { ; true if it's timed out
          continue
        }
        
        MsgBox("Error at reading: " err.Message)
        return
      }

      ; Do something with the data

      MsgBox(Format("First 3 bytes: [{}, {}, {}].", input[1], input[2], input[3]))
  
    }
  } finally {
    device.Close()
  }
}
```

In its Raw version, the body of a loop would look like the following:

```ahk
; ...

loop {
  input := device.ReadRaw(timeout, &err)
  if err {
    ; ...
  }
	
  ; Do something with the data
	
  ; The first byte is Report ID and should be ignored.
  ; To access the actual data, start from the second byte, specifying an Offset as 1 + i'th index:
  byte1 := NumGet(input, 1, "UChar")
  byte2 := NumGet(input, 2, "UChar")
  byte3 := NumGet(input, 3, "UChar")
  
  MsgBox(Format("First 3 bytes: [{}, {}, {}]", byte1, byte2, byte3))
}

; ...
```

### Measuring Write-Read time in milliseconds

```ahk
DllCall("kernel32\QueryPerformanceFrequency", "Int64*", &Frequency:=0)

^i:: {
  DllCall("kernel32\QueryPerformanceCounter", "Int64*", &startingTime:=0)
	
  device := HidDevice(DeviceInfo)
	
  device.Open(&err)
  if err {
    MsgBox("Error at opening: " err.Message)
    return
  }
	
  try {
    device.Write([], &err)
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
	
  DllCall("kernel32\QueryPerformanceCounter", "Int64*", &endingTime:=0)
	
  elapsedMilliseconds := Round((endingTime - startingTime) * 1000 / Frequency)
  MsgBox(elapsedMilliseconds " ms")
}

```


> [!NOTE]
> Usage of `MsgBox()` is for demonstration purposes only.<br>
> Personally, I do not recommend to use it for simply displaying errors, while there is a handle (or anythig that should be closed/released/freed) waiting for it to close, since `MsgBox()` blocks the executing thread until you close the dialog window.