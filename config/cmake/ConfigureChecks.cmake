#-----------------------------------------------------------------------------
# Include all the necessary files for macros
#-----------------------------------------------------------------------------
INCLUDE (${CMAKE_ROOT}/Modules/CheckFunctionExists.cmake)
INCLUDE (${CMAKE_ROOT}/Modules/CheckIncludeFile.cmake)
INCLUDE (${CMAKE_ROOT}/Modules/CheckIncludeFileCXX.cmake)
INCLUDE (${CMAKE_ROOT}/Modules/CheckIncludeFiles.cmake)
INCLUDE (${CMAKE_ROOT}/Modules/CheckLibraryExists.cmake)
INCLUDE (${CMAKE_ROOT}/Modules/CheckSymbolExists.cmake)
INCLUDE (${CMAKE_ROOT}/Modules/CheckTypeSize.cmake)

#-----------------------------------------------------------------------------
# Always SET this for now IF we are on an OS X box
#-----------------------------------------------------------------------------
IF (APPLE)
  SET (H5_AC_APPLE_UNIVERSAL_BUILD 1)
ENDIF (APPLE)

SET (LINUX_LFS 0)
SET (HDF_EXTRA_FLAGS)
IF (CMAKE_SYSTEM MATCHES "Linux-([3-9]\\.[0-9]|2\\.[4-9])\\.")
  # Linux Specific flags
  ADD_DEFINITIONS (-D_POSIX_SOURCE -D_BSD_SOURCE)
  OPTION (HDF_ENABLE_LARGE_FILE "Enable support for large (64-bit) files on Linux." ON)
  IF (HDF_ENABLE_LARGE_FILE)
    SET (LARGEFILE 1)
    SET (HDF_EXTRA_FLAGS -D_FILE_OFFSET_BITS=64 -D_LARGEFILE64_SOURCE -D_LARGEFILE_SOURCE)
    SET (CMAKE_REQUIRED_DEFINITIONS ${HDF_EXTRA_FLAGS})
  ENDIF (HDF_ENABLE_LARGE_FILE)
ENDIF (CMAKE_SYSTEM MATCHES "Linux-([3-9]\\.[0-9]|2\\.[4-9])\\.")
IF (LINUX_LFS)
  SET (HDF_EXTRA_FLAGS -D_FILE_OFFSET_BITS=64 -D_LARGEFILE64_SOURCE -D_LARGEFILE_SOURCE)
  SET (CMAKE_REQUIRED_DEFINITIONS ${HDF_EXTRA_FLAGS})
ENDIF (LINUX_LFS)
ADD_DEFINITIONS (${HDF_EXTRA_FLAGS})

SET (WINDOWS)
IF (WIN32)
  IF (NOT UNIX)
    SET (WINDOWS 1)
  ENDIF (NOT UNIX)
ENDIF (WIN32)

# ----------------------------------------------------------------------
# Set the flag to indicate that the machine can handle converting
# floating-point to long long values.
# (This flag should be _unset_ for all machines)
#
#  SET (H5_HW_FP_TO_LLONG_NOT_WORKS 0)

# so far we have no check for this
SET(HAVE_TMPFILE 1)

#-----------------------------------------------------------------------------
# This MACRO checks IF the symbol exists in the library and IF it
# does, it appends library to the list.
#-----------------------------------------------------------------------------
SET (LINK_LIBS "")
MACRO (CHECK_LIBRARY_EXISTS_CONCAT LIBRARY SYMBOL VARIABLE)
  CHECK_LIBRARY_EXISTS ("${LIBRARY};${LINK_LIBS}" ${SYMBOL} "" ${VARIABLE})
  IF (${VARIABLE})
    SET (LINK_LIBS ${LINK_LIBS} ${LIBRARY})
  ENDIF (${VARIABLE})
ENDMACRO (CHECK_LIBRARY_EXISTS_CONCAT)

#-----------------------------------------------------------------------------
#  Check for the math library "m"
#-----------------------------------------------------------------------------
IF (WINDOWS)
  SET (HAVE_LIBM 1)
ELSE (WINDOWS)
  CHECK_LIBRARY_EXISTS_CONCAT ("m" printf     HAVE_LIBM)
ENDIF (WINDOWS)
CHECK_LIBRARY_EXISTS_CONCAT ("ws2_32" printf  HAVE_LIBWS2_32)
CHECK_LIBRARY_EXISTS_CONCAT ("wsock32" printf HAVE_LIBWSOCK32)
#CHECK_LIBRARY_EXISTS_CONCAT ("dl"     dlopen       HAVE_LIBDL)
CHECK_LIBRARY_EXISTS_CONCAT ("ucb"    gethostname  HAVE_LIBUCB)
CHECK_LIBRARY_EXISTS_CONCAT ("socket" connect      HAVE_LIBSOCKET)
CHECK_LIBRARY_EXISTS ("c" gethostbyname "" NOT_NEED_LIBNSL)


IF (NOT NOT_NEED_LIBNSL)
  CHECK_LIBRARY_EXISTS_CONCAT ("nsl"    gethostbyname  HAVE_LIBNSL)
ENDIF (NOT NOT_NEED_LIBNSL)


SET (USE_INCLUDES "")
#-----------------------------------------------------------------------------
# Check IF header file exists and add it to the list.
#-----------------------------------------------------------------------------
MACRO (CHECK_INCLUDE_FILE_CONCAT FILE VARIABLE)
  CHECK_INCLUDE_FILES ("${USE_INCLUDES};${FILE}" ${VARIABLE})
  IF (${VARIABLE})
    SET (USE_INCLUDES ${USE_INCLUDES} ${FILE})
  ENDIF (${VARIABLE})
ENDMACRO (CHECK_INCLUDE_FILE_CONCAT)

#-----------------------------------------------------------------------------
# If we are on Windows we know some of the answers to these tests already
#-----------------------------------------------------------------------------
IF (WINDOWS)
  SET (HAVE_IO_H 1)
  SET (HAVE_SETJMP_H 1)
  SET (HAVE_STDDEF_H 1)
  SET (HAVE_SYS_STAT_H 1)
  SET (HAVE_SYS_TIMEB_H 1)
  SET (HAVE_SYS_TYPES_H 1)
  SET (HAVE_WINSOCK_H 1)
ENDIF (WINDOWS)

#-----------------------------------------------------------------------------
#  Check for the existence of certain header files
#-----------------------------------------------------------------------------
CHECK_INCLUDE_FILE_CONCAT ("globus/common.h" HAVE_GLOBUS_COMMON_H)
CHECK_INCLUDE_FILE_CONCAT ("io.h"            HAVE_IO_H)
CHECK_INCLUDE_FILE_CONCAT ("mfhdf.h"         HAVE_MFHDF_H)
CHECK_INCLUDE_FILE_CONCAT ("pdb.h"           HAVE_PDB_H)
CHECK_INCLUDE_FILE_CONCAT ("pthread.h"       HAVE_PTHREAD_H)
CHECK_INCLUDE_FILE_CONCAT ("setjmp.h"        HAVE_SETJMP_H)
CHECK_INCLUDE_FILE_CONCAT ("srbclient.h"     HAVE_SRBCLIENT_H)
CHECK_INCLUDE_FILE_CONCAT ("stddef.h"        HAVE_STDDEF_H)
CHECK_INCLUDE_FILE_CONCAT ("stdint.h"        HAVE_STDINT_H)
CHECK_INCLUDE_FILE_CONCAT ("string.h"        HAVE_STRING_H)
CHECK_INCLUDE_FILE_CONCAT ("strings.h"       HAVE_STRINGS_H)
CHECK_INCLUDE_FILE_CONCAT ("sys/ioctl.h"     HAVE_SYS_IOCTL_H)
CHECK_INCLUDE_FILE_CONCAT ("sys/proc.h"      HAVE_SYS_PROC_H)
CHECK_INCLUDE_FILE_CONCAT ("sys/resource.h"  HAVE_SYS_RESOURCE_H)
CHECK_INCLUDE_FILE_CONCAT ("sys/socket.h"    HAVE_SYS_SOCKET_H)
CHECK_INCLUDE_FILE_CONCAT ("sys/stat.h"      HAVE_SYS_STAT_H)
IF (CMAKE_SYSTEM_NAME MATCHES "OSF")
  CHECK_INCLUDE_FILE_CONCAT ("sys/sysinfo.h" HAVE_SYS_SYSINFO_H)
ELSE (CMAKE_SYSTEM_NAME MATCHES "OSF")
  SET (HAVE_SYS_SYSINFO_H "" CACHE INTERNAL "" FORCE)
ENDIF (CMAKE_SYSTEM_NAME MATCHES "OSF")
CHECK_INCLUDE_FILE_CONCAT ("sys/time.h"      HAVE_SYS_TIME_H)
CHECK_INCLUDE_FILE_CONCAT ("time.h"          HAVE_TIME_H)
CHECK_INCLUDE_FILE_CONCAT ("sys/timeb.h"     HAVE_SYS_TIMEB_H)
CHECK_INCLUDE_FILE_CONCAT ("sys/types.h"     HAVE_SYS_TYPES_H)
CHECK_INCLUDE_FILE_CONCAT ("unistd.h"        HAVE_UNISTD_H)
CHECK_INCLUDE_FILE_CONCAT ("stdlib.h"        HAVE_STDLIB_H)
CHECK_INCLUDE_FILE_CONCAT ("memory.h"        HAVE_MEMORY_H)
CHECK_INCLUDE_FILE_CONCAT ("dlfcn.h"         HAVE_DLFCN_H)
CHECK_INCLUDE_FILE_CONCAT ("features.h"      HAVE_FEATURES_H)
CHECK_INCLUDE_FILE_CONCAT ("inttypes.h"      HAVE_INTTYPES_H)
CHECK_INCLUDE_FILE_CONCAT ("winsock2.h"      HAVE_WINSOCK_H)
CHECK_INCLUDE_FILE_CONCAT ("netinet/in.h"    HAVE_NETINET_IN_H)


# IF the c compiler found stdint, check the C++ as well. On some systems this
# file will be found by C but not C++, only do this test IF the C++ compiler
# has been initialized (e.g. the project also includes some c++)
IF (HAVE_STDINT_H AND CMAKE_CXX_COMPILER_LOADED)
  CHECK_INCLUDE_FILE_CXX ("stdint.h" HAVE_STDINT_H_CXX)
  IF (NOT HAVE_STDINT_H_CXX)
    SET (HAVE_STDINT_H "" CACHE INTERNAL "Have includes HAVE_STDINT_H")
  ENDIF (NOT HAVE_STDINT_H_CXX)
ENDIF (HAVE_STDINT_H AND CMAKE_CXX_COMPILER_LOADED)

#-----------------------------------------------------------------------------
#  Check the size in bytes of all the int and float types
#-----------------------------------------------------------------------------
MACRO (H5_CHECK_TYPE_SIZE type var)
  SET (aType ${type})
  SET (aVar  ${var})
#  MESSAGE (STATUS "Checking size of ${aType} and storing into ${aVar}")
  CHECK_TYPE_SIZE (${aType}   ${aVar})
  IF (NOT ${aVar})
    SET (${aVar} 0 CACHE INTERNAL "SizeOf for ${aType}")
#    MESSAGE (STATUS "Size of ${aType} was NOT Found")
  ENDIF (NOT ${aVar})
ENDMACRO (H5_CHECK_TYPE_SIZE)



H5_CHECK_TYPE_SIZE (char           H5_SIZEOF_CHAR)
H5_CHECK_TYPE_SIZE (short          H5_SIZEOF_SHORT)
H5_CHECK_TYPE_SIZE (int            H5_SIZEOF_INT)
H5_CHECK_TYPE_SIZE (unsigned       H5_SIZEOF_UNSIGNED)
IF (NOT APPLE)
  H5_CHECK_TYPE_SIZE (long         H5_SIZEOF_LONG)
ENDIF (NOT APPLE)
H5_CHECK_TYPE_SIZE ("long long"    H5_SIZEOF_LONG_LONG)
H5_CHECK_TYPE_SIZE (__int64        H5_SIZEOF___INT64)
IF (NOT H5_SIZEOF___INT64)
  SET (H5_SIZEOF___INT64 0)
ENDIF (NOT H5_SIZEOF___INT64)

H5_CHECK_TYPE_SIZE (float          H5_SIZEOF_FLOAT)
H5_CHECK_TYPE_SIZE (double         H5_SIZEOF_DOUBLE)
H5_CHECK_TYPE_SIZE ("long double"  H5_SIZEOF_LONG_DOUBLE)
H5_CHECK_TYPE_SIZE (int8_t         H5_SIZEOF_INT8_T)
H5_CHECK_TYPE_SIZE (uint8_t        H5_SIZEOF_UINT8_T)
H5_CHECK_TYPE_SIZE (int_least8_t   H5_SIZEOF_INT_LEAST8_T)
H5_CHECK_TYPE_SIZE (uint_least8_t  H5_SIZEOF_UINT_LEAST8_T)
H5_CHECK_TYPE_SIZE (int_fast8_t    H5_SIZEOF_INT_FAST8_T)
H5_CHECK_TYPE_SIZE (uint_fast8_t   H5_SIZEOF_UINT_FAST8_T)
H5_CHECK_TYPE_SIZE (int16_t        H5_SIZEOF_INT16_T)
H5_CHECK_TYPE_SIZE (uint16_t       H5_SIZEOF_UINT16_T)
H5_CHECK_TYPE_SIZE (int_least16_t  H5_SIZEOF_INT_LEAST16_T)
H5_CHECK_TYPE_SIZE (uint_least16_t H5_SIZEOF_UINT_LEAST16_T)
H5_CHECK_TYPE_SIZE (int_fast16_t   H5_SIZEOF_INT_FAST16_T)
H5_CHECK_TYPE_SIZE (uint_fast16_t  H5_SIZEOF_UINT_FAST16_T)
H5_CHECK_TYPE_SIZE (int32_t        H5_SIZEOF_INT32_T)
H5_CHECK_TYPE_SIZE (uint32_t       H5_SIZEOF_UINT32_T)
H5_CHECK_TYPE_SIZE (int_least32_t  H5_SIZEOF_INT_LEAST32_T)
H5_CHECK_TYPE_SIZE (uint_least32_t H5_SIZEOF_UINT_LEAST32_T)
H5_CHECK_TYPE_SIZE (int_fast32_t   H5_SIZEOF_INT_FAST32_T)
H5_CHECK_TYPE_SIZE (uint_fast32_t  H5_SIZEOF_UINT_FAST32_T)
H5_CHECK_TYPE_SIZE (int64_t        H5_SIZEOF_INT64_T)
H5_CHECK_TYPE_SIZE (uint64_t       H5_SIZEOF_UINT64_T)
H5_CHECK_TYPE_SIZE (int_least64_t  H5_SIZEOF_INT_LEAST64_T)
H5_CHECK_TYPE_SIZE (uint_least64_t H5_SIZEOF_UINT_LEAST64_T)
H5_CHECK_TYPE_SIZE (int_fast64_t   H5_SIZEOF_INT_FAST64_T)
H5_CHECK_TYPE_SIZE (uint_fast64_t  H5_SIZEOF_UINT_FAST64_T)
IF (NOT APPLE)
  H5_CHECK_TYPE_SIZE (size_t       H5_SIZEOF_SIZE_T)
  H5_CHECK_TYPE_SIZE (ssize_t      H5_SIZEOF_SSIZE_T)
  IF (NOT H5_SIZEOF_SSIZE_T)
    SET (H5_SIZEOF_SSIZE_T 0)
  ENDIF (NOT H5_SIZEOF_SSIZE_T)
ENDIF (NOT APPLE)
H5_CHECK_TYPE_SIZE (off_t          H5_SIZEOF_OFF_T)
H5_CHECK_TYPE_SIZE (off64_t        H5_SIZEOF_OFF64_T)
IF (NOT H5_SIZEOF_OFF64_T)
  SET (H5_SIZEOF_OFF64_T 0)
ENDIF (NOT H5_SIZEOF_OFF64_T)


# For other tests to use the same libraries
SET (CMAKE_REQUIRED_LIBRARIES ${LINK_LIBS})

#-----------------------------------------------------------------------------
# Check for some functions that are used
IF (WINDOWS)
  SET (HAVE_STRDUP 1)
  SET (HAVE_SYSTEM 1)
  SET (HAVE_DIFFTIME 1)
  SET (HAVE_LONGJMP 1)
  SET (STDC_HEADERS 1)
  SET (HAVE_GETHOSTNAME 1)
ENDIF (WINDOWS)

CHECK_FUNCTION_EXISTS (alarm             HAVE_ALARM)
CHECK_FUNCTION_EXISTS (fork              HAVE_FORK)
CHECK_FUNCTION_EXISTS (frexpf            HAVE_FREXPF)
CHECK_FUNCTION_EXISTS (frexpl            HAVE_FREXPL)

CHECK_FUNCTION_EXISTS (gethostname       HAVE_GETHOSTNAME)
CHECK_FUNCTION_EXISTS (getpwuid          HAVE_GETPWUID)
CHECK_FUNCTION_EXISTS (getrusage         HAVE_GETRUSAGE)
CHECK_FUNCTION_EXISTS (lstat             HAVE_LSTAT)

CHECK_FUNCTION_EXISTS (rand_r            HAVE_RAND_R)
CHECK_FUNCTION_EXISTS (random            HAVE_RANDOM)
CHECK_FUNCTION_EXISTS (setsysinfo        HAVE_SETSYSINFO)

CHECK_FUNCTION_EXISTS (signal            HAVE_SIGNAL)
CHECK_FUNCTION_EXISTS (longjmp           HAVE_LONGJMP)
CHECK_FUNCTION_EXISTS (setjmp            HAVE_SETJMP)
CHECK_FUNCTION_EXISTS (siglongjmp        HAVE_SIGLONGJMP)
CHECK_FUNCTION_EXISTS (sigsetjmp         HAVE_SIGSETJMP)
CHECK_FUNCTION_EXISTS (sigaction         HAVE_SIGACTION)
CHECK_FUNCTION_EXISTS (sigprocmask       HAVE_SIGPROCMASK)

CHECK_FUNCTION_EXISTS (snprintf          HAVE_SNPRINTF)
CHECK_FUNCTION_EXISTS (srandom           HAVE_SRANDOM)
CHECK_FUNCTION_EXISTS (strdup            HAVE_STRDUP)
CHECK_FUNCTION_EXISTS (symlink           HAVE_SYMLINK)
CHECK_FUNCTION_EXISTS (system            HAVE_SYSTEM)

CHECK_FUNCTION_EXISTS (tmpfile           HAVE_TMPFILE)
CHECK_FUNCTION_EXISTS (vasprintf         HAVE_VASPRINTF)
CHECK_FUNCTION_EXISTS (waitpid           HAVE_WAITPID)

CHECK_FUNCTION_EXISTS (vsnprintf         HAVE_VSNPRINTF)
CHECK_FUNCTION_EXISTS (ioctl             HAVE_IOCTL)
#CHECK_FUNCTION_EXISTS (gettimeofday      HAVE_GETTIMEOFDAY)
CHECK_FUNCTION_EXISTS (difftime          HAVE_DIFFTIME)
CHECK_FUNCTION_EXISTS (fseeko            HAVE_FSEEKO)
CHECK_FUNCTION_EXISTS (ftello            HAVE_FTELLO)
CHECK_FUNCTION_EXISTS (fstat64           HAVE_FSTAT64)
CHECK_FUNCTION_EXISTS (stat64            HAVE_STAT64)

#-----------------------------------------------------------------------------

#-----------------------------------------------------------------------------
#  Since gettimeofday is not defined any where standard, lets look in all the
#  usual places. On MSVC we are just going to use ::clock()
#-----------------------------------------------------------------------------
IF (NOT MSVC)
  IF ("HAVE_TIME_GETTIMEOFDAY" MATCHES "^HAVE_TIME_GETTIMEOFDAY$")
    TRY_COMPILE (HAVE_TIME_GETTIMEOFDAY
        ${CMAKE_BINARY_DIR}
        ${HDF_RESOURCES_DIR}/GetTimeOfDayTest.c
        COMPILE_DEFINITIONS -DTRY_TIME_H
        OUTPUT_VARIABLE OUTPUT
    )
    IF (HAVE_TIME_GETTIMEOFDAY STREQUAL "TRUE")
      SET (HAVE_TIME_GETTIMEOFDAY "1" CACHE INTERNAL "HAVE_TIME_GETTIMEOFDAY")
    ENDIF (HAVE_TIME_GETTIMEOFDAY STREQUAL "TRUE")
  ENDIF ("HAVE_TIME_GETTIMEOFDAY" MATCHES "^HAVE_TIME_GETTIMEOFDAY$")

  IF ("HAVE_SYS_TIME_GETTIMEOFDAY" MATCHES "^HAVE_SYS_TIME_GETTIMEOFDAY$")
    TRY_COMPILE (HAVE_SYS_TIME_GETTIMEOFDAY
        ${CMAKE_BINARY_DIR}
        ${HDF_RESOURCES_DIR}/GetTimeOfDayTest.c
        COMPILE_DEFINITIONS -DTRY_SYS_TIME_H
        OUTPUT_VARIABLE OUTPUT
    )
    IF (HAVE_SYS_TIME_GETTIMEOFDAY STREQUAL "TRUE")
      SET (HAVE_SYS_TIME_GETTIMEOFDAY "1" CACHE INTERNAL "HAVE_SYS_TIME_GETTIMEOFDAY")
    ENDIF (HAVE_SYS_TIME_GETTIMEOFDAY STREQUAL "TRUE")
  ENDIF ("HAVE_SYS_TIME_GETTIMEOFDAY" MATCHES "^HAVE_SYS_TIME_GETTIMEOFDAY$")
ENDIF (NOT MSVC)

IF (NOT HAVE_SYS_TIME_GETTIMEOFDAY AND NOT HAVE_GETTIMEOFDAY AND NOT MSVC)
  MESSAGE (STATUS "---------------------------------------------------------------")
  MESSAGE (STATUS "Function 'gettimeofday()' was not found. SZIP will use its")
  MESSAGE (STATUS "  own implementation.. This can happen on older versions of")
  MESSAGE (STATUS "  MinGW on Windows. Consider upgrading your MinGW installation")
  MESSAGE (STATUS "  to a newer version such as MinGW 3.12")
  MESSAGE (STATUS "---------------------------------------------------------------")
ENDIF (NOT HAVE_SYS_TIME_GETTIMEOFDAY AND NOT HAVE_GETTIMEOFDAY AND NOT MSVC)


# Check for Symbols
CHECK_SYMBOL_EXISTS (tzname "time.h" HAVE_DECL_TZNAME)

#-----------------------------------------------------------------------------
#
#-----------------------------------------------------------------------------
IF (NOT WINDOWS)
  CHECK_SYMBOL_EXISTS (TIOCGWINSZ "sys/ioctl.h" HAVE_TIOCGWINSZ)
  CHECK_SYMBOL_EXISTS (TIOCGETD   "sys/ioctl.h" HAVE_TIOCGETD)
ENDIF (NOT WINDOWS)


# For other other specific tests, use this MACRO.
MACRO (HDF_FUNCTION_TEST OTHER_TEST)
  IF ("H5_${OTHER_TEST}" MATCHES "^H5_${OTHER_TEST}$")
    SET (MACRO_CHECK_FUNCTION_DEFINITIONS "-D${OTHER_TEST} ${CMAKE_REQUIRED_FLAGS}")
    SET (OTHER_TEST_ADD_LIBRARIES)
    IF (CMAKE_REQUIRED_LIBRARIES)
      SET (OTHER_TEST_ADD_LIBRARIES "-DLINK_LIBRARIES:STRING=${CMAKE_REQUIRED_LIBRARIES}")
    ENDIF (CMAKE_REQUIRED_LIBRARIES)

    FOREACH (def ${HDF_EXTRA_TEST_DEFINITIONS})
      SET (MACRO_CHECK_FUNCTION_DEFINITIONS "${MACRO_CHECK_FUNCTION_DEFINITIONS} -D${def}=${${def}}")
    ENDFOREACH (def)

    FOREACH (def
        HAVE_SYS_TIME_H
        HAVE_UNISTD_H
        HAVE_SYS_TYPES_H
        HAVE_SYS_SOCKET_H
    )
      IF ("${def}")
        SET (MACRO_CHECK_FUNCTION_DEFINITIONS "${MACRO_CHECK_FUNCTION_DEFINITIONS} -D${def}")
      ENDIF ("${def}")
    ENDFOREACH (def)

    IF (LINUX_LFS)
      SET (MACRO_CHECK_FUNCTION_DEFINITIONS
          "${MACRO_CHECK_FUNCTION_DEFINITIONS} -D_FILE_OFFSET_BITS=64 -D_LARGEFILE64_SOURCE -D_LARGEFILE_SOURCE"
      )
    ENDIF (LINUX_LFS)

    # (STATUS "Performing ${OTHER_TEST}")
    TRY_COMPILE (${OTHER_TEST}
        ${CMAKE_BINARY_DIR}
        ${HDF_RESOURCES_DIR}/HDFTests.c
        CMAKE_FLAGS -DCOMPILE_DEFINITIONS:STRING=${MACRO_CHECK_FUNCTION_DEFINITIONS}
        "${OTHER_TEST_ADD_LIBRARIES}"
        OUTPUT_VARIABLE OUTPUT
    )
    IF (${OTHER_TEST})
      SET (H5_${OTHER_TEST} 1 CACHE INTERNAL "Other test ${FUNCTION}")
      MESSAGE (STATUS "Performing Other Test ${OTHER_TEST} - Success")
    ELSE (${OTHER_TEST})
      MESSAGE (STATUS "Performing Other Test ${OTHER_TEST} - Failed")
      SET (H5_${OTHER_TEST} "" CACHE INTERNAL "Other test ${FUNCTION}")
      FILE (APPEND ${CMAKE_BINARY_DIR}/CMakeFiles/CMakeError.log
          "Performing Other Test ${OTHER_TEST} failed with the following output:\n"
          "${OUTPUT}\n"
      )
    ENDIF (${OTHER_TEST})
  ENDIF ("H5_${OTHER_TEST}" MATCHES "^H5_${OTHER_TEST}$")
ENDMACRO (HDF_FUNCTION_TEST)

#-----------------------------------------------------------------------------
# Check a bunch of other functions
#-----------------------------------------------------------------------------
IF (WINDOWS)
  SET (HAVE_TIMEZONE 1)
  SET (HAVE_FUNCTION 1)
ELSE (WINDOWS)
  FOREACH (test
      TIME_WITH_SYS_TIME
      STDC_HEADERS
      HAVE_TM_ZONE
      HAVE_STRUCT_TM_TM_ZONE
      HAVE_ATTRIBUTE
      HAVE_FUNCTION
      HAVE_TM_GMTOFF
      HAVE_TIMEZONE
      HAVE_STRUCT_TIMEZONE
      HAVE_STAT_ST_BLOCKS
      HAVE_FUNCTION
      SYSTEM_SCOPE_THREADS
      HAVE_SOCKLEN_T
      DEV_T_IS_SCALAR
      HAVE_OFF64_T
      GETTIMEOFDAY_GIVES_TZ
      VSNPRINTF_WORKS
      HAVE_C99_FUNC
      HAVE_C99_DESIGNATED_INITIALIZER
      CXX_HAVE_OFFSETOF
  )
    HDF_FUNCTION_TEST (${test})
  ENDFOREACH (test)
ENDIF (WINDOWS)

#-----------------------------------------------------------------------------
# Look for 64 bit file stream capability
#-----------------------------------------------------------------------------
IF (HAVE_OFF64_T)
  CHECK_FUNCTION_EXISTS (lseek64           HAVE_LSEEK64)
  CHECK_FUNCTION_EXISTS (fseek64           HAVE_FSEEK64)
ENDIF (HAVE_OFF64_T)

#-----------------------------------------------------------------------------
# Determine how 'inline' is used
#-----------------------------------------------------------------------------
SET (HDF_EXTRA_TEST_DEFINITIONS INLINE_TEST_INLINE)
FOREACH (inline_test inline __inline__ __inline)
  SET (INLINE_TEST_INLINE ${inline_test})
  HDF_FUNCTION_TEST (INLINE_TEST_${inline_test})
ENDFOREACH (inline_test)

SET (HDF_EXTRA_TEST_DEFINITIONS)
IF (INLINE_TEST___inline__)
  SET (H5_inline __inline__)
ELSE (INLINE_TEST___inline__)
  IF (INLINE_TEST___inline)
    SET (H5_inline __inline)
  ELSE (INLINE_TEST___inline)
    IF (INLINE_TEST_inline)
      SET (H5_inline inline)
    ENDIF (INLINE_TEST_inline)
  ENDIF (INLINE_TEST___inline)
ENDIF (INLINE_TEST___inline__)

#-----------------------------------------------------------------------------
# Check how to print a Long Long integer
#-----------------------------------------------------------------------------
SET (H5_PRINTF_LL_WIDTH "H5_PRINTF_LL_WIDTH")
IF (H5_PRINTF_LL_WIDTH MATCHES "^H5_PRINTF_LL_WIDTH$")
  SET (PRINT_LL_FOUND 0)
  MESSAGE (STATUS "Checking for appropriate format for 64 bit long:")
  FOREACH (HDF_PRINTF_LL l64 l L q I64 ll)
    SET (CURRENT_TEST_DEFINITIONS "-DPRINTF_LL_WIDTH=${HDF_PRINTF_LL}")
    IF (H5_SIZEOF_LONG_LONG)
      SET (CURRENT_TEST_DEFINITIONS "${CURRENT_TEST_DEFINITIONS} -DHAVE_LONG_LONG")
    ENDIF (H5_SIZEOF_LONG_LONG)
    TRY_RUN (HDF_PRINTF_LL_TEST_RUN   HDF_PRINTF_LL_TEST_COMPILE
        ${SZIP_BINARY_DIR}/CMake
        ${HDF_RESOURCES_DIR}/HDFTests.c
        CMAKE_FLAGS -DCOMPILE_DEFINITIONS:STRING=${CURRENT_TEST_DEFINITIONS}
        OUTPUT_VARIABLE OUTPUT
    )
    IF (HDF_PRINTF_LL_TEST_COMPILE)
      IF (HDF_PRINTF_LL_TEST_RUN MATCHES 0)
        SET (H5_PRINTF_LL_WIDTH "\"${HDF_PRINTF_LL}\"" CACHE INTERNAL "Width for printf for type `long long' or `__int64', us. `ll")
        SET (PRINT_LL_FOUND 1)
      ELSE (HDF_PRINTF_LL_TEST_RUN MATCHES 0)
        MESSAGE ("Width with ${HDF_PRINTF_LL} failed with result: ${HDF_PRINTF_LL_TEST_RUN}")
      ENDIF (HDF_PRINTF_LL_TEST_RUN MATCHES 0)
    ELSE (HDF_PRINTF_LL_TEST_COMPILE)
      FILE (APPEND ${CMAKE_BINARY_DIR}/CMakeFiles/CMakeError.log
          "Test H5_PRINTF_LL_WIDTH for ${HDF_PRINTF_LL} failed with the following output:\n ${OUTPUT}\n"
      )
    ENDIF (HDF_PRINTF_LL_TEST_COMPILE)
  ENDFOREACH (HDF_PRINTF_LL)

  IF (PRINT_LL_FOUND)
    MESSAGE (STATUS "Checking for apropriate format for 64 bit long: found ${H5_PRINTF_LL_WIDTH}")
  ELSE (PRINT_LL_FOUND)
    MESSAGE (STATUS "Checking for apropriate format for 64 bit long: not found")
    SET (H5_PRINTF_LL_WIDTH "\"unknown\"" CACHE INTERNAL
        "Width for printf for type `long long' or `__int64', us. `ll"
    )
  ENDIF (PRINT_LL_FOUND)
ENDIF (H5_PRINTF_LL_WIDTH MATCHES "^H5_PRINTF_LL_WIDTH$")

# ----------------------------------------------------------------------
# Set the flag to indicate that the machine can handle converting
# denormalized floating-point values.
# (This flag should be set for all machines, except for the Crays, where
# the cache value is set in it's config file)
#
SET (H5_CONVERT_DENORMAL_FLOAT 1)

IF (CYGWIN)
  SET (HAVE_LSEEK64 0)
ENDIF (CYGWIN)

#-----------------------------------------------------------------------------
# Macro to determine the various conversion capabilities
#-----------------------------------------------------------------------------
MACRO (HDFConversionTests TEST msg)
  IF ("${TEST}" MATCHES "^${TEST}$")
   # MESSAGE (STATUS "===> ${TEST}")
    TRY_RUN (${TEST}_RUN   ${TEST}_COMPILE
        ${SZIP_BINARY_DIR}/CMake
        ${HDF_RESOURCES_DIR}/ConversionTests.c
        CMAKE_FLAGS -DCOMPILE_DEFINITIONS:STRING=-D${TEST}_TEST
        OUTPUT_VARIABLE OUTPUT
    )
    IF (${TEST}_COMPILE)
      IF (${TEST}_RUN  MATCHES 0)
        SET (${TEST} 1 CACHE INTERNAL ${msg})
        MESSAGE(STATUS "${msg}... yes")
      ELSE (${TEST}_RUN  MATCHES 0)
        SET (${TEST} "" CACHE INTERNAL ${msg})
        MESSAGE (STATUS "${msg}... no")
        FILE (APPEND ${CMAKE_BINARY_DIR}/CMakeFiles/CMakeError.log
              "Test ${TEST} Run failed with the following output and exit code:\n ${OUTPUT}\n"
        )
      ENDIF (${TEST}_RUN  MATCHES 0)
    ELSE (${TEST}_COMPILE )
      SET (${TEST} "" CACHE INTERNAL ${msg})
      MESSAGE (STATUS "${msg}... no")
      FILE (APPEND ${CMAKE_BINARY_DIR}/CMakeFiles/CMakeError.log
          "Test ${TEST} Compile failed with the following output:\n ${OUTPUT}\n"
      )
    ENDIF (${TEST}_COMPILE)

  ENDIF("${TEST}" MATCHES "^${TEST}$")
ENDMACRO (HDFConversionTests)

#-----------------------------------------------------------------------------
# Macro to make some of the conversion tests easier to write/read
#-----------------------------------------------------------------------------
MACRO (HDFMiscConversionTest  VAR TEST msg)
  IF ("${TEST}" MATCHES "^${TEST}$")
    IF (${VAR})
      SET (${TEST} 1 CACHE INTERNAL ${msg})
      MESSAGE (STATUS "${msg}... yes")
    ELSE (${VAR})
      SET (${TEST} "" CACHE INTERNAL ${msg})
      MESSAGE (STATUS "${msg}... no")
    ENDIF (${VAR})
  ENDIF ("${TEST}" MATCHES "^${TEST}$")
ENDMACRO (HDFMiscConversionTest)

#-----------------------------------------------------------------------------
# Check various conversion capabilities
#-----------------------------------------------------------------------------

# -----------------------------------------------------------------------
# Set flag to indicate that the machine can handle conversion from
# long double to integers accurately.  This flag should be set "yes" for
# all machines except all SGIs.  For SGIs, some conversions are
# incorrect and its cache value is set "no" in its config/irix6.x and
# irix5.x.
#
HDFMiscConversionTest (HDF_SIZEOF_LONG_DOUBLE HDF_LDOUBLE_TO_INTEGER_ACCURATE "checking IF converting from long double to integers is accurate")
# -----------------------------------------------------------------------
# Set flag to indicate that the machine can do conversion from
# long double to integers regardless of accuracy.  This flag should be
# set "yes" for all machines except HP-UX 11.00.  For HP-UX 11.00, the
# compiler has 'floating exception' when converting 'long double' to all
# integers except 'unsigned long long'.  Other HP-UX systems are unknown
# yet. (1/8/05 - SLU)
#
HDFConversionTests (HDF_LDOUBLE_TO_INTEGER_WORKS "Checking IF converting from long double to integers works")
# -----------------------------------------------------------------------
# Set flag to indicate that the machine can handle conversion from
# integers to long double.  (This flag should be set "yes" for all
# machines except all SGIs, where some conversions are
# incorrect and its cache value is set "no" in its config/irix6.x and
# irix5.x)
#
HDFMiscConversionTest (HDF_SIZEOF_LONG_DOUBLE HDF_INTEGER_TO_LDOUBLE_ACCURATE "checking IF accurately converting from integers to long double")
# ----------------------------------------------------------------------
# Set the flag to indicate that the machine can accurately convert
# 'unsigned long' to 'float' values.
# (This flag should be set for all machines, except for Pathscale compiler
# on Sandia's Linux machine where the compiler interprets 'unsigned long'
# values as negative when the first bit of 'unsigned long' is on during
# the conversion to float.)
#
HDFConversionTests (HDF_ULONG_TO_FLOAT_ACCURATE "Checking IF accurately converting unsigned long to float values")
# ----------------------------------------------------------------------
# Set the flag to indicate that the machine can accurately convert
# 'unsigned (long) long' values to 'float' and 'double' values.
# (This flag should be set for all machines, except for the SGIs, where
# the cache value is set in the config/irix6.x config file) and Solaris
# 64-bit machines, where the short program below tests if round-up is
# correctly handled.
#
HDFConversionTests (HDF_ULONG_TO_FP_BOTTOM_BIT_ACCURATE "Checking IF accurately converting unsigned long long to floating-point values")
# ----------------------------------------------------------------------
# Set the flag to indicate that the machine can accurately convert
# 'float' or 'double' to 'unsigned long long' values.
# (This flag should be set for all machines, except for PGI compiler
# where round-up happens when the fraction of float-point value is greater
# than 0.5.
#
HDFConversionTests (HDF_FP_TO_ULLONG_ACCURATE "Checking IF accurately roundup converting floating-point to unsigned long long values" )
# ----------------------------------------------------------------------
# Set the flag to indicate that the machine can accurately convert
# 'float', 'double' or 'long double' to 'unsigned long long' values.
# (This flag should be set for all machines, except for HP-UX machines
# where the maximal number for unsigned long long is 0x7fffffffffffffff
# during conversion.
#
HDFConversionTests (HDF_FP_TO_ULLONG_RIGHT_MAXIMUM "Checking IF right maximum converting floating-point to unsigned long long values" )
# ----------------------------------------------------------------------
# Set the flag to indicate that the machine can accurately convert
# 'long double' to 'unsigned int' values.  (This flag should be set for
# all machines, except for some Intel compilers on some Linux.)
#
HDFConversionTests (HDF_LDOUBLE_TO_UINT_ACCURATE "Checking IF correctly converting long double to unsigned int values")
# ----------------------------------------------------------------------
# Set the flag to indicate that the machine can _compile_
# 'unsigned long long' to 'float' and 'double' typecasts.
# (This flag should be set for all machines.)
#
IF (HDF_ULLONG_TO_FP_CAST_WORKS MATCHES ^HDF_ULLONG_TO_FP_CAST_WORKS$)
  SET (HDF_ULLONG_TO_FP_CAST_WORKS 1 CACHE INTERNAL "Checking IF compiling unsigned long long to floating-point typecasts work")
  MESSAGE (STATUS "Checking IF compiling unsigned long long to floating-point typecasts work... yes")
ENDIF (HDF_ULLONG_TO_FP_CAST_WORKS MATCHES ^HDF_ULLONG_TO_FP_CAST_WORKS$)
# ----------------------------------------------------------------------
# Set the flag to indicate that the machine can _compile_
# 'long long' to 'float' and 'double' typecasts.
# (This flag should be set for all machines.)
#
IF (HDF_LLONG_TO_FP_CAST_WORKS MATCHES ^HDF_LLONG_TO_FP_CAST_WORKS$)
  SET (HDF_LLONG_TO_FP_CAST_WORKS 1 CACHE INTERNAL "Checking IF compiling long long to floating-point typecasts work")
  MESSAGE (STATUS "Checking IF compiling long long to floating-point typecasts work... yes")
ENDIF (HDF_LLONG_TO_FP_CAST_WORKS MATCHES ^HDF_LLONG_TO_FP_CAST_WORKS$)
# ----------------------------------------------------------------------
# Set the flag to indicate that the machine can convert from
# 'unsigned long long' to 'long double' without precision loss.
# (This flag should be set for all machines, except for FreeBSD(sleipnir)
# where the last 2 bytes of mantissa are lost when compiler tries to do
# the conversion, and Cygwin where compiler doesn't do rounding correctly.)
#
HDFConversionTests (HDF_ULLONG_TO_LDOUBLE_PRECISION "Checking IF converting unsigned long long to long double with precision")
# ----------------------------------------------------------------------
# Set the flag to indicate that the machine can handle overflow converting
# all floating-point to all integer types.
# (This flag should be set for all machines, except for Cray X1 where
# floating exception is generated when the floating-point value is greater
# than the maximal integer value).
#
HDFConversionTests (HDF_FP_TO_INTEGER_OVERFLOW_WORKS  "Checking IF overflows normally converting floating-point to integer values")
# ----------------------------------------------------------------------
# Set the flag to indicate that the machine can accurately convert
# 'long double' to '(unsigned) long long' values.  (This flag should be set for
# all machines, except for Mac OS 10.4 and SGI IRIX64 6.5.  When the bit sequence
# of long double is 0x4351ccf385ebc8a0bfcc2a3c..., the values of (unsigned)long long
# start to go wrong on these two machines.  Adjusting it higher to
# 0x4351ccf385ebc8a0dfcc... or 0x4351ccf385ebc8a0ffcc... will make the converted
# values wildly wrong.  This test detects this wrong behavior and disable the test.
#
HDFConversionTests (HDF_LDOUBLE_TO_LLONG_ACCURATE "Checking IF correctly converting long double to (unsigned) long long values")
# ----------------------------------------------------------------------
# Set the flag to indicate that the machine can accurately convert
# '(unsigned) long long' to 'long double' values.  (This flag should be set for
# all machines, except for Mac OS 10.4, when the bit sequences are 003fff...,
# 007fff..., 00ffff..., 01ffff..., ..., 7fffff..., the converted values are twice
# as big as they should be.
#
HDFConversionTests (HDF_LLONG_TO_LDOUBLE_CORRECT "Checking IF correctly converting (unsigned) long long to long double values")
HDFConversionTests (HDF_NO_ALIGNMENT_RESTRICTIONS "Checking IF alignment restrictions are strictly enforced")

#-----------------------------------------------------------------------------
# These tests need to be manually SET for windows since there is currently
# something not quite correct with the actual test implementation. This affects
# the 'dt_arith' test and most likely lots of other code
# ----------------------------------------------------------------------------
IF (WINDOWS)
  SET (HDF_FP_TO_ULLONG_RIGHT_MAXIMUM "" CACHE INTERNAL "")
ENDIF (WINDOWS)
