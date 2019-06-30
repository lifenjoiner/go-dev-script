::https://golang.org/cmd/go/#hdr-Compile_packages_and_dependencies
::If a package matches patterns given in multiple flags, the latest match on the command line wins.
@echo off
Setlocal Enabledelayedexpansion

echo Usage: %~n0 [MainDir [PkgSrcRoot PkgDir [ExtArgs]]]
echo Overwrite ldflags example: -ldflags="all=-s -w -X main.APP_VERSION=2.0"

set NeedPopd=
set ExtArgs=%*
if not "%~1"=="" (
    pushd %1 && set NeedPopd=Y
    if "%~2"=="" (set "ExtArgs=!ExtArgs:%1=!") else (set "ExtArgs=!ExtArgs:%1 =!")
)

set MainDir=%cd%
set Build=go build -ldflags="all=-s -w" -gcflags="all=-trimpath=%GoPath%\src" -gcflags="std=-trimpath=%GOROOT%\src" -gcflags="-trimpath=%MainDir%" -asmflags="all=-trimpath=%GoPath%\src" -asmflags="std=-trimpath=%GOROOT%\src" -asmflags="-trimpath=%MainDir%"

:CusGoPath
if "%~2"=="" (
    set PkgRoot=%cd%\..
) else (
    set PkgRoot=%2
    if "%~3"=="" (set "ExtArgs=!ExtArgs:%2=!") else (set "ExtArgs=!ExtArgs:%2 =!")
)
if "%PkgRoot:~-1%"=="\" set PkgRoot=%PkgRoot:~0,-1%

:CurPkgPath
if "%~3"=="" (
    set PkgDir=%MainDir%
) else (
    set PkgDir=%3
    if "%~4"=="" (set "ExtArgs=!ExtArgs:%3=!") else (set "ExtArgs=!ExtArgs:%3 =!")
)
if "%PkgDir:~-1%"=="\" set PkgDir=%PkgDir:~0,-1%

call :BuildCmd "%PkgDir%" %PkgRoot%

@echo on
%Build% %ExtArgs%
@echo off

if _%NeedPopd%==_Y popd

Endlocal
exit /b

::BuildCmd PkgDir PkgRoot
:BuildCmd
if not "%~n2"=="src" goto :EOF
set "PkgName=!PkgDir:%~dpn2\=!"
set PkgSpc=%PkgName:\=/%
set Build=%Build% -gcflags="%PkgSpc%/...=-trimpath=%~2\%PkgName%" -asmflags="%PkgSpc%/...=-trimpath=%~2\%PkgName%" -gcflags="%PkgSpc%/vendor/...=-trimpath=%~2\%PkgName%\vendor" -asmflags="%PkgSpc%/vendor/...=-trimpath=%~2\%PkgName%\vendor"
set GOPATH=%GOROOT%\GOPATH;%~dp2
exit /b
