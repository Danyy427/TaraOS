[BITS 16]

; params: si -> hex number to be printed
printhex:
    xor bx, bx
    mov ah, si

reverseloop:
    ; ax = divisor * al + ah
    mov ax, ah
    div 10

    mov ax, ah
    mul 10
    add ax, ah
    

endprinthex:
    ret