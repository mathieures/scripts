@echo off

title Auto Winget Upgrade

set packages_file=%LOCALAPPDATA%\auto_winget_upgrade_packages.txt
rem Create empty file if it doesn't exist
if not exist %packages_file% (
	rem Note: fsutil displays a message for file creation
	fsutil file createnew %packages_file% 0
	echo To add packages, use:
	echo %~nx0 add ^<package1^> [package2] [...]
	goto end
)

if [%~1] == [add] goto adding_loop
if [%~1] == [list] goto list_command
if [%~1] == [edit] goto edit_command
if [%~1] == [help] goto help_command
if [%~1] == [?] goto help_command

rem No argument
:upgrade
echo Updating sources...
rem List upgradable packages in a file
set temp_file=%tmp%\winget_upgradable_packages.txt
>%temp_file% winget upgrade

rem Run the winget upgrade command for packages in the file
for /f %%A in (%packages_file%) do (
	rem If the package is found in the upgradable packages
	>NUL find /i "%%A" %temp_file%
	if not ERRORLEVEL 1 (
		echo - Upgrading %%A
		winget upgrade %%A
	) else (
		echo x No upgrade for %%A
	)
)
goto end


:add_command
:adding_loop
shift
rem Break condition
if [%~1] == [] (
	goto adding_loop_end
) else (
	echo Adding %1
	>>%packages_file% echo %1
	goto adding_loop
)
:adding_loop_end
goto end


:list_command
rem List packages in the file
for /f %%A in (%packages_file%) do (
	echo %%A
)
goto end


:edit_command
rem Open the file for edit
notepad %packages_file%
goto end


:help_command
echo %~nx0:
echo     Automatically upgrade packages from a list of packages ID's with winget
echo;
echo     Commands:
echo       add package [package ...]    Add given packages to the list
echo       list                         List the packages in the packages list
echo       edit                         Open the packages list in notepad.exe
echo;
pause
goto end


:end