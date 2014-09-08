cmake_minimum_required (VERSION 2.8.11)
PROJECT (SZIP_EXAMPLES)

#-----------------------------------------------------------------------------
# Setup include Directories
#-----------------------------------------------------------------------------
INCLUDE_DIRECTORIES (${SZIP_SOURCE_DIR})
INCLUDE_DIRECTORIES (${SZIP_TEST_SOURCE_DIR})

#-----------------------------------------------------------------------------
# Add Tests
#-----------------------------------------------------------------------------
add_executable (burst_szip burst_szip.c)
TARGET_NAMING (burst_szip ${LIB_TYPE})
TARGET_C_PROPERTIES (burst_szip " " " ")
target_link_libraries (burst_szip ${SZIP_LIB_TARGET} ${SZIP_TEST_LIB_TARGET})

add_test (NAME burst_szip COMMAND $<TARGET_FILE:burst_szip> -msb 8 8 1024 16 image.8.in)

#-- Adding test for example
add_executable (example example.c)
TARGET_NAMING (example ${LIB_TYPE})
TARGET_C_PROPERTIES (example " " " ")
target_link_libraries (example ${SZIP_LIB_TARGET})

add_test (NAME example COMMAND $<TARGET_FILE:example>)
set_tests_properties (example PROPERTIES DEPENDS burst_szip)
