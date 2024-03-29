# CMake configuration file for Sparkle

if(NOT DEFINED Sparkle::lib)
	if(WIN32)
		set(SPARKLE_BASE_DIR "${SPARKLEHELPER_ROOT_DIR}/3rdparty/winsparkle")

		set(IMPORT_ARCH "x86")
		if(CMAKE_SIZEOF_VOID_P EQUAL 8)
			set(IMPORT_ARCH "x64")
		endif()

		add_library(winsparkle SHARED IMPORTED GLOBAL)

		set_target_properties(winsparkle PROPERTIES
			IMPORTED_IMPLIB "${SPARKLE_BASE_DIR}/lib/${IMPORT_ARCH}/WinSparkle.lib"
			IMPORTED_LOCATION "${SPARKLE_BASE_DIR}/bin/${IMPORT_ARCH}/WinSparkle.dll"
			INTERFACE_INCLUDE_DIRECTORIES "${SPARKLE_BASE_DIR}/include"
		)

		add_library(Sparkle::lib ALIAS winsparkle)

	elseif(APPLE)
		# Disabling our Hack that sets a source file property and declare INTERFACE_SOURCES as it's not working if the source property scope is not the same than the final app bundle
		# Until https://gitlab.kitware.com/cmake/cmake/-/issues/22760 is resolved at least
		# So for the time being, this file defines a macro (that will have to be removed when the above ticket is resolved) the final app bundle will have to call before linking with SparkleHelper
		# Unfortunately only Xcode generator does correctly copy the full framework so we have to provide another fixup method (until the above ticket is resolved)
		set(SPARKLE_BASE_DIR "${SPARKLEHELPER_ROOT_DIR}/3rdparty/sparkle")
		set(SPARKLE_FRAMEWORK_PATH "${SPARKLE_BASE_DIR}/Sparkle.framework")
		set_property(GLOBAL PROPERTY FIXUP_SPARKLE_PATH "${SPARKLE_FRAMEWORK_PATH}")
		# set_source_files_properties("${SPARKLE_FRAMEWORK_PATH}" PROPERTIES MACOSX_PACKAGE_LOCATION Frameworks) # MACOSX_PACKAGE_LOCATION = Place a 'source file' (here it is Sparkle.framework) into the app bundle

		add_library(sparkle INTERFACE IMPORTED GLOBAL)

		set_target_properties(sparkle PROPERTIES
			INTERFACE_SOURCES "${SPARKLE_FRAMEWORK_PATH}" # So that our framework is considered a source file, and copied to the app bundle through MACOSX_PACKAGE_LOCATION
			INTERFACE_LINK_LIBRARIES "${SPARKLE_FRAMEWORK_PATH}" # So the framework is linked to the target, as well as adding include search path (automatically done by cmake when detecting a framework)
		)

		add_library(Sparkle::lib ALIAS sparkle)

	else()
		add_library(dummySparkle INTERFACE IMPORTED GLOBAL)
		add_library(Sparkle::lib ALIAS dummySparkle)

	endif()
endif()

macro(fixup_sparkleHelper_dependencies)
	if("${CMAKE_GENERATOR}" STREQUAL "Xcode")
		get_property(fixupPath GLOBAL PROPERTY FIXUP_SPARKLE_PATH)
		set_source_files_properties(${fixupPath} PROPERTIES MACOSX_PACKAGE_LOCATION Frameworks)
	endif()
endmacro()

function(fixup_sparkleHelper_resources TARGET_NAME)
	# https://gitlab.kitware.com/cmake/cmake/-/issues/16886
	if(APPLE AND NOT "${CMAKE_GENERATOR}" STREQUAL "Xcode")
		get_target_property(targetType ${TARGET_NAME} TYPE)
		if(${targetType} STREQUAL "EXECUTABLE")
			get_target_property(isBundle ${TARGET_NAME} MACOSX_BUNDLE)
			if(${isBundle})
				get_property(fixupPath GLOBAL PROPERTY FIXUP_SPARKLE_PATH)
				add_custom_command(
					TARGET ${TARGET_NAME}
					POST_BUILD
					COMMAND ${CMAKE_COMMAND} -E make_directory "$<TARGET_BUNDLE_CONTENT_DIR:${TARGET_NAME}>/Frameworks"
					COMMAND cp -a "${fixupPath}" "$<TARGET_BUNDLE_CONTENT_DIR:${TARGET_NAME}>/Frameworks/" # Cannot use cmake copy_directory as it doesn't preserve symlinks: https://gitlab.kitware.com/cmake/cmake/-/issues/14609
					COMMENT "Fixup Sparkle resources for ${TARGET_NAME}"
					VERBATIM
				)
			endif()
		endif()
	endif()
endfunction()
