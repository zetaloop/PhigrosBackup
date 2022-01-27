@echo off
cd /d %~dp0
set adb=.\bin\adb.exe
title PhigrOS Data Transfer
::By Zetaspace
::20220127

echo =======================
echo  PhigrOS Data Transfer
echo =======================
if not exist .\var\ mkdir var
set device=nodevice
for /f "skip=1 tokens=1" %%a in ('%adb% devices') do set device=%%a
if %device%==nodevice echo 无设备连接&echo.&echo 退出...&choice /t 1 /d n >nul&goto :EOF
echo 设备已连接: %device%
echo.

echo 您需要:
echo [B] 备份数据
echo [R] 恢复数据到设备
echo [X] 退出
::
choice /c brx /n /m "＞"
echo.
if %errorlevel%==1 goto :backup
if %errorlevel%==2 goto :restore
echo 退出...
choice /t 1 /d n >nul&goto :EOF

:backup
for /f "tokens=1,2,3 delims=/" %%a in ('echo %date%') do set date1=%%a%%b%%c
set date1=%date1:~0,8%
for /f "tokens=1,2,3 delims=:" %%a in ('echo %time%') do set time1=%%a%%b%%c
for /f "tokens=1,2 delims=." %%a in ('echo %time1%') do set time1=%%a%%b
set filename=PhigrOS_%device%_%date1%_%time1%.bak
echo  [备份数据]
echo 设备: %device%
echo 日期: %date% %time%
echo 文件: PhigrOS_%device%_%date1%_%time1%.bak
echo.
echo 已发起备份，请确认
::
%adb% backup -f .\var\%filename% com.PigeonGames.Phigros
echo 备份结束
explorer .\var\
echo.
echo 退出...
choice /t 1 /d n >nul&goto :EOF

:restore
set filename=PhigrOS_%device%_%date1%_%time1%.bak
echo  [恢复数据到设备]
echo 设备: %device%
echo 日期: %date% %time%
echo.
set /p a=请选择备份文件^> <nul
set filename=nul
for /f "usebackq delims=" %%a in (`mshta vbscript:CreateObject("Scripting.FileSystemObject"^).GetStandardStream(1^).WriteLine(CStr(CreateObject("WScript.Shell"^).Exec("mshta vbscript:""<input type=file id=a><script>a.click();new ActiveXObject('Scripting.FileSystemObject').GetStandardStream(1).Write(a.value)[close()];</script>"""^).StdOut.ReadAll^)^)(window.close^)`) do set filename=%%a
if "%filename%"=="nul" echo [未选择文件]&echo.&echo 错误: 未选择文件&echo.&echo 退出...&choice /t 1 /d n >nul&goto :EOF
echo %filename%
if not exist "%filename%" echo.&echo 错误: 文件不存在&echo.&echo 退出...&choice /t 1 /d n >nul&goto :EOF
echo.
echo 已发起恢复，请确认
::
%adb% restore "%filename%"
echo 恢复结束
echo.
echo 退出...
choice /t 1 /d n >nul&goto :EOF