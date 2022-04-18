[BITS 16]
[ORG 0x7c00]
global _start

_start:
    jmp short _boot
    
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

_boot:
    mov dl, [_SystemDriveNumber]
    
    call _CheckA20Status
    cmp ax, 1
    je _a20Enabled
    
    call _EnableA20BIOS
    call _CheckA20Status
    cmp ax, 1
    je _a20Enabled
    
    call _EnableA20WithKeyboard
    call _CheckA20Status
    cmp ax, 1
    je _a20Enabled
    
    call _EnableA20Fast     
    call _CheckA20Status
    cmp ax, 1
    je _a20Enabled
    
    call _ReadSecondStage
    
    mov bx, _ReadLoaderMessage
    call printStr
    call printNewline
    
    mov dl, [_SystemDriveNumber]
    mov si, 0
    jmp 0x7e00
    
    jmp $
    
_a20Enabled:    
    
    call _ReadSecondStage
    
    mov dl, [_SystemDriveNumber]
    mov si, 1
    jmp 0x7e00
    
    jmp $
    
_CheckA20Status:
    pushf
    push ds
    push es
    push di
    push si
    cli
    xor ax, ax
    mov es, ax
    not ax
    mov ds, ax
    mov di, 0x0500
    mov si, 0x0510
    mov al, byte [es:di]
    push ax
    mov al, byte [ds:si]
    push ax
    mov byte [es:di], 0x00
    mov byte [ds:si], 0xFF
    cmp byte [es:di], 0xFF
    pop ax
    mov byte [ds:si], al
    pop ax
    mov byte [es:di], al
    mov ax, 0
    je _CheckA20Status_exit
    mov ax, 1
_CheckA20Status_exit:
    pop si
    pop di
    pop es
    pop ds
    popf
    ret
    
_EnableA20WithKeyboard:
    cli
    call    A20IOWait
    mov     al,0xAD
    out     0x64,al
    call    A20IOWait
    mov     al,0xD0
    out     0x64,al
    call    A20IOWait2
    in      al,0x60
    push    eax
    call    A20IOWait
    mov     al,0xD1
    out     0x64,al
    call    A20IOWait
    pop     eax
    or      al,2
    out     0x60,al
    call    A20IOWait
    mov     al,0xAE
    out     0x64,al
    call    A20IOWait
    sti
    ret
A20IOWait:
    in      al,0x64
    test    al,2
    jnz     A20IOWait
    ret
A20IOWait2:
    in      al,0x64
    test    al,1
    jz      A20IOWait2
    ret

_EnableA20BIOS:
    pusha
    mov     ax,2403h
    int     15h
    jb      a20_failed
    cmp     ah,0
    jnz     a20_failed
    mov     ax,2402h
    int     15h
    jb      a20_failed
    cmp     ah,0
    jnz     a20_failed
    cmp     al,1
    jz      a20_activated
    mov     ax,2401h
    int     15h
    jb      a20_failed
    cmp     ah,0
    jnz     a20_failed
    popa
    ret
a20_activated:
    ret
a20_failed: 
    ret
   
_EnableA20Fast:
    pusha
    in al, 0x92
    test al, 2
    jnz after
    or al, 2
    and al, 0xFE
    out 0x92, al
    after:
    popa
    ret

_ReadSecondStage:
    pusha
    
    mov BYTE [_ReadRetries], 0x3
    
    ; check for extended BIOS functions
    mov ah, 0x41
    mov bx, 0x55aa
    mov dl, [_SystemDriveNumber]
    int 0x13
    
    jc .ExtensionsNotSupported
    
    mov si, _SecondStageStorageData
    mov dl, [_SystemDriveNumber]
    mov ah, 0x42
    int 0x13
    
    jc .ReadingFailed
    popa
    ret
    
.ExtensionsNotSupported:

.loop:
    ; try non extended read
    mov ah, 0x02
    mov al, 0x08
    mov ch, 0x00
    mov cl, 0x03
    mov dh, 0x00
    mov dl, [_SystemDriveNumber]
    mov bx, 0x7e00
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
   
   
_ReadRetries: db 0x00
_SystemDriveNumber: db 0x00
_ReadLoaderMessage: db "Read Loader, calling 0x7e00",0
_ReadFailedMessage: db "Reading failed",0
_SecondStageStorageData:
    db 0x10
    db 0x00
    dw 0x8
.of:dw 0x7e00
.sg:dw 0x0000
    dq 0x2

times 512 - ($-$$) db 0x00
    
    
    
    
    
    