[BITS 16]
[ORG 0x600]
global _start

_start:
    jmp short _load
    
_BPB:
    db "TARAOS  "
    dw 0x00
    db 0x00
    dw 0x00
    db 0x00
    dw 0x00
    dw 0x00
    db 0x00
    dw 0x00
    dw 0x00
    dw 0x00 
    dd 0x00
    dd 0x00

_load:
    ; clear segments
    xor ax, ax
    mov ds, ax
    mov es, ax
    mov gs, ax
    mov ax, ax
    
    ; move this bootloader to 0x600
    mov cx, 0x100
    mov si, 0x7c00            
    mov di, 0x600            
    rep movsw
    
    ; clear code segment
    jmp 0x00:_boot

_boot:
    ; save drive number
    mov [_systemDriveNumber], dl
    
    ; set stack
    mov sp, 0x5ff
    mov bp, sp
    
    call _ReadVBR
    
    mov bx, _VBRReadMessage
    call printStr
    call printNewline
    
    mov dl, [_systemDriveNumber]
    jmp 0x0000:0x7c00
    
    jmp $
    
_ReadVBR:
    pusha
    
    mov BYTE [_ReadRetries], 0x3
    
    ; check for extended BIOS functions
    mov ah, 0x41
    mov bx, 0x55aa
    mov dl, [_systemDriveNumber]
    int 0x13
    
    jc .ExtensionsNotSupported
    
    mov si, _VBRStorageData
    mov dl, [_systemDriveNumber]
    mov ah, 0x42
    int 0x13
    
    jc .ReadingFailed
    popa
    ret
    
.ExtensionsNotSupported:

.loop:
    ; try non extended read
    mov ah, 0x02
    mov al, 0x01
    mov ch, 0x00
    mov cl, 0x02
    mov dh, 0x00
    mov dl, [_systemDriveNumber]
    mov bx, 0x7c00
    int 0x13
    
    dec BYTE [_ReadRetries]
    jc .ReadingFailed
    
.ReadingFailed:
    
    cmp BYTE [_ReadRetries], 0x00
    jne .loop
    
    ; if we tried 3 times and still fail just die 
    mov bx, _ReadFailedMessage
    call printStr
    call printNewline
    
    jmp $

printStr:
	push ax
	push bx
	mov ah, 0x0E
.loop:
	mov al, [bx]
	cmp al, 0x00
	je .return
	int 0x10
	inc bx
	jmp .loop
.return:
	pop bx
	pop ax
	ret

printNewline:
	push ax
	mov ah, 0x0E
	mov al, 10 ; newline
	int 0x10
	mov al, 13 ; carriage return
	int 0x10
	pop ax
	ret

_systemDriveNumber: db 0x00
_ReadRetries: db 0x00
_VBRReadMessage: db "VBR read, calling 0x7c00", 0
_ReadFailedMessage: db "Reading failed",0
_VBRStorageData:
    db 0x10
    db 0x00
    dw 0x1
.of:dw 0x7c00
.sg:dw 0x0000
    dq 0x1

times 446 - ($-$$) db 0x00

_partitionTable1:
    .driveAttributes:
        db 0x80
    .driveCHSStart:
        db 0x00
        db 0x00
        db 0x00
    .drivePartitionType:
        db 0x00
    .driveCHSLastSector:
        db 0x00
        db 0x00
        db 0x00
    .driveLBAStart:
        dd 0x1
    .driveSectorsSize:
        dd 0x200

_partitionTable2:
    .driveAttributes:
        db 0x00
    .driveCHSStart:
        db 0x00
        db 0x00
        db 0x00
    .drivePartitionType:
        db 0x00
    .driveCHSLastSector:
        db 0x00
        db 0x00
        db 0x00
    .driveLBAStart:
        dd 0x00
    .driveSectorsSize:
        dd 0x00

_partitionTable3:
    .driveAttributes:
        db 0x00
    .driveCHSStart:
        db 0x00
        db 0x00
        db 0x00
    .drivePartitionType:
        db 0x00
    .driveCHSLastSector:
        db 0x00
        db 0x00
        db 0x00
    .driveLBAStart:
        dd 0x00
    .driveSectorsSize:
        dd 0x00

_partitionTable4:
    .driveAttributes:
        db 0x00
    .driveCHSStart:
        db 0x00
        db 0x00
        db 0x00
    .drivePartitionType:
        db 0x00
    .driveCHSLastSector:
        db 0x00
        db 0x00
        db 0x00
    .driveLBAStart:
        dd 0x00
    .driveSectorsSize:
        dd 0x00

dw 0xAA55
