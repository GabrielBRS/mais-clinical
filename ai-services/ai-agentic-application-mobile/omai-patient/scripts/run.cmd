@echo off
setlocal
set "QT_PLUGIN_PATH=%CONDA_PREFIX%\Library\lib\qt6\plugins"
set "QML_IMPORT_PATH=%CONDA_PREFIX%\Library\lib\qt6\qml"
set "PATH=%CONDA_PREFIX%\Library\bin;%PATH%"
set "QT_QUICK_BACKEND=software"
set "QML_DISABLE_DISK_CACHE=1"
set "QT_QPA_PLATFORM=windows"
if "%1"=="--smoke" (
  set "QT_QPA_PLATFORM=offscreen"
  set "QT_QUICK_BACKEND=software"
  set "QT_QPA_FONTDIR=C:\Windows\Fonts"
)
build\omai-patient.exe %*
