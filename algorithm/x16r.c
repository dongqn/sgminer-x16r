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
#include "sph/sph_echo.h"
#include "sph/sph_echo.h"
#include "sph/sph_hamsi.h"
#include "sph/sph_fugue.h"
#include "sph/sph_shabal.h"
#include "sph/sph_whirlpool.h"
#include "sph/sph_sha2.h"

#define HASH_FUNC_COUNT 16


/* Move init out of loop, so init once externally, and then use one single memcpy with that bigger memory block */
typedef struct {
	sph_blake512_context    blake;
	sph_bmw512_context      bmw;
	sph_groestl512_context  groestl;
	sph_skein512_context    skein;
	sph_jh512_context       jh;
	sph_keccak512_context   keccak;
	sph_luffa512_context    luffa;
	sph_cubehash512_context cubehash;
	sph_shavite512_context  shavite;
	sph_simd512_context     simd;
	sph_echo512_context     echo;
  sph_hamsi512_context    hamsi;
  sph_fugue512_context    fugue;
  sph_shabal512_context   shabal;
  sph_whirlpool_context   whirlpool;
  sph_sha512_context      sha512;
} Xhash_context_holder;

static Xhash_context_holder base_contexts;


static void init_Xhash_contexts()
{
	sph_blake512_init(&base_contexts.blake);
	sph_bmw512_init(&base_contexts.bmw);
	sph_groestl512_init(&base_contexts.groestl);
	sph_skein512_init(&base_contexts.skein);
	sph_jh512_init(&base_contexts.jh);
	sph_keccak512_init(&base_contexts.keccak);
	sph_luffa512_init(&base_contexts.luffa);
	sph_cubehash512_init(&base_contexts.cubehash);
	sph_shavite512_init(&base_contexts.shavite);
	sph_simd512_init(&base_contexts.simd);
	sph_echo512_init(&base_contexts.echo);
	sph_hamsi512_init(&base_contexts.hamsi);
	sph_fugue512_init(&base_contexts.fugue);
	sph_shabal512_init(&base_contexts.shabal);
	sph_whirlpool_init(&base_contexts.whirlpool);
	sph_sha512_init(&base_contexts.sha512);
}


static void getAlgoString(const uint32_t* prevblock, char *output)
{
	char *sptr = output;
	uint8_t* data = (uint8_t*)prevblock;

	for (uint8_t j = 0; j < 16; j++) {
		uint8_t b = (15 - j) >> 1; // 16 ascii hex chars, reversed
		uint8_t algoDigit = (j & 1) ? data[b] & 0xF : data[b] >> 4;
		if (algoDigit >= 10)
			sprintf(sptr, "%c", 'A' + (algoDigit - 10));
		else
			sprintf(sptr, "%u", (uint32_t) algoDigit);
		sptr++;
	}
	*sptr = '\0';
}


void x16r_twisted_code(const uint32_t* prevblock, char *code)
{
	getAlgoString(prevblock, code);
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


static inline void xhash(void *state, const void *input,
		const uint32_t* prevblock)
{
	init_Xhash_contexts();

	Xhash_context_holder ctx;

	uint32_t hashA[16], hashB[16];
	memcpy(&ctx, &base_contexts, sizeof(base_contexts));

	char resultCode[HASH_FUNC_COUNT + 1];
	x16r_twisted_code(prevblock, resultCode);

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
			sph_blake512(&ctx.blake, in, size);
			sph_blake512_close(&ctx.blake, out);
			break;
		case 1:
			sph_bmw512(&ctx.bmw, in, size);
			sph_bmw512_close(&ctx.bmw, out);
			break;
		case 2:
			sph_groestl512(&ctx.groestl, in, size);
			sph_groestl512_close(&ctx.groestl, out);
			break;
		case 3:
			sph_skein512(&ctx.skein, in, size);
			sph_skein512_close(&ctx.skein, out);
			break;
		case 4:
			sph_jh512(&ctx.jh, in, size);
			sph_jh512_close(&ctx.jh, out);
			break;
		case 5:
			sph_keccak512(&ctx.keccak, in, size);
			sph_keccak512_close(&ctx.keccak, out);
			break;
		case 6:
			sph_luffa512(&ctx.luffa, in, size);
			sph_luffa512_close(&ctx.luffa, out);
			break;
		case 7:
			sph_cubehash512(&ctx.cubehash, in, size);
			sph_cubehash512_close(&ctx.cubehash, out);
			break;
		case 8:
			sph_shavite512(&ctx.shavite, in, size);
			sph_shavite512_close(&ctx.shavite, out);
			break;
		case 9:
			sph_simd512(&ctx.simd, in, size);
			sph_simd512_close(&ctx.simd, out);
			break;
		case 10:
			sph_echo512(&ctx.echo, in, size);
			sph_echo512_close(&ctx.echo, out);
			break;
		case 11:
			sph_hamsi512(&ctx.hamsi, in, size);
			sph_hamsi512_close(&ctx.hamsi, out);
			break;
		case 12:
			sph_fugue512(&ctx.fugue, in, size);
			sph_fugue512_close(&ctx.fugue, out);
			break;
		case 13:
			sph_shabal512(&ctx.shabal, in, size);
			sph_shabal512_close(&ctx.shabal, out);
			break;
		case 14:
			sph_whirlpool(&ctx.whirlpool, in, size);
			sph_whirlpool_close(&ctx.whirlpool, out);
			break;
		case 15:
			sph_sha512(&ctx.sha512,in, size);
			sph_sha512_close(&ctx.sha512, out);
			break;
		}
	}

	memcpy(state, out, 32);
}

static const uint32_t diff1targ = 0x0000ffff;


/* Used externally as confirmation of correct OCL code */
int x16r_test(unsigned char *pdata, const unsigned char *ptarget, uint32_t nonce)
{
	uint32_t tmp_hash7, Htarg = le32toh(((const uint32_t *)ptarget)[7]);
	uint32_t data[20], ohash[8];

	be32enc_vect(data, (const uint32_t *)pdata, 19);
	data[19] = htobe32(nonce);
	xhash(ohash, data, (const uint32_t* )pdata);
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

void x16r_regenhash(struct work *work)
{
	uint32_t data[20];
	uint32_t *nonce = (uint32_t *)(work->data + 76);
	uint32_t *ohash = (uint32_t *)(work->hash);

	be32enc_vect(data, (const uint32_t *)work->data, 19);
	data[19] = htobe32(*nonce);

	xhash(ohash, data, (const uint32_t* )work->data);
}

bool scanhash_x16r(struct thr_info *thr, const unsigned char __maybe_unused *pmidstate,
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
		xhash(ostate, data, (const uint32_t* )pdata);
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
