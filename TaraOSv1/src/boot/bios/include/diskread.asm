[BITS 16]

;
; Gets CHS drive parameters
; Output: ax: Maximum cylinder number
;         dh: Maximum head number
;         cl: Maximum sector number
;

getCHSDriveParameters:
    push es
    push di
    push dx

    xor di, di
    mov es, di ; es:di = 0x0000 to avoid BIOS bugs
    mov ah, 0x08 ; Get drive parameters
    int 0x13

    mov byte [MaximumHead], dh ; dh is the maximum head number

    push cx ; Save cx value
    and cl, 0b00111111 ; Gets maximum sector number 0-5 bits
    mov byte [MaximumSector], cl
    pop cx ; Restore cx value
    
    and cl, 0b11000000 ; Gets higher two bits of cylinder number 6-7 bits
    shr cl, 0x06 ; Shift right two get the higher two bits to lowest two bits
    mov ah, cl
    mov al, ch ; Construct the total cylinder number in ax
    mov dh, byte [MaximumHead] ; Head number in dh
    mov cl, byte [MaximumSector] ; Sector number in cl

    pop dx
    pop di
    pop es
    ret

MaximumHead: resb 1
MaximumSector: resb 1

;
; Reads one sector using non-extended BIOS functions
; Params: dl: drive number
;         cl: sector number 0-5, cylinder 6-7
;         ch: cylinder number
;         dh: head number
;         es:bx: data buffer
; Output: ah = 0x11 on error
;         ah = 0x00 on sucess
;         al = 0x01 on success
;

readOneSectorLegacy:
    mov ah, 0x02
    mov al, 0x01
    int 0x13
    
    ret

;
; Check if extended BIOS disk functions exist
; Params: dl: drive number
; Output: ah = 0x01 on extensions not supported
;         ah = 0x00 on extensions supported
;

checkBIOSReadExtensions:
    mov ah, 0x41
    mov bx, 0x55aa
    int 0x13 ; Check if extensions exist

    mov ah, 0x01 ; ah = 0x01 if they do not
    jc checkEnd ; Nope they don't exist

    cmp bx, 0xaa55 ; Check if they really exist
    jne checkEnd ; Nope

    mov ah, 0x00 ; We have the extensions

checkEnd:
    ret

;
; Read one sector from disk
; Params: dl: drive number
;         ecx: start LBA
;         ds:si: buffer
; Output: Carry set on error
;         ah: error code
;

readOneSectorExtended:

    mov dword [b], ecx ; Starting block ; Do Illegal stuff
    mov word [o], si ; Buffer offset
    mov word [s], ds ; Buffer segment
    
    xor ax, ax
    mov ds, ax
    mov si, DAPACK ; address of data pack
    mov ah, 0x42
    int 0x13 ; Read sectors

    ret

DAPACK:
    db 0x10 ; packet size
    db 0x00 ; reserved 
    dw 0x01 ; transfer size in sectors
o:  dw 0x0000 ; transfer buffer offset
s:  dw 0x0000 ; segment
b:  dd 0x00 ; starting block
    dd 0x00