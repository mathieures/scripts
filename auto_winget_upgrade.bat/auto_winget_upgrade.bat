@echo off

title Auto Winget Upgrade

set packages_file=%LOCALAPPDATA%\auto_winget_upgrade_packages.txt
rem Create empty file if it doesn't exist
if not exist %packages_file% (
	rem Note: fsutil displays a message for file creation
	fsutil file createnew %packages_file% 0
	echo To add packages, use:
	echo %~nx0 add ^<package_id_1^> [package_id_2 ...]
	goto end
)

if [%~1] == [add] goto add_command
if [%~1] == [remove] goto remove_command
if [%~1] == [list] goto list_command
if [%~1] == [edit] goto edit_command
if [%~1] == [help] goto help_command
if [%~1] == [?] goto help_command

rem No argument
:upgrade
echo Updating sources...
rem List upgradable packages in a file
set temp_file=%tmp%\auto_winget_upgrade_temp_file.txt
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
rem If there is only one argument ('add')
if [%~2] == [] (
	echo Argument needed.
	goto end
)
:adding_loop
rem Remove the first argument each iteration
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


:remove_command
rem If there is only one argument ('remove')
if [%~2] == [] (
	echo Argument needed.
	goto end
)
:removing_loop
rem Remove the first argument each iteration
shift
rem Break condition
if [%~1] == [] (
	goto removing_loop_end
) else (
	rem Search for the package in the file
	>NUL findstr /i /x %~1 %packages_file%
	if ERRORLEVEL 1 (
		echo Package '%~1' not found.
	) else (
		echo Removing '%~1'
		rem Output all non matching lines in the temp file
		>%temp_file% findstr /v /i /x %~1 %packages_file%
		rem Overwrite the packages file with the temp file
		>NUL move /y %temp_file% %packages_file%
	)

	goto removing_loop
)
:removing_loop_end
goto end


:list_command
rem List packages in the file
for /f %%A in (%packages_file%) do (
	echo %%A
)
goto end


:edit_command
rem Open the file to edit it
notepad %packages_file%
goto end


:help_command
echo %~nx0:
echo     Automatically upgrade packages from a list of packages ID's with winget
echo     Tip: put a shortcut in %APPDATA%\Microsoft\Windows\Start Menu\Programs\Startup
echo;
echo     Commands:
echo       add package_id [package_id ...]		Add given packages to the list
echo       remove package_id [package_id ...]	Remove given packages from the list
echo       list                           		List the packages in the packages list
echo       edit                           		Open the packages list in notepad.exe
echo       help^|?                        		Display this help
echo;
pause
goto end


:end
