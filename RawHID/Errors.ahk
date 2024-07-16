class OSErrorC extends Error {
	_errorCode := unset
	
	ErrorCode => this._errorCode
	
	__New(message, errorCode, what := -1) {
		this._errorCode := errorCode
		super.__New(message, what)
	}
}