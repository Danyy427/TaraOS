@echo off

REM BIOS build
nasm -fbin .\src\boot\bios\src\mbr.asm -o .\build\mbr.bin
nasm -fbin .\src\boot\bios\src\vbr.asm -o .\build\vbr.bin
nasm -fbin .\src\boot\bios\src\loader.asm -o .\build\loader.bin