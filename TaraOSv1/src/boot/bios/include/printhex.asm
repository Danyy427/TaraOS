[BITS 16]

; params: si -> hex number to be printed
printhex:
    xor bx, bx
    mov ah, si

reverseloop:
    ; ax = divisor * al + ah
    ; divide by 16 to get the first digit
    mov ax, ah
    div 16

    ; multiply the remainder by 16 to reverse it
    mov ax, ah
    mul 16

    ; store the reversed number in si
    mov si, ax
    add si, ah

    ; loop logic
    inc word[counter]
    cmp word[counter], 4
    je endrevloop
    jmp reverseloop

endrevloop:
    xor word[counter], word[counter]

hexprintloop:

    mov ax, si
    div 16
    
    mov si, al ; si/=16
    mov al, [ah]
    mov ah, 0x0e

    int 0x10

    ; loop logic
    inc word[counter]
    cmp word[counter], 4
    je endprinthex
    jmp hexprintloop

endprinthex:
    ret

counter dw 0