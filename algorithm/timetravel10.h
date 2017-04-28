#ifndef TIMETRAVEL10_H
#define TIMETRAVEL10_H

#include "miner.h"

extern int timetravel10_test(unsigned char *pdata, const unsigned char *ptarget,	uint32_t nonce);
extern void timetravel10_regenhash(struct work *work);
extern void timetravel10_twisted_code(char *result, char *ntime, char *code);

#endif /* TIMETRAVEL10_H */
