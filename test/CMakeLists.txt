cmake_minimum_required (VERSION 2.8.11)
PROJECT (SZIP_TEST)

#-----------------------------------------------------------------------------
# Setup include Directories
#-----------------------------------------------------------------------------
INCLUDE_DIRECTORIES (${SZIP_SOURCE_DIR})

#-----------------------------------------------------------------------------
# Define Sources
#-----------------------------------------------------------------------------
set (TEST_LIB_SRCS
    ${SZIP_TEST_SOURCE_DIR}/mcgill.c
)

set (TEST_LIB_HEADERS
    ${SZIP_TEST_SOURCE_DIR}/mcgill.h
)

add_library (${SZIP_TEST_LIB_TARGET} ${LIB_TYPE} ${TEST_LIB_SRCS} ${TEST_LIB_HEADERS})
TARGET_C_PROPERTIES (${SZIP_TEST_LIB_TARGET} " " " ")
target_link_libraries (${SZIP_TEST_LIB_TARGET} ${SZIP_LIB_TARGET})
#set_global_variable (SZIP_LIBRARIES_TO_EXPORT "${SZIP_LIBRARIES_TO_EXPORT};${SZIP_TEST_LIB_TARGET}")
SZIP_SET_LIB_OPTIONS (${SZIP_TEST_LIB_TARGET} ${SZIP_TEST_LIB_NAME} ${LIB_TYPE})

#-- Adding test 
if (SZIP_ENABLE_ENCODING)
  ADD_EXECUTABLE (gentest gentest.c)
  TARGET_NAMING (gentest ${LIB_TYPE})
  TARGET_C_PROPERTIES (gentest " " " ")
  target_link_libraries (gentest ${SZIP_TEST_LIB_TARGET} ${SZIP_LIB_TARGET})

  add_test (NAME gentest COMMAND $<TARGET_FILE:gentest>)
endif (SZIP_ENABLE_ENCODING)
