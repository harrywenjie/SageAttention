@echo off
call "C:\Program Files\Microsoft Visual Studio\2022\Community\VC\Auxiliary\Build\vcvarsall.bat" x64

REM 设置Python编译环境变量
set DISTUTILS_USE_SDK=1
set PY_VCRUNTIME_REDIST=No
set MSSdk=1

call venv\Scripts\activate.bat
python setup.py clean --all
set DISTUTILS_DEBUG=1
set VERBOSE=1
@REM python setup.py bdist_wheel
python -m pip wheel . -vvv -w dist/
