;
; BIOS-BOOTLOADER
; Simple single-sector BIOS bootloader
;
; https://github.com/jayc3-3/BIOS-BOOTLOADER
; Free for use and/or modification
;

;
; disk.asm
; INT 13h disk functions
;

disk_read: ; Input: AX = LBA, CL = Sectors to read, DL = Drive; Output: [ES:BX] = Data read from disk, Carry Flag = Set on error
pusha
push bx
clc

mov bl, cl

mov byte[.drive], dl
xor dx, dx

push ax
mov al, 63
mov cl, 16
mul cl
mov cx, ax
pop ax

push ax
xor dx, dx
div cx
and ax, 1023
mov word[.cylinder], ax
pop ax

push ax
mov cl, 63
div cl
xor ah, ah

mov cl, 16
div cl

mov al, ah
mov byte[.head], al
pop ax

push ax
mov cl, 63
div cl
shr ax, 8
inc ax

and ax, 63
mov byte[.sector], al
pop ax

mov dl, bl
pop bx
push dx
mov ah, 2
mov al, dl
mov cx, word[.cylinder]
shl cx, 8
mov cl, byte[.sector]
mov dh, byte[.head]
mov dl, byte[.drive]
int 0x13
jc .error
cmp ah, 0
jne .error
pop dx
cmp al, dl
jne .error

.done:
popa
ret

.error:
stc
jmp .done

.cylinder: dw 0
.head:     db 0
.sector:   db 0
.drive:    db 0