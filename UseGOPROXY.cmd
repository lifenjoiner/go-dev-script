if "%~1"=="on" (
    set GO111MODULE=on
    set GOPROXY=https://goproxy.io
) else (
    set GO111MODULE=
    set GOPROXY=
)
