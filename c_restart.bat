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
	rem add the pid on index i

	rem Expands %%A into a drive, path, file and file extension
	if "!i!"=="1" set execPath=%%~dpnxA
)

if "%doprompt%"=="yes" goto :prompt
goto :restart


:prompt
if "!i!"=="0" echo No process running have this name & goto :end
echo;
echo Number of process(es): !i!

set "answer="
set /p answer=Do you really want to restart the(se) process(es)? [Any key to NOT]: 

if "%answer%"=="" goto :restart
goto :end


:restart
set /a i-=1
for /L %%j in (0,1,!i!) do taskkill /f /pid !liste[%%j]!

START "%execPath%" "%execPath%"
goto :end


:end
echo [Closing in 3s]
timeout 3 > NUL
goto :eof


:usage
echo Usage :
echo c_restart [/p] application
echo 	   /p	prompts before restarting
echo;
pause