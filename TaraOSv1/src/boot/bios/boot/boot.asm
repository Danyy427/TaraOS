[BITS 16]
[ORG 0x7e00]

global _boot
global _boot64

_boot:
    
    call enablea20
    cmp ah, 0
    jne a20error
    
    mov si, a20success
    call printstr
    
    jmp $

a20error:
    mov si, a20errmsg
    call printstr
    
    hlt
    jmp $

%include "diskread.asm"
%include "printstr.asm"
%include "printhex.asm"
%include "a20.asm"

a20errmsg: db "I gave up (A20)", 13, 10, 0
a20success: db "A20 Enabled", 13, 10, 0


[BITS 64]

_boot64:

    jmp 0x01000000
    
    jmp $
    

times 4096 - ($-$$) db 0x00
