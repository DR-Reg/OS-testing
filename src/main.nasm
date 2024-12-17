org 0x7c00                          ; bootloader loaded to this address in RAM

; VGA 13h video mode:
mov ah, 00h
mov al, 13h
int 10h

; clear screen to blue:
push 0xA000
pop es          ; cannot mov directly into segment register
mov ax, 0       ; row
mov bx, 0       ; col
lp:
    mov di, ax
    mov cx, [cols]                              ; offset from extra segment
    mul cx
    mov cx, di
    mov di, ax
    mov ax, cx
    add di, bx
    mov byte [es:di], 0x20 
    inc bx
    cmp bx, [cols] 
    jne lp
    mov bx, 0
    inc ax
    cmp ax, [rows] 
    jne lp

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
rows: dw 320
cols: dw 400
times 510-($-$$) db 0
dw 0xAA55