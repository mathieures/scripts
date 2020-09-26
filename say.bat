@echo off
if "%*"=="/?" goto :usage
if "%*"=="-?" goto :usage

rem modified version from https://stackoverflow.com/a/27807260, thank to dbenham
rem with the help of: https://stackoverflow.com/a/10535753

setlocal

:getTemp
set "lockFile=%temp%\%~nx0_%time::=.%.lock"

set "lockFile=%lockFile:,=.%"
rem ^ turn commas into dots

set "tempFile=%lockFile%.temp"
9>&2 2>nul (2>&9 8>"%lockFile%" call :start %*) || goto :getTemp

rem Cleanup
2>nul del "%lockFile%" "%tempFile%.ps1"
exit /b

:start
>> %tempFile% echo Add-Type -AssemblyName System.speech
>> %tempFile% echo $say = New-Object System.Speech.Synthesis.SpeechSynthesizer

>> %tempFile% echo function Start-PSSpeech {
>> %tempFile% echo 	param ($text)
>> %tempFile% echo     $say.Speak($text)
>> %tempFile% echo }

>> %tempFile% echo if ($args[0] -eq $null){
>> %tempFile% echo     $words = Read-Host -Prompt 'Words to say'

>> %tempFile% echo     While($words -ne ""){
>> %tempFile% echo 	    Start-PSSpeech($words)
>> %tempFile% echo 	    $words = Read-Host -Prompt 'Words to say'}
>> %tempFile% echo 	}
>> %tempFile% echo else { Start-PSSpeech($args) }


set "name=%tempFile:\= %"
for /f "tokens=*" %%I in ('echo %name%') do for %%A in (%%~I) do set "last=%%A"

rename "%tempFile%" "%last%.ps1"

powershell -ExecutionPolicy Bypass -NoProfile %tempFile%.ps1 %*
exit /b

:usage
echo This script uses the SpeechSynthesizer from Powershell to say stuff.
echo  Usage:
echo  say [text]
echo 	   text		Text to speech. If not specified, the window will close only by entering ENTER.
echo;
pause