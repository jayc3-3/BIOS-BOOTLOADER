ASM = nasm

ASMFLAGS = -Ox -f bin
COMPNAME = BIOS-BOOTLOADER

all: bin

clean:
	rm *.bin

bin: src/bootloader.asm
	${ASM} $< -o ${COMPNAME}.bin