@echo off

if [%~1] == [] (
    echo Usage: %~nx0 ^<file^> [...]
    echo    OR: Drag files onto the .bat script in the explorer
    goto end
)

rem For each file in the arguments
for %%f in (%*) do (
    if exist %%f (
        echo File: %%f
        rem Loop through its hardlinks
        for /f "usebackq tokens=*" %%h in (`fsutil hardlink list %%f`) DO (
            echo;  Hardlink : %%~dh%%h
        )
    ) else (
        echo File '%%f' not found.
    )
)

echo;
rem Note: there is a space at the end of the next line
set /p answer=Delete all these files? (y/yes/anything else for no) 

rem Logical OR
if [%answer%] == [y] goto :delete
if [%answer%] == [yes] goto :delete

goto :cancel

rem For each file in the arguments
for %%f in (%*) do (
    rem Loop through its hardlinks
    for /f "usebackq tokens=*" %%h in (`fsutil hardlink list %%f`) DO (
        echo Deleting: %%~dh%%h
        del "%%~dh%%h"
    )
)
goto :end


:cancel
echo;Cancelled
goto end


:end
echo;
pause