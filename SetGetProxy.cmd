if "%~1"=="on" (
    set /p http_proxy= <proxy.txt
    set /p https_proxy= <proxy.txt
    set /p all_proxy= <proxy.txt
) else (
    set http_proxy=
    set https_proxy=
    set all_proxy=
)
