[BITS 16]

; PARAM: si -> source
printstr:
    mov ah, 0x0e

printstrloop:
    mov al, byte [si]
    cmp al, 0
    je endprintstr
    
    int 0x10
    inc si
    jmp printstrloop

endprintstr:
    ret