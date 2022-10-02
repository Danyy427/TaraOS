[BITS 16]

; Print Hex Number
; input: dx

printhex:
    push cx
    push bx
    push ax
    mov cx, 4

printhexloop:

    dec cx

    push cx
    push dx
    mov ax, 4
    mul cx
    mov cx, ax ; cx -> number to shift right by
    pop dx

    push dx
    shr dx, cl

    and dx , 0x000F
    mov bx, hexNums
    add bx, dx
    mov al, byte[bx]
    mov ah, 0x0e
    int 0x10

    pop dx

    pop cx
    cmp cx, 0
    je endhex
    jmp printhexloop

endhex:
    pop ax
    pop bx
    pop cx
    ret

hexNums: db "0123456789abcdef"