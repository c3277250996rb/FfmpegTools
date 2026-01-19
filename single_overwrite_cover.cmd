@REM <pre>
@REM 金米妮金米妮金米妮金米妮金米妮金米妮金米妮金米妮金米妮金米妮

@echo off
title FFmpeg 视频封面覆盖工具

echo ================================
echo   FFmpeg 视频封面设置（覆盖）
echo ================================
echo.

:: 输入视频
echo 请拖入【视频文件】，然后回车：
set /p video=

if not exist "%video%" (
    echo 视频不存在
    pause
    exit
)

:: 输入图片
echo.
echo 请拖入【封面图片】，然后回车：
set /p image=

if not exist "%image%" (
    echo 图片不存在
    pause
    exit
)

:: 解析路径
for %%i in ("%video%") do (
    set "dir=%%~dpi"
    set "name=%%~ni"
    set "ext=%%~xi"
)

set "tmp=%dir%%name%.__tmp__%ext%"

echo.
echo 正在写入封面...
echo.

ffmpeg -y ^
    -i "%video%" ^
    -i "%image%" ^
    -map 0 ^
    -map 1 ^
    -c copy ^
    -disposition:v:1 attached_pic ^
    "%tmp%"

if errorlevel 1 (
    echo.
    echo ? FFmpeg 失败，原视频未修改
    pause
    exit
)

:: 覆盖
del "%video%"
ren "%tmp%" "%name%%ext%"

echo.
echo ? 封面设置完成（已覆盖原视频）
pause
