@echo off

title Auto Winget Upgrade

set packages_file=%LOCALAPPDATA%\auto_winget_upgrade_packages.txt
rem Create empy file if it doesn't exist
if not exist %packages_file% ( fsutil file createnew %packages_file% 0 )

if "%1"=="add" goto adding_loop
if "%1"=="list" goto list_packages
if "%1"=="edit" goto edit_file

rem No argument
:upgrading
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

:adding_loop
shift
rem Break condition
if "%1"=="" (
	goto adding_loop_end
) else (
	echo Adding %1
	>>%packages_file% echo %1
	goto adding_loop
)
:adding_loop_end
goto end


:list_packages
rem List packages in the file
for /f %%A in (%packages_file%) do (
	echo %%A
)
goto end


:edit_file
rem Open the file for edit
notepad %packages_file%
goto end


:end
rem pause
exit /b