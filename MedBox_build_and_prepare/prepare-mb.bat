@echo off

if "%~3"=="" (
	echo "Usage: build-mb <32|64> <Debug|RelWithDebInfo> <OpenGL|OpenGL2>"
	goto end
)

set BIT=%1
set CONFIG=%2
set OPENGL_VERSION=%3

if %BIT%==32 (
	set GENERATOR="Visual Studio 12 2013"
	set QT_PATH="C:/dev/Qt/Qt5.4.1.32bit/5.4/msvc2013_opengl"
)
if %BIT%==64 (
	set GENERATOR="Visual Studio 12 2013 Win64"
	set QT_PATH="C:/dev/Qt/Qt5.4.1.64bit/5.4/msvc2013_64_opengl"
)

echo Creating directory: build.%BIT%.%CONFIG%.%OPENGL_VERSION%
set BUILD_DIR=build.%BIT%.%CONFIG%.%OPENGL_VERSION%
if not exist %BUILD_DIR% mkdir %BUILD_DIR%
cd %BUILD_DIR%

echo Running CMake...
cmake .. -DMB_BIT:STRING="%BIT%" -DMB_BUILD_CONFIG:STRING="%CONFIG%" -DMB_OPENGL_VERSION="%OPENGL_VERSION%" -G%GENERATOR%

goto end





:end
@cd ..