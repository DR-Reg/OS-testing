; first sector:
org 0x7c00      ; bootloader is always loaded here

; video mode: large res text
mov ah, 00h
mov al, 12h
int 10h

mov ah, 0x02        ; int 13h, ah = 2 -> read sectors
mov al, 0x01        ; read 1 sector
mov bx, 0x7e00      ; load at address 0x7e00
mov cx, 0x0002      ; cylinder 0, sector 2
mov dx, 0x0080      ; head 0, boot drive = 0x80 (hard disk)
int 13h

mov cx, 170
mov dx, 0
mov ah, 0ch
mov al, 0x04
mov bx, 0
logo_loop:
    mov [stash], bx
    mov byte bl, [logo_data+bx]
    shr bl, 8
    jnc transparent

    mov bx, [stash]
    mov byte bl, [logo_data+bx]
    and bl, 0x7f

    white_loop:
        int 10h
        dec bl
        add cx, 3
        cmp cx, 470
        jl white_loop_end
        mov cx, 170
        add dx, 3          ; row never inc more than 1
        white_loop_end:
        cmp bl, 0
        jg white_loop
        jmp logo_loop_end

    transparent:
        mov bx, [stash]
        mov byte bl, [logo_data+bx]
        and bx, 0x7f
        add cx, bx
        add cx, bx
        add cx, bx
        cmp cx, 470
        jl logo_loop_end
        ; mov cx, 170
        sub cx, 300
        add dx, 3
        

    logo_loop_end:
        mov bx, [stash]
        inc bx
        cmp bx, 311
        jl logo_loop

; int 10h

jmp 0x7e00
%include "src/logo-data.nasm"
stash: dw 0
times 510-($-$$) db 0
dw 0xAA55

; second sector: add extra code to print
mov dx, 0x0615
mov cx, title
call print

inc dh
mov cx, credits
call print

inc dh
mov cx, kmsg 
call print
add dl, 17
mov cx, kmsg2 
call print

jmp hang

; dx: <row><col>, cx: <addr of str>
print:
    mov bx, 0
    mov ah, 02h
    int 10h
    mov ah, 0x0E
    _print_lp:
        mov bx, cx
        mov al, [bx]
        mov bl, 0x0f
        int 10h

        inc cx
        cmp al, 0
        jne _print_lp
    ret

hang:
    jmp hang

title: db "=== Micro Bootloader ===",0
credits: db "David Raibaut (c) 2024", 0
kmsg: db "Loading kernel...", 0
kmsg2: db "Loaded", 0
pmsg: db "Enabling protected mode", 0
pmsg2: db "Enabled", 0

times 1024-($-$$) db 0
; third sector: add kernel code using gcc

; determine which partition to boot from: this is the partition
; determine where your kernel image is located on the boot partition: 1024 bytes for bootloader, then kernel.
; load the kernel image into memory (requires basic disk I/O);
; enable protected mode;
; preparing the runtime environment for the kernel (e.g. setting up stack space);