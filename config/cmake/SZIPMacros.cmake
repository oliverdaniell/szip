#-------------------------------------------------------------------------------
MACRO (SZIP_SET_LIB_OPTIONS libtarget libname libtype)
  # message (STATUS "${libname} libtype: ${libtype}")
  HDF_SET_LIB_OPTIONS (${libtarget} ${libname} ${libtype})

  if (${libtype} MATCHES "SHARED")
    if (WIN32)
      set (LIBSZIP_VERSION ${SZIP_PACKAGE_VERSION_MAJOR})
    else (WIN32)
      set (LIBSZIP_VERSION ${SZIP_PACKAGE_VERSION})
    endif (WIN32)

    if (NOT CYGWIN)
      # This property causes shared libraries on Linux to have the full version
      # encoded into their final filename.  We disable this on Cygwin because
      # it causes cygszip-${SZIP_FULL_VERSION}.dll to be created when cygszip.dll
      # seems to be the default.
      set_target_properties (${libtarget} PROPERTIES VERSION ${LIBSZIP_VERSION})
    endif (NOT CYGWIN)
    set_target_properties (${libtarget} PROPERTIES SOVERSION ${LIBSZIP_VERSION})
  endif (${libtype} MATCHES "SHARED")

  #-- Apple Specific install_name for libraries
  if (APPLE)
    option (SZIP_BUILD_WITH_INSTALL_NAME "Build with library install_name set to the installation path" OFF)
    if (SZIP_BUILD_WITH_INSTALL_NAME)
      set_target_properties (${libtarget} PROPERTIES
          LINK_FLAGS "-current_version ${SZIP_PACKAGE_VERSION} -compatibility_version ${SZIP_PACKAGE_VERSION}"
          INSTALL_NAME_DIR "${CMAKE_INSTALL_PREFIX}/lib"
          BUILD_WITH_INSTALL_RPATH ${SZIP_BUILD_WITH_INSTALL_NAME}
      )
    endif (SZIP_BUILD_WITH_INSTALL_NAME)
  endif (APPLE)

ENDMACRO (SZIP_SET_LIB_OPTIONS)

