@echo off
setlocal enabledelayedexpansion

:START
@REM cls
echo.
echo ===== 视频 + SRT 字幕合成 =====
echo.

:: ==============================
:: 输入视频
:: ==============================
echo 请拖入【视频文件】：
set /p video=

if "%video%"=="" (
    echo 未输入视频
    pause
    goto START
)

if not exist "%video%" (
    echo 视频不存在
    pause
    goto START
)

:: ==============================
:: 输入字幕
:: ==============================
echo.
echo 请拖入【SRT 字幕文件】：
set /p srt=

if "%srt%"=="" (
    echo 未输入字幕
    pause
    goto START
)

if not exist "%srt%" (
    echo 字幕不存在
    pause
    goto START
)

:: ==============================
:: 路径处理
:: ==============================
for %%A in ("%video%") do (
    set "vname=%%~nA"
    set "vdir=%%~dpA"
)

set "outfile=%vdir%subtitle_%vname%.mp4"

:: ==============================
:: 合成字幕（软字幕）
:: ==============================
echo.
echo 正在合成字幕...

ffmpeg -y ^
    -i "%video%" ^
    -i "%srt%" ^
    -c copy ^
    -c:s mov_text ^
    "%outfile%"

echo.
echo 完成：
echo %outfile%
echo.
pause

goto START
