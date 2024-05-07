#Include <WinApi\Dll\Kernel32>

class StopWatch {
	static Frequency := 0
	
	_startingTime := 0
	_endingTime   := 0
	
	static __New() {
		Kernel32.QueryPerformanceFrequency(&frequency)
		this.Frequency := frequency
	}
	
	Start() {
		if this._endingTime {
			this._endingTime := 0
		}
		
		Kernel32.QueryPerformanceCounter(&startingTime)
		this._startingTime := startingTime
	}
	
	Stop() {
		if not this._startingTime {
			return
		}
		
		Kernel32.QueryPerformanceCounter(&endingTime)
		this._endingTime := endingTime
	}
	
	Reset() {
		this._startingTime := this._endingTime := 0
	}
	
	ElapsedMilliseconds => Round((this._endingTime-this._startingTime) * 1000 / StopWatch.Frequency)
	
	ElapsedMicroseconds => Round((this._endingTime-this._startingTime) * 1000000 / StopWatch.Frequency)
}