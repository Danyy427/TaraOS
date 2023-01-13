; All VESA functions return 0x4F in AL if they are supported
; and use AH as a status flag, with 0x00 being success.
; This means that you should check that AX is 0x004F after each VESA call to see if it succeeded.
; VESA stopped assigning codes for video modes long ago -- 
; instead they standardized a much better solution: 
; you can query the video card for what modes it supports, 
; and query it about the attributes of each mode. 
; In your OS, you can have a function that you call with a 
; desired width, height, and depth, and it returns the video mode number for it 
; (or the closest match). Then, just set that mode

; Source: OSDEV
