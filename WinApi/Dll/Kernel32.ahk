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
}