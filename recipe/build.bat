@echo off
:: Windows build script for zbar via autotools_clang_conda.
::
:: autotools_clang_conda sets up a bash + clang + lld + MSYS2 environment
:: that can run autotools configure scripts and produce MSVC-compatible binaries.
::
:: The actual build logic lives in build.sh; this script just hands off to it
:: through the shim provided by autotools_clang_conda.

call %BUILD_PREFIX%\Library\bin\run_autotools_clang_conda_build.bat
if %ERRORLEVEL% neq 0 exit /b 1
