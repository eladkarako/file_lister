@echo off

pushd "%~sdp0"

call "%~sdp0file_lister.cmd" "%~1" "%~2" "*.xml" "%~3" "%~4" "%~5" "%~6" "%~7" "%~8" "%~9"
set "EXIT_CODE=%ErrorLevel%"

popd
exit /b %EXIT_CODE%

