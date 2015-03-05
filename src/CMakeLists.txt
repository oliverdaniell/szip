cmake_minimum_required (VERSION 3.1.0)
PROJECT (SZIP_SRC C)

#-----------------------------------------------------------------------------
# Setup include Directories
#-----------------------------------------------------------------------------
INCLUDE_DIRECTORIES (${SZIP_SRC_SOURCE_DIR})
INCLUDE_DIRECTORIES (${CMAKE_BINARY_DIR})

#-----------------------------------------------------------------------------
# Define szip Library
#-----------------------------------------------------------------------------
set (SZIP_SRCS
    ${SZIP_SRC_SOURCE_DIR}/rice.c
    ${SZIP_SRC_SOURCE_DIR}/sz_api.c
    ${SZIP_SRC_SOURCE_DIR}/encoding.c
)

set (SZIP_PUBLIC_HEADERS
    ${SZIP_SRC_SOURCE_DIR}/ricehdf.h
    ${SZIP_SRC_SOURCE_DIR}/szip_adpt.h
    ${SZIP_SRC_SOURCE_DIR}/szlib.h
)

add_library (${SZIP_LIB_TARGET} ${LIB_TYPE} ${SZIP_SRCS} ${SZIP_PUBLIC_HEADERS})
#set_target_properties (${SZIP_LIB_TARGET}
#  PROPERTIES
#      LINK_FLAGS "-version-info 2:0:0"
#) 
set_target_properties (${SZIP_LIB_TARGET} PROPERTIES DEFINE_SYMBOL ${SZIP_LIB_CORENAME}_EXPORTS)
TARGET_C_PROPERTIES (${SZIP_LIB_TARGET} " " " ")
target_link_libraries (${SZIP_LIB_TARGET} ${LINK_LIBS})
set_global_variable (SZIP_LIBRARIES_TO_EXPORT ${SZIP_LIB_TARGET})
SZIP_SET_LIB_OPTIONS (${SZIP_LIB_TARGET} ${SZIP_LIB_NAME} ${LIB_TYPE})

#-----------------------------------------------------------------------------
# Add file(s) to CMake Install 
#-----------------------------------------------------------------------------
install (
    FILES
        ${SZIP_PUBLIC_HEADERS}
    DESTINATION
        ${SZIP_INSTALL_INCLUDE_DIR}
    COMPONENT
        headers
)

#-----------------------------------------------------------------------------
# Add Target(s) to CMake Install for import into other projects
#-----------------------------------------------------------------------------
if (SZIP_EXPORTED_TARGETS)
  install (
      TARGETS
          ${SZIP_LIB_TARGET}
      EXPORT
          ${SZIP_EXPORTED_TARGETS}
      LIBRARY DESTINATION ${SZIP_INSTALL_LIB_DIR} COMPONENT libraries
      ARCHIVE DESTINATION ${SZIP_INSTALL_LIB_DIR} COMPONENT libraries
      RUNTIME DESTINATION ${SZIP_INSTALL_BIN_DIR} COMPONENT libraries
  )
endif (SZIP_EXPORTED_TARGETS)
