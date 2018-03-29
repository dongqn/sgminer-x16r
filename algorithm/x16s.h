#ifndef X16S_H
#define X16S_H

#include "miner.h"

extern int x16s_test(unsigned char *pdata, const unsigned char *ptarget,	uint32_t nonce);
extern void x16s_regenhash(struct work *work);
extern void x16s_twisted_code(const uint32_t* prevblock, char *code);

#endif /* X16S_H */
