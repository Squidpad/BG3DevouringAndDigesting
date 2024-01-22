@echo off
setlocal
cd /d %~dp0

if not exist "Tools\BG3ModdingTools\.git" (
    git clone "https://github.com/LaughingLeader/BG3ModdingTools.git" "Tools\BG3ModdingTools" || goto :error
)

if not exist "Tools\ConverterApp\ConverterApp.exe" (
    call :downloadAndUnzip "https://github.com/Norbyte/lslib/releases/download/v1.18.7/ExportTool-v1.18.7.zip" "Tools\ConverterApp"
    if not exist "Tools\ConverterApp\ConverterApp.exe" goto :error
)

@rem I failed to make lxml 4.6.3 work with Python 3.10+ on Windows. So let's replace its version and hope nothing breaks.
python -c "import re; file = 'Tools\\BG3ModdingTools\\scripts\\requirements.txt'; open(file, 'r+').write(re.sub(r'^lxml==4\.6\.3$', 'lxml==5.1.0', open(file).read(), flags=re.MULTILINE))"

python -m venv "Tools\PythonVEnvs\BG3ModdingTools" || goto :error
call .\Tools\PythonVEnvs\BG3ModdingTools\Scripts\activate.bat || goto :error
pushd "Tools\BG3ModdingTools" || goto :error
call .\InstallScriptRequirements.bat || goto :error
popd || goto :error

echo.
echo Done.
goto :eof


:downloadAndUnzip <Url> <Output>
set py="%temp%\downloadAndUnzip.py"
if exist %py% del /f /q %py%
>%py%  echo import os, zipfile, io, pathlib, urllib.request
>>%py% echo extractFrom = pathlib.Path(%1).stem + '/'
>>%py% echo with urllib.request.urlopen(%1) as response:
>>%py% echo     with zipfile.ZipFile(io.BytesIO(response.read())) as z:
>>%py% echo         for file_info in z.infolist():
>>%py% echo             if file_info.filename.startswith(extractFrom) and not file_info.is_dir():
>>%py% echo                 file_info.filename = os.path.relpath(file_info.filename, extractFrom)
>>%py% echo                 z.extract(file_info, %2)
python %py%
del /f /q %py%
goto :eof

:error
echo Interrupted by an error. 1>&2
exit /b 1
