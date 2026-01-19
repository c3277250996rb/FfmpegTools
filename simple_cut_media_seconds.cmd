@REM <pre>
@REM 金米妮金米妮金米妮金米妮金米妮金米妮金米妮金米妮金米妮金米妮

@echo off
set input=%1
set seconds=1636
ffmpeg -ss %seconds% -i "%input%" -acodec copy "%~dpn1_cut%~x1"
