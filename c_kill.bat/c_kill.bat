@echo off

SetLocal EnableExtensions

if [%1] == [] goto usage
rem If there is no argument, show usage and end

set args=%*

echo %args%| FIND /i "/f" > NUL
if ERRORLEVEL 1 goto normalkill
goto forcekill


:forcekill
rem Remove the '/f', wherever it is
set args=%args:/f=%
set args=%args:/F=%

for %%A in (%args%) do taskkill /f /FI "imagename eq %%~A*"
goto end


:normalkill
for %%A in (%args%) do taskkill /FI "imagename eq %%~A*"
goto end


:end
echo [Closing in 3s]
timeout 3 > NUL
exit /b 0


:usage
echo This script provides an easier way to kill processes than the taskkill command.
echo It uses the FIND command to search the processes, so the full names are not required.
echo  Usage:
echo  %~nx0 [/f] ^<proc_1^> [proc_2] [...]
echo 		 /f        force kill the processes
echo 		 proc_n    name of the process to kill
echo;
rem pause