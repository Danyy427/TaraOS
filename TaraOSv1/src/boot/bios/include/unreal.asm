start:   
    cli                    ; no interrupts
    push ds                ; save real mode
    
    lgdt [gdtinfo]         ; load gdt register
    
    mov  eax, cr0          ; switch to pmode by
    or al,1                ; set pmode bit
    mov  cr0, eax
    
    jmp $+2                ; tell 386/486 to not crash
    
    mov  bx, 0x08          ; select descriptor 1
    mov  ds, bx            ; 8h = 1000b
    
    and al,0xFE            ; back to realmode
    mov  cr0, eax          ; by toggling bit again
    
    pop ds                 ; get back old segment
    sti
    
    ret
 
gdtinfo:
    dw gdt_end - gdt - 1   ;last byte in table
    dd gdt                 ;start of table
 
gdt: dd 0,0        ; entry 0 is always unused
flatdesc: db 0xff, 0xff, 0, 0, 0, 10010010b, 11001111b, 0
gdt_end:
    times 510-($-$$) db 0  ; fill sector w/ 0's
    dw 0xAA55              ; Required by some BIOSes
