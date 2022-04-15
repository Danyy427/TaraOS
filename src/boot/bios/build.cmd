@echo off

REM BIOS build
nasm -fbin .\src\boot\bios\src\boot.asm -o .\build\boot.bin
