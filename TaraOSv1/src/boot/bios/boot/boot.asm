[BITS 16]
[ORG 0x7e00]

global _boot
global _boot64

_boot:

    mov dx, 0xdead
    call printhex

    jmp $



%include "diskread.asm"
%include "printstr.asm"
%include "printhex.asm"

[BITS 64]

_boot64:

    jmp 0x01000000
    
    jmp $
    

times 4096 - ($-$$) db 0x00
