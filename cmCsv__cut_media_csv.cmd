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
set "ext=%~x1"
set "dir=%~dp1"

set "outdir=%dir%%name%_split"
if not exist "%outdir%" mkdir "%outdir%"

echo.
echo 请把 CSV 文件拖进来（直接回车=手动输入）（CSV要GBK编码的）（CSV路径不用双引号,有空格也没关系）：
set /p csvfile=

if not "%csvfile%"=="" (
    if exist "%csvfile%" (
        goto CSV_MODE
    ) else (
        echo CSV 文件不存在，转为手动模式
    )
)

:MANUAL_MODE
echo.
echo 请输入分割时间点，例如：
echo 00:03:00,00:06:14
set /p points=时间点：

set "points=%points:,= %"
goto GET_ENDTIME


:CSV_MODE
set prev=00:00:00
set idx=1
goto GET_ENDTIME


:GET_ENDTIME
rem 获取视频总时长
for /f "tokens=1 delims=." %%a in ('
    ffprobe -v error -show_entries format^=duration -of default^=noprint_wrappers^=1:nokey^=1 "%input%"
') do set /a dursec=%%a

set /a h=dursec/3600
set /a m=(dursec%%3600)/60
set /a s=dursec%%60

if %h% LSS 10 (set endtime=0%h%) else set endtime=%h%
if %m% LSS 10 (set endtime=%endtime%:0%m%) else set endtime=%endtime%:%m%
if %s% LSS 10 (set endtime=%endtime%:0%s%) else set endtime=%endtime%:%s%


if "%csvfile%"=="" goto MANUAL_CUT

rem ================= CSV 剪辑 =================
set idx=1
set prev=00:00:00
set first=1

for /f "usebackq tokens=1-3 delims=," %%a in ("%csvfile%") do (
    set "cur_title=%%b"
    set "cur_time=%%c"

    if "!first!"=="1" (
        call :CUT "!prev!" "!cur_time!" "开头"
        set first=0
    ) else (
        call :CUT "!prev!" "!cur_time!" "!last_title!"
    )

    set "last_title=!cur_title!"
    set "prev=!cur_time!"
)

call :CUT "!prev!" "%endtime%" "!last_title!"

goto DONE


:MANUAL_CUT
set idx=1
set prev=00:00:00

for %%t in (%points%) do (
    call :CUT "!prev!" "%%t" ""
    set "prev=%%t"
)

call :CUT "!prev!" "%endtime%" ""
goto DONE


:CUT
set "start=%~1"
set "end=%~2"
set "title=%~3"

if %idx% LSS 10 (set no=0%idx%) else set no=%idx%

set "sname=%start::=-%"
set "ename=%end::=-%"

if "%title%"=="" (
    ffmpeg -y -ss "%start%" -to "%end%" -i "%input%" -c copy ^
    "%outdir%\%name%_(%no%)_(%sname%_%ename%)%ext%"
) else (
    ffmpeg -y -ss "%start%" -to "%end%" -i "%input%" -c copy ^
    "%outdir%\%name%_(%no%)_%title%_(%sname%_%ename%)%ext%"
)

set /a idx+=1
exit /b


:DONE
echo.
echo 分割完成
echo 输出目录：%outdir%
pause
exit /b
