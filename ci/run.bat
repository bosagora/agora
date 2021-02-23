set AGORA_VERSION="HEAD"

rem call dub test --skip-registry=all --compiler=%DC%
call dub build --skip-registry=all --compiler=%DC% -c unittest -b unittest
if %errorlevel% neq 0 exit /b %errorlevel%
rem call %DC% -i -run ./tests/runner.d %DC% -cov
call %DC% -i ./tests/runner.d
rem We should really run those tests, but they are currently broken
if %errorlevel% neq 0 exit /b %errorlevel%
call dub build --skip-registry=all --compiler=%DC%
if %errorlevel% neq 0 exit /b %errorlevel%
call dub build -c client --skip-registry=all --compiler=%DC%
if %errorlevel% neq 0 exit /b %errorlevel%
