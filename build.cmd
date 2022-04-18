@echo off

REM clear previous build:
del /F /Q .\build\*
del /F /Q .\release\*

REM component builds:
REM BIOS
call .\src\boot\bios\build.cmd

REM link:

REM build image:
copy /b ".\build\mbr.bin" + ".\build\vbr.bin" + ".\build\loader.bin" /b ".\release\TaraOS.img"
     
REM run image:
if %1==debug qemu-system-x86_64 -monitor stdio .\release\TaraOS.img
else qemu-system-x86_64 .\release\TaraOS.img 

pause