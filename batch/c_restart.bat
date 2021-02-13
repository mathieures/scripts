@echo off

SetLocal EnableDelayedExpansion EnableExtensions

if "%*"=="" goto :usage
rem if there is no argument, show usage and end


set "doprompt="
rem initialise 'doprompt' to nothing
set newargs=%*

echo %newargs% | FIND /i "/p" > NUL
if ERRORLEVEL 1 goto :loop
goto :setnewargs


:setnewargs
set "doprompt=yes"

rem we remove the '/p', wherever it is
set newargs=%newargs:/p=%
set newargs=%newargs:/P=%

rem remove spaces if there is any
set newargs=%newargs: =%


:loop
set /a i=0

FOR /F "delims=, tokens=2,3" %%A IN (
	'"wmic process get ProcessId, ExecutablePath /format:csv | find /i ^"%newargs%^""'
) DO (

	echo %%A - %%B

	set /A liste[!i!]=%%B
	set /A i+=1
	rem Add the pid on index i

	rem Expand %%A into a drive, path, file and file extension
	if "!i!"=="1" set execPath=%%~fA
)

if "!i!"=="0" echo No process running have this name & goto :end

if "%doprompt%"=="yes" goto :prompt
goto :restart


:prompt
echo;
echo Number of process(es): !i!

set "answer="
set /p answer=Do you really want to restart the(se) process(es)? [Any key to NOT]: 

if "%answer%"=="" goto :restart
goto :end


:restart
set /a i-=1
for /L %%j in (0,1,!i!) do taskkill /f /pid !liste[%%j]!
rem From 0 to i, by steps of 1
rem Start the program in a new cmd but without window
start /b "" "%execPath%" > NUL
goto :end


:end
echo [Closing in 3s]
timeout 3 > NUL
goto :eof


:usage
echo This script provides an easy way to restart certain processes from the command line.
echo  Usage :
echo  %~nx0	[/p] ^<process^>
echo 		 /p 	prompts before restarting
echo;
pause