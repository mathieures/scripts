@echo off

if [%~1] == [] (
    echo Usage: %~nx0 ^<file^> [...]
    echo    OR: Drag files onto the .bat script in the explorer
    goto end
)

rem Initialization
set args=%*

rem If /d is found at the beginning with a space after,
rem at the end with a space before, or in the middle
rem with spaces before and after: clean args, list and delete
echo %args%|findstr /i /B "\/d " > NUL && set args=%args:~3% && goto :list_and_delete
echo %args%|findstr /i /E " \/d" > NUL && set args=%args:~0,-3% && goto :list_and_delete
echo %args%|findstr /i /C:" \/d " > NUL && set args=%args: /d = % && goto :list_and_delete
rem Note: the last option removes every occurrence of ' /d ', but it shouldn't be a big problem

rem Else, list and end
call :list
goto :end


:list
rem For each file in the arguments
for %%f in (%args%) do (
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
exit /b


:list_and_delete
rem Clean the arguments

call :list

echo;
rem Note: there is a space at the end of the next line
set /p answer=Delete all these files? (y/yes/anything else for no) 

rem Logical OR
if [%answer%] == [y] goto :delete
if [%answer%] == [yes] goto :delete

goto :cancel

:delete
rem For each file in the arguments
for %%f in (%args%) do (
    rem Loop through its hardlinks
    for /f "usebackq tokens=*" %%h in (`fsutil hardlink list %%f`) DO (
        echo Deleting: %%~dh%%h
        rem del "%%~dh%%h"
    )
)
goto :end


:cancel
echo;Cancelled
goto end


:end
echo;
pause