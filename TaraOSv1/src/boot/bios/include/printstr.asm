[BITS 16]

; PARAM: si -> source
printstr:
    mov ah 0x0e

printstrloop:
    mov al, byte[si]
    int 0x10
    
    inc si

    cmp [si], 0
    je endprintstr

    jmp printstrloop

endprintstr:
    ret