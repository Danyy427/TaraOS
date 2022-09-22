[BITS 16]
[ORG 0x7e00]

global _boot
global _boot64

_boot:

    jmp $

[BITS 64]

_boot64:

    jmp 0x01000000
    
    jmp $