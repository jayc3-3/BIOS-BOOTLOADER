;
; BIOS-BOOTLOADER
; A simple BIOS bootloader
;
; https://github.com/jayc3-3/BIOS-BOOTLOADER
; Free for use and/or modification
;

;
; console.asm
; Console interface using INT 10h functions
;

console_cursorx: db 0
console_cursory: db 0

console_init: ; No input; No output
push ax
push dx

xor ah, ah
mov al, 0x12
int 0x10

mov ah, 5
xor al, al
int 0x10

xor dx, dx
call console_set_cursor

pop dx
pop ax
ret

console_set_cursor: ; Input: DH = Cursor Y, DL = Cursor X; No output
push ax
push bx

mov ah, 2
xor bh, bh
int 0x10

pop bx
pop ax
ret

console_clear: ; No input; No output
pusha

mov ah, 6
xor al, al
mov bh, 0xF0
xor bl, bl
xor cx, cx
mov dx, 0x1E50
int 0x10

mov dx, cx
call console_set_cursor

mov byte[console_cursorx], dl
mov byte[console_cursory], dl

popa
ret

console_print: ; Input: AX = 0x8A1F (for no newline), BX = Pointer to string; No output
pusha
push ax

mov dh, byte[console_cursorx]
mov dl, byte[console_cursory]

.loop:
mov al, byte[bx]
cmp al, 0
je .done

cmp dh, 80
je .loop_sety

cmp dl, 30
je .done

push ax
push bx
push cx

ror dx, 8
call console_set_cursor
rol dx, 8

mov ah, 9
xor bh, bh
mov bl, 0x0F
mov cx, 1
int 0x10

pop cx
pop bx
pop ax

inc bx
inc dh
jmp .loop

.loop_sety:
xor dh, dh
inc dl
jmp .loop

.done:
ror dx, 8
call console_set_cursor
rol dx, 8

mov byte[console_cursorx], dh
mov byte[console_cursory], dl

pop ax
cmp ax, 0x8A1F
je .no_newline

call .newline

.no_newline:

popa
ret

.newline:
push ax
push dx

mov al, byte[console_cursory]

xor ah, ah
inc al

cmp al, 30
je .newline_y_overflow

.newline_done:
mov dx, ax
call console_set_cursor

mov byte[console_cursorx], ah
mov byte[console_cursory], al

pop dx
pop ax
ret

.newline_y_overflow:
xor al, al
call console_clear

jmp .newline_done