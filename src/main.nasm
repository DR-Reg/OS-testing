org 0x7c00                          ; bootloader loaded to this address in RAM

; VGA 0eh video mode:
mov ah, 00h
mov al, 0x12
int 10h

; print logo:
push 0xA000
pop es
mov di, 0        ; logo start offset: 30*320 + 110
mov cx, 0           ; column within logo
logo_loop:
    mov byte al, [logo_data+bx]
    mov ah, al             ; so after shr al same contents
    shr ax, 8              ; last bit -> carry flag
    jnc pre_post            ; carry -> write pixels
    
    and al, 0x7f            ; remove first bit
    ; mov al, 15 
    ; loop to write white pixels:
    pre:
        mov byte [es:di], 0xff  ; white
        dec al
        inc di
        inc cx
        cmp cx, [logo_cols]
        jl after_add
        add di, 640             ; beginning of next row
        mov cx, 0
        after_add:
        cmp al, 0
        jne pre
    jmp post

    ; advance di by pixels not written / 2
    pre_post:
        mov ah, 0
        and al, 0x7f
        add cx, ax
        ; mov bl, 2
        ; div bl
        ; mov ah, 0
        add di, ax
    
    ; if over 100, subtract 100 add 320 -> next row same col
    cmp cx, [logo_cols]
    jl post
    sub di, [logo_cols]
    add di, 640
    sub cx, [logo_cols]

    post:
        inc bx              ; read next bit in logo_data
        cmp bx, 311         ; TODO: not hardcoded
        jl logo_loop

; Output text example
; bg blue:
mov al, 0
mov ah, 0x0b
mov bh, 0
mov bl, 0x20
int 10h


mov ah, 0x02
mov dh, 10
mov dl, 10
mov bh, 0
int 10h

mov cx, 0
print:
    mov ah, 0x0E
    mov bx, cx
    mov al, [credits+bx]
    mov bl, 0x0f
    int 10h

    inc cx
    cmp al, 0
    jne print

hang:
    jmp hang

rows: dw 480
cols: dw 640 
logo_cols: dw 50
credits: db "David Raibaut (c) 2024", 0
%include "src/logo-data.nasm"
times 510-($-$$) db 0
dw 0xAA55