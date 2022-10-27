@echo off
::-----------------------------------------------------------------------------------
:: first  argument  - what a folder to list
:: second argument  - (optional) "NONE"|""|path to a program to launch when done.
::                               if you want to specify 3rd..9th args for dir, you need to specify "NONE"
:: third..ninth     - (optional) dir arguments, for example "*.smali" "*.xml"
::-----------------------------------------------------------------------------------
chcp 65001 1>nul 2>nul

::------------------------------- normalize env to English. might help with ls (has no effect for dir..)
set "LANG=en_US.UTF-8"
set "LANGUAGE=en_US"
set "LC_CTYPE=en_US.UTF-8"
set "LC_NUMERIC=en_US.UTF-8"
set "LC_TIME=en_US.UTF-8"
set "LC_COLLATE=en_US.UTF-8"
set "LC_MONETARY=en_US.UTF-8"
set "LC_MESSAGES=en_US.UTF-8"
set "LC_PAPER=en_US.UTF-8"
set "LC_NAME=en_US.UTF-8"
set "LC_ADDRESS=en_US.UTF-8"
set "LC_TELEPHONE=en_US.UTF-8"
set "LC_MEASUREMENT=en_US.UTF-8"
set "LC_IDENTIFICATION=en_US.UTF-8"
set "LC_ALL=en_US.UTF-8"
::-------------------------------------------

echo [INFO] arguments: 1>&2
echo [INFO] 1: »%~1«   1>&2
echo [INFO] 2: »%~2«   1>&2
echo [INFO] 3: »%~3«   1>&2
echo [INFO] 4: »%~4«   1>&2
echo [INFO] 5: »%~5«   1>&2
echo [INFO] 6: »%~6«   1>&2
echo [INFO] 7: »%~7«   1>&2
echo [INFO] 8: »%~8«   1>&2
echo [INFO] 9: »%~9«   1>&2
echo. 1>&2


pushd "%~dp0"

if ["%~1"] equ [""]    ( goto ERROR_NO_ARGS                    )
if not exist "%~1"     ( goto ERROR_FIRST_ARG_NOT_EXIST        )
if not exist %~s1\NUL  ( goto ERROR_FIRST_ARG_IS_NOT_A_FOLDER  )

pushd "%~1"

::----------------------------- path in %~1 is valid, pushd resolves relative path. this solves %~nx1 empty on relative paths, since it is now extracted from %CD%. loop breaking makes variable only set once, in-case there is some weird empty space. just two little tricks.
for /f %%a in ("%CD%") do ( 
  set "NAME=%%~nxa"
  goto BREAK_LOOP
)
:BREAK_LOOP

::------------ the location does not matter, for debug purposes you can use the script's own folder, in any other case write this junk to the temp folder..
::set "FILE_LIST=%TEMP%\%~nx1__file_list.txt"
set "FILE_LIST=%~dp0\%NAME%__file_list.txt"


::--------------------- only include arguments for dir if actually needed, since including six "" (empty argument) is making dir loop, searching for "*" 6 more times (duplicated entries).
set "ARGS="
if ["%~3"] EQU [""] ( goto NO_ARG_3 )
set  ARGS=%ARGS% "%~3"
:NO_ARG_3
if ["%~4"] EQU [""] ( goto NO_ARG_4 )
set  ARGS=%ARGS% "%~4"
:NO_ARG_4
if ["%~5"] EQU [""] ( goto NO_ARG_5 )
set  ARGS=%ARGS% "%~5"
:NO_ARG_5
if ["%~6"] EQU [""] ( goto NO_ARG_6 )
set  ARGS=%ARGS% "%~6"
:NO_ARG_6
if ["%~7"] EQU [""] ( goto NO_ARG_7 )
set  ARGS=%ARGS% "%~7"
:NO_ARG_7
if ["%~8"] EQU [""] ( goto NO_ARG_8 )
set  ARGS=%ARGS% "%~8"
:NO_ARG_8
if ["%~9"] EQU [""] ( goto NO_ARG_9 )
set  ARGS=%ARGS% "%~9"
:NO_ARG_9


title %NAME% [listing files]
echo [INFO] listing files in [%~1]... 1>&2
echo dir /b /s /a-d %ARGS%  1>&2
dir /b /s /a-d %ARGS%  1>"%FILE_LIST%"
set "EXIT_CODE=%ErrorLevel%"
echo [INFO] done. 1>&2
title %NAME% [done]
if ["%EXIT_CODE%"] neq ["0"] ( goto ERROR_LISTING_FILES )
popd
echo. 1>&2



if ["%~2"] EQU [""] ( 
  echo [INFO] there is no second argument, no need to launch anything. 1>&2
  goto CONTINUE__IT_IS_FINE__NO_NEED_TO_LAUNCH_ANYTHING 
)
echo.%2 | findstr /I /C:"NONE" 1>nul 2>nul
set "EXIT_CODE=%ErrorLevel%"
if ["%EXIT_CODE%"] EQU ["0"] ( 
  echo [INFO] second argument is set to "NONE", no need to launch anything. 1>&2
  goto CONTINUE__IT_IS_FINE__NO_NEED_TO_LAUNCH_ANYTHING 
)

where "%~2" 1>nul 2>nul
set "EXIT_CODE=%ErrorLevel%"
if ["%EXIT_CODE%"] EQU ["0"] ( 
  echo [INFO] second argument [%~2] is found is system PATH and available to launch. 1>&2
  goto CONTINUE__IT_IS_FINE__PROGRAM_FOUND_IN_PATH 
)

::------- need to launch something..
if not exist "%~2"      ( goto ERROR_SECOND_ARG_NOT_EXIST       )
if exist %~s2\NUL       ( goto ERROR_SECOND_ARG_IS_NOT_A_FILE   )

:CONTINUE__IT_IS_FINE__PROGRAM_FOUND_IN_PATH

title %~nx2 [launch]
echo [INFO] launching second argument as program with file list as its argument. 1>&2
echo "%~2" "%FILE_LIST%"  1>&2
call "%~2" "%FILE_LIST%"
set "EXIT_CODE=%ErrorLevel%"
echo [INFO] done. 1>&2
title %~nx2 [done]
if ["%EXIT_CODE%"] neq ["0"] ( goto ERROR_LAUNCH )


:CONTINUE__IT_IS_FINE__NO_NEED_TO_LAUNCH_ANYTHING


goto END

::---------------------------------------------------------------

:ERROR_NO_ARGS
  set "EXIT_CODE=111"
  echo [ERROR] no arguments. 1>&2
  goto END

:ERROR_FIRST_ARG_NOT_EXIST
  set "EXIT_CODE=222"
  echo [ERROR] missing second argument, the path to run when listing is done. 1>&2
  goto END

:ERROR_FIRST_ARG_IS_NOT_A_FOLDER
  set "EXIT_CODE=333"
  echo [ERROR] first argument is not a folder. 1>&2
  goto END

:ERROR_SECOND_ARG_NOT_EXIST
  set "EXIT_CODE=444"
  echo [ERROR] second argument is not an empty string or a "NONE", which means it should be ran, but it does not seems to exist.. 1>&2
  goto END
 
:ERROR_SECOND_ARG_IS_NOT_A_FILE
  set "EXIT_CODE=555"
  echo [ERROR] second argument is not an empty string or a "NONE", which means it should be ran, but it looks like it is a folder. please specify a file to run. 1>&2
  goto END

:ERROR_LAUNCH
  echo [ERROR] you've specified to run [%~2], and it looks like it ended with an error (exit code that is not zero). 1>&2
  goto END

:END
  echo [INFO] EXIT_CODE: %EXIT_CODE%. 1>&2
  ::pause
  popd
  ::timeout /t 7 1>&2
  exit /b %EXIT_CODE%
  
