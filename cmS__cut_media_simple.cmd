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

set /p time=请输入时间点(00:00:00)：
set /p mode=请输入模式(start 或 end)：

for %%F in ("%input%") do (
    set "name=%%~nF"
    set "ext=%%~xF"
    set "dir=%%~dpF"
)

if /i "%mode%"=="start" (
    echo.
    echo 保留【开头 → %time%】
    ffmpeg -i "%input%" -t %time% -c copy "%dir%start_!name!!ext!"
) else if /i "%mode%"=="end" (
    echo.
    echo 保留【%time% → 结尾】
    ffmpeg -ss %time% -i "%input%" -c copy "%dir%end_!name!!ext!"
) else (
    echo 模式只能输入 start 或 end
)

pause
