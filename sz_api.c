#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "szlib.h"

#define SZ_MAX_PIXELS_PER_BLOCK 32
#define SZ_MAX_PIXELS_PER_SCANLINE 2048
#define SZ_RAW_OPTION_MASK 128

long szip_compress_memory(
	int options_mask,
	int bits_per_pixel,
	int pixels_per_block,
	int pixels_per_scanline,
	const void *in,
	long pixels,
	char *out);

long szip_uncompress_memory(
	int new_options_mask,
	int new_bits_per_pixel,
	int new_pixels_per_block,
	int new_pixels_per_scanline, 
	const char *in,
	long in_bytes,
	void *out,
	long out_pixels);

#if 0
#define FAR
#define Bytef char *
#define uInt unsigned int
#define uLong unsigned long
#define SZ_NULL 0
typedef void FAR *voidpf;
#define OF(args)  args

typedef voidpf (*alloc_func) OF((voidpf opaque, uInt items, uInt size));
typedef void   (*free_func)  OF((voidpf opaque, voidpf address));
voidpf zcalloc OF((voidpf opaque, unsigned items, unsigned size));
void   zcfree  OF((voidpf opaque, voidpf ptr));
#endif

int
SZ_check_params(bits_per_pixel, pixels_per_block, pixels_per_scanline, image_pixels, msg)
int bits_per_pixel;
int pixels_per_block;
int pixels_per_scanline;
long image_pixels;
char **msg;
{
	if (bits_per_pixel >= 1 && bits_per_pixel <= 24)
		;
	else if (bits_per_pixel == 32 || bits_per_pixel == 64)
		;
	else
		{
		*msg = "bits per pixel must be in range 1..24,32,64";
		return 0;
		}

	if (pixels_per_block > SZ_MAX_PIXELS_PER_BLOCK)	
		{
		*msg = "maximum pixels per block exceeded";
		return 0;
		}

	if (pixels_per_block > pixels_per_scanline)
		{
		*msg = "pixels per block > pixels per scanline";
		return 0;
		}

	if (pixels_per_scanline > SZ_MAX_PIXELS_PER_SCANLINE)
		{
		*msg = "maximum pixels per scanline exceeded";
		return 0;
		}

	if (image_pixels < pixels_per_scanline)
		{
		*msg = "image pixels less than pixels per scanline";
		return 0;
		}

	return 1;
}

int
SZ_CompressInit(sz_stream *strm)
{
	int rv;

	if (strm == SZ_NULL)
		return SZ_STREAM_ERROR; 

	strm->hidden = (voidpf) 0;
	strm->msg = SZ_NULL;

#if 0
	if (strm->szalloc == SZ_NULL)
		{
		strm->szalloc = szalloc;
		strm->hidden = (voidpf) 0;
		}
#endif

#if 0
	if (strm->szfree == SZ_NULL)
		strm->szfree = szfree;
#endif

	strm->state = SZ_INPUT_IMAGE;

	if (strm->hidden == SZ_NULL)
		{
		strm->hidden = (sz_hidden_data *) malloc(sizeof(sz_hidden_data));
		if (strm->hidden == SZ_NULL)
			return SZ_MEM_ERROR;

		memset(strm->hidden, 0, sizeof(sz_hidden_data));
		}

	rv = SZ_check_params(strm->bits_per_pixel, strm->pixels_per_block, strm->pixels_per_scanline, strm->image_pixels, &strm->msg);
	if (rv == 0)
		return SZ_INIT_ERROR;

	return SZ_OK;
}

int
SZ_Compress(sz_stream *strm, int flush)
{
	sz_stream *sz;
	sz_hidden_data *hidden;
	int bytes_per_pixel;
	long image_size;
	long size_in;
	long size_out;
	long output_bytes;

	if (strm == SZ_NULL || strm->next_in == SZ_NULL)
		return SZ_STREAM_ERROR;

	bytes_per_pixel = (strm->bits_per_pixel+7) >> 3;
#if 0
	if (strm->avail_in < strm->image_pixels * bytes_per_pixel)
		{
		strm->msg = "avail_in number of bytes to small for image size";
		return SZ_STREAM_ERROR;
		}
#endif

	hidden = (sz_hidden_data *) strm->hidden;
	if (hidden->image_in == SZ_NULL)
		{
		image_size = strm->image_pixels * bytes_per_pixel;
		hidden->image_in = (char *) malloc(image_size);
		hidden->next_in = hidden->image_in;
		hidden->avail_in = image_size;
		}

	if (hidden->image_out == SZ_NULL)
		{
		image_size = strm->image_pixels * bytes_per_pixel * 1.25;
		hidden->image_out = (char *) malloc(image_size);
		hidden->next_out = hidden->image_out;
		hidden->avail_out = 0;
		}

	if (strm->state == SZ_INPUT_IMAGE)
		{
		/*** store input data in buffer ***/
		size_in = hidden->avail_in < strm->avail_in ? hidden->avail_in : strm->avail_in;
		memcpy(hidden->next_in, strm->next_in, size_in);
		hidden->next_in += size_in;
		hidden->avail_in -= size_in;

		strm->next_in += size_in;
		strm->avail_in -= size_in;
		strm->total_in += size_in;

		if (hidden->avail_in == 0)
			{
			sz = strm;
			output_bytes = szip_compress_memory(sz->options_mask, sz->bits_per_pixel, sz->pixels_per_block, sz->pixels_per_scanline, hidden->image_in, sz->image_pixels, hidden->image_out);
			printf("compress_memory: output_bytes=%ld\n", output_bytes);
			hidden->avail_out = output_bytes;
			sz->state = SZ_OUTPUT_IMAGE;
			if (flush == SZ_NO_FLUSH)
				return SZ_OK;
			}
		}

	if (strm->state == SZ_OUTPUT_IMAGE)
		{
		/*** read output data in buffer ***/
		size_out = hidden->avail_out < strm->avail_out ? hidden->avail_out : strm->avail_out;
		memcpy(strm->next_out, hidden->next_out, size_out);
		hidden->next_out += size_out;
		hidden->avail_out -= size_out;

		strm->next_out += size_out;
		strm->avail_out -= size_out;
		strm->total_out += size_out;

		if (hidden->avail_out == 0)
			strm->state = SZ_FINISH;
		}

	if (strm->state == SZ_FINISH)
		return SZ_STREAM_END;

	return SZ_OK;
}

int
SZ_CompressEnd(sz_stream *strm)
{
	sz_hidden_data *hidden;

	if (strm == SZ_NULL)
		return SZ_STREAM_ERROR;

	strm->avail_in = 0;
	strm->avail_out = 0;

	strm->next_in = 0;
	strm->next_out = 0;
	if (strm->hidden)
		{
		hidden = strm->hidden;
		if (hidden->image_in)
			{
			free(hidden->image_in);
			hidden->image_in = 0;
			}

		if (hidden->image_out)
			{
			free(hidden->image_out);
			hidden->image_out = 0;
			}
		}

	strm->state = SZ_FINISH;

	return SZ_OK;
}

int
SZ_DecompressInit(sz_stream *strm)
{
	int rv;

	if (strm == SZ_NULL)
		return SZ_STREAM_ERROR; 

	strm->msg = SZ_NULL;
	strm->hidden = (voidpf) 0;
#if 0
	if (strm->szalloc == SZ_NULL)
		{
		strm->szalloc = zcalloc;
		strm->hidden = (voidpf) 0;
		}
#endif

#if 0
	if (strm->szfree == SZ_NULL)
		strm->szfree = szfree;
#endif

	strm->state = SZ_INPUT_IMAGE;

	if (strm->hidden == SZ_NULL)
		{
		strm->hidden = (sz_hidden_data *) malloc(sizeof(sz_hidden_data));
		if (strm->hidden == SZ_NULL)
			return SZ_MEM_ERROR;

		memset(strm->hidden, 0, sizeof(sz_hidden_data));
		}

	rv = SZ_check_params(strm->bits_per_pixel, strm->pixels_per_block, strm->pixels_per_scanline, strm->image_pixels, &strm->msg);
	if (rv == 0)
		return SZ_INIT_ERROR;

	return SZ_OK;
}

int
SZ_Decompress(sz_stream *strm, int flush)
{
	sz_stream *sz;
	sz_hidden_data *hidden;
	int bytes_per_pixel;
	long image_size;
	long size_in;
	long size_out;
	long output_bytes;

	if (strm == SZ_NULL || strm->next_out == SZ_NULL)
		return SZ_STREAM_ERROR;

	bytes_per_pixel = (strm->bits_per_pixel+7) >> 3;
#if 0
	if (strm->avail_in < strm->image_pixels * bytes_per_pixel)
		{
		strm->msg = "avail_in number of bytes to small for image size";
		return SZ_STREAM_ERROR;
		}
#endif

	hidden = (sz_hidden_data *) strm->hidden;
	if (hidden->image_in == SZ_NULL)
		{
		image_size = strm->image_pixels * bytes_per_pixel * 1.25;
		hidden->image_in = (char *) malloc(image_size);
		hidden->next_in = hidden->image_in;
		hidden->avail_in = image_size * 1.25;
		}

	if (hidden->image_out == SZ_NULL)
		{
		image_size = strm->image_pixels * bytes_per_pixel * 1.0;
		hidden->image_out = (char *) malloc(image_size);
		hidden->next_out = hidden->image_out;
		hidden->avail_out = 0;
		}

	if (strm->state == SZ_INPUT_IMAGE)
		{
		/*** store input data in buffer ***/
		size_in = hidden->avail_in < strm->avail_in ? hidden->avail_in : strm->avail_in;
		memcpy(hidden->next_in, strm->next_in, size_in);
		hidden->next_in += size_in;
		hidden->avail_in -= size_in;

		strm->next_in += size_in;
		strm->avail_in -= size_in;
		strm->total_in += size_in;

		if (hidden->avail_in == 0 || flush == SZ_FINISH)
			{
			sz = strm;
			size_in = hidden->next_in - hidden->image_in;
			output_bytes = szip_uncompress_memory(sz->options_mask, sz->bits_per_pixel, sz->pixels_per_block, sz->pixels_per_scanline, hidden->image_in, size_in, hidden->image_out, strm->image_pixels);
			hidden->avail_out = output_bytes;
			sz->state = SZ_OUTPUT_IMAGE;
			}
		}

	if (strm->state == SZ_OUTPUT_IMAGE)
		{
		/*** read output data in buffer ***/
		size_out = hidden->avail_out < strm->avail_out ? hidden->avail_out : strm->avail_out;
		memcpy(strm->next_out, hidden->next_out, size_out);
		hidden->next_out += size_out;
		hidden->avail_out -= size_out;

		strm->next_out += size_out;
		strm->avail_out -= size_out;
		strm->total_out += size_out;

		if (hidden->avail_out == 0)
			strm->state = SZ_FINISH;
		}

	if (strm->state == SZ_FINISH)
		return SZ_STREAM_END;

	return SZ_OK;
}

int
SZ_DecompressEnd(sz_stream *strm)
{
	sz_hidden_data *hidden;

	if (strm == SZ_NULL)
		return SZ_STREAM_ERROR;

	strm->avail_in = 0;
	strm->avail_out = 0;

	strm->next_in = 0;
	strm->next_out = 0;
	if (strm->hidden)
		{
		hidden = strm->hidden;
		if (hidden->image_in)
			{
			free(hidden->image_in);
			hidden->image_in = 0;
			}

		if (hidden->image_out)
			{
			free(hidden->image_out);
			hidden->image_out = 0;
			}
		}

	strm->state = SZ_FINISH;

	return SZ_OK;
}

#define SZ_OUTBUFF_FULL 1
#define SZ_PARAM_ERROR  2

extern int szip_output_buffer_full;

static SZ_com_t sz_default_param = { SZ_RAW_OPTION_MASK, 8, 16, 256 };

int
SZ_BufftoBuffCompress(void *dest, size_t *destLen, const void *source, size_t sourceLen, SZ_com_t *param)
{
	SZ_com_t *sz;
	char *image_out;
	char *msg;
	int bytes_per_pixel;
	int rv;
	long out_size;
	long pixels;
	long output_bytes;

	sz = param;
	if (sz == 0)
		sz = &sz_default_param;

	rv = SZ_check_params(sz->bits_per_pixel, sz->pixels_per_block, sz->pixels_per_scanline, sz->pixels_per_scanline, &msg);
	if (rv == 0)
		return SZ_PARAM_ERROR;

	bytes_per_pixel = (sz->bits_per_pixel+7) >> 3;
	pixels = (sourceLen+bytes_per_pixel-1)/bytes_per_pixel;
	out_size = sourceLen * 1.25;

	if (*destLen >= out_size)
		image_out = dest;
	else
		{
		image_out = (char *) malloc(out_size);
		if (image_out == 0)
			return SZ_MEM_ERROR;
		}

	output_bytes = szip_compress_memory(sz->options_mask, sz->bits_per_pixel, sz->pixels_per_block, sz->pixels_per_scanline, source, pixels, image_out);
	rv = SZ_OK;
	if (*destLen >= output_bytes)
		*destLen = output_bytes;
	else
		rv = SZ_OUTBUFF_FULL;

	if (image_out != dest)
		memcpy(dest, image_out, *destLen);

	return rv;
}

int
SZ_BufftoBuffDecompress(void *dest, size_t *destLen, const void *source, size_t sourceLen, SZ_com_t *param)
{
	SZ_com_t *sz;
	char *msg;
	int bytes_per_pixel;
	int rv;
	long pixels;
	long output_bytes;

	sz = param;
	if (sz == 0)
		sz = &sz_default_param;

	rv = SZ_check_params(sz->bits_per_pixel, sz->pixels_per_block, sz->pixels_per_scanline, sz->pixels_per_scanline, &msg);
	if (rv == 0)
		return SZ_PARAM_ERROR;

	bytes_per_pixel = (sz->bits_per_pixel+7) >> 3;
	pixels = *destLen/bytes_per_pixel;

	output_bytes = szip_uncompress_memory(sz->options_mask, sz->bits_per_pixel, sz->pixels_per_block, sz->pixels_per_scanline, source, sourceLen, dest, pixels);

	rv = SZ_OK;
	if (szip_output_buffer_full)
		rv = SZ_OUTBUFF_FULL;
	else
		*destLen = output_bytes;

	return rv;
}
