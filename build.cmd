@echo off

REM clear previous build:
del /F /Q .\build\*

REM component builds:
REM BIOS
call .\src\boot\bios\build.cmd

REM link:
