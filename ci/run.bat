rem call dub test --skip-registry=all --compiler=%DC%
call dub build --skip-registry=all --compiler=%DC% -c unittest -b unittest
if %errorlevel% neq 0 exit /b %errorlevel%
call rdmd --build-only --compiler=%DC% ./tests/runner.d --compiler=%DC% -cov
if %errorlevel% neq 0 exit /b %errorlevel%
call dub build --skip-registry=all --compiler=%DC%
if %errorlevel% neq 0 exit /b %errorlevel%
call dub build -c client --skip-registry=all --compiler=%DC%
if %errorlevel% neq 0 exit /b %errorlevel%
