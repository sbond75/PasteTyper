@echo off

"C:\Program Files\AutoHotkey\Compiler\Ahk2Exe.exe" /in "Paste.ahk" /out "PasteTyper-%version%.exe"

REM Now build the python scripts
.venv\Scripts\activate.bat && pyinstaller -y diffs.py
