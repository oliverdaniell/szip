/*==============================================================================
The SZIP Science Data Lossless Compression Program is Copyright (C) 2001
Science & Technology Corporation @ UNM.  All rights released and licensed
to ICs Corp. for distribution  by the University of Illinois' National 
Center for Supercomputing Applications as a part of the HDF data storage 
and retrieval file format and software library products package. All 
rights reserved.  Do not modify or use for other purposes.

SZIP implements an extended Rice adaptive lossless compression algorithm
for sample data.  The primary algorithm was developed by R. F. Rice at
Jet Propulsion Laboratory.  

SZIP embodies certain inventions patented by the National Aeronautics &
Space Administration.  United States Patent Nos. 5,448,642, 5,687,255,
and 5,822,457 have been licensed to ICs Corp. for distribution with the
HDF data storage and retrieval file format and software library products.
All rights reserved.

Revocable, royalty-free, nonexclusive sublicense to use SZIP decompression
software routines and underlying patents is hereby granted by ICs Corp. to 
all users of and in conjunction with HDF data storage and retrieval file 
format and software library products.

Revocable, royalty-free, nonexclusive sublicense to use SZIP compression
software routines and underlying patents for non-commercial, scientific use
only is hereby granted by ICs Corp. to users of and in conjunction with HDF 
data storage and retrieval file format and software library products.

For commercial use license to SZIP compression software routines and underlying 
patents please contact ICs Corp. at ICs Corp., 721 Lochsa Street, Suite 8,
Post Falls, ID 83854.  (208) 262-2008.

==============================================================================*/
/*
	H5api_adpt.h
	Used for the HDF5 dll project
*/
#ifndef SZAPI_ADPT_H
#define SZAPI_ADPT_H

#if defined(WIN32)
#if defined(_SZDLL_)
#pragma warning(disable: 4273)	/* Disable the dll linkage warnings */
#define __SZ_DLL__ __declspec(dllexport)
/*#define __DLLVARH425__ __declspec(dllexport)*/
#elif defined(_SZUSEDLL_)
#define __SZ_DLL__ __declspec(dllimport)
/*#define __DLLVARH425__ __declspec(dllimport)*/
#else
#define __SZ_DLL__
/*#define __DLLVARH425__ extern*/
#endif /* _SZDLL_ */

#else /*WIN32*/
#define __SZ_DLL__
/*#define __DLLVAR__ extern*/
#endif

#endif /* H5API_ADPT_H */
