@REM <pre>
@REM 金米妮金米妮金米妮金米妮金米妮金米妮金米妮金米妮金米妮金米妮

@echo off
set /p VIDEODIR=请输入视频所在目录（如 D:\videos）： 

if not exist "%VIDEODIR%" (
    echo 目录不存在！
    exit /b
)

for %%F in ("%VIDEODIR%\*.mp4") do (
    echo 正在处理 %%F ...
    ffmpeg -i "%%F" -map 0 -map -0:v:1 -c copy "%VIDEODIR%\temp_%%~nxF"
    move /y "%VIDEODIR%\temp_%%~nxF" "%%F"
)
echo 所有视频封面已删除完成！
pause
