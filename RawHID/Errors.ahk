class OSErrorC extends Error {
	_errorCode := unset
	
	ErrorCode => this._errorCode
	
	__New(message, errorCode, what := -1) {
		this._errorCode := errorCode
		super.__New(message, what)
	}
}

class DeviceNotConnectedError extends Error {
	__New(message := "Device not connected.", what := -1) {
		super.__New(message, what)
	}
}

class DeviceNotFoundError extends Error {
	__New(message := "Device not found.", what := -1) {
		super.__New(message, what)
	}
}