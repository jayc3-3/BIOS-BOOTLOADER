;
; BIOS-BOOTLOADER
; Simple single-sector BIOS bootloader
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

mov bx, boot_message
call console_print
mov bx, date_message
call console_print

mov ax, 1
mov bx, kernel_address
mov cl, 32
mov dl, byte[boot_drive]
call disk_read
jc disk_error

xor ax, ax
mov bx, ax
mov cx, ax
xor dh, dh
mov dl, byte[boot_drive]
mov di, ax
mov si, ax
mov fs, ax
mov gs, ax
jmp kernel_address

disk_error:
mov bx, disk_error_message
call console_print

jmp $

%include "src/console.asm"
%include "src/disk.asm"

boot_message: db "Started BIOS-BOOTLOADER rev. 002", 0
date_message: db "Software dated Oct. 01, 2023", 0

disk_error_message: db "ERROR: Unable to load data from disk", 0

boot_drive:   db 0
kernel_address: equ 0x8000

times 510 - ($ - $$) db 0
dw 0xAA55