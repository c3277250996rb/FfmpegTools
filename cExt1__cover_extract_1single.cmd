@REM <pre>
@REM 金米妮金米妮金米妮金米妮金米妮金米妮金米妮金米妮金米妮金米妮

@echo off
setlocal enabledelayedexpansion

if "%~1"=="" (
    echo 请把视频文件拖到本脚本上
    pause
    exit /b
)

set "input=%~1"
set "name=%~n1"

echo 正在检测封面流...

:: 从 "Stream #0:2[0x0]" 中只提取 2
for /f "tokens=2 delims=#:0" %%A in ('
    ffmpeg -i "%input%" 2^>^&1 ^| findstr /i "attached pic"
') do (
    for /f "delims=[" %%B in ("%%A") do (
        set "stream=%%B"
    )
)

if not defined stream (
    echo 未发现内嵌封面
    echo 尝试截图第 1 秒...
    ffmpeg -ss 1 -i "%input%" -frames:v 1 -q:v 2 "cover_%name%.jpg"
    goto end
)

echo 发现封面流：0:%stream%
ffmpeg -i "%input%" -map 0:%stream% -c copy "cover_%name%.jpg"

:end
echo.
echo 完成
pause
