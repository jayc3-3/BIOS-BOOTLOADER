;
; BIOS-BOOTLOADER
; A simple BIOS bootloader
;
; https://github.com/jayc3-3/BIOS-BOOTLOADER
; Free for use and/or modification
;

;
; disk.asm
; Simple INT 13h disk functions
;

disk_read: ; Input: AL = Sectors to read, CH = Cylinder, CL = First sector, DH = Head, DL = Drive; Output: [ES:BX] = Data read from disk, Carry Flag = Set on error
push bx
push ax
clc

mov ah, 2
int 0x13
jc .error
pop bx
cmp al, bl
jne .error

.done:
pop bx
ret

.error:
stc
jmp .done