@echo off
setlocal enabledelayedexpansion

echo.
echo ===== 视频 + 字幕 文件夹批量合成 =====
echo.

:: ==============================
:: 输入视频文件夹
:: ==============================
echo 请输入【视频文件夹路径】：
set /p videodir=

if "%videodir%"=="" exit /b
if not exist "%videodir%" (
    echo 视频文件夹不存在
    pause
    exit /b
)

:: ==============================
:: 输入字幕文件夹
:: ==============================
echo.
echo 请输入【字幕文件夹路径】：
set /p srtdir=

if "%srtdir%"=="" exit /b
if not exist "%srtdir%" (
    echo 字幕文件夹不存在
    pause
    exit /b
)

:: ==============================
:: 统计文件数量
:: ==============================
set vcount=0
for %%f in ("%videodir%\*.mp4") do set /a vcount+=1

set scount=0
for %%f in ("%srtdir%\*.srt") do set /a scount+=1

echo.
echo 视频数量：%vcount%
echo 字幕数量：%scount%

if not "%vcount%"=="%scount%" (
    echo.
    echo ? 视频和字幕数量不一致，已退出
    pause
    exit /b
)

:: ==============================
:: 输出目录
:: ==============================
set "outdir=%videodir%\subtitle-video"
if not exist "%outdir%" mkdir "%outdir%"

:: ==============================
:: 批量合成
:: ==============================
echo.
echo ===== 开始合成 =====
echo.

set idx=0

for %%v in ("%videodir%\*.mp4") do (
    set /a idx+=1
    set "video=%%v"

    set sidx=0
    for %%s in ("%srtdir%\*.srt") do (
        set /a sidx+=1
        if !sidx! EQU !idx! (
            set "srt=%%s"
        )
    )

    for %%A in ("!video!") do set "vname=%%~nA"

    set "outfile=%outdir%\subtitle_!vname!.mp4"

    echo ----------------------------------
    echo 视频：!video!
    echo 字幕：!srt!
    echo 输出：!outfile!

    ffmpeg -y ^
        -i "!video!" ^
        -i "!srt!" ^
        -c copy ^
        -c:s mov_text ^
        "!outfile!"
)

echo.
echo ? 全部完成
pause
