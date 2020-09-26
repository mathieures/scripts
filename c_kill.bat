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
echo This script provides an easier way to kill processes than the taskkill command.
echo It uses the FIND command to search the processes, so the full names are not required.
echo  Usage:
echo  c_kill [/f] proc_1 [proc_2] [...]
echo 		  /f		force kill the processes
echo 		  proc_n	name of the process to kill
echo;
pause