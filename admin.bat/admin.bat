@echo off

if [%~1] == [] goto :usage
rem if there is no argument, show usage and end

powershell -NoProfile -Command "Start-Process %* -Verb RunAs"
goto end


:usage
echo This script starts the given process with administrator privileges.
echo  Usage:
echo  %~nx0 ^<process^>
pause
goto end

:end
echo;