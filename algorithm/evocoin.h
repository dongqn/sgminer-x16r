#ifndef EVOCOIN_H
#define EVOCOIN_H

#include "miner.h"

extern int evocoin_test(unsigned char *pdata, const unsigned char *ptarget,	uint32_t nonce);
extern void evocoin_regenhash(struct work *work);
extern void evocoin_twisted_code(char *result, char *ntime, char *code);

#endif /* EVOCOIN_H */
