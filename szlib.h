/* szlib.h -- defines, typedefs, and data structures for szlib API functions.
 *
 *   The attribution below is included because the szip API code is loosely
 *   based on that of zlib.
 *
 *   Copyright (C) 1995-1998 Jean-loup Gailly and Mark Adler
 *
 *   This software is provided 'as-is', without any express or implied
 *   warranty.  In no event will the authors be held liable for any damages
 *   arising from the use of this software.
 *
 *   Permission is granted to anyone to use this software for any purpose,
 *   including commercial applications, and to alter it and redistribute it
 *   freely, subject to the following restrictions:
 *
 *   1. The origin of this software must not be misrepresented; you must not
 *      claim that you wrote the original software. If you use this software
 *      in a product, an acknowledgment in the product documentation would be
 *      appreciated but is not required.
 *   2. Altered source versions must be plainly marked as such, and must not be
 *      misrepresented as being the original software.
 *   3. This notice may not be removed or altered from any source distribution.
 *
 *   Jean-loup Gailly        Mark Adler
 *   jloup@gzip.org          madler@alumni.caltech.edu
 *
 */

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
#ifndef _SZLIB_H
#define _SZLIB_H

#include "ricehdf.h"
#include "szip_adpt.h"

#define SZLIB_VERSION "1.0"

/*
   The application must update next_in and avail_in when avail_in has
   dropped to zero. It must update next_out and avail_out when avail_out
   has dropped to zero. The application must initialize zalloc, zfree and
   opaque before calling the init function. All other fields are set by the
   compression library and must not be updated by the application.

   The fields total_in and total_out can be used for statistics or
   progress reports. After compression, total_in holds the total size of
   the uncompressed data and may be saved for use in the decompressor
   (particularly if the decompressor wants to decompress everything in
   a single step).
*/

#define SZ_NULL  0

/*** API flush values ***/
#define SZ_NO_FLUSH      0
#define SZ_FINISH        4

/*** API state values ***/
#define SZ_INPUT_IMAGE   5
#define SZ_OUTPUT_IMAGE  6

/*** API return values ***/
#define SZ_OK			0
#define SZ_STREAM_END	1
#define SZ_OUTBUFF_FULL 2

#define SZ_STREAM_ERROR (-1)
#define SZ_MEM_ERROR    (-2)
#define SZ_INIT_ERROR   (-3)
#define SZ_PARAM_ERROR  (-4)

typedef struct sz_hidden_data_s
	{
	char *image_in;
	long avail_in;
	char *next_in;

	char *image_out;
	long avail_out;
	char *next_out;
	} sz_hidden_data; 

typedef struct sz_stream_s
	{
	char    		*next_in;  /* next input byte */
	unsigned int	avail_in;  /* number of bytes available at next_in */
	unsigned long	total_in;  /* total nb of input bytes read so far */

	char			*next_out; /* next output byte should be put there */
	unsigned int	avail_out; /* remaining free space at next_out */
	unsigned long	total_out; /* total nb of bytes output so far */

	char			*msg;
	int				state;

	void			*hidden;	/* this data hidden from user */

	int		options_mask;
	int		bits_per_pixel;
	int		pixels_per_block;
	int		pixels_per_scanline;
	long	image_pixels;
	} sz_stream;

typedef sz_stream *sz_streamp;

typedef struct SZ_com_t_s
	{
	int options_mask;
	int bits_per_pixel;
	int pixels_per_block;
	int pixels_per_scanline;
	} SZ_com_t;

__SZ_DLL__ int SZ_BufftoBuffCompress(void *dest, size_t *destLen, const void *source, size_t sourceLen, SZ_com_t *param);
__SZ_DLL__ int SZ_BufftoBuffDecompress(void *dest, size_t *destLen, const void *source, size_t sourceLen, SZ_com_t *param);

__SZ_DLL__ int SZ_DecompressInit(sz_stream *strm);
__SZ_DLL__ int SZ_Decompress(sz_stream *strm, int flush);
__SZ_DLL__ int SZ_DecompressEnd(sz_stream *strm);

__SZ_DLL__ int SZ_CompressInit(sz_stream *strm);
__SZ_DLL__ int SZ_Compress(sz_stream *strm, int flush);
__SZ_DLL__ int SZ_CompressEnd(sz_stream *strm);

#endif /* _SZLIB_H */
