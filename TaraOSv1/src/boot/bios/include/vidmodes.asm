; All VESA functions return 0x4F in AL if they are supported
; and use AH as a status flag, with 0x00 being success.
; This means that you should check that ax is 0x004F after each VESA call to see if it succeeded.
; VESA stopped assigning codes for video modes long ago -- 
; instead they standardized a much better solution: 
; you can query the video card for what modes it supports, 
; and query it about the attributes of each mode. 
; In your OS, you can have a function that you call with a 
; desired width, height, and depth, and it returns the video mode number for it 
; (or the closest match). Then, just set that mode

; Source: OSDEV

; THIS PROGRAM DOESN'T WORK YET!!!

; setvidmode:
; Sets a VESA mode
; In\	ax = Width
; In\	bx = Height
; In\	cx = Bits per pixel
; returns ax: 0 -> success, 1-> failure
setvidmode:
    mov [.width], ax
    mov [.height], bx
    mov [.bpp], cx

    sti

    push es
    push di

    mov ax, 0x4f00 ; get VBE BIOS info
    mov [es:di], VbeSignature ; Pointer to buffer in which to place VbeInfoBlock structure
    int 0x10
    
    ; Check if the call succeeded
    cmp ax, 0x004f
    jne .fail
    xor ax, ax
    jmp .end

.fail:
    mov ax, 1

.end:
    
    pop di
    pop es
    ret

.width dw 0
.height dw 0
.bpp dw 0 ; bits per pixel

; PMInfoBlock struc
Signature db 'PMID' ; PM Info Block Signature
EntryPoint dw 0 ; Offset of PM entry point within BIOS
PMInitialize dw 0 ; Offset of PM initialization entry point
BIOSDataSel dw 0 ; Selector to BIOS data area emulation block
A0000Sel dw 0xA000 ; Selector to access A0000h physical mem
B0000Sel dw 0xB000 ; Selector to access B0000h physical mem
B8000Sel dw 0xB800 ; Selector to access B8000h physical mem
CodeSegSel dw 0xC000 ; Selector to access code segment as data
InProtectMode db 0 ; Set to 1 when in protected mode
Checksum db 0 ; Checksum byte for structure
; PMInfoBlock ends

; VbeInfoBlock struc
VbeSignature db 'VESA' ; VBE Signature
VbeVersion dw 0x0300 ; VBE Version (0x0300 for VBE 3)
OemStringPtr dd 0 ; VbeFarPtr to OEM String
Capabilities db 4 dup 0 ; Capabilities of graphics controller
VideoModePtr dd 0 ; VbeFarPtr to VideoModeList
TotalMemory dw 0 ; Number of 64kb memory blocks
; Added for VBE 2.0+
OemSoftwareRev dw 0 ; VBE implementation Software revision
OemVendorNamePtr dd 0 ; VbeFarPtr to Vendor Name String
OemProductNamePtr dd 0 ; VbeFarPtr to Product Name String
OemProductRevPtr dd 0 ; VbeFarPtr to Product Revision String
Reserved db 222 dup 0 ; Reserved for VBE implementation scratch
; area
OemData db 256 dup 0 ; Data Area for OEM Strings
; VbeInfoBlock ends