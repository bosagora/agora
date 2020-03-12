call dub test --skip-registry=all --compiler=%DC%
call rdmd --compiler=%DC% ./tests/runner.d --compiler=%DC% -cov
call dub build --skip-registry=all --compiler=%DC%
call dub build -c client --skip-registry=all --compiler=%DC%
