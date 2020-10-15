@echo off
if "%*"=="" goto :usage

SetLocal EnableDelayedExpansion EnableExtensions
for %%F in (%*) do (
	set "cname=%%F"
	echo Optimizing !cname!...
	set "exename=!cname:.c=.exe!"
	gcc -Wall -O !cname! -o !exename!
)
goto :eof

:usage
echo This script can be used to bulk optimize .c files by running gcc -O
echo  Usage :
echo  %~nx0 file1 [file2] [...] [*[.ext]]
echo		* 	You can use '*' to autocomplete filenames.
echo		ext 	The file extension you want to target.
echo;
pause