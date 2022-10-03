[BITS 16]

%include "printstr.asm"

; Checks if the A20 line is already enabled
; compares 0000:0500 to ffff:0510
; if they're different, the A20 line is already enabled
; Returns ax: 1 -> enabled, 0 -> disabled
checka20:
    ; Secure the registers' values
    pushf
    push es
    push ds
    push di
    push si

    cli

    ; Set segments
    ; Set es to 0x0000
    xor ax, ax
    mov es, ax

    ; Set ds to 0xffff
    not ax
    mov ds, ax

    mov di, 0x0500
    mov si, 0x0510

    ; Preserve old values of the adresses
    mov al, byte [es:di]
    push ax

    mov al, byte [ds:si]
    push ax

    ; Move different values to the two adresses
    mov byte[es, di], 0x0000
    mov byte[ds, si], 0xffff

    cmp byte[es, di], 0xffff

    ; Retrieve old values of the adresses
    pop ax
    mov byte[ds:si], al
 
    pop ax
    mov byte[es:di], al

    ; Return logic
    xor ax, ax
    je endchecka20

    mov ax, 1

endchecka20:
    ; Retrieve the old register values
    pop si
    pop di
    pop ds
    pop es
    popf

    ret

; Enables the A20 line
enablea20:
    ; Secure ax as it will be modified during the check
    push ax

    ; Check if the A20 line is already enabled
    call checka20
    cmp ax, 1
    je endenablea20

    ; Else, enable the A20 line

    ; Some systems have a BIOS function for this
    mov ax, 0x2401
    int 0x15
    ; Check if it worked
    call checka20
    cmp ax, 1
    je endenablea20

    ; Keyboard interrupt
    call    a20wait
    mov     al,0xAD
    out     0x64,al

    call    a20wait
    mov     al,0xD0
    out     0x64,al

    call    a20wait2
    in      al,0x60
    push    eax

    call    a20wait
    mov     al,0xD1
    out     0x64,al

    call    a20wait
    pop     eax
    or      al,2
    out     0x60,al

    call    a20wait
    mov     al,0xAE
    out     0x64,al

    call    a20wait
    sti
    ret
    ; Check if it worked (It will probably crash if it doesn't but anyway)
    call checka20
    cmp ax, 1
    je endenablea20

    ; Fast A20
    in al, 0x92
    or al, 2
    out 0x92, al
    ; Check if it worked (It will probably crash if it doesn't but anyway)
    call checka20
    cmp ax, 1
    je endenablea20

    ; Give up (print an error message)
    push si
    mov si, a20errmsg
    call printstr
    pop si

    ; magik trick
    hlt
    jmp $-1

endenablea20:
    pop ax
    ret

a20wait:
    in      al,0x64
    test    al,2
    jnz     a20wait
    ret
 
 
a20wait2:
    in      al,0x64
    test    al,1
    jz      a20wait2
    ret

a20errmsg: db "I gave up (A20 line enabling error)", 0