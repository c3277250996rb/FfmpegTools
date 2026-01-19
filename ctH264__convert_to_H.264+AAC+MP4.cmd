@REM <pre>
@REM 金米妮金米妮金米妮金米妮金米妮金米妮金米妮金米妮金米妮金米妮

@echo off
setlocal enabledelayedexpansion

:: ==== 配置前缀 ====
set prefix=converted_

:: ==== 输入文件 ====
set "input=%~1"

if "%input%"=="" (
    echo 用法: 把视频文件拖到本脚本上，或输入：
    echo   transcode.bat inputfile
    pause
    exit /b
)

:: ==== 解析输入文件名 ====
for %%f in ("%input%") do (
    set "name=%%~nf"
    set "ext=%%~xf"
)

:: ==== 下载文件夹路径 ====
set "download=%USERPROFILE%\Downloads"

:: ==== 输出文件路径 ====
set "output=%download%\%prefix%!name!.mp4"

echo 转码中...
ffmpeg -i "%input%" -c:v libx264 -preset medium -crf 23 -c:a aac -b:a 128k -movflags +faststart "%output%"

echo.
echo ? 完成！输出文件位于：
echo   %output%
pause
@REM </pre>