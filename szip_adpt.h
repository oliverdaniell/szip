/*
	H5api_adpt.h
	Used for the HDF5 dll project
	Created by Patrick Lu on 1/12/99
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
