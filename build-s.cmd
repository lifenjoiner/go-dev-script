::https://golang.org/cmd/go/#hdr-Compile_packages_and_dependencies
::If a package matches patterns given in multiple flags, the latest match on the command line wins.
::New `-trimpath` strategy has been implemented: https://golang.org/doc/go1.13. Old style one still works!
@echo off
Setlocal Enabledelayedexpansion

echo Usage: %~n0 [MainDir [SrcParent TopDir [ExtArgs]]]
echo Overwrite ldflags example: -ldflags="all=-s -w -X main.APP_VERSION=2.0"

set NeedPopd=
set ExtArgs=%*

:CurMainDir
if not "%~1"=="" (
    pushd %1 && set NeedPopd=Y
    if "%~2"=="" (set "ExtArgs=!ExtArgs:%1=!") else (set "ExtArgs=!ExtArgs:%1 =!")
)
set MainDir=%cd%

:CusGoPath
set SrcParent=
if "%~2"=="" (
    if "%~n1"=="src" (
        set SrcParent=%~dp1
    ) else if exist src\ (
        set SrcParent=%~dpn1
    )
) else (
    set SrcParent=%2
    if "%~3"=="" (set "ExtArgs=!ExtArgs:%2=!") else (set "ExtArgs=!ExtArgs:%2 =!")
)
if not "%SrcParent%"=="" if "!SrcParent:~-1!"=="\" set SrcParent=%SrcParent:~0,-1%

:CurTopPath
if "%~3"=="" (
    set TopDir=%MainDir%
) else (
    set TopDir=%3
    if "%~4"=="" (set "ExtArgs=!ExtArgs:%3=!") else (set "ExtArgs=!ExtArgs:%3 =!")
)
if "%TopDir:~-1%"=="\" set TopDir=%TopDir:~0,-1%

echo.
echo MainDir: %MainDir%
echo SrcParent: %SrcParent%
echo TopDir: %TopDir%
echo ExtArgs: %ExtArgs%

if not "%SrcParent%"=="" set GOPATH=%GOPATH%;%SrcParent%
set Build=go build -ldflags="all=-s -w" -trimpath -gcflags="-trimpath=%MainDir%" -asmflags="-trimpath=%MainDir%"
if not "%MainDir%"=="%TopDir%" set Build=%Build% -gcflags="-trimpath=%TopDir%" -asmflags="-trimpath=%TopDir%"

@echo on
%Build% %ExtArgs%
@echo off

if _%NeedPopd%==_Y popd

Endlocal
exit /b
