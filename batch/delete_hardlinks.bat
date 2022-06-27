@echo off

if "%~1"=="" (
    echo Usage: delete_hardlinks.bat [file_1] [file_2] [...]
    echo    OR: Drag files onto the .bat script in the explorer
    exit /b
)

rem For each file in the arguments
for %%f in (%*) do (
    echo Fichier : %%f
    rem Loop through its hardlinks
    for /f "usebackq tokens=*" %%h in (`fsutil hardlink list %%f`) DO (
        echo;  Hardlink : %%h
    )
)

echo;
rem Note: there is a space at the end of the next line
set /p answer=Delete all these files? ([y]es) 

rem Logical OR
if "%answer%" == "y" goto delete
if "%answer%" == "yes" goto delete

goto cancel

:delete
rem For each file in the arguments
for %%f in (%*) do (
    rem Loop through its hardlinks
    for /f "usebackq tokens=*" %%h in (`fsutil hardlink list %%f`) DO (
        echo Deleting: %%h
        del "%%h"
    )
)
goto end

:cancel
echo;Cancelled
goto end


:end
echo;
pause