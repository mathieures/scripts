@echo off

if [%~1] == [?] goto usage
if [%~1] == [help] goto usage

setlocal
setlocal enabledelayedexpansion

rem Accents are not redirected correctly without this command
chcp 65001 >NUL


rem Get basic info for all networks
rem For each line of the output containing a network name
for /F "tokens=*" %%r in ('netsh wlan show profiles ^| findstr /R ":.."') do (
	set "name="
	rem Save the right side of the colon in the 'name' variable
	for /F "tokens=2 delims=:" %%a in ('echo %%r') do (
		set "name=%%a"
	)
	rem We now have the network name with a space in front of it, so we cut it
	set name=!name:~1!

	rem This command displays infos on the network with the
	rem name 'name', the 33rd line containing the password:
	rem netsh wlan show profiles name="!name!" key=clear

	call :get_pass_of_network !name!
)
goto end


rem Subroutine: display the name and password of the network with the name given in parameter
:get_pass_of_network
rem Split on colons and skip 32 lines (is it consistent?)
for /F "delims=: tokens=*" %%c in (
	'netsh wlan show profiles name^="%*" key^=clear ^| more +32'
) do (
	rem The password with a space is the second element
	for /F "delims=: tokens=1,*" %%d in ('echo %%c') do (
		set "pass=%%e"
		rem If there is a password, 'pass' will have a space in the front
		if not [!pass!] == [] (
			set "pass=!pass:~1!"
		)
		echo !name!:!pass!
		rem Break
		exit /b
	)
)
exit /b


:usage
echo This script displays all registered wifi names and passwords in the form 'network:password'.
echo Networks without a password just do not have anything after the colon.
echo  Usage:
echo  %~nx0 [?^|help]
pause
goto end

:end