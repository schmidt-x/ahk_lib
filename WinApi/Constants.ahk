; --- winuser.h ---

WM_KEYDOWN := 0x0100
WM_ACTIVATE := 0x0006

VK_BACK   := 0x08
VK_RETURN := 0x0D
VK_ESCAPE := 0x1B

WA_INACTIVE := 0


; --- hidpi.h ---

HIDP_STATUS_SUCCESS := 0x00110000
HIDP_STATUS_INVALID_PREPARSED_DATA := 0xC0110001


; --- winnt.h ---

FILE_SHARE_NONE   := 0
FILE_SHARE_READ   := 0x00000001
FILE_SHARE_WRITE  := 0x00000002
FILE_SHARE_DELETE := 0x00000004

ACCESS_NONE   := 0
GENERIC_WRITE := 0x40000000
GENERIC_READ  := 0x80000000


; --- winbase.h ---

FILE_FLAG_OVERLAPPED := 0x40000000


; --- fileapi.h ---

OPEN_EXISTING := 3


; --- ntrxdef ---

INVALID_HANDLE_VALUE := -1


; --- setupapi.h ---

; Flags controlling what is included in the device information set built
; by SetupDiGetClassDevs

DIGCF_DEFAULT         := 0x00000001 ; only valid with DIGCF_DEVICEINTERFACE
DIGCF_PRESENT         := 0x00000002
DIGCF_ALLCLASSES      := 0x00000004
DIGCF_PROFILE         := 0x00000008
DIGCF_DEVICEINTERFACE := 0x00000010


; --- todo ---

; ERROR_IO_PENDING := 0 ; TODO



