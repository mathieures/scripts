@echo off

if [%~1] == [?] goto usage
if [%~1] == [help] goto usage

setlocal
setlocal enabledelayedexpansion

rem Accents are not redirected correctly without this command
chcp 65001 >NUL

set networks_list=%tmp%\networks.txt
set current_wifi_info_file=%networks_list%.tmp

netsh wlan show profiles > %networks_list%

rem For each line with a network name
for /F "tokens=*" %%r in ('type %networks_list% ^| findstr /R ":.."') do (
	set "name="
	rem Save the right side of the colon in the 'name' variable
	for /F "tokens=2 delims=:" %%a in ('echo %%r') do (
		set "name=%%a"
	)
	rem We now have the network name with a space in front of it, so we cut it
	set name=!name:~1!

	rem This command displays infos on the network with the name 'name':
	rem netsh wlan show profiles name="!name!" key=clear

	rem The 20th line of this command is the password:
	rem for /F "delims=: tokens=2" %a in ('export-wifi.bat') do (echo%a)

	rem Split lines with a colon and put the output to the file (ideally we wouldn't need one)
	(
		for /F "delims=: tokens=2" %%c in (
			'netsh wlan show profiles name^="!name!" key^=clear'
		) do (
			echo%%c
		)
	) > %current_wifi_info_file%

	rem Display the name and password of the network in the file
	call :get_pass_of_current_wifi
)
goto cleanup


rem Subroutine: display the name and password of the network in %current_wifi_info_file%
:get_pass_of_current_wifi
for /F "usebackq tokens=* skip=19" %%a in ("%current_wifi_info_file%") do (
	echo !name!:%%a
	rem Break (we only need one line)
	exit /b
)
exit /b


:usage
echo This script displays all registered wifi names and passwords.
echo Networks without a password are just shown with 'No'.
echo  Usage:
echo  %~nx0 [?^|help]
pause
goto end

:cleanup
del %networks_list%
del %current_wifi_info_file%

:end