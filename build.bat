@echo off
REM it's almost like linux!
REM Requires DASM and VICE on PATH (vice named x64)
dasm main.asm -llist.txt -oout.prg
REM i know this looks wrong, but dasm is just like that
x64 out.prg