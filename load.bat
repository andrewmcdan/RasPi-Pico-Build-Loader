@REM TASKKILL /f /im putty.exe
@REM TIMEOUT /t 4 /nobreak
@REM START "" "E:\Program Files (x86)\PuTTY\putty.exe" -serial COM6 -sercfg 1200,8,n,1,N
@REM TIMEOUT /t 2 /nobreak
@REM TASKKILL /f /im putty.exe
@REM TIMEOUT /t 2 /nobreak
@REM copy "P:\Documents\RasPi Pico\i2c slave testing\build\i2c_slave_test.uf2" j:
@REM TIMEOUT /t 3 /nobreak
@REM START "" "E:\Program Files (x86)\PuTTY\putty.exe" -serial COM6 -sercfg 115200,8,n,1,N

@echo off
echo.
set /A loopCount = 1
:beginOfScript
echo checking for running PuTTy.exe
echo.
tasklist /FI "IMAGENAME eq putty.exe" 2>NUL | find /I /N "putty.exe">NUL
if "%ERRORLEVEL%"=="0" (  echo Killing PuTTy process & TASKKILL /f /im putty.exe & TIMEOUT /t 2 /nobreak) else ( echo putty.exe process not found. Continuing.)
echo Resetting PICO into bootloader.
START "" "E:\Program Files (x86)\PuTTY\putty.exe" -serial COM6 -sercfg 1200,8,n,1,N
echo Waiting for PICO to load bootloader.
TIMEOUT /t 1 /nobreak
TASKKILL /f /im putty.exe
echo Finding PICO...
:checkLoop
setlocal
for %%i in (d:,e:,f:,g:,h:,i:,j:,k:,l:,m:,n:,o:,p:,q:,r:,s:,t:,u:,v:,w:,x:,y:,z:) do (
    call :FindADrive %%i
    echo Checking for PICO as drive %%i
    set /A loopCount = %loopCount% + 1
)
if %loopCount% == 2 TIMEOUT /t 2 /nobreak & goto :beginOfScript
if %loopCount% == 3 TIMEOUT /t 2 /nobreak & goto :beginOfScript
if %loopCount% == 4 goto :notFound
goto :checkLoop
:IsRPI_PICO
setlocal
if "%~1" == "RPI-RP2" ( echo Found PICO & call :FoundPICO %~2)
endlocal
EXIT /B 0
:FindADrive
setlocal
::
call :IsDeviceReady %~1 isready_
@REM echo Device %~1 ready: %isready_%
if /i "%isready_%"=="false" (endlocal & exit /b 0)
::
call :GetLabel %~1 label_
echo The label of Volume %~1 is %label_%
call :IsRPI_PICO %label_% %~1
endlocal
exit /b 0
::
:IsDeviceReady
setlocal
set ready_=true
dir "%~1" > nul 2>&1
if %errorlevel% NEQ 0 set ready_=false
endlocal & set "%2=%ready_%"
exit /b 0
::
:GetLabel
setlocal
for /f "tokens=5*" %%a in (
  'vol "%~1"^|find "Volume in drive "') do (
    set label_=%%b)
endlocal & set "%2=%label_%"
exit /b 0
:notFound
echo PICO not found. Exiting.
TIMEOUT /t 4 /nobreak
goto :EOF
:FoundPICO
echo PICO was found. Copying.
copy "P:\Documents\RasPi Pico\i2c slave testing\build\i2c_slave_test.uf2" %~1
echo Waiting for PICO to reboot before starting serial terminal
TIMEOUT /t 2 /nobreak

@REM The following lines can be removed if you like.
START "" "E:\Program Files (x86)\PuTTY\putty.exe" -serial COM6 -sercfg 115200,8,n,1,N
echo PuTTy was started. Switching to PuTTy.
nircmd win activate process putty.exe
EXIT
