@echo off
setlocal enabledelayedexpansion

set /p VIDEODIR=请输入视频目录：

if not exist "%VIDEODIR%" (
    echo 目录不存在
    pause
    exit /b
)

echo.
echo ====== 检测封面数量 ======
echo.

for %%F in ("%VIDEODIR%\*.mp4") do (
    call :GetCoverCount "%%F"

    set "count=!errorlevel!"

    if !count! gtr 0 (
        set /a count+=1
        echo %%~nxF  → 封面数量：!count!

        for /l %%i in (1,1,!count!) do (
            @REM echo %%i
            call :RemoveCover "%%F"
        )

    )
)

echo.
echo 检测完成
@REM pause
exit /b


:: ==================================================
:: 函数：统计 attached pic 出现次数
:: 参数：
::   %1 视频路径
:: 返回：
::   errorlevel = attached pic 出现次数
:: ==================================================
:GetCoverCount
set "file=%~1"
set count=0

for /f %%C in ('
    ffmpeg -i "%file%" 2^>^&1 ^| findstr /i "attached pic"
') do (
    set /a count+=1
)

exit /b %count%



:: ==================================================
:: 函数：删除视频封面
:: 参数：
::   %1 视频完整路径
:: ==================================================
:RemoveCover
set "file=%~1"
set "name=%~nx1"
set "dir=%~dp1"

echo 正在处理 %name% ...

ffmpeg -i "%file%" -map 0 -map -0:v:1 -c copy "%dir%temp_%name%"

move /y "%dir%temp_%name%" "%file%"

exit /b
