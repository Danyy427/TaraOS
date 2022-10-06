[BITS 16]
[ORG 0x7e00]

global _boot

_boot:
    
    call enablea20
    cmp ax, 1
    je a20error
    
    mov si, a20success
    call printstr
    
    mov ax, 0x1000
    mov es, ax
    call do_e820
    jc e820error
    
    mov si, memorymapsuccessmsg
    call printstr
    
    jmp $

a20error:
    mov si, a20errmsg
    call printstr
    
    jmp $
    
e820error:
    mov si, memorymapfailmsg
    call printstr

    jmp $

a20errmsg: db "I gave up (A20)", 13, 10, 0
a20success: db "A20 Enabled", 13, 10, 0
memorymapsuccessmsg: db "Memory Map Received", 13, 10, 0
memorymapfailmsg: db "Memory Map Error", 13, 10, 0

%include "diskread.asm"
%include "printstr.asm"
%include "printhex.asm"
%include "a20.asm"
%include "memorymap.asm"

times 4096 - ($-$$) db 0x00
