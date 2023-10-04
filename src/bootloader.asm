;
; BIOS-BOOTLOADER
; A simple BIOS bootloader
;
; https://github.com/jayc3-3/BIOS-BOOTLOADER
; Free for use and/or modification
;

;
; bootloader.asm
; Main boot file
;

org 0x7C00
bits 16

db 0xEB, 0x3C, 0x90
times 87 db 0 ; Leave space for FAT

cld
cli

jmp 0:reload

reload:
xor ax, ax
mov ds, ax
mov es, ax
mov ss, ax

mov byte[boot_drive], dl

mov bp, 0x7C00
mov sp, bp
sti

call console_init
mov byte[console_cursorx], al
mov byte[console_cursory], al

mov bx, boot_message
call console_print
mov bx, date_message
call console_print

mov al, 1
mov bx, 0x7E00
xor ch, ch
mov cl, 2
xor dh, dh
mov dl, byte[boot_drive]
call disk_read
jc disk_error

call enable_a20

jmp bootloader_continue

disk_error:
mov bx, disk_error_message
call console_print

jmp $

%include "src/console.asm"
%include "src/disk.asm"

boot_message: db "Started BIOS-BOOTLOADER rev. 004-1", 0
date_message: db "Software dated Oct. 03, 2023", 0

disk_error_message: db "Unable to load data from disk", 0

boot_drive:   db 0
kernel_address: equ 0x8000

times 510 - ($ - $$) db 0
dw 0xAA55

extended:

check_a20: ; No input: Carry Flag = Set if NOT enabled
push ax
push di
push si
push es
push ds
cli

xor ax, ax
mov es, ax

not ax
mov dx, ax

mov di, 0x0500
mov si, 0x0510

mov al, byte[es:di]
push ax

mov al, byte[ds:si]
push ax

mov byte[es:di], 0x00
mov byte[ds:si], 0xFF

cmp byte[es:di], 0xFF

pop ax
mov byte[ds:si], al

pop ax
mov byte[es:di], al

clc
je .error

.done:
pop ds
pop es
pop si
pop di
pop ax
sti
ret

.error:
stc
jmp .done

enable_a20:
push ax

call check_a20
jnc .done

mov ax, 0x2403
int 0x15
jb .skip_15h
cmp ah, 0
jnz .skip_15h

mov ax, 0x2402
int 0x15
jb .skip_15h
cmp ah, 0
jnz .skip_15h

call check_a20
jnc .done

.skip_15h:

in al, 0x92
test al, 2
jnz .skip_fast_a20

or al, 2
and al, 0xFE
out 0x92, al

call check_a20
jnc .done

.skip_fast_a20:

in al, 0xEE

call check_a20
jnc .done

cli

call .kwait
mov al, 0xAD
out 0x64, al

call .kwait
mov al, 0xD0
out 0x64, al

call .kwait2
in al, 0x60
push ax

call .kwait
pop ax
or al, 2
out 0x60, al

call .kwait
mov al, 0xAE
out 0x64, al

call .kwait
sti

call check_a20
jnc .done

jmp no_a20

.kwait:
in al, 0x64
test al, 2
jnz .kwait
ret

.kwait2:
in al, 0x64
test al, 1
jz .kwait2
ret

.done:
pop ax
ret

no_a20:
mov bx, no_a20_message
call console_print
jmp $

no_a20_message: db "ERROR: Unable to enable the A20 line", 0

bootloader_continue:
;mov ax, 2
;mov bx, kernel_address
;mov cl, 32
;mov dl, byte[boot_drive]
;call disk_read_ext
;jc disk_error

mov al, 32
mov bx, kernel_address
xor ch, ch
mov cl, 3
xor dh, dh
mov dl, byte[boot_drive]
call disk_read
jc disk_error

xor ax, ax
mov bx, ax
mov cx, ax
mov dh, ah
mov dl, byte[boot_drive]
mov di, ax
mov si, ax
mov fs, ax
mov gs, ax

jmp kernel_address

;%include "src/disk_ext.asm"

times 512 - ($ - extended) db 0