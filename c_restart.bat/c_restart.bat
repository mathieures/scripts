@echo off

SetLocal EnableDelayedExpansion EnableExtensions

if [%1] == [] goto usage
rem If there is no argument, show usage and end


rem Initialize 'doprompt'
set "doprompt="
set args=%*

rem If no /p is present, go to the loop
echo %args%| FIND /i "/p" > NUL
if ERRORLEVEL 1 goto loop

goto doprompt


:doprompt
rem Set the new args
set "doprompt=true"

rem Remove the '/p', wherever it is
set args=%args:/p=%
set args=%args:/P=%

rem Remove spaces if there are any
set args=%args: =%


:loop
set /a i=0

FOR /F "delims=, tokens=2,3" %%A IN (
	'"wmic process get ProcessId, ExecutablePath /format:csv | find /i ^"%args%^""'
) DO (

	echo %%A - %%B

	set /A liste[!i!]=%%B
	set /A i+=1
	rem Add the pid on index i

	rem Expand %%A into a drive, path, file and file extension
	if [!i!] == [1] set execPath=%%~fA
)

if [!i!] == [0] echo No process running have this name & goto end

if [%doprompt%] == [true] goto prompt
goto restart


:prompt
echo;
echo Number of process(es): !i!

set "answer="
set /p answer=Do you really want to restart the(se) process(es)? [Any key to NOT]: 

if [%answer%] == [] goto restart
goto end


:restart
set /a i-=1
for /L %%j in (0,1,!i!) do taskkill /f /pid !liste[%%j]!
rem From 0 to i, by steps of 1
rem Start the program in a new cmd but without window
start /b "" "%execPath%" > NUL
goto end


:end
echo [Closing in 3s]
timeout 3 > NUL
exit /b 0


:usage
echo This script provides an easy way to restart certain processes from the command line.
echo  Usage :
echo  %~nx0	[/p] ^<process^>
echo         /p    prompts before restarting
echo;
rem pause