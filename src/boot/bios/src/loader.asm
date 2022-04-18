[BITS 16]
[ORG 0x7e00]
global _start

_start:

    jmp $
    
    
times 8192 - ($-$$) db 0x00