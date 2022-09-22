[BITS 16]
[ORG 0x7c00]

global _vbr

_vbr:
    mov [Drive], dl

    jmp $

Drive: db 0x00
