/**
 * Simple QPC wrapper.
 * https://learn.microsoft.com/en-us/windows/win32/sysinfo/acquiring-high-resolution-time-stamps
 * 
 * How to use:
 * 
 * ```ahk
 * #Requires AutoHotkey v2.0
 * 
 * sw := Stopwatch()
 * sw.Start()
 * ; or 
 * sw := Stopwatch.StartNew()
 * 
 * ; Activity to be timed
 * sw.Stop()
 * 
 * MsgBox(sw.ElapsedMilliseconds)
 * MsgBox(sw.ElapsedMicroseconds)
 * ```
 */
class Stopwatch {
	_isRunning := false
	_startTimeStamp := 0
	_elapsed := 0
	
	static Frequency := (DllCall("Kernel32\QueryPerformanceFrequency", "Int64*", &f:=0), f)
	
	static StartNew() {
		sw := Stopwatch()
		sw.Start()
		return sw
	}
	
	Start() {
		if !this._isRunning {
			this._startTimeStamp := this._GetTimeStamp()
			this._isRunning := true
		}
	}
	
	Stop() {
		if this._isRunning {
			this._elapsed += this._GetTimeStamp() - this._startTimeStamp
			this._isRunning := false
		}
	}
	
	Reset() {
		this._startTimeStamp := this._elapsed := this._isRunning := 0
	}
	
	Restart() {
		this._elapsed := 0
		this._startTimeStamp := this._GetTimeStamp()
		this._isRunning := true
	}
	
	ElapsedMilliseconds => Round(this._GetRawElapsedTicks() * 1000 / Stopwatch.Frequency)
	
	ElapsedMicroseconds => Round(this._GetRawElapsedTicks() * 1000000 / Stopwatch.Frequency)
	
	
	_GetRawElapsedTicks() {
		elapsed := this._elapsed
		if this._isRunning {
			elapsed += this._GetTimeStamp() - this._startTimeStamp
		}
		return elapsed
	}
	
	_GetTimeStamp() {
		DllCall("Kernel32\QueryPerformanceCounter", "Int64*", &timeStamp:=0)
		return timeStamp
	}
}