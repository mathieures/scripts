@echo off

if "%*"=="" goto :usage
rem if there is no argument, show usage and end

powershell -Command "Start-Process %* -Verb RunAs"
goto end


:usage
echo This script starts the given process with administrator privileges.
echo  Usage:
echo  %~nx0 ^<process^>

:end
echo;
pause