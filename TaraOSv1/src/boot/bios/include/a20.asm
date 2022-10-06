[BITS 16]

; Checks if the A20 line is already enabled
; compares 0000:0500 to ffff:0510
; if they're different, the A20 line is already enabled
; Returns ax: 1 -> enabled, 0 -> disabled
checka20:
    pushf
    push ds
    push es
    push di
    push si
 
    cli
 
    xor ax, ax ; ax = 0
    mov es, ax
 
    not ax ; ax = 0xFFFF
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
    je check_a20__exit
 
    mov ax, 1
 
check_a20__exit:
    pop si
    pop di
    pop es
    pop ds
    popf
 
    ret

; Enables the A20 line
enablea20:
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
    cli
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
    mov ax, 1 ; 1 for error
    ret

endenablea20: 
    mov ax, 0 ; 0 for success
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

