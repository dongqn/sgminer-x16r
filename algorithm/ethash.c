#include <stdint.h>
#include <x86intrin.h>

#include "config.h"
#include "miner.h"
#include "algorithm/ethash.h"
#include "algorithm/eth-sha3.h"

#define FNV_PRIME		0x01000193

#define fnv(x, y)		(((x) * FNV_PRIME) ^ (y))
#define fnv_reduce(v)	fnv(fnv(fnv((v)[0], (v)[1]), (v)[2]), (v)[3])
#define ETHEREUM_EPOCH_LENGTH 30000UL

extern cglock_t EthCacheLock[2];
extern uint8_t* EthCache[2];


typedef struct _DAG128
{
	uint32_t Columns[32];
} DAG128;

typedef union _Node
{
	uint8_t bytes[16 * 4];
	uint32_t words[16];
	uint64_t double_words[16 / 2];
	__m128i xmm[16/4];
} Node;

uint32_t EthCalcEpochNumber(uint8_t *SeedHash)
{
	uint8_t TestSeedHash[32] = { 0 };
	
	for(int Epoch = 0; Epoch < 2048; ++Epoch)
	{
		SHA3_256(TestSeedHash, TestSeedHash, 32);
		if(!memcmp(TestSeedHash, SeedHash, 32)) return(Epoch + 1);
	}
	
	applog(LOG_ERR, "Error on epoch calculation.");
	
	return(0UL);
}

Node CalcDAGItem(const Node *CacheInputNodes, uint32_t NodeCount, uint32_t NodeIdx)
{
	Node DAGNode = CacheInputNodes[NodeIdx % NodeCount];
	
	DAGNode.words[0] ^= NodeIdx;

	SHA3_512(DAGNode.bytes, DAGNode.bytes, sizeof(Node));
	
	__m128i const fnv_prime = _mm_set1_epi32(FNV_PRIME);
	__m128i xmm0 = DAGNode.xmm[0];
	__m128i xmm1 = DAGNode.xmm[1];
	__m128i xmm2 = DAGNode.xmm[2];
	__m128i xmm3 = DAGNode.xmm[3];
	
	for(uint32_t i = 0; i < 256; ++i)
	{
		uint32_t parent_index = fnv(NodeIdx ^ i, DAGNode.words[i % 16]) % NodeCount;
		Node const *parent = CacheInputNodes + parent_index; //&cache_nodes[parent_index];
		
		xmm0 = _mm_mullo_epi32(xmm0, fnv_prime);
		xmm1 = _mm_mullo_epi32(xmm1, fnv_prime);
		xmm2 = _mm_mullo_epi32(xmm2, fnv_prime);
		xmm3 = _mm_mullo_epi32(xmm3, fnv_prime);
		xmm0 = _mm_xor_si128(xmm0, parent->xmm[0]);
		xmm1 = _mm_xor_si128(xmm1, parent->xmm[1]);
		xmm2 = _mm_xor_si128(xmm2, parent->xmm[2]);
		xmm3 = _mm_xor_si128(xmm3, parent->xmm[3]);

		// have to write to ret as values are used to compute index
		DAGNode.xmm[0] = xmm0;
		DAGNode.xmm[1] = xmm1;
		DAGNode.xmm[2] = xmm2;
		DAGNode.xmm[3] = xmm3;
	}

	SHA3_512(DAGNode.bytes, DAGNode.bytes, sizeof(Node));
	
	return(DAGNode);
}

// OutHash & MixHash MUST have 32 bytes allocated (at least)
void LightEthash(uint8_t *restrict OutHash, uint8_t *restrict MixHash, const uint8_t *restrict HeaderPoWHash, const Node *Cache, const uint64_t EpochNumber, const uint64_t Nonce)
{
	uint32_t MixState[32], TmpBuf[24], NodeCount = EthGetCacheSize(EpochNumber) / sizeof(Node);
	uint64_t DagSize;
	Node *EthCache = Cache;
	
	// Initial hash - append nonce to header PoW hash and
	// run it through SHA3 - this becomes the initial value
	// for the mixing state buffer. The init value is used
	// later for the final hash, and is therefore saved.
	memcpy(TmpBuf, HeaderPoWHash, 32UL);
	memcpy(TmpBuf + 8UL, &Nonce, 8UL);
	sha3_512((uint8_t *)TmpBuf, 64UL, (uint8_t *)TmpBuf, 40UL);
	
	memcpy(MixState, TmpBuf, 64UL);
	
	// The other half of the state is filled by simply
	// duplicating the first half of its initial value.
	memcpy(MixState + 16UL, MixState, 64UL);
	
	DagSize = EthGetDAGSize(EpochNumber) / (sizeof(Node) << 1);
	
	// Main mix of Ethash
	for(uint32_t i = 0, Init0 = MixState[0], MixValue = MixState[0]; i < 64; ++i)
	{
		uint32_t row = fnv(Init0 ^ i, MixValue) % DagSize;
		Node DAGSliceNodes[2];
		DAGSliceNodes[0] = CalcDAGItem(EthCache, NodeCount, row << 1);
		DAGSliceNodes[1] = CalcDAGItem(EthCache, NodeCount, (row << 1) + 1);
		DAG128 *DAGSlice = (DAG128 *)DAGSliceNodes;
		
		for(uint32_t col = 0; col < 32; ++col)
		{
			MixState[col] = fnv(MixState[col], DAGSlice->Columns[col]);
			MixValue = col == ((i + 1) & 0x1F) ? MixState[col] : MixValue;
		}
	}
	
	// The reducing of the mix state directly into where
	// it will be hashed to produce the final hash. Note
	// that the initial hash is still in the first 64
	// bytes of TmpBuf - we're appending the mix hash.
	for(int i = 0; i < 8; ++i) TmpBuf[i + 16] = fnv_reduce(MixState + (i << 2));
	
	memcpy(MixHash, TmpBuf + 16, 32UL);
	
	// Hash the initial hash and the mix hash concatenated
	// to get the final proof-of-work hash that is our output.
	sha3_256(OutHash, 32UL, (uint8_t *)TmpBuf, 96UL);
}

void ethash_regenhash(struct work *work)
{
	work->Nonce += *((uint32_t *)(work->data + 32));
	applog(LOG_DEBUG, "Regenhash: First qword of input: 0x%016llX.", work->Nonce);
	int idx = work->EpochNumber % 2;
	cg_rlock(&EthCacheLock[idx]);
	LightEthash(work->hash, work->mixhash, work->data, EthCache[idx] + 64, work->EpochNumber, work->Nonce);
	cg_runlock(&EthCacheLock[idx]);
	
	char *DbgHash = bin2hex(work->hash, 32);
	
	applog(LOG_DEBUG, "Regenhash result: %s.", DbgHash);
	applog(LOG_DEBUG, "Last ulong: 0x%016llX.", __builtin_bswap64(*((uint64_t *)(work->hash + 0))));
	free(DbgHash);
}