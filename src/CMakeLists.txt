# SparklerHelper Sources CMake File

# Declare project
project(${PROJECT_NAME} LANGUAGES CXX VERSION ${SPARKLEHELPER_VERSION})

# Find dependencies
find_package(Sparkle REQUIRED)

set(HEADER_FILES_PUBLIC
	${SPARKLEHELPER_ROOT_DIR}/include/sparkleHelper/sparkleHelper.hpp
)

set(ADD_LINK_LIBS "")

if(USE_EMPTY_SPARKLE)
	set(SOURCE_FILES_COMMON
		sparkleHelper_dummy.cpp
	)
elseif(WIN32)
	set(SOURCE_FILES_COMMON
		sparkleHelper_win32.cpp
	)
elseif(APPLE)
	set(SOURCE_FILES_COMMON
		sparkleHelper_mac.mm
	)
	list(APPEND ADD_LINK_LIBS "-framework Foundation")
else()
	set(SOURCE_FILES_COMMON
		sparkleHelper_unix.cpp
	)
endif()

# Group source files
source_group("Header Files\\\\Public" FILES ${PUBLIC_HEADER_FILES})
source_group(TREE ${CMAKE_CURRENT_SOURCE_DIR} PREFIX "Source Files" FILES ${SOURCE_FILES_COMMON})

# Define static library
add_library(${PROJECT_NAME}_static STATIC ${HEADER_FILES_PUBLIC} ${SOURCE_FILES_COMMON})

# Setup common options
# Add a postfix in debug mode
set_target_properties(${PROJECT_NAME}_static PROPERTIES DEBUG_POSTFIX "-d")
# Use cmake folders
set_target_properties(${PROJECT_NAME}_static PROPERTIES FOLDER "Libraries")

# Link libraries
if(ADD_LINK_LIBS)
	target_link_libraries(${PROJECT_NAME}_static PUBLIC ${ADD_LINK_LIBS})
endif()
if(NOT USE_EMPTY_SPARKLE)
	target_link_libraries(${PROJECT_NAME}_static PUBLIC Sparkle::lib)
endif()

# Include directories
target_include_directories(${PROJECT_NAME}_static
	PUBLIC
		$<BUILD_INTERFACE:${SPARKLEHELPER_ROOT_DIR}/include>
)

# Define an alias for the library
add_library(SparkleHelper::lib ALIAS ${PROJECT_NAME}_static)
