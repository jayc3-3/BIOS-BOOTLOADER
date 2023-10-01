# BIOS-BOOTLOADER
A simple BIOS bootloader

Made for use with small OS projects that can launch from real mode and carry their weight from there.

## Usage
If any crazy psycho wishes to use this, I'll provide a little handbook.

First off, machine state. How does the bootloader leave the computer?

All registers (except for DL) are set to zero before control is handed to the operating system.
The DL register is set to the BIOS boot drive (that is, the drive the computer booted from).

Next, how does it load the kernel?
Well, it just loads the second sector from the disk into memory at 0x8000, and jumps to there.

So all a working kernel needs is to run in 16-bit real mode with a global memory offset of 0x8000 (achieved in NASM with the 'org' directive).
After all of that, you've sucessfully launched a 16-bit kernel with a garbage bootloader! Congratulations!
