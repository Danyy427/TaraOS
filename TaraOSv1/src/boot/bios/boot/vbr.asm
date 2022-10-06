[BITS 16]
[ORG 0x7c00]

global _vbr

_vbr:
    mov [Drive], dl

    mov si, WelcomeToVbrMessage ; Test if we loaded VBR correctly
    call printstr
    
    mov dl, [Drive] ; Drive Number
    mov cl, 0x03 ; Start Sector
    mov ch, 0x00 ; Start Cylinder
    mov dh, 0x00 ; Start Head
    mov bx, 0x7e00 ; To 0x7e00
    mov al, 0x08
    call readNSectorLegacy ; Read eight sectors, the second stage bootloader
    jc .legacyError

    mov dl, [Drive]
    jmp 0x0000:0x7e00

    jmp $
    

.legacyError:
    
    mov dl, [Drive]
    call checkBIOSReadExtensions
    
    cmp ah, 0x01
    mov si, ExtensionsNotSupportedMessage
    je .error
    
    mov dl, [Drive]
    mov cx, 0x02
    xor ax, ax
    mov ds, ax
    mov si, 0x7e00
    mov bx, 0x08
    call readNSectorExtended
    mov si, LoadErrorMessage
    jc .error
    
    mov dl, [Drive]
    jmp 0x0000:0x7e00
    
.error:
    
    call printstr
    
    jmp $

%include "diskread.asm"
%include "printstr.asm"

Drive: db 0x00
WelcomeToVbrMessage: db "VBR Loaded succesfully, now loading second stage bootloader", 10, 13, 0
LoadErrorMessage: db "Error Loading Second Stage!", 10, 13, 0
ExtensionsNotSupportedMessage: db "BIOS Extensions Not Supported", 10, 13, 0

times 510 - ($ - $$) db 0x00
dw 0xaa55
