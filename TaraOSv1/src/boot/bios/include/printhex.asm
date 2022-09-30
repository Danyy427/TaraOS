[BITS 16]

; Print Hex Number
; input: dx

hexsetup:
    push cx
    push bx
    xor cx, cx

hexreverse:
    push ax

    mov ax, 4
    mul cx

    push cx
    mov cx, ax
    shr dx, cl
    pop cx
    
    and dx, 0x000F

    mov bx, hexNums
    add bx, dx
    mov al, [bx]
    mov ah, 0x0e
    int 0x10

    pop ax

    inc cx

    cmp cx, 4 
    je endreverse
    jmp hexreverse

endreverse:
    pop bx
    pop cx
    ret

hexNums: db "0123456789abcdef"