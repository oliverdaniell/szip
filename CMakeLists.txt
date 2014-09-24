cmake_minimum_required (VERSION 2.8.11)
PROJECT (SZIP C)

#-----------------------------------------------------------------------------
# Basic SZIP stuff here
#-----------------------------------------------------------------------------

#-----------------------------------------------------------------------------
# Define some CMake variables for use later in the project
#-----------------------------------------------------------------------------
set (HDF_RESOURCES_DIR           ${SZIP_SOURCE_DIR}/config/cmake)
set (SZIP_SRC_DIR                ${SZIP_SOURCE_DIR}/src)
set (SZIP_TEST_SOURCE_DIR        ${SZIP_SOURCE_DIR}/test)
set (SZIP_EXAMPLES_SOURCE_DIR    ${SZIP_SOURCE_DIR}/examples)

#-----------------------------------------------------------------------------
# Set the core names of all the libraries
#-----------------------------------------------------------------------------
set (SZIP_LIB_CORENAME              "szip")

#-----------------------------------------------------------------------------
# Set the true names of all the libraries if customized by external project
#-----------------------------------------------------------------------------
set (SZIP_LIB_NAME              "${SZIP_EXTERNAL_LIB_PREFIX}${SZIP_LIB_CORENAME}")

#-----------------------------------------------------------------------------
# Set the target names of all the libraries
#-----------------------------------------------------------------------------
set (SZIP_LIB_TARGET              ${SZIP_LIB_CORENAME})

if (NOT SZIP_INSTALL_BIN_DIR)
  set (SZIP_INSTALL_BIN_DIR bin)
endif (NOT SZIP_INSTALL_BIN_DIR)
if (NOT SZIP_INSTALL_LIB_DIR)
  set (SZIP_INSTALL_LIB_DIR lib)
endif (NOT SZIP_INSTALL_LIB_DIR)
if (NOT SZIP_INSTALL_INCLUDE_DIR)
  set (SZIP_INSTALL_INCLUDE_DIR include)
endif (NOT SZIP_INSTALL_INCLUDE_DIR)
if (NOT SZIP_INSTALL_DATA_DIR)
  if (NOT WIN32)
    set (SZIP_INSTALL_DATA_DIR share)
    set (SZIP_INSTALL_CMAKE_DIR share/cmake)
  else (NOT WIN32)
    set (SZIP_INSTALL_DATA_DIR ".")
    set (SZIP_INSTALL_CMAKE_DIR cmake)
  endif (NOT WIN32)
endif (NOT SZIP_INSTALL_DATA_DIR)

#-----------------------------------------------------------------------------
# parse the full version number from szlib.h and include in SZLIB_FULL_VERSION
#-----------------------------------------------------------------------------
file (READ ${SZIP_SRC_DIR}/szlib.h _szlib_h_contents)
string (REGEX REPLACE ".*#define[ \t]+SZLIB_VERSION[ \t]+\"([0-9]*.[0-9]*)\".*"
    "\\1" SZLIB_FULL_VERSION ${_szlib_h_contents})
string (REGEX REPLACE ".*#define[ \t]+SZLIB_VERSION[ \t]+\"([0-9]*).*$"
    "\\1" SZIP_VERS_MAJOR ${_szlib_h_contents})
string (REGEX REPLACE ".*#define[ \t]+SZLIB_VERSION[ \t]+\"[0-9]*.([0-9]*)\".*$"
    "\\1" SZIP_VERS_MINOR ${_szlib_h_contents})
#message (STATUS "VERSION: ${SZLIB_FULL_VERSION}")
#set (SZIP_VERS_MAJOR 2)
#set (SZIP_VERS_MINOR 1)
set (SZIP_VERS_RELEASE 0)

#-----------------------------------------------------------------------------
set (SZIP_PACKAGE "szip")
set (SZIP_PACKAGE_NAME "SZIP")
set (SZIP_PACKAGE_VERSION "${SZIP_VERS_MAJOR}.${SZIP_VERS_MINOR}")
set (SZIP_PACKAGE_VERSION_MAJOR "${SZIP_VERS_MAJOR}")
set (SZIP_PACKAGE_VERSION_MINOR "${SZIP_VERS_MINOR}")
set (SZIP_PACKAGE_STRING "${SZIP_PACKAGE_NAME} ${SZIP_PACKAGE_VERSION}")
set (SZIP_PACKAGE_TARNAME "szip${HDF_PACKAGE_EXT}")
set (SZIP_PACKAGE_URL "http://www.hdfgroup.org")
set (SZIP_PACKAGE_BUGREPORT "help@hdfgroup.org")

#-----------------------------------------------------------------------------
# Include some macros for reusable code
#-----------------------------------------------------------------------------
include (${HDF_RESOURCES_DIR}/HDFMacros.cmake)
include (${HDF_RESOURCES_DIR}/SZIPMacros.cmake)

#-----------------------------------------------------------------------------
# Setup output Directories
#-----------------------------------------------------------------------------
if (NOT SZIP_EXTERNALLY_CONFIGURED)
  set (CMAKE_RUNTIME_OUTPUT_DIRECTORY
      ${PROJECT_BINARY_DIR}/bin CACHE PATH "Single Directory for all Executables."
  )
  set (CMAKE_LIBRARY_OUTPUT_DIRECTORY
      ${PROJECT_BINARY_DIR}/bin CACHE PATH "Single Directory for all Libraries"
  )
  set (CMAKE_ARCHIVE_OUTPUT_DIRECTORY
      ${PROJECT_BINARY_DIR}/bin CACHE PATH "Single Directory for all static libraries."
  )
else (NOT SZIP_EXTERNALLY_CONFIGURED)
  # if we are externally configured, but the project uses old cmake scripts
  # this may not be set
  if (NOT CMAKE_RUNTIME_OUTPUT_DIRECTORY)
    set (CMAKE_RUNTIME_OUTPUT_DIRECTORY ${EXECUTABLE_OUTPUT_PATH})
  endif (NOT CMAKE_RUNTIME_OUTPUT_DIRECTORY)
endif (NOT SZIP_EXTERNALLY_CONFIGURED)

#-----------------------------------------------------------------------------
# Targets built within this project are exported at Install time for use
# by other projects using FindSZIP. 
#-----------------------------------------------------------------------------
if (NOT SZIP_EXPORTED_TARGETS)
  set (SZIP_EXPORTED_TARGETS "szip-targets")
endif (NOT SZIP_EXPORTED_TARGETS)

#-----------------------------------------------------------------------------
# To include a library in the list exported by the project AT BUILD TIME,
# add it to this variable. This is NOT used by Make Install, but for projects
# which include SZIP as a sub-project within their build tree
#-----------------------------------------------------------------------------
set_global_variable (SZIP_LIBRARIES_TO_EXPORT "")

#-----------------------------------------------------------------------------
# Run all the CMake configuration tests for our build environment
#-----------------------------------------------------------------------------
include (${HDF_RESOURCES_DIR}/ConfigureChecks.cmake)

#-----------------------------------------------------------------------------
# Option to enable encoding
#-----------------------------------------------------------------------------
option (SZIP_ENABLE_ENCODING  "Enable SZIP Encoding" ON)
if (SZIP_ENABLE_ENCODING)
  set (HAVE_ENCODING 1)
  set (SZIP_HAVE_ENCODING 1)
endif (SZIP_ENABLE_ENCODING)

#-----------------------------------------------------------------------------
# Option to Build Shared/Static libs, default is static
#-----------------------------------------------------------------------------
option (BUILD_SHARED_LIBS "Build Shared Libraries" OFF)
set (LIB_TYPE STATIC)
if (BUILD_SHARED_LIBS)
  set (LIB_TYPE SHARED)
  set (SZ_BUILT_AS_DYNAMIC_LIB 1)
else (BUILD_SHARED_LIBS)
  set (SZ_BUILT_AS_STATIC_LIB 1)
  set (CMAKE_POSITION_INDEPENDENT_CODE ON)
endif (BUILD_SHARED_LIBS)

#-----------------------------------------------------------------------------
# When building utility executables that generate other (source) files :
# we make use of the following variables defined in the root CMakeLists.
# Certain systems may add /Debug or /Release to output paths
# and we need to call the executable from inside the CMake configuration
#-----------------------------------------------------------------------------
set (EXE_EXT "")
if (WIN32)
  set (EXE_EXT ".exe")
  add_definitions (-DBIND_TO_CURRENT_VCLIBS_VERSION=1)
  add_definitions (-D_CRT_SECURE_NO_WARNINGS)
endif (WIN32)

if (MSVC)
  set (CMAKE_MFC_FLAG 0)
endif (MSVC)

set (MAKE_SYSTEM)
if (CMAKE_BUILD_TOOL MATCHES "make")
  set (MAKE_SYSTEM 1)
endif (CMAKE_BUILD_TOOL MATCHES "make")

set (CFG_INIT "/${CMAKE_CFG_INTDIR}")
if (MAKE_SYSTEM)
  set (CFG_INIT "")
endif (MAKE_SYSTEM)

#-----------------------------------------------------------------------------
# Compiler specific flags : Shouldn't there be compiler tests for these
#-----------------------------------------------------------------------------
if (CMAKE_COMPILER_IS_GNUCC)
  set (CMAKE_C_FLAGS "${CMAKE_ANSI_CFLAGS} ${CMAKE_C_FLAGS} -std=c99 -fomit-frame-pointer -finline-functions -fno-common")
endif (CMAKE_COMPILER_IS_GNUCC)
if (CMAKE_COMPILER_IS_GNUCXX)
  set (CMAKE_CXX_FLAGS "${CMAKE_ANSI_CFLAGS} ${CMAKE_CXX_FLAGS} -fomit-frame-pointer -finline-functions -fno-common")
endif (CMAKE_COMPILER_IS_GNUCXX)

#-----------------------------------------------------------------------------
# This is in here to help some of the GCC based IDES like Eclipse
# and code blocks parse the compiler errors and warnings better.
#-----------------------------------------------------------------------------
if (CMAKE_COMPILER_IS_GNUCC)
  set (CMAKE_C_FLAGS "${CMAKE_C_FLAGS} -fmessage-length=0")
endif (CMAKE_COMPILER_IS_GNUCC)
if (CMAKE_COMPILER_IS_GNUCXX)
  set (CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -fmessage-length=0")
endif (CMAKE_COMPILER_IS_GNUCXX)

#-----------------------------------------------------------------------------
# Include user macros
#-----------------------------------------------------------------------------
include (UserMacros.cmake)

#-----------------------------------------------------------------------------
# All libs/tests/examples need the main include directories
#-----------------------------------------------------------------------------
INCLUDE_DIRECTORIES (${SZIP_BINARY_DIR} ${SZIP_SOURCE_DIR}/src)

add_subdirectory (${SZIP_SOURCE_DIR}/src ${PROJECT_BINARY_DIR}/src)

#-----------------------------------------------------------------------------
# Dashboard and Testing Settings
#-----------------------------------------------------------------------------
option (BUILD_TESTING "Build SZIP Unit Testing" OFF)
if (BUILD_TESTING)
  set (DART_TESTING_TIMEOUT 1200 CACHE INTEGER
       "Timeout in seconds for each test (default 1200=20minutes)")
  enable_testing ()
  include (CTest)
  add_subdirectory (${SZIP_SOURCE_DIR}/test ${PROJECT_BINARY_DIR}/test)
endif (BUILD_TESTING)

#-----------------------------------------------------------------------------
# Generate the SZconfig.h file containing user settings needed by compilation
#-----------------------------------------------------------------------------
configure_file (${HDF_RESOURCES_DIR}/SZconfig.h.in ${SZIP_BINARY_DIR}/SZconfig.h @ONLY)

#-----------------------------------------------------------------------------
# Add file(s) to CMake Install
#-----------------------------------------------------------------------------
if (NOT SZIP_INSTALL_NO_DEVELOPMENT)
  install (
      FILES ${PROJECT_BINARY_DIR}/SZconfig.h
      DESTINATION ${SZIP_INSTALL_INCLUDE_DIR}
      COMPONENT headers
  )
endif (NOT SZIP_INSTALL_NO_DEVELOPMENT)

#-----------------------------------------------------------------------------
# Add Target(s) to CMake Install for import into other projects
#-----------------------------------------------------------------------------
if (NOT SZIP_EXTERNALLY_CONFIGURED)
  install (
      EXPORT ${SZIP_EXPORTED_TARGETS}
      DESTINATION ${SZIP_INSTALL_CMAKE_DIR}/SZIP
      FILE ${SZIP_PACKAGE}${HDF_PACKAGE_EXT}-targets.cmake
      COMPONENT configinstall
  )
endif (NOT SZIP_EXTERNALLY_CONFIGURED)

#-----------------------------------------------------------------------------
# Export all exported targets to the build tree for use by parent project
#-----------------------------------------------------------------------------
if (NOT SZIP_EXTERNALLY_CONFIGURED)
  export (
      TARGETS ${SZIP_LIBRARIES_TO_EXPORT} ${SZIP_LIB_DEPENDENCIES}
      FILE ${SZIP_PACKAGE}${HDF_PACKAGE_EXT}-targets.cmake
  )
endif (NOT SZIP_EXTERNALLY_CONFIGURED)

#-----------------------------------------------------------------------------
# Configure the SZIP-config.cmake file for the build directory
#-----------------------------------------------------------------------------
set (SZIP_INCLUDES_BUILD_TIME
    ${SZIP_SRC_DIR} ${SZIP_BINARY_DIR}
)
set (SZIP_VERSION_STRING @SZIP_PACKAGE_VERSION@)
set (SZIP_VERSION_MAJOR  @SZIP_PACKAGE_VERSION_MAJOR@)
set (SZIP_VERSION_MINOR  @SZIP_PACKAGE_VERSION_MINOR@)

configure_file (
    ${HDF_RESOURCES_DIR}/SZIP-config.cmake.build.in 
    ${SZIP_BINARY_DIR}/${SZIP_PACKAGE}${HDF_PACKAGE_EXT}-config.cmake @ONLY
)

#-----------------------------------------------------------------------------
# Configure the SZIP-config.cmake file for the install directory
#-----------------------------------------------------------------------------
if (NOT SZIP_EXTERNALLY_CONFIGURED)
  configure_file (
      ${HDF_RESOURCES_DIR}/SZIP-config.cmake.install.in
      ${SZIP_BINARY_DIR}/CMakeFiles/${SZIP_PACKAGE}${HDF_PACKAGE_EXT}-config.cmake @ONLY
  )
  install (
      FILES ${SZIP_BINARY_DIR}/CMakeFiles/${SZIP_PACKAGE}${HDF_PACKAGE_EXT}-config.cmake
      DESTINATION ${SZIP_INSTALL_CMAKE_DIR}/SZIP
      COMPONENT configinstall
  )
endif (NOT SZIP_EXTERNALLY_CONFIGURED)

#-----------------------------------------------------------------------------
# Configure the SZIP-config-version.cmake file for the install directory
#-----------------------------------------------------------------------------
if (NOT SZIP_EXTERNALLY_CONFIGURED)
  configure_file (
      ${HDF_RESOURCES_DIR}/SZIP-config-version.cmake.in
      ${SZIP_BINARY_DIR}/CMakeFiles/${SZIP_PACKAGE}${HDF_PACKAGE_EXT}-config-version.cmake @ONLY
  )
  install (
      FILES ${SZIP_BINARY_DIR}/CMakeFiles/${SZIP_PACKAGE}${HDF_PACKAGE_EXT}-config-version.cmake
      DESTINATION ${SZIP_INSTALL_CMAKE_DIR}/SZIP
      COMPONENT configinstall
  )
endif (NOT SZIP_EXTERNALLY_CONFIGURED)

#-----------------------------------------------------------------------------
# Add Document File(s) to CMake Install
#-----------------------------------------------------------------------------
if (NOT SZIP_EXTERNALLY_CONFIGURED)
  install (
      FILES
          ${SZIP_SOURCE_DIR}/COPYING
          ${SZIP_SOURCE_DIR}/README
          ${SZIP_SOURCE_DIR}/HISTORY.txt
          ${SZIP_SOURCE_DIR}/INSTALL
          ${SZIP_SOURCE_DIR}/RELEASE.txt
      DESTINATION ${SZIP_INSTALL_DATA_DIR}
      COMPONENT hdfdocuments
  )
endif (NOT SZIP_EXTERNALLY_CONFIGURED)

#-----------------------------------------------------------------------------
# Set the cpack variables
#-----------------------------------------------------------------------------
if (NOT SZIP_EXTERNALLY_CONFIGURED)
  set (CPACK_PACKAGE_VENDOR "HDF_Group")
  set (CPACK_PACKAGE_NAME "${SZIP_PACKAGE_NAME}")
  set (CPACK_PACKAGE_INSTALL_DIRECTORY "${SZIP_PACKAGE_NAME}")
  set (CPACK_PACKAGE_VERSION "${SZIP_PACKAGE_VERSION}")
  set (CPACK_PACKAGE_VERSION_MAJOR "${SZIP_PACKAGE_VERSION_MAJOR}")
  set (CPACK_PACKAGE_VERSION_MINOR "${SZIP_PACKAGE_VERSION_MINOR}")
  set (CPACK_PACKAGE_VERSION_PATCH "")
  set (CPACK_PACKAGE_DESCRIPTION_FILE "${CMAKE_CURRENT_SOURCE_DIR}/RELEASE.txt")
  set (CPACK_RESOURCE_FILE_LICENSE "${CMAKE_CURRENT_SOURCE_DIR}/COPYING")
  set (CPACK_RESOURCE_FILE_README "${CMAKE_CURRENT_SOURCE_DIR}/RELEASE.txt")
  set (CPACK_PACKAGE_RELOCATABLE TRUE)
  if (WIN32)
    set (CPACK_MONOLITHIC_INSTALL ON)
    set (CPACK_NSIS_CONTACT "help@hdfgroup.org")
    set (CPACK_NSIS_MODIFY_PATH ON)
    set (CPACK_NSIS_PACKAGE_NAME "SZIP ${SZIP_PACKAGE_VERSION}")
  else (WIN32)
    set (CPACK_PACKAGING_INSTALL_PREFIX "/usr")
    set (CPACK_COMPONENTS_ALL_IN_ONE_PACKAGE ON)

    set (CPACK_DEBIAN_PACKAGE_SECTION "Libraries")
    set (CPACK_DEBIAN_PACKAGE_MAINTAINER "${SZIP_PACKAGE_BUGREPORT}")
    
    set (CPACK_RPM_COMPONENT_INSTALL ON)
    set (CPACK_RPM_PACKAGE_RELOCATABLE ON)
  endif (WIN32)
  
  include (InstallRequiredSystemLibraries)

  set (CPACK_INSTALL_CMAKE_PROJECTS "${SZIP_BINARY_DIR};SZIP;ALL;/")
  
  include (CPack)

  cpack_add_component (libraries 
      DISPLAY_NAME "SZIP Libraries"
      GROUP Runtime
  )
  cpack_add_component (headers 
      DISPLAY_NAME "SZIP Headers" 
      DEPENDS libraries
      GROUP Development
  )
  cpack_add_component (hdfdocuments 
      DISPLAY_NAME "SZIP Documents"
      GROUP Documents
  )
  cpack_add_component (configinstall 
      DISPLAY_NAME "SZIP CMake files" 
      DEPENDS libraries
      GROUP Development
  )
  
endif (NOT SZIP_EXTERNALLY_CONFIGURED)
  