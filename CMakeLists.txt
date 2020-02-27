# Root CMake File for SparklerHelper

# Minimum CMake version
cmake_minimum_required(VERSION 3.13)

############ Versioning

# Using Semantic Versioning (http://semver.org/spec/v2.0.0.html)
# This variable defines the project version number.
# It should have 3 digits (x.y.z) on main branch, and 4 digits (x.y.z.w) on dev and task branches. The last digit being used as beta label.
# As soon as a new version begins, update the version number by following SemVer rules.
# Example: 1.5.0 is the upcoming release version (main branch) of current 1.5.0.3 devel version (dev/task) which will be labelled 1.5.0-beta3
set(SPARKLEHELPER_VERSION 1.0.0.1)

############ Override from command line "CMake -D<OPTION>=TRUE/FALSE/0/1/ON/OFF"

# Build options
option(USE_EMPTY_SPARKLE "Compile the library but as en empty shell." FALSE)

############ Override from command line "CMake -D<PARAM>=<VALUE>"


############ CMake Configuration

project(sparkleHelper)

# Using c++17 standard for all targets
set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED TRUE)

# Default Component
set(CMAKE_INSTALL_DEFAULT_COMPONENT_NAME "sparkleHelper")

# Set minimum OSX version
set(CMAKE_OSX_DEPLOYMENT_TARGET 10.9 CACHE INTERNAL "Force the target to be at least a Mac OS X 10.9" FORCE)

# Enable cmake folders
set_property(GLOBAL PROPERTY USE_FOLDERS ON)

# Configure installation path: we override the default installation path.
if(CMAKE_INSTALL_PREFIX_INITIALIZED_TO_DEFAULT)
	set(CMAKE_INSTALL_PREFIX "./Install" CACHE PATH "default install path" FORCE)
endif()

# Setup "Release" build type, if not specified
if(NOT CMAKE_BUILD_TYPE AND NOT CMAKE_CONFIGURATION_TYPES)
	message(STATUS "Setting build type to 'Release' as none was specified.")
	set(CMAKE_BUILD_TYPE "Release" CACHE STRING "Specifies the build type." FORCE)
endif()

# Include our internal macros
list(APPEND CMAKE_PREFIX_PATH ${CMAKE_CURRENT_LIST_DIR}/cmake) # Required to find_package 3rd party modules that don't provide their CMake Config files

############ Define some variables

set(SPARKLEHELPER_ROOT_DIR "${PROJECT_SOURCE_DIR}")
#string(TIMESTAMP CURRENT_YEAR "%Y")
#set(PROJECT_COPYRIGHT_YEAR "2017-${CURRENT_YEAR}")
#set(PROJECT_FULL_NAME "${PROJECT_NAME} - Pro Audio Avdecc Controller")
#set(PROJECT_COMPANYNAME "KikiSoft")
#set(PROJECT_ORIGINAL_AUTHORS "Emilien Vallot and Christophe Calmejane")
#set(PROJECT_AUTHORS "Emilien Vallot, Christophe Calmejane and other contributors")
#set(PROJECT_CONTACT "christophe.calmejane@l-acoustics.com")
#set(PROJECT_REVERSE_DOMAINNAME "fr.${PROJECT_COMPANYNAME}")
#set(PROJECT_DOMAINNAME "${PROJECT_COMPANYNAME}.fr")
#set(PROJECT_URL "https://github.com/christophe-calmejane/Hive")
#set(PROJECT_LEGALCOPYRIGHT "(c) ${PROJECT_AUTHORS}")
#set(PROJECT_READABLE_COPYRIGHT "Copyright ${PROJECT_COPYRIGHT_YEAR}, ${PROJECT_AUTHORS}")
#set(PROJECT_ROOT_DIR "${PROJECT_SOURCE_DIR}")
#set(PROJECT_ARCH "32-bit")
#if(CMAKE_SIZEOF_VOID_P EQUAL 8)
#  set(PROJECT_ARCH "64-bit")
#endif()

## Split HIVE_VERSION string
#string(REGEX MATCHALL "([0-9]+)" HIVE_VERSION_SPLIT "${HIVE_VERSION}")
#list(LENGTH HIVE_VERSION_SPLIT HIVE_VERSION_SPLIT_LENGTH)
#if(${HIVE_VERSION_SPLIT_LENGTH} LESS 3)
#	message(FATAL_ERROR "Cannot parse version string")
#endif()
#list(GET HIVE_VERSION_SPLIT 0 HIVE_VERSION_MAJOR)
#list(GET HIVE_VERSION_SPLIT 1 HIVE_VERSION_MINOR)
#list(GET HIVE_VERSION_SPLIT 2 HIVE_VERSION_PATCH)
#if(${HIVE_VERSION_SPLIT_LENGTH} EQUAL 4)
#	list(GET HIVE_VERSION_SPLIT 3 HIVE_VERSION_BETA)
#else()
#	set(HIVE_VERSION_BETA "0")
#endif()
#
## Compute Marketing Version String (Visible)
#if(NOT DEFINED MARKETING_VERSION_DIGITS)
#	set(MARKETING_VERSION_DIGITS 2)
#endif()
#set(HIVE_MARKETING_VERSION "")
#if(${MARKETING_VERSION_DIGITS} GREATER 0)
#	set(HIVE_MARKETING_VERSION "${HIVE_VERSION_MAJOR}")
#	if(${MARKETING_VERSION_DIGITS} GREATER 1)
#		math(EXPR LOOP_COUNT "${MARKETING_VERSION_DIGITS} - 1")
#		foreach(index RANGE 1 ${LOOP_COUNT})
#			list(GET HIVE_VERSION_SPLIT ${index} LOOP_VERSION)
#			string(APPEND HIVE_MARKETING_VERSION ".${LOOP_VERSION}")
#		endforeach()
#	endif()
#endif()
#if(${MARKETING_VERSION_POSTFIX})
#	string(APPEND HIVE_MARKETING_VERSION "${MARKETING_VERSION_POSTFIX}")
#endif()
#
## Compute Full Friendly Version String (Visible)
#if(${HIVE_VERSION_BETA} STREQUAL "0")
#	set(HIVE_FRIENDLY_VERSION "${HIVE_VERSION_MAJOR}.${HIVE_VERSION_MINOR}.${HIVE_VERSION_PATCH}")
#else()
#	set(HIVE_FRIENDLY_VERSION "${HIVE_VERSION_MAJOR}.${HIVE_VERSION_MINOR}.${HIVE_VERSION_PATCH}-beta${HIVE_VERSION_BETA}")
#endif()

############ Add projects

# Add main project
add_subdirectory(src)
