#############################################################################
##                      Setup for building programs                        ##
#############################################################################

AM_CPPFLAGS=-I$(top_srcdir)/src -I$(top_srcdir)/test

#############################################################################
##                              Testing                                    ##
#############################################################################

TESTS = gentest
check_PROGRAMS = gentest

lib_LIBRARIES = libmcgill.a
CSOURCES = mcgill.c
CHEADERS = mcgill.h
libmcgill_a_SOURCES = $(CSOURCES)
include_HEADERS = $(CHEADERS)

gentest_SOURCES = gentest.c 
gentest_LDADD = ./libmcgill.a ../src/libsz.a
gentest_DEPENDENCIES = ./libmcgill.a ../src/libsz.a

#############################################################################
##                          And the cleanup                                ##
#############################################################################

DISTCLEANFILES = 
