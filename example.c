/* example.c -- usage example of the zlib compression library
 * Copyright (C) 1995-1998 Jean-loup Gailly.
 * For conditions of distribution and use, see copyright notice in zlib.h 
 */

/* @(#) $Id$ */

#include <stdio.h>
#include "szlib.h"

#ifdef STDC
#  include <string.h>
#  include <stdlib.h>
#else
   extern void exit  OF((int));
#endif

#define CHECK_ERR(err, msg) { \
    if (err != SZ_OK) { \
        fprintf(stderr, "%s error: %d\n", msg, err); \
        exit(1); \
    } \
}

#if 0
const char hello[] = "AAAAAAAAAAAAAAAA";
#endif

const char hello[] = "A 16 byte line!!";

int  main               OF((int argc, char *argv[]));

char *image_in;
char *image_in2;
char *image_out;

long
read_image(file_name)
char *file_name;
{
	FILE *fp;
	int n;
	long size;

	if ((fp = fopen(file_name, "r")) == 0)
		{
		fprintf(stderr, "Could not open input file: %s\n", file_name);
		exit(1);
		}

	size = 0;
	while (1)
		{
		n = fread(image_in+size, 1, 16*1024, fp);
		if (n == 0)
			break;

		size += n;
		}

	fprintf(stderr, "read_image(%s): size=%ld\n", file_name, size);
	fclose(fp);

	return size;
}

/* ===========================================================================
 * Test deflate() with small buffers
 */
long
test_deflate(in, size, out, buffer_size)
char *in;
long size;
char *out;
long buffer_size;
{
    sz_stream c_stream; /* compression stream */
    int err;
    int len;

#if 0
    c_stream.szalloc = (alloc_func)0;
    c_stream.szfree = (free_func)0;
#endif
    c_stream.hidden = (voidpf)0;

	c_stream.options_mask = SZ_RAW_OPTION_MASK | SZ_NN_OPTION_MASK;
	c_stream.bits_per_pixel = 8;
	c_stream.pixels_per_block = 8;
	c_stream.pixels_per_scanline = 16;

	c_stream.image_pixels = size;

	len = size;

    c_stream.next_in  = (Bytef*) image_in;
	c_stream.total_in = 0;

    c_stream.next_out = out;
	c_stream.total_out = 0;

    err = SZ_CompressInit(&c_stream);
    CHECK_ERR(err, "CompressInit");

    while (c_stream.total_in < (uLong)len)
		{
        c_stream.avail_in = c_stream.avail_out = buffer_size; /* force small buffers */
		if (c_stream.avail_in + c_stream.total_in > len)
			c_stream.avail_in = len - c_stream.total_in;

        err = SZ_Compress(&c_stream, SZ_NO_FLUSH);
        CHECK_ERR(err, "SZ_Compress");
    	}

    /* Finish the stream, still forcing small buffers: */
    for (;;)
		{
        c_stream.avail_out = buffer_size;
        err = SZ_Compress(&c_stream, SZ_FINISH);
#if 0
		printf("output byte=%02X\n", c_stream.next_out[-1]);
#endif
        if (err == SZ_STREAM_END)
			break;

        CHECK_ERR(err, "SZ_Compress");
	    }

    err = SZ_CompressEnd(&c_stream);
    CHECK_ERR(err, "SZ_CompressEnd");

	{
	int i;

	if (c_stream.total_out < 30)
		{
		printf("total_out=%ld\n", c_stream.total_out);
		for (i = 0; i < c_stream.total_out; i++)
			printf("%02X", out[i]);

		printf("\n");
		}
	}

	return c_stream.total_out;
}

/* ===========================================================================
 * Test inflate() with small buffers
 */
long
test_inflate(in, size, out, out_size, buffer_size)
char *in;
long size;
char *out;
long out_size;
long buffer_size;
{
    int err;
    sz_stream d_stream; /* decompression stream */

    strcpy((char*)out, "garbage");

#if 0
    d_stream.zalloc = (alloc_func)0;
    d_stream.zfree = (free_func)0;
#endif
    d_stream.hidden = (voidpf)0;

    d_stream.next_in  = in;
    d_stream.next_out = out;

    d_stream.avail_in = 0;
    d_stream.avail_out = 0;

	d_stream.total_in = 0;
	d_stream.total_out = 0;

	d_stream.options_mask = SZ_RAW_OPTION_MASK | SZ_NN_OPTION_MASK;
	d_stream.bits_per_pixel = 8;
	d_stream.pixels_per_block = 8;
	d_stream.pixels_per_scanline = 16;

	d_stream.image_pixels = out_size;

    err = SZ_DecompressInit(&d_stream);
    CHECK_ERR(err, "SZ_DecompressInit");

    while (d_stream.total_in < size)
		{
        d_stream.avail_in = d_stream.avail_out = buffer_size; /* force small buffers */
		if (d_stream.avail_in + d_stream.total_in > size)
			d_stream.avail_in = size - d_stream.total_in;

        err = SZ_Decompress(&d_stream, SZ_NO_FLUSH);
        if (err == SZ_STREAM_END)
			break;
        CHECK_ERR(err, "SZ_Decompress");
    	}

    while (d_stream.total_out < out_size)
		{
        d_stream.avail_out = buffer_size; /* force small buffers */
		err = SZ_Decompress(&d_stream, SZ_FINISH);
		if (err == SZ_STREAM_END)
			break;
		CHECK_ERR(err, "SZ_Decompress");
		}

    err = SZ_DecompressEnd(&d_stream);
    CHECK_ERR(err, "SZ_DecompressEnd");

	return d_stream.total_out;
}

/* ===========================================================================
 * Usage:  example [output.gz  [input.gz]]
 */

int main(argc, argv)
    int argc;
    char *argv[];
{
    Byte *compr, *uncompr;
    uLong comprLen = 10000*sizeof(int); /* don't overflow on MSDOS */
    uLong uncomprLen = comprLen;
    static const char* myVersion = SZLIB_VERSION;
	size_t size;
	size_t size2;
	size_t image_size;
	int rv;
	int i;
	SZ_com_t params;

#if 0
    if (zlibVersion()[0] != myVersion[0]) {
        fprintf(stderr, "incompatible zlib version\n");
        exit(1);

    } else if (strcmp(zlibVersion(), ZLIB_VERSION) != 0) {
        fprintf(stderr, "warning: different zlib version\n");
    }
#endif

    compr    = (Byte*)calloc((uInt)comprLen, 1);
    uncompr  = (Byte*)calloc((uInt)uncomprLen, 1);
    /* compr and uncompr are cleared to avoid reading uninitialized
     * data and to ensure that uncompr compresses well.
     */
    if (compr == SZ_NULL || uncompr == SZ_NULL) {
        printf("out of memory\n");
	exit(1);
    }
#if 0
    test_compress(compr, comprLen, uncompr, uncomprLen);

    test_gzio((argc > 1 ? argv[1] : TESTFILE),
              (argc > 2 ? argv[2] : TESTFILE),
	      uncompr, (int)uncomprLen);
#endif

	image_in   = (char *) malloc(1024*1024);
	image_out  = (char *) malloc(1024*1024);
	image_in2 = (char *) malloc(1024*1024);

	strcpy(image_out, "Junk!!!");
	strcpy(image_in2, "Junk!!!");

	image_size = read_image("image.in", image_in);

	for (i = 1; i < 1025; i <<= 1)
		{
		strcpy(image_out, "Junk!!!");
		strcpy(image_in2, "Junk!!!");

		printf("buffer_size=%d\n", i);

	    size = test_deflate(image_in, image_size, image_out, i);
		size = test_inflate(image_out, size, image_in2, image_size, i);
#if 0
		image_in2[1111] ^= 0x44;
#endif
		rv = memcmp(image_in, image_in2, image_size);
		printf("memcmp(image_in, image_in2, %d) = %d\n", image_size, rv);
		if (rv)
			exit(1);

		params.options_mask = SZ_RAW_OPTION_MASK | SZ_NN_OPTION_MASK;
		params.bits_per_pixel = 8;
		params.pixels_per_block = 8;
		params.pixels_per_scanline = 16;
		
		size = 1024*1024;
#if 0
		size = 8000;
#endif
                printf("Image size %ld \n", image_size);
		rv = SZ_BufftoBuffCompress(image_out, &size, image_in, image_size, &params); 
		printf("SZ_bufftoBuffCompress()\n");
		if (rv != SZ_OK)
			{
			fprintf(stderr, "SZ_BufftoBuffCompress fails\n");
			exit(1);
			}

		size2 = 1024*1024;
#if 0
		size2 = 14000;
#endif
		rv = SZ_BufftoBuffDecompress(image_in2, &size2, image_out, size, &params); 
		printf("SZ_bufftoBuffDecompress()\n");
		if (rv != SZ_OK)
			{
			fprintf(stderr, "SZ_BufftoBuffDecompress fails\n");
			exit(1);
			}

		rv = memcmp(image_in, image_in2, image_size);
		printf("memcmp(image_in, image_in2, %d) = %d\n", image_size, rv);
		if (rv)
			exit(1);
		}

    return 0; /* to avoid warning */
}
