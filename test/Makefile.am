#############################################################################
##                      Setup for building programs                        ##
#############################################################################

AM_CPPFLAGS=-I$(top_srcdir)/src -I$(top_srcdir)/test

#############################################################################
##                              Testing                                    ##
#############################################################################

TESTS = gentest
check_PROGRAMS = gentest

noinst_LTLIBRARIES = libmcgill.la
CSOURCES = mcgill.c
CHEADERS = mcgill.h
libmcgill_la_SOURCES = $(CSOURCES)
include_HEADERS = $(CHEADERS)

gentest_SOURCES = gentest.c 
gentest_LDADD = ./libmcgill.la ../src/libsz.la
gentest_DEPENDENCIES = ./libmcgill.la ../src/libsz.la

#############################################################################
##                          And the cleanup                                ##
#############################################################################

DISTCLEANFILES = 
