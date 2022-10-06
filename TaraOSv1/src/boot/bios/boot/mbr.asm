[BITS 16]
[ORG 0x600]



global _move

_move:
    cli
    xor ax, ax ; Reset segments 
	mov es, ax
	mov ds, ax
	mov gs, ax
	mov fs, ax
    
    mov cx, 0x100 ; Move 0x100 words 
    mov si, 0x7c00 ; From 0x7c00
    mov di, 0x600 ; To 0x500
    rep movsw ; Move
    
	jmp 0x0:_start ; Make sure we are in 0x0:0xxxx, Long Jump
    
_start:
    sti
    mov [Drive], dl ; Save drive number given to us by BIOS
    
    mov ss, [BootloaderStackSegment] ; Set stack segment 0x0000
    mov bp, [BootloaderStack] ; Set stack 0x7c00
    mov sp, bp ; The stack starts from 0x7c00 = 0x0 * 0x10 + 0x7c00
    
    mov si, WelcomeMessage
    call printstr
    
    mov dl, [Drive] ; Drive Number
    mov cl, 0x02 ; Start Sector
    mov ch, 0x00 ; Start Cylinder
    mov dh, 0x00 ; Start Head
    mov bx, 0x7c00 ; To 0x7c00
    call readOneSectorLegacy ; Read one sector, aka the VBR

    jc .legacyError
    
    mov dl, [Drive]
    jmp 0x0000:0x7c00

.legacyError:
    
    mov dl, [Drive]
    call checkBIOSReadExtensions
    
    cmp ah, 0x01
    mov si, ExtensionsNotSupportedMessage
    je .error
    
    mov dl, [Drive]
    mov cx, 0x01
    xor ax, ax
    mov ds, ax
    mov si, 0x7c00
    call readOneSectorExtended
    mov si, LoadErrorMessage
    jc .error
    
    mov dl, [Drive]
    jmp 0x0000:0x7c00
    
.error:
    
    call printstr
    
    jmp $

%include "diskread.asm"
%include "printstr.asm"

Drive: resb 1
BootloaderStackSegment: dw 0x0000
BootloaderStack: dw 0x7c00
WelcomeMessage: db "Welcome to TaraOS MBR. Loading VBR...", 10, 13, 0
LoadErrorMessage: db "Error Loading VBR!", 10, 13, 0
ExtensionsNotSupportedMessage: db "BIOS Extensions Not Supported", 10, 13, 0

times 446 - ($ - $$) db 0x00

partition_table_1:
    db 0x80 ; Status, 0x80 means active
    db 0x00 ; First Absolute Sector CHS
    db 0x00 ; 
    db 0x00 ;  
    db 0x00 ; Partition Type
    db 0x00 ; Last Absolute Sector CHS
    db 0x00 ; 
    db 0x00 ; 
    dd 0x00000001 ; First Absolute Sector LBA
    dd 0x00000200 ; Number of Sectors
    
partition_table_2:
    db 0x00 ; Status, 0x80 means active
    db 0x00 ; First Absolute Sector CHS
    db 0x00 ; 
    db 0x00 ;  
    db 0x00 ; Partition Type
    db 0x00 ; Last Absolute Sector CHS
    db 0x00 ; 
    db 0x00 ; 
    dd 0x00000000 ; First Absolute Sector LBA
    dd 0x00000000 ; Number of Sectors
    
partition_table_3:
    db 0x00 ; Status, 0x80 means active
    db 0x00 ; First Absolute Sector CHS
    db 0x00 ; 
    db 0x00 ;  
    db 0x00 ; Partition Type
    db 0x00 ; Last Absolute Sector CHS
    db 0x00 ; 
    db 0x00 ; 
    dd 0x00000000 ; First Absolute Sector LBA
    dd 0x00000000 ; Number of Sectors
    
partition_table_4:
    db 0x00 ; Status, 0x80 means active
    db 0x00 ; First Absolute Sector CHS
    db 0x00 ; 
    db 0x00 ;  
    db 0x00 ; Partition Type
    db 0x00 ; Last Absolute Sector CHS
    db 0x00 ; 
    db 0x00 ; 
    dd 0x00000000 ; First Absolute Sector LBA
    dd 0x00000000 ; Number of Sectors

dw 0xaa55 ; Boot Signature

