
// sha512
{
  ulong W[16] = { 0UL }, SHA512Out[8];
  uint SHA256Buf[16];

  for(int i = 0; i < 10; ++i) W[i] = DEC64BE(block +  8*i);

  W[9] &= 0xFFFFFFFF00000000UL;
  W[9] ^= SWAP4(gid);
  W[10] = 0x8000000000000000UL;
  W[15] = 0x0000000000000280UL;

  for(int i = 0; i < 8; ++i) hash.h8[i] = SHA512_INIT[i];

  SHA512Block(W, hash.h8);

  for(int i = 0; i < 8; ++i) hash.h8[i] = SWAP64(SHA512Out[i]);
}
