cmake_minimum_required (VERSION 2.8)
PROJECT (SZIP_EXAMPLES)

#-----------------------------------------------------------------------------
# Setup include Directories
#-----------------------------------------------------------------------------
INCLUDE_DIRECTORIES (${SZIP_SOURCE_DIR})
INCLUDE_DIRECTORIES (${SZIP_TEST_SOURCE_DIR})

#-----------------------------------------------------------------------------
# Add Tests
#-----------------------------------------------------------------------------
ADD_EXECUTABLE (burst_szip burst_szip.c)
TARGET_NAMING (burst_szip ${LIB_TYPE})
TARGET_C_PROPERTIES (burst_szip " " " ")
TARGET_LINK_LIBRARIES (burst_szip ${SZIP_LIB_TARGET} ${SZIP_TEST_LIB_TARGET})

ADD_TEST (NAME burst_szip COMMAND $<TARGET_FILE:burst_szip> -msb 8 8 1024 16 image.8.in)

#-- Adding test for example
ADD_EXECUTABLE(example example.c)
TARGET_NAMING (example ${LIB_TYPE})
TARGET_C_PROPERTIES (example " " " ")
TARGET_LINK_LIBRARIES(example ${SZIP_LIB_TARGET})

ADD_TEST (NAME example COMMAND $<TARGET_FILE:example>)
