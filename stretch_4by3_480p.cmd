@REM <pre>
@REM 金米妮金米妮金米妮金米妮金米妮金米妮金米妮金米妮金米妮金米妮

@echo off
@REM chcp 65001 >nul
setlocal

if "%~1"=="" (
    echo 请把视频文件拖到本脚本上
    pause
    exit /b
)

for %%F in (%*) do (
    ffmpeg -y -i "%%~fF" -map 0:v:0 -map 0:a? ^
    -vf "scale=640:480,setsar=1" ^
    -c:v libx264 -pix_fmt yuv420p -c:a copy ^
    "%%~dpF%%~nF_4by3_480p%%~xF"
)

echo.
echo 处理完成
pause
