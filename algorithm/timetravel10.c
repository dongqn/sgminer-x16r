/*-
* Copyright 2009 Colin Percival, 2011 ArtForz
* All rights reserved.
*
* Redistribution and use in source and binary forms, with or without
* modification, are permitted provided that the following conditions
* are met:
* 1. Redistributions of source code must retain the above copyright
*    notice, this list of conditions and the following disclaimer.
* 2. Redistributions in binary form must reproduce the above copyright
*    notice, this list of conditions and the following disclaimer in the
*    documentation and/or other materials provided with the distribution.
*
* THIS SOFTWARE IS PROVIDED BY THE AUTHOR AND CONTRIBUTORS ``AS IS'' AND
* ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
* IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
* ARE DISCLAIMED.  IN NO EVENT SHALL THE AUTHOR OR CONTRIBUTORS BE LIABLE
* FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
* DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS
* OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION)
* HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT
* LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY
* OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF
* SUCH DAMAGE.
*
* This file was originally written by Colin Percival as part of the Tarsnap
* online backup system.
*/

#include "config.h"
#include "miner.h"

#include <stdlib.h>
#include <stdint.h>
#include <string.h>
//#include <algorithm.h>

#include "sph/sph_blake.h"
#include "sph/sph_bmw.h"
#include "sph/sph_groestl.h"
#include "sph/sph_jh.h"
#include "sph/sph_keccak.h"
#include "sph/sph_skein.h"
#include "sph/sph_luffa.h"
#include "sph/sph_cubehash.h"
#include "sph/sph_shavite.h"
#include "sph/sph_simd.h"
#include "sph/sph_echo.h"

#define INITIAL_DATE 1492973331
#define HASH_FUNC_COUNT 10
#define HASH_FUNC_COUNT_PERMUTATIONS 40320
#define DEFAULT_NTIME "00000000"


/* Move init out of loop, so init once externally, and then use one single memcpy with that bigger memory block */
typedef struct {
	sph_blake512_context    blake1;
	sph_bmw512_context      bmw1;
	sph_groestl512_context  groestl1;
	sph_skein512_context    skein1;
	sph_jh512_context       jh1;
	sph_keccak512_context   keccak1;
	sph_luffa512_context    luffa1;
	sph_cubehash512_context cubehash1;
	sph_shavite512_context  shavite1;
	sph_simd512_context     simd1;
	sph_echo512_context     echo1;
} Xhash_context_holder;

static Xhash_context_holder base_contexts;


static void init_Xhash_contexts()
{
	sph_blake512_init(&base_contexts.blake1);
	sph_bmw512_init(&base_contexts.bmw1);
	sph_groestl512_init(&base_contexts.groestl1);
	sph_skein512_init(&base_contexts.skein1);
	sph_jh512_init(&base_contexts.jh1);
	sph_keccak512_init(&base_contexts.keccak1);
	sph_luffa512_init(&base_contexts.luffa1);
	sph_cubehash512_init(&base_contexts.cubehash1);
	sph_shavite512_init(&base_contexts.shavite1);
	sph_simd512_init(&base_contexts.simd1);
	sph_echo512_init(&base_contexts.echo1);
}


static uint32_t getCurrentAlgoSeq(uint32_t current_time, uint32_t base_time) {
	return (current_time - base_time) % HASH_FUNC_COUNT_PERMUTATIONS;
}

static void swap(uint8_t *a, uint8_t *b) {
	uint8_t __tmp = *a;
	*a = *b;
	*b = __tmp;
}

static void initPerm(uint8_t n[], uint8_t count) {
	int i;
	for (i = 0; i<count; i++)
		n[i] = i;
}

static int nextPerm(uint8_t n[], uint32_t count) {
	uint32_t tail, i, j;

	if (count <= 1)
		return 0;

	for (i = count - 1; i>0 && n[i - 1] >= n[i]; i--);
	tail = i;

	if (tail > 0) {
		for (j = count - 1; j>tail && n[j] <= n[tail - 1]; j--);
		swap(&n[tail - 1], &n[j]);
	}

	for (i = tail, j = count - 1; i<j; i++, j--)
		swap(&n[i], &n[j]);

	return (tail != 0);
}


static void getAlgoString(char *str, uint32_t count)
{
	uint8_t algoList[HASH_FUNC_COUNT];
	char s[100];
	char *sptr;

	initPerm(algoList, HASH_FUNC_COUNT);

	int j;

	int k;
	for (k = 0; k < count; k++) {
		nextPerm(algoList, HASH_FUNC_COUNT);
	}

	sptr = str;
	for (j = 0; j < HASH_FUNC_COUNT; j++) {
		if (algoList[j] >= 10)
			sprintf(sptr, "%c", 'A' + (algoList[j] - 10));
		else
			sprintf(sptr, "%u", algoList[j]);
		sptr++;
	}
	*sptr = 0;
}


void timetravel10_twisted_code(char *result, const char *ntime, char *code)
{
	unsigned char bin[4];
	uint32_t h32, *be32 = (uint32_t *)bin;
	hex2bin(bin, ntime, 4);
	h32 = be32toh(*be32);
	uint32_t count = getCurrentAlgoSeq(h32, INITIAL_DATE);
	getAlgoString(code, count);
	sprintf(result, "_%d_%s_", count, code);
}

/*
* Encode a length len/4 vector of (uint32_t) into a length len vector of
* (unsigned char) in big-endian form.  Assumes len is a multiple of 4.
*/
static inline void
be32enc_vect(uint32_t *dst, const uint32_t *src, uint32_t len)
{
	uint32_t i;

	for (i = 0; i < len; i++)
		dst[i] = htobe32(src[i]);
}


static inline void xhash(void *state, const void *input , const char* ntime)
{
	init_Xhash_contexts();

	Xhash_context_holder ctx;

	uint32_t hashA[16], hashB[16];
	memcpy(&ctx, &base_contexts, sizeof(base_contexts));
	
	char completeCode[64];
	char resultCode[HASH_FUNC_COUNT + 1];
	timetravel10_twisted_code(completeCode, ntime, resultCode);

	int i;
	const void *in;
	void *out;


	for (i = 0; i < strlen(resultCode); i++) {
		char elem = resultCode[i];
		uint8_t idx;
		if (elem >= 'A')
			idx = elem - 'A' + 10;
		else
			idx = elem - '0';

		int size;

		if (i == 0) {
			in = input;
			size = 80;
			out = hashA;
		}
		else {
			if (out == hashA) {
				in = hashA;
				out = hashB;
			}
			else {
				in = hashB;
				out = hashA;
			}
			size = 64;
		}

		switch (idx) {
		case 0:
			sph_blake512(&ctx.blake1, in, size);
			sph_blake512_close(&ctx.blake1, out);
			break;
		case 1:
			sph_bmw512(&ctx.bmw1, in, size);
			sph_bmw512_close(&ctx.bmw1, out);
			break;
		case 2:
			sph_groestl512(&ctx.groestl1, in, size);
			sph_groestl512_close(&ctx.groestl1, out);
			break;
		case 3:
			sph_skein512(&ctx.skein1, in, size);
			sph_skein512_close(&ctx.skein1, out);
			break;
		case 4:
			sph_jh512(&ctx.jh1, in, size);
			sph_jh512_close(&ctx.jh1, out);
			break;
		case 5:
			sph_keccak512(&ctx.keccak1, in, size);
			sph_keccak512_close(&ctx.keccak1, out);
			break;
		case 6:
			sph_luffa512(&ctx.luffa1, in, size);
			sph_luffa512_close(&ctx.luffa1, out);
			break;
		case 7:
			sph_cubehash512(&ctx.cubehash1, in, size);
			sph_cubehash512_close(&ctx.cubehash1, out);
			break;
		case 8:
			sph_shavite512(&ctx.shavite1, in, size);
			sph_shavite512_close(&ctx.shavite1, out);
			break;
		case 9:
			sph_simd512(&ctx.simd1, in, size);
			sph_simd512_close(&ctx.simd1, out);
			break;
		case 10:
			sph_echo512(&ctx.echo1, in, size);
			sph_echo512_close(&ctx.echo1, out);
			break;
		}
	}

	memcpy(state, out, 32);
}

static const uint32_t diff1targ = 0x0000ffff;


/* Used externally as confirmation of correct OCL code */
int timetravel10_test(unsigned char *pdata, const unsigned char *ptarget, uint32_t nonce)
{
	uint32_t tmp_hash7, Htarg = le32toh(((const uint32_t *)ptarget)[7]);
	uint32_t data[20], ohash[8];

	be32enc_vect(data, (const uint32_t *)pdata, 19);
	data[19] = htobe32(nonce);
	xhash(ohash, data, DEFAULT_NTIME);
	tmp_hash7 = be32toh(ohash[7]);

	applog(LOG_DEBUG, "htarget %08lx diff1 %08lx hash %08lx",
		(long unsigned int)Htarg,
		(long unsigned int)diff1targ,
		(long unsigned int)tmp_hash7);
	if (tmp_hash7 > diff1targ)
		return -1;
	if (tmp_hash7 > Htarg)
		return 0;
	return 1;
}

void timetravel10_regenhash(struct work *work)
{
	uint32_t data[20];
	uint32_t *nonce = (uint32_t *)(work->data + 76);
	uint32_t *ohash = (uint32_t *)(work->hash);

	be32enc_vect(data, (const uint32_t *)work->data, 19);
	data[19] = htobe32(*nonce);


	unsigned char bin[4];
	uint32_t h32, *be32 = (uint32_t *)bin;
	hex2bin(bin, work->pool->swork.ntime, 4);
	h32 = be32toh(*be32);

	xhash(ohash, data, work->pool->swork.ntime);
}

bool scanhash_timetravel10(struct thr_info *thr, const unsigned char __maybe_unused *pmidstate,
	unsigned char *pdata, unsigned char __maybe_unused *phash1,
	unsigned char __maybe_unused *phash, const unsigned char *ptarget,
	uint32_t max_nonce, uint32_t *last_nonce, uint32_t n)
{
	uint32_t *nonce = (uint32_t *)(pdata + 76);
	uint32_t data[20];
	uint32_t tmp_hash7;
	uint32_t Htarg = le32toh(((const uint32_t *)ptarget)[7]);
	bool ret = false;

	be32enc_vect(data, (const uint32_t *)pdata, 19);

	while (1) {
		uint32_t ostate[8];

		*nonce = ++n;
		data[19] = (n);
		xhash(ostate, data, DEFAULT_NTIME);
		tmp_hash7 = (ostate[7]);

		applog(LOG_INFO, "data7 %08lx",
			(long unsigned int)data[7]);

		if (unlikely(tmp_hash7 <= Htarg)) {
			((uint32_t *)pdata)[19] = htobe32(n);
			*last_nonce = n;
			ret = true;
			break;
		}

		if (unlikely((n >= max_nonce) || thr->work_restart)) {
			*last_nonce = n;
			break;
		}
	}

	return ret;
}




