class Kernel32 {
	
	/**
	 * Creates or opens a file or I/O device.
	 * 
	 * @param {[in] LPCWSTR} lpFileName
	 * The name of the file or device to be created or opened.
	 * 
	 * @param {[in] DWORD} dwDesiredAccess
	 * The requested access to the file or device, which can be summarized as `GENERIC_READ`, `GENERIC_WRITE`,
	 * both or neither (`ACCESS_NONE`).
	 * 
	 * @param {[in] DWORD} dwShareMode
	 * The requested sharing mode of the file or device, which can be `read`, `write`, both,
	 * `delete`, all of these, or `none`.
	 * 
	 * @param {[in, optional] LPSECURITY_ATTRIBUTES} lpSecurityAttributes
	 * A pointer to a `SECURITY_ATTRIBUTES` structure.
	 * 
	 * @param {[in] DWORD} dwCreationDisposition
	 * An action to take on a file or device that exists or does not exist.
	 * 
	 * @param {[in] DWORD} dwFlagsAndAttributes
	 * The file or device attributes and flags.
	 * 
	 * @param {[in, optional] HANDLE} hTemplateFile
	 * A valid handle to a template file with the `GENERIC_READ` access right.
	 * 
	 * @returns {Integer}
	 * If the function succeeds, the return value is an open handle to the specified file, device,
	 * named pipe, or mail slot.
	 * If the function fails, the return value is `INVALID_HANDLE_VALUE`.
	 */
	static CreateFileW(lpFileName,
		dwDesiredAccess,
		dwShareMode,
		lpSecurityAttributes,
		dwCreationDisposition,
		dwFlagsAndAttributes,
		hTemplateFile)
	{
		return DllCall("kernel32\CreateFileW",
			"Ptr",  StrPtr(lpFileName),
			"UInt", dwDesiredAccess,
			"UInt", dwShareMode,
			"Ptr",  lpSecurityAttributes,
			"UInt", dwCreationDisposition,
			"UInt", dwFlagsAndAttributes,
			"Ptr",  hTemplateFile,
			"Ptr")
	}
	
	/**
	 * Writes data to the specified file or input/output (I/O) device.
	 * 
	 * @param {[in] HANDLE} hFile
	 * A handle to the file or I/O device.
	 * 
	 * @param {[in] LPCVOID} lpBuffer
	 * A pointer to the buffer containing the data to be written to the file or device.
	 * 
	 * @param {[in] DWORD} nNumberOfBytesToWrite
	 * The number of bytes to be written to the file or device.
	 * 
	 * @param {[out, optional] LPDWORD} lpNumberOfBytesWritten
	 * A pointer to the variable that receives the number of bytes written when using a synchronous
	 * `hFile` parameter. Use `0` for this parameter if this is an asynchronous operation to avoid
	 * potentially erroneous results.
	 * 
	 * @param {[in, out, optional] LPOVERLAPPED} lpOverlapped
	 * A pointer to an OVERLAPPED structure is required if the `hFile` parameter was opened with
	 * `FILE_FLAG_OVERLAPPED`, otherwise this parameter can be `0`.
	 * 
	 * @returns {Boolean}
	 * If the function succeeds, the return value is `true`.
	 * If the function fails, the return value is `false`.<br>
	 * If the function is completing asynchronously, the return value is `false` with
	 * `A_LastError` set to `ERROR_IO_PENDING`.
	 */
	static WriteFile(hFile, lpBuffer, nNumberOfBytesToWrite, &lpNumberOfBytesWritten, lpOverlapped) {
		return DllCall("kernel32\WriteFile",
			"Ptr",   hFile,
			"Ptr",   lpBuffer,
			"UInt",  nNumberOfBytesToWrite,
			"UInt*", &lpNumberOfBytesWritten:=0,
			"Ptr",   lpOverlapped)
	}
	
	/**
	 * Reads data from the specified file or input/output (I/O) device.
	 * 
	 * @param {[in] HANDLE} hFile
	 * A handle to the opened device. The `hFile` parameter must have been created with
	 * `read` access.<br>
	 * For asynchronous read operations, `hFile` can be any handle that is
	 * opened with the `FILE_FLAG_OVERLAPPED` flag by the `CreateFile` function.
	 * 
	 * @param {[out] LPVOID} lpBuffer
	 * A pointer to the buffer that receives the data read from a file or device.
	 * 
	 * @param {[in] DWORD} nNumberOfBytesToRead
	 * The maximum number of bytes to be read.
	 * 
	 * @param {[out, optional] LPDWORD} lpNumberOfBytesRead
	 * A pointer to the variable that receives the number of bytes read when using a synchronous
	 * `hFile` parameter.<br> 
	 * If the operation is asynchronous, the received number when this function returned is `0`.
	 * To get the actual number of bytes read, use the `GetOverlappedResult` function.
	 * 
	 * @param {[in, out, optional] LPOVERLAPPED} lpOverlapped
	 * A pointer to an `OVERLAPPED` structure is required if the `hFile` parameter was opened
	 * with `FILE_FLAG_OVERLAPPED`, otherwise it can be `0`.
	 * 
	 * @returns {Boolean}
	 * If the function succeeds, the return value is `true`.
	 * If the function fails, the return value is `false`.<br>
	 * If the function is completing asynchronously, the return value is `false` with
	 * `A_LastError` set to `ERROR_IO_PENDING`.
	 */
	static ReadFile(hFile, lpBuffer, nNumberOfBytesToRead, &lpNumberOfBytesRead, lpOverlapped) {
		return DllCall("kernel32\ReadFile",
			"Ptr",   hFile,
			"Ptr",   lpBuffer,
			"UInt",  nNumberOfBytesToRead,
			"UInt*", &lpNumberOfBytesRead:=0,
			"Ptr",   lpOverlapped)
	}
	
	
	/**
	 * Closes an open object handle.
	 * 
	 * @param {[in] HANDLE} hObject
	 * A valid handle to an open object.
	 * 
	 * @returns {Boolean}
	 * If the function succeeds, the return value is `true`.
	 * Otherwise, it returns `false`.
	 */
	static CloseHandle(hObject) {
		return DllCall("kernel32\CloseHandle", "Ptr", hObject)
	}
	
	/**
	 * Loads the specified module into the address space of the calling process.
	 * The specified module may cause other modules to be loaded.
	 * 
	 * @param {[in] LPCWSTR} lpLibFileName
	 * The name of the module.
	 * 
	 * @returns {Integer}
	 * If the function succeeds, the return value is a handle to the module.
	 * If the function fails, the return value is `0`
	 */
	static LoadLibraryW(lpLibFileName) {
		return DllCall("kernel32\LoadLibraryW", "Str", lpLibFileName, "Ptr")
	}
	
	/**
	 * Frees the loaded dynamic-link library (DLL) module.
	 * 
	 * @param {[in] HMODULE} hLibModule
	 * A handle to the loaded library module.
	 * 
	 * @returns {Boolean}
	 * If the function succeeds, the return value is `true`. `false` otherwise.
	 */
	static FreeLibrary(hLibModule) {
		return DllCall("kernel32\FreeLibrary", "Ptr", hLibModule)
	}
	
	/**
	 * Creates or opens a named or unnamed event object.
	 * 
	 * @param {[in, optional] LPSECURITY_ATTRIBUTES} lpEventAttributes
	 * A pointer to a `SECURITY_ATTRIBUTES` structure.
	 * 
	 * @param {[in] BOOL} bManualReset
	 * Defines if the event is reset manually with `ResetEvent()` (`true`), or 
	 * automatically after releasing a waiting thread (`false`).
	 * 
	 * @param {[in] BOOL} bInitialState
	 * If this parameter is `true`, the initial state of the event object is `signaled`;
	 * otherwise, it is `nonsignaled`.
	 * 
	 * @param {[in, optional] LPCWSTR} lpName
	 * The name of the event object. The name is limited to `MAX_PATH` characters. Name
	 * comparison is case sensitive.
	 * 
	 * @returns {Integer}
	 * If the function succeeds, the return value is a handle to the event object.
	 * If the function fails, the return value is `0`.
	 */
	static CreateEventW(lpEventAttributes, bManualReset, bInitialState, lpName) {
		return DllCall("kernel32\CreateEventW",
			"Ptr", lpEventAttributes,
			"Int", bManualReset,
			"Int", bInitialState,
			"Ptr", lpName,
			"Ptr")
	}
	
	/**
	 * Waits until the specified object is in the signaled state or the time-out
	 * interval elapses.
	 * 
	 * @param {[in] HANDLE} hHandle
	 * A handle to one of the following objects:
	 * - Change notification
	 * - Console input
	 * - Event
	 * - Memory resource notification
	 * - Mutex
	 * - Process
	 * - Semaphore
	 * - Thread
	 * - Waitable timer
	 * 
	 * @param {[in] DWORD} dwMilliseconds
	 * The time-out interval, in milliseconds.<br>
	 * If a nonzero value is specified, the function waits until the object is signaled 
	 * or the interval elapses.<br>
	 * If `dwMilliseconds` is zero, the function does not enter a wait state if the object
	 * is not signaled; it always returns immediately.<br>
	 * If `dwMilliseconds` is `INFINITE`, the function will return only when the object is 
	 * signaled.
	 * 
	 * @returns {Integer}
	 * The return value indicates the event that caused the function to return. It can be 
	 * one of the following values:
	 * 
	 * - `WAIT_ABANDONED`: The specified object is a mutex object that was not released by
	 * the thread that owned the mutex object before the owning thread terminated.
	 * 
	 * - `WAIT_OBJECT_0`: The state of the specified object is signaled.
	 * 
	 * - `WAIT_TIMEOUT`: The time-out interval elapsed, and the object's state is nonsignaled.
	 * 
	 * - `WAIT_FAILED`: The function has failed. To get extended error information, see `A_LastError`.
	 */
	static WaitForSingleObject(hHandle, dwMilliseconds) {
		return DllCall("kernel32\WaitForSingleObject", "Ptr", hHandle, "UInt", dwMilliseconds)
	}
	
	/**
	 * Marks any outstanding I/O operations for the specified file handle. The function
	 * only cancels I/O operations in the current process, regardless of which thread
	 * created the I/O operation.
	 * 
	 * @param {[in] HANDLE} hFile
	 * A handle to the file or device.
	 * 
	 * @param {[in, optional] LPOVERLAPPED} lpOverlapped
	 * A pointer to an `OVERLAPPED` data structure that contains the data used for asynchronous I/O.
	 * If this parameter is `0`, all I/O requests for the `hFile` parameter are canceled.
	 * 
	 * @returns {Boolean}
	 * If the function succeeds, the return value is `true`; otherwise - `false`,
	 */
	static CancelIoEx(hFile, lpOverlapped) {
		return DllCall("kernel32\CancelIoEx", "Ptr", hFile, "Ptr", lpOverlapped)
	}
	
}