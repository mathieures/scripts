if "%1"=="" goto :usage
if "%3"=="" goto :usage
cd %1
for %%F in (*) do mklink /h %2/%%F %%F
goto :eof

:usage
@echo Creates hardlinks for every file in the source directory into the target directory
@echo Usage:
@echo 	hardlinks source_dir target_dir
echo;
pause
