#ifndef X16R_H
#define X16R_H

#include "miner.h"

extern int x16r_test(unsigned char *pdata, const unsigned char *ptarget,	uint32_t nonce);
extern void x16r_regenhash(struct work *work);
extern void x16r_twisted_code(const uint32_t* prevblock, char *code);

#endif /* X16R_H */
