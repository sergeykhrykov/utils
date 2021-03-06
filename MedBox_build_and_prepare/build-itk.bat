@rem Define build properties
@set BIT=32
@set BUILD_CONFIG=Debug
@rem set BUILD_CONFIG=RelWithDebInfo

@set CMAKE_INSTALL_PREFIX="c:\dev\ITK\_install\%BIT%bit\%BUILD_CONFIG%"
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

@echo Building ITK for %BIT% bit in %BUILD_CONFIG% configuration
@echo Running CMake...

@rem Change current dir and call CMake
@cd build
@cmake ..\src -DCMAKE_BUILD_TYPE="%BUILD_CONFIG%" -DBUILD_TESTING:BOOL=FALSE -DBUILD_EXAMPLES:BOOL=FALSE -DBUILD_SHARED_LIBS:BOOL=TRUE -DCMAKE_INSTALL_PREFIX=%CMAKE_INSTALL_PREFIX% -G%GENERATOR% %CMAKE_ADDITIONAL_OPTS%

@echo Running MSBuild...
@rem Call MSBuild
@msbuild ALL_BUILD.vcxproj /p:configuration=%BUILD_CONFIG%
@msbuild INSTALL.vcxproj /p:configuration=%BUILD_CONFIG%

@ rem Return to the initial directory
@cd ..
@echo Done.