org 0x7c00                          ; bootloader loaded to this address in RAM

; VGA 13h video mode:
mov ah, 00h
mov al, 13h
int 10h

; clear screen to blue:
push 0xA000
pop es          ; cannot mov directly into segment register
mov cx, 0       ; row
mov bx, 0       ; col
mov di, 0       ; offset
lp:
    cmp cx, 10
    jle red
    cmp cx, 190
    jge red
    cmp bx, 10
    jle red
    cmp bx, 310
    jge red

    mov byte [es:di], 0x20 
    jmp past 

    red:
    mov byte [es:di], 0x4 

    past:

    inc di

    inc bx
    cmp bx, [cols] 
    jl lp

    mov bx, 0
    inc cx
    cmp cx, [rows] 
    jl lp

; mov bx, 0 
; print:
;     mov ah, 0x0E
;     mov al, [msg + bx]
;     int 0x10
;     inc bx
;     cmp al, 0
;     jne print

hang:
    jmp hang

msg: db "Hello World!", 0
rows: dw 200
cols: dw 320 
times 510-($-$$) db 0
dw 0xAA55