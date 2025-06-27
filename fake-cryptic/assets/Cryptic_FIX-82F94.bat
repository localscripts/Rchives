@echo off
title Utility Fix Tool
color 0A

:: Function to check if running as admin
:CheckAdmin
fsutil dirty query %systemdrive% >nul 2>&1
if '%errorlevel%'=='0' goto Admin
echo.
echo [!] PLEASE RUN THIS SCRIPT AS ADMINISTRATOR.
pause
exit

:Admin
:: We are running as admin
goto MENU

:MENU
cls
echo ------------------------------------------------------------------------
echo                           WINDOWS FIX MENU
echo ------------------------------------------------------------------------
echo 1) - INSTALL REQUIRED FILES
echo 5) - REPAIR REDISTRIBUTABLES
echo 6) - FIX CORE ISOLATION "PAGE NOT AVAILABLE"
echo 9) - FIX BLUE SCREENS
echo 10) - FIX BLACK SCREENS
echo 11) - DISABLE CORE ISOLATION
echo 12) - DISABLE VULNERABLE DRIVER BLOCKLIST
echo 13) - CLEAR TEMP
echo 14) - EXIT
echo ------------------------------------------------------------------------

set /p choice="Select an option (1-14): "

if "%choice%"=="1" goto FIX1
if "%choice%"=="5" goto FIX5
if "%choice%"=="6" goto FIX6
if "%choice%"=="9" goto FIX9
if "%choice%"=="10" goto FIX10
if "%choice%"=="11" goto FIX11
if "%choice%"=="12" goto FIX12
if "%choice%"=="13" goto FIX13
if "%choice%"=="14" exit

goto MENU

:FIX1
echo INSTALLING REQUIRED SOFTWARES...

:: Install VC Redist X64
echo DOWNLOADING VC REDIST X64...
powershell -Command "Invoke-WebRequest -Uri 'https://aka.ms/vs/17/release/vc_redist.x64.exe' -OutFile '%temp%\vc_redist.x64.exe'; Start-Process '%temp%\vc_redist.x64.exe' -Wait"

:: Install VC Redist X86
echo DOWNLOADING VC REDIST X86...
powershell -Command "Invoke-WebRequest -Uri 'https://aka.ms/vs/17/release/vc_redist.x86.exe' -OutFile '%temp%\vc_redist.x86.exe'; Start-Process '%temp%\vc_redist.x86.exe' -Wait"

:: Install DirectX
echo DOWNLOADING DIRECTX...
powershell -Command "Invoke-WebRequest -Uri 'https://download.microsoft.com/download/1/7/1/1718CCC4-6315-4D8E-9543-8E28A4E18C4C/dxwebsetup.exe' -OutFile '%temp%\dxwebsetup.exe'; Start-Process '%temp%\dxwebsetup.exe' -Wait"

echo INSTALLATION COMPLETE.
pause
goto MENU

:FIX5
echo REPAIRING REDISTRIBUTABLES...

set "x64_url=https://aka.ms/vs/17/release/vc_redist.x64.exe"
set "x86_url=https://aka.ms/vs/17/release/vc_redist.x86.exe"
set "x64_file=%temp%\vc_redist.x64.exe"
set "x86_file=%temp%\vc_redist.x86.exe"

echo DOWNLOADING X64 REDIST...
bitsadmin /transfer "DownloadX64" %x64_url% %x64_file%

echo DOWNLOADING X86 REDIST...
bitsadmin /transfer "DownloadX86" %x86_url% %x86_file%

echo RUNNING REPAIR FOR X64...
%x64_file% /repair /quiet /norestart

echo RUNNING REPAIR FOR X86...
%x86_file% /repair /quiet /norestart

echo CLEANING UP...
del "%x64_file%" >nul 2>&1
del "%x86_file%" >nul 2>&1

echo DONE! PLEASE RESTART YOUR PC.
pause
goto MENU

:FIX6
echo FIXING CORE ISOLATION "PAGE NOT AVAILABLE"

echo STARTING WMI SERVICE...
net start winmgmt

echo STARTING SECURITY CENTER SERVICE...
net start wscsvc

echo APPLYING REGISTRY FIXES...
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\DeviceGuard" /v EnableVirtualizationBasedSecurity /t REG_DWORD /d 0 /f
reg add "HKLM\SYSTEM\CurrentControlSet\Control\DeviceGuard" /v EnableVirtualizationBasedSecurity /t REG_DWORD /d 0 /f
reg add "HKLM\SYSTEM\CurrentControlSet\Control\DeviceGuard\Scenarios\CredentialGuard" /v Enabled /t REG_DWORD /d 0 /f
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows Defender Security Center\Device Security" /v CoreIsolation /t REG_DWORD /d 1 /f

echo.
echo [!] A RESTART IS REQUIRED TO APPLY CHANGES.
set /p restartChoice=Do you want to restart now? (Y/N): 
if /I "%restartChoice%"=="Y" (
    shutdown /r /t 0
)
goto MENU

:FIX9
echo FIXING BLUE SCREENS...

echo DISABLING MEMORY INTEGRITY AND BLOCKLIST...
reg add "HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Control\DeviceGuard" /v EnableVirtualizationBasedSecurity /t REG_DWORD /d 0 /f
reg add "HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Control\DeviceGuard" /v EnableUefiNetworkStack /t REG_DWORD /d 0 /f
reg add "HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Control\DeviceGuard" /v EnableDriverSecurity /t REG_DWORD /d 0 /f

echo DONE. RESTART YOUR COMPUTER.
pause
goto MENU

:FIX10
echo FIXING BLACK SCREENS ON ROBLOX...

echo 1. OPEN DISPLAY SETTINGS.
echo 2. INCREASE YOUR SCREEN RESOLUTION.
echo 3. TEST UNTIL THE BLACK SCREEN IS GONE.
pause
goto MENU

:FIX11
echo DISABLING CORE ISOLATION...
reg add "HKLM\SYSTEM\CurrentControlSet\Control\DeviceGuard\Scenarios\HypervisorEnforcedCodeIntegrity" /v Enabled /t REG_DWORD /d 0 /f
echo DONE. PLEASE RESTART YOUR COMPUTER.
pause
goto MENU

:FIX12
echo DISABLING VULNERABLE DRIVER BLOCKLIST...
reg add "HKLM\SYSTEM\CurrentControlSet\Control\CI\Config" /v VulnerableDriverBlocklistEnable /t REG_DWORD /d 0 /f

if %errorlevel%==0 (
    echo VULNERABLE DRIVER BLOCKLIST DISABLED.
) else (
    echo FAILED TO MODIFY REGISTRY!
)

pause
goto MENU

:FIX13
echo CLEARING TEMP FILES...

del /f /s /q "%temp%\*.*" >nul 2>&1
for /d %%p in ("%temp%\*.*") do rmdir "%%p" /s /q >nul 2>&1

echo TEMP FILES CLEARED.
pause
goto MENU
