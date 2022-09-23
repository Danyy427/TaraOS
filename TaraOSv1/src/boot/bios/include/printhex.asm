[BITS 16]

; params: si -> hex number to be printed
printhex:
    mov ah, 0x0e
    xor al, al

findlen:
    xor cx, cx

findlenloop:
    inc cx
    cmp [si+cx], 0x0
    je printhexloop
    jmp findlenloop

printhexloop:
    mov al, byte[si+cx]
    add al, 0x30 ; convert to char
    int 0x10

    dec cx
    cmp cx, 0
    je endprinthex
    jmp printhexloop

endprinthex:
    ret