#############################################################################
##                          Library to build                               ##
#############################################################################

lib_LTLIBRARIES = libsz.la

CSOURCES = rice.c sz_api.c encoding.c

CHEADERS =  rice.h ricehdf.h szip_adpt.h szlib.h

libsz_la_SOURCES = $(CSOURCES)
libsz_la_LDFLAGS = -version-info 1:2:1
include_HEADERS = $(CHEADERS)


