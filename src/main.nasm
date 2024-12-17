org 0x7c00                          ; bootloader loaded to this address in RAM

; VGA 13h video mode:
mov ah, 00h
mov al, 13h
int 10h

; clear screen to blue w/ red borders:
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

; print logo:
push 0xA000
pop es
mov di, 0        ; logo start offset
; mov bx, 0
; mylp:
;     mov cl, [logo_data+bx]
;     mov [es:di], cl
;     inc bx
;     inc di
;     cmp bx, 311
;     jne mylp
; jmp hang
; mov si, 0
; mov di, 0
mov cx, 0         ; column
logo_loop:
    mov byte al, [logo_data+bx]
    mov ah, al             ; so after shr al same contents
    shr ax, 8              ; last bit -> carry flag
    jnc pre_post            ; carry -> write pixels
    
    and al, 0x7f            ; remove first bit
    ; mov al, 15 
    ; loop to write white pixels:
    pre:
        mov byte [es:di], 0x0f  ; white
        dec al
        inc di
        inc cx
        cmp cx, 100
        jl after_add
        add di, 220             ; beginning of next row
        mov cx, 0
        after_add:
        cmp al, 0
        jne pre
    jmp post

    ; advance di by pixels not written
    pre_post:
        mov ah, 0
        and al, 0x7f
        add di, ax
        add cx, ax
    
    ; if over 100, subtract 100 add 320 -> next row same col
    cmp cx, 100
    jl post
    sub di, 100
    add di, 320
    sub cx, 100

    post:
        inc bx              ; read next bit in logo_data
        cmp bx, 311         ; TODO: not hardcoded
        jl logo_loop
    
hang:
    jmp hang

rows: dw 200
cols: dw 320 
me: db 0x0f
%include "src/logo-data.nasm"
times 510-($-$$) db 0
dw 0xAA55