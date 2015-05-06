# CMAKE Build file
# -------------------------------- 
# Expects passed vars MB_BIT, MB_BUILD_CONFIG, and MB_OPENGL_VERSION
# Note that platform (32/64 bit) is actually chosen with cmake -G command line option. 
# MB_BIT won't affect target platform
# --------------------------------

# SET UP VERSION INFORMATION
cmake_minimum_required(VERSION 3.1)

# No idea what it does
if(POLICY CMP0020)
  cmake_policy(SET CMP0020 NEW)
endif()
if(POLICY CMP0043)
  cmake_policy(SET CMP0043 NEW)
endif()

project("mb_test_gui")

# --------------------------------
# Set variables for build configuration
# Restrict possible configs to the chosen one
set(CMAKE_CONFIGURATION_TYPES "${MB_BUILD_CONFIG}" CACHE STRING "Type of configuration" FORCE)

set (CMAKE_BUILD_TYPE ${MB_BUILD_CONFIG} CACHE STRING "Choose the type of build." FORCE)

# Set variables for 32 or 64 bit
if(${CMAKE_SIZEOF_VOID_P} MATCHES 4)
	message(STATUS "Configuring for 32 bit")
	set(BIT 32)
	set(BIT_S "32")	
	
else(${CMAKE_SIZEOF_VOID_P} MATCHES 8)
	message(STATUS "Configuring for 64 bit")
	set(BIT 64)
	set(BIT_S "64")		
endif()

# Set variable for OpenGL version
set(OpenGL_VERSION ${MB_OPENGL_VERSION})
message(STATUS "OpenGL version is ${OpenGL_VERSION}")

# --------------------------------
# Set paths to find Qt
set (QT_PATH_32 "C:/dev/Qt/Qt5.4.1_32bit/5.4/msvc2013_opengl")
set (QT_PATH_64 "C:/dev/Qt/Qt5.4.1_64bit/5.4/msvc2013_64_opengl")

# Set path to find VTK
set(VTK_ROOT_PATH "C:/dev/VTK/_install/${BIT}bit.${OpenGL_VERSION}/${CMAKE_BUILD_TYPE}" CACHE PATH "VTK directory" FORCE)
set(VTK_PATH "${VTK_ROOT_PATH}/lib/cmake/vtk-6.3/")

# --------------------------------

if (BIT MATCHES 32)
	set (QT_PATH ${QT_PATH_32})
else (BIT MATCHES 64)
	set (QT_PATH ${QT_PATH_64})
endif()

set(QT_QMAKE_EXECUTABLE PATH ${QT_PATH}/bin/qmake.exe)
set(QT_BIN_DIR ${QT_PATH}/bin)

set(PROJ_NAME "mb_test_gui${BIT}_${CMAKE_BUILD_TYPE}_${OpenGL_VERSION}")

# For MinGW, I suppose
if (NOT MSVC) 
	set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -std=c++11")
endif(NOT MSVC)


#set(VS_DIR "C:/Program Files (x86)/Microsoft Visual Studio 12.0")
#set(MS_SDK_DIR "C:/Program Files (x86)/Microsoft SDKs")

# --------------------------------
# Set up Qt

set (CMAKE_PREFIX_PATH "${QT_PATH};${CMAKE_PREFIX_PATH}")
#set(QT_USE_IMPORTED_TARGETS TRUE)
#find_package(Qt5Widgets CONFIG REQUIRED PATHS QT_PATH)
#find_package(Qt5Concurrent CONFIG REQUIRED PATHS QT_PATH)
find_package(Qt5 REQUIRED NO_MODULE COMPONENTS Widgets Concurrent REQUIRED PATHS QT_PATH)

# --------------------------------
# Set up VTK

set (CMAKE_PREFIX_PATH "${VTK_PATH};${CMAKE_PREFIX_PATH}")
message (STATUS "Looking for VTK at: ${VTK_PATH}")

if(${OpenGL_VERSION} STREQUAL "OpenGL")
	find_package(VTK REQUIRED NO_MODULE COMPONENTS vtkRenderingOpenGL vtkGUISupportQt PATHS ${VTK_PATH} NO_DEFAULT_PATH)
	
elseif(${OpenGL_VERSION} STREQUAL "OpenGL2")
	find_package(VTK REQUIRED NO_MODULE COMPONENTS vtkRenderingOpenGL2 vtkGUISupportQt PATHS ${VTK_PATH} NO_DEFAULT_PATH)
	
endif(${OpenGL_VERSION} STREQUAL "OpenGL")

include(${VTK_USE_FILE})

message (STATUS "Found VTK at: ${VTK_DIR}")
message (STATUS "Available modules: ${VTK_MODULES_ENABLED}")
message (STATUS "VTK_LIBRARY_DIRS: ${VTK_LIBRARY_DIRS}")

# --------------------------------
# Set up Windows Libraries
if(${BIT} MATCHES 64)
#	set(WIN_LIB_DIR ${MS_SDK_DIR}"/Windows/v7.1A/Lib/x64")
else()
#	set(WIN_LIB_DIR ${MS_SDK_DIR}"/Windows/v7.1A/Lib")
endif()
# set(WIN_LIBRARIES ${WIN_LIB_DIR}/IPHlpApi.Lib)

# --------------------------------
# General include directories
include_directories(${CMAKE_CURRENT_SOURCE_DIR} ${CMAKE_CURRENT_BINARY_DIR} ${CRYPT_INCLUDE_DIR})


# --------------------------------
set(GLOBAL_SRCS_H
	${CMAKE_CURRENT_SOURCE_DIR}/Phonger.h
)

set(GLOBAL_SRCS_UI
	${CMAKE_CURRENT_SOURCE_DIR}/Phonger.ui
)

set(GLOBAL_SRCS_CXX 
	${CMAKE_CURRENT_SOURCE_DIR}/Phonger.cxx
	
	${CMAKE_CURRENT_SOURCE_DIR}/main.cxx
)


set(MOC_HEADERS ${GLOBAL_SRCS_H})
	
set(UI_FILES ${GLOBAL_SRCS_UI})

set(QT_RES )
	
set(H_FILES ${GLOBAL_SRCS_H})
	
SET(CXX_FILES ${GLOBAL_SRCS_CXX})

# We don't use AUTOMOC and AUTOUIC, because we want to add the according files to the "gen" sourcegroup
qt5_wrap_ui(UISrcs ${UI_FILES})
qt5_wrap_cpp(MOCSrcs ${MOC_HEADERS})
qt5_add_resources(RCCSrcs ${QT_RES})

add_executable(${PROJ_NAME} ${H_FILES} ${CXX_FILES} ${UISrcs} ${MOCSrcs} ${RCCSrcs})


if (MB_BUILD_CONFIG MATCHES Debug)
	target_link_libraries(${PROJ_NAME} debug ${VTK_LIBRARIES} debug Qt5::Core)
	#message(STATUS "Libraries of dependency: ${VTK_LIBRARIES} ${Qt5Core_QTMAIN_LIBRARIES}")
	#add_custom_command(TARGET ${PROJ_NAME} POST_BUILD COMMAND ${CMAKE_COMMAND} -E copy $<TARGET_FILE_DIR:${PROJ_NAME}> /bin VERBATIM)
	
elseif(MB_BUILD_CONFIG MATCHES RelWithDebInfo)
	target_link_libraries(${PROJ_NAME} optimized ${VTK_LIBRARIES} optimized ${Qt5Core_QTMAIN_LIBRARIES} )
	
endif()






# --------------------------------
# Copy required DLLs to the build folder

# get list of VTK files with paths
set(VTK_DLLS_PATH "${VTK_ROOT_PATH}/bin")

foreach (VTK_LIBRARY ${VTK_LIBRARIES})
	set(FILENAME_WITH_PATH "${VTK_DLLS_PATH}/${VTK_LIBRARY}-${VTK_MAJOR_VERSION}.${VTK_MINOR_VERSION}.dll")
#	message(STATUS "File to copy: ${FILENAME_WITH_PATH}")
	list(APPEND VTK_DLLS_TO_COPY ${FILENAME_WITH_PATH})
endforeach (VTK_LIBRARY)

#message(STATUS "DLLs to copy: ${VTK_DLLS_TO_COPY}")
# Determine where to copy
set (VTK_DLLS_INSTALL_DIR "${CMAKE_CURRENT_BINARY_DIR}/${CMAKE_BUILD_TYPE}")
#message(STATUS "VTK_DLLS_INSTALL_DIR=${VTK_DLLS_INSTALL_DIR}")
#file(INSTALL ${VTK_DLLS_TO_COPY} DESTINATION ${VTK_DLLS_INSTALL_DIR})

# Install required Qt libraries
set (QT_DLLS_INSTALL_DIR ${VTK_DLLS_INSTALL_DIR})
#install(TARGETS ${Qt5Core_QTMAIN_LIBRARIES} LIBRARY DESTINATION ${QT_DLLS_INSTALL_DIR})
STRING(TOUPPER "${CMAKE_BUILD_TYPE}" BUILD_TYPE_UPPERCASE)
get_target_property(Qt5WinMain_IMPORTED_CONFIGURATIONS Qt5::WinMain IMPORTED_CONFIGURATIONS)
message(${BUILD_TYPE_UPPERCASE})
get_target_property(p Qt5::Widgets INTERFACE_LINK_LIBRARIES)
message ("::::: p=${p}")
message("${Qt5Widgets_LIBRARIES}")
#LIST_PREREQUISITES(${PROJ_NAME})


get_target_property(QtWidgets_location Qt5::Widgets LOCATION_DEBUG)

message("${VTK_ROOT_PATH}")
get_target_property(QtWidgets_DEBUG_POSTFIX Qt5::Widgets DEBUG_POSTFIX)
if (${QtWidgets_DEBUG_POSTFIX} MATCHES "QtWidgets_DEBUG_POSTFIX-NOTFOUND")
#	set(QtWidgets_DEBUG_POSTFIX "d")
#	set_target_properties(Qt5::Widgets PROPERTIES DEBUG_POSTFIX "d")
endif()

message (STATUS "QtWidgets_location  is: ${QtWidgets_location}")
message (STATUS "VTK_LIBRARIES_LOC  is: ${VTK_LIBRARIES_LOC}")

get_target_property(Qt5Concurrent_location Qt5::Concurrent LOCATION)
message (STATUS "Qt5Concurrent_location  is: ${Qt5Concurrent_location}")

message ("Qt5Core_QTMAIN_LIBRARIES is: ${Qt5Core_QTMAIN_LIBRARIES}")


# --------------------------------
# SET UP FOR VISUAL STUDIO

# Configure the template file that allows debugging
set(USER_FILE ${PROJ_NAME}.vcxproj.user) 	
set(OUTPUT_PATH ${CMAKE_CURRENT_BINARY_DIR}/${USER_FILE})
configure_file(UserTemplate.user ${USER_FILE} @ONLY)

source_group(gen FILES ${UISrcs} ${MOCSrcs} ${RCCSrcs})
source_group(global FILES ${GLOBAL_SRCS_H} ${GLOBAL_SRCS_UI} ${GLOBAL_SRCS_CXX} ${GLOBAL_SRCS_MAIN})


