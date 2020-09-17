@echo off

SetLocal EnableDelayedExpansion EnableExtensions

if "%*"=="" goto :usage
rem if there is no argument, show usage and end

echo %* | FIND /i "/f" > NUL
if ERRORLEVEL 1 goto :normalkill
goto :forcekill

:forcekill
::we remove the '/f', wherever it is
set args=%*
set newargs=%args:/f=%
set newargs=%args:/F=%

for %%A in (%newargs%) do taskkill /f /FI "imagename eq %%A*"
goto :end

:normalkill
for %%A in (%*) do taskkill /FI "imagename eq %%A*"
goto :end

:end
echo [Closing in 3s]
timeout 3 > NUL
goto :eof

:usage
echo Usage:
echo %TAB%c_kill application1 [application2] [...]
echo;
pause