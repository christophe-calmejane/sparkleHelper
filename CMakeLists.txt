# Root CMake File for SparklerHelper

# Minimum CMake version
cmake_minimum_required(VERSION 3.13)

############ Versioning

# Using Semantic Versioning (http://semver.org/spec/v2.0.0.html)
# This variable defines the project version number.
# It should have 3 digits (x.y.z) on main branch, and 4 digits (x.y.z.w) on dev and task branches. The last digit being used as beta label.
# As soon as a new version begins, update the version number by following SemVer rules.
# Example: 1.5.0 is the upcoming release version (main branch) of current 1.5.0.3 devel version (dev/task) which will be labelled 1.5.0-beta3
set(SPARKLEHELPER_VERSION 1.0.0.2)

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

############ Add projects

# Add main project
add_subdirectory(src)
