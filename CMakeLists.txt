cmake_minimum_required (VERSION 2.8)
PROJECT (SZIP C)

#-----------------------------------------------------------------------------
# Basic SZIP stuff here
#-----------------------------------------------------------------------------
SET (SZIP_VERS_MAJOR 2)
SET (SZIP_VERS_MINOR 1)
SET (SZIP_VERS_RELEASE 0)
#-----------------------------------------------------------------------------
SET (SZIP_PACKAGE "szip")
SET (SZIP_PACKAGE_NAME "SZIP")
SET (SZIP_PACKAGE_VERSION "${SZIP_VERS_MAJOR}.${SZIP_VERS_MINOR}")
SET (SZIP_PACKAGE_VERSION_MAJOR "${SZIP_VERS_MAJOR}.${SZIP_VERS_MINOR}")
SET (SZIP_PACKAGE_VERSION_MINOR "${SZIP_VERS_RELEASE}")
SET (SZIP_PACKAGE_STRING "${SZIP_PACKAGE_NAME} ${SZIP_PACKAGE_VERSION}")
SET (SZIP_PACKAGE_TARNAME "szip")
SET (SZIP_PACKAGE_URL "htt://www.hdfgroup.org")
SET (SZIP_PACKAGE_BUGREPORT "help@hdfgroup.org")

#-----------------------------------------------------------------------------
# Define some CMake variables for use later in the project
#-----------------------------------------------------------------------------
SET (SZIP_RESOURCES_DIR          ${SZIP_SOURCE_DIR}/config/cmake)
SET (HDF_RESOURCES_DIR           ${SZIP_SOURCE_DIR}/config/cmake)
SET (SZIP_SRC_DIR                ${SZIP_SOURCE_DIR}/src)
SET (SZIP_TEST_SOURCE_DIR        ${SZIP_SOURCE_DIR}/test)
SET (SZIP_EXAMPLES_SOURCE_DIR    ${SZIP_SOURCE_DIR}/examples)

#-----------------------------------------------------------------------------
# Set the core names of all the libraries
#-----------------------------------------------------------------------------
SET (SZIP_LIB_CORENAME              "szip")
SET (SZIP_TEST_LIB_CORENAME         "mcgill")

#-----------------------------------------------------------------------------
# Set the true names of all the libraries if customized by external project
#-----------------------------------------------------------------------------
SET (SZIP_LIB_NAME              "${SZIP_EXTERNAL_LIB_PREFIX}${SZIP_LIB_CORENAME}")
SET (SZIP_TEST_LIB_NAME         "${SZIP_EXTERNAL_LIB_PREFIX}${SZIP_TEST_LIB_CORENAME}")

#-----------------------------------------------------------------------------
# Set the target names of all the libraries
#-----------------------------------------------------------------------------
SET (SZIP_LIB_TARGET              ${SZIP_LIB_CORENAME})
SET (SZIP_TEST_LIB_TARGET         ${SZIP_TEST_LIB_CORENAME})

#-----------------------------------------------------------------------------
# Include some macros for reusable code
#-----------------------------------------------------------------------------
INCLUDE (${HDF_RESOURCES_DIR}/HDFMacros.cmake)
INCLUDE (${SZIP_RESOURCES_DIR}/SZIPMacros.cmake)

#-----------------------------------------------------------------------------
# Setup output Directories
#-----------------------------------------------------------------------------
IF (NOT SZIP_EXTERNALLY_CONFIGURED)
  SET (CMAKE_RUNTIME_OUTPUT_DIRECTORY
      ${PROJECT_BINARY_DIR}/bin CACHE PATH "Single Directory for all Executables."
  )
  SET (CMAKE_LIBRARY_OUTPUT_DIRECTORY
      ${PROJECT_BINARY_DIR}/bin CACHE PATH "Single Directory for all Libraries"
  )
  SET (CMAKE_ARCHIVE_OUTPUT_DIRECTORY
      ${PROJECT_BINARY_DIR}/bin CACHE PATH "Single Directory for all static libraries."
  )
ELSE (NOT SZIP_EXTERNALLY_CONFIGURED)
  # if we are externally configured, but the project uses old cmake scripts
  # this may not be set
  IF (NOT CMAKE_RUNTIME_OUTPUT_DIRECTORY)
    SET (CMAKE_RUNTIME_OUTPUT_DIRECTORY ${EXECUTABLE_OUTPUT_PATH})
  ENDIF (NOT CMAKE_RUNTIME_OUTPUT_DIRECTORY)
ENDIF(NOT SZIP_EXTERNALLY_CONFIGURED)

#-----------------------------------------------------------------------------
# Targets built within this project are exported at Install time for use
# by other projects using FindSZIP. 
#-----------------------------------------------------------------------------
IF (NOT SZIP_EXPORTED_TARGETS)
  SET (SZIP_EXPORTED_TARGETS "szip-targets")
ENDIF (NOT SZIP_EXPORTED_TARGETS)

#-----------------------------------------------------------------------------
# To include a library in the list exported by the project AT BUILD TIME,
# add it to this variable. This is NOT used by Make Install, but for projects
# which include SZIP as a sub-project within their build tree
#-----------------------------------------------------------------------------
SET_GLOBAL_VARIABLE(SZIP_LIBRARIES_TO_EXPORT "")

#-----------------------------------------------------------------------------
# Run all the CMake configuration tests for our build environment
#-----------------------------------------------------------------------------
INCLUDE (${HDF_RESOURCES_DIR}/ConfigureChecks.cmake)

#-----------------------------------------------------------------------------
# Option to enable encoding
#-----------------------------------------------------------------------------
OPTION (SZIP_ENABLE_ENCODING  "Enable SZIP Encoding" ON)
IF (SZIP_ENABLE_ENCODING)
  SET (HAVE_ENCODING 1)
  SET (SZIP_HAVE_ENCODING 1)
ENDIF (SZIP_ENABLE_ENCODING)

#-----------------------------------------------------------------------------
# Option to Build Shared/Static libs, default is static
#-----------------------------------------------------------------------------
OPTION (BUILD_SHARED_LIBS "Build Shared Libraries" OFF)
SET (LIB_TYPE STATIC)
IF (BUILD_SHARED_LIBS)
  SET (LIB_TYPE SHARED)
  SET (SZ_BUILT_AS_DYNAMIC_LIB 1)
  IF (MSVC)
    SET (CMAKE_MFC_FLAG 0)
    FOREACH (flag_var
        CMAKE_C_FLAGS CMAKE_C_FLAGS_DEBUG CMAKE_C_FLAGS_RELEASE
        CMAKE_C_FLAGS_MINSIZEREL CMAKE_C_FLAGS_RELWITHDEBINFO
        CMAKE_CXX_FLAGS CMAKE_CXX_FLAGS_DEBUG CMAKE_CXX_FLAGS_RELEASE
        CMAKE_CXX_FLAGS_MINSIZEREL CMAKE_CXX_FLAGS_RELWITHDEBINFO)
      IF (${flag_var} MATCHES "/MT")
        STRING (REGEX REPLACE "/MT" "/MD" ${flag_var} "${${flag_var}}")
      ENDIF (${flag_var} MATCHES "/MT")
    ENDFOREACH (flag_var)
  ENDIF (MSVC)
ELSE (BUILD_SHARED_LIBS)
  IF (NOT WIN32)
    # should this be a user setting : Everyone uses it anyway ?
    ADD_DEFINITIONS(-DPIC)
  ENDIF (NOT WIN32)
  IF (MSVC)
    SET (CMAKE_MFC_FLAG 0)
    FOREACH (flag_var
        CMAKE_C_FLAGS CMAKE_C_FLAGS_DEBUG CMAKE_C_FLAGS_RELEASE
        CMAKE_C_FLAGS_MINSIZEREL CMAKE_C_FLAGS_RELWITHDEBINFO
        CMAKE_CXX_FLAGS CMAKE_CXX_FLAGS_DEBUG CMAKE_CXX_FLAGS_RELEASE
        CMAKE_CXX_FLAGS_MINSIZEREL CMAKE_CXX_FLAGS_RELWITHDEBINFO)
      IF (${flag_var} MATCHES "/MD")
        STRING (REGEX REPLACE "/MD" "/MT" ${flag_var} "${${flag_var}}")
      ENDIF (${flag_var} MATCHES "/MD")
    ENDFOREACH (flag_var)
  ENDIF (MSVC)
ENDIF (BUILD_SHARED_LIBS)

#-----------------------------------------------------------------------------
# When building utility executables that generate other (source) files :
# we make use of the following variables defined in the root CMakeLists.
# Certain systems may add /Debug or /Release to output paths
# and we need to call the executable from inside the CMake configuration
#-----------------------------------------------------------------------------
SET (EXE_EXT "")
IF (WIN32)
  SET (EXE_EXT ".exe")
  ADD_DEFINITIONS (-DBIND_TO_CURRENT_VCLIBS_VERSION=1)
  ADD_DEFINITIONS (-D_CRT_SECURE_NO_WARNINGS)
ENDIF (WIN32)

SET (MAKE_SYSTEM)
IF (CMAKE_BUILD_TOOL MATCHES "make")
  SET (MAKE_SYSTEM 1)
ENDIF (CMAKE_BUILD_TOOL MATCHES "make")

SET (CFG_INIT "/${CMAKE_CFG_INTDIR}")
IF (MAKE_SYSTEM)
  SET (CFG_INIT "")
ENDIF (MAKE_SYSTEM)

#-----------------------------------------------------------------------------
# Compiler specific flags : Shouldn't there be compiler tests for these
#-----------------------------------------------------------------------------
IF (CMAKE_COMPILER_IS_GNUCC)
  SET (CMAKE_C_FLAGS "${CMAKE_ANSI_CFLAGS} ${CMAKE_C_FLAGS} -std=c99 -fomit-frame-pointer -finline-functions -fno-common")
ENDIF (CMAKE_COMPILER_IS_GNUCC)

#-----------------------------------------------------------------------------
# This is in here to help some of the GCC based IDES like Eclipse
# and code blocks parse the compiler errors and warnings better.
#-----------------------------------------------------------------------------
IF (CMAKE_COMPILER_IS_GNUCC)
  SET (CMAKE_C_FLAGS "${CMAKE_C_FLAGS} -fmessage-length=0")
ENDIF (CMAKE_COMPILER_IS_GNUCC)
IF (CMAKE_COMPILER_IS_GNUCXX)
  SET (CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -fmessage-length=0")
ENDIF (CMAKE_COMPILER_IS_GNUCXX)

# parse the full version number from szlib.h and include in SZLIB_FULL_VERSION
FILE (READ ${SZIP_SRC_DIR}/szlib.h _szlib_h_contents)
STRING (REGEX REPLACE ".*#define[ \t]+SZLIB_VERSION[ \t]+\"([0-9A-Za-z.]+)\".*"
    "\\1" SZLIB_FULL_VERSION ${_szlib_h_contents})
#MESSAGE (STATUS "VERSION: ${SZLIB_FULL_VERSION}")

#-----------------------------------------------------------------------------
# All libs/tests/examples need the main include directories
#-----------------------------------------------------------------------------
INCLUDE_DIRECTORIES (${SZIP_BINARY_DIR} ${SZIP_SOURCE_DIR}/src)

ADD_SUBDIRECTORY (${SZIP_SOURCE_DIR}/src ${PROJECT_BINARY_DIR}/src)

#-----------------------------------------------------------------------------
# Dashboard and Testing Settings
#-----------------------------------------------------------------------------
OPTION (BUILD_TESTING "Build SZIP Unit Testing" OFF)
IF (BUILD_TESTING)
  SET (DART_TESTING_TIMEOUT 1200 CACHE INTEGER
       "Timeout in seconds for each test (default 1200=20minutes)")
  ENABLE_TESTING ()
  INCLUDE (CTest)
  ADD_SUBDIRECTORY (${SZIP_SOURCE_DIR}/test ${PROJECT_BINARY_DIR}/test)

#-----------------------------------------------------------------------------
# Option to build examples
#-----------------------------------------------------------------------------
  OPTION (SZIP_BUILD_EXAMPLES  "Build SZIP Library Examples" OFF)
  IF (SZIP_BUILD_EXAMPLES)
    ADD_SUBDIRECTORY (${SZIP_SOURCE_DIR}/examples ${PROJECT_BINARY_DIR}/examples)
  ENDIF (SZIP_BUILD_EXAMPLES)
ENDIF (BUILD_TESTING)

#-----------------------------------------------------------------------------
# Generate the SZconfig.h file containing user settings needed by compilation
#-----------------------------------------------------------------------------
CONFIGURE_FILE (${SZIP_RESOURCES_DIR}/SZconfig.h.in ${SZIP_BINARY_DIR}/SZconfig.h @ONLY)

#-----------------------------------------------------------------------------
# Add file(s) to CMake Install
#-----------------------------------------------------------------------------
INSTALL (
    FILES
        ${PROJECT_BINARY_DIR}/SZconfig.h
    DESTINATION
        include
    COMPONENT
        headers
)

#-----------------------------------------------------------------------------
# Add Target(s) to CMake Install for import into other projects
#-----------------------------------------------------------------------------
INSTALL (
    EXPORT
        ${SZIP_EXPORTED_TARGETS}
    DESTINATION
        lib
    FILE
        SZIP-targets.cmake
)

#-----------------------------------------------------------------------------
# Export all exported targets to the build tree for use by parent project
#-----------------------------------------------------------------------------
EXPORT (
    TARGETS
        ${SZIP_LIBRARIES_TO_EXPORT} ${SZIP_LIB_DEPENDENCIES}
    FILE
        SZIP-targets.cmake
)

#-----------------------------------------------------------------------------
# Configure the SZIP-config.cmake file for the build directory
#-----------------------------------------------------------------------------
SET (SZIP_INCLUDES_BUILD_TIME
    ${SZIP_SRC_DIR} ${SZIP_BINARY_DIR}
)
SET (SZIP_VERSION_STRING @SZIP_PACKAGE_VERSION@)
SET (SZIP_VERSION_MAJOR  @SZIP_PACKAGE_VERSION_MAJOR@)
SET (SZIP_VERSION_MINOR  @SZIP_PACKAGE_VERSION_MINOR@)

CONFIGURE_FILE (
    ${SZIP_RESOURCES_DIR}/SZIP-config.cmake.build.in 
    ${SZIP_BINARY_DIR}/SZIP-config.cmake @ONLY
)

#-----------------------------------------------------------------------------
# Configure the SZIP-config.cmake file for the install directory
#-----------------------------------------------------------------------------
INSTALL (CODE
    "SET (SZIP_INSTALL_SKIP_TARGETS 1)
     INCLUDE (${SZIP_BINARY_DIR}/SZIP-config.cmake) 
     CONFIGURE_FILE (
         \"${SZIP_RESOURCES_DIR}/SZIP-config.cmake.install.in\" 
         \"${CMAKE_INSTALL_PREFIX}/lib/SZIP-config.cmake\" @ONLY
     )
    "
)
