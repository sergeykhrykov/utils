@rem Define build properties
@set BIT=32
@set BUILD_CONFIG=Debug
@rem set BUILD_CONFIG=RelWithDebInfo
@set OPENGL_VERSION=OpenGL2
@rem set OPENGL_VERSION=OpenGL
@set CMAKE_INSTALL_PREFIX="c:\dev\VTK\_install\%BIT%bit.%OPENGL_VERSION%\%BUILD_CONFIG%"
@set CMAKE_ADDITIONAL_OPTS=

@rem Get generator name for MSVC 2013 and Qt path using BIT variable
@if "%BIT%"=="32" (
	@set GENERATOR="Visual Studio 12 2013"
	@set QT_PATH="C:/dev/Qt/Qt5.4.1.32bit/5.4/msvc2013_opengl"
)
@if "%BIT%"=="64" (
	@set GENERATOR="Visual Studio 12 2013 Win64"
	@set QT_PATH="C:/dev/Qt/Qt5.4.1.64bit/5.4/msvc2013_64_opengl"
)

@rem Add path to Visual Studio 12 MSBuild Binaries
@if exist "%ProgramFiles%\MSBuild\12.0\bin" set PATH=%ProgramFiles%\MSBuild\12.0\bin;%PATH%
@if exist "%ProgramFiles(x86)%\MSBuild\12.0\bin" set PATH=%ProgramFiles(x86)%\MSBuild\12.0\bin;%PATH%

@rem Change current dir and call CMake
cd build
cmake ..\src -DCMAKE_BUILD_TYPE="%BUILD_CONFIG%" -DBUILD_TESTING:BOOL=FALSE -DVTK_Group_Qt:BOOL=TRUE -DVTK_QT_VERSION:STRING="5" -DVTK_RENDERING_BACKEND:STRING="%OPENGL_VERSION%" -DCMAKE_PREFIX_PATH:PATH=%QT_PATH% -DCMAKE_INSTALL_PREFIX=%CMAKE_INSTALL_PREFIX% -G%GENERATOR% %CMAKE_ADDITIONAL_OPTS%

@rem Call MSBuild
@msbuild ALL_BUILD.vcxproj /p:configuration=%BUILD_CONFIG%
@msbuild INSTALL.vcxproj /p:configuration=%BUILD_CONFIG%

@ rem Return to the initial directory
cd ..
