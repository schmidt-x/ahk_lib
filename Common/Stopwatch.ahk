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
	static Frequency := 0
	
	_startingTime := 0
	_endingTime   := 0
	
	static __New() {
		DllCall("Kernel32\QueryPerformanceFrequency", "Int64*", &frequency:=0)
		this.Frequency := frequency
	}
	
	static StartNew() {
		sw := Stopwatch()
		sw.Start()
		return sw
	}
	
	
	Start() {
		if this._endingTime {
			this._endingTime := 0
		}
		
		DllCall("Kernel32\QueryPerformanceCounter", "Int64*", &startingTime:=0)
		this._startingTime := startingTime
	}
	
	Stop() {
		if not this._startingTime {
			return
		}
		
		DllCall("Kernel32\QueryPerformanceCounter", "Int64*", &endingTime:=0)
		this._endingTime := endingTime
	}
	
	Reset() {
		this._startingTime := this._endingTime := 0
	}
	
	ElapsedMilliseconds => Round((this._endingTime-this._startingTime) * 1000 / Stopwatch.Frequency)
	
	ElapsedMicroseconds => Round((this._endingTime-this._startingTime) * 1000000 / Stopwatch.Frequency)
}