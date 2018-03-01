
// whirlpool
  {
    sph_u64 n[8];
    sph_u64 h[8];
    sph_u64 state[8];

    h[0] = h[1] = h[2] = h[3] = h[4] = h[5] = h[6] = h[7] = 0;

    n[0] =  h[0] ^ DEC64BE(block +    0);
    n[1] =  h[1] ^ DEC64BE(block +    8);
    n[2] =  h[2] ^ DEC64BE(block +   16);
    n[3] =  h[3] ^ DEC64BE(block +   24);
    n[4] =  h[4] ^ DEC64BE(block +   32);
    n[5] =  h[5] ^ DEC64BE(block +   40);
    n[6] =  h[6] ^ DEC64BE(block +   48);
    n[7] =  h[7] ^ DEC64BE(block +   56);

    whirlpool_round(n, h);

    h[0] = state[0] = n[0] ^ DEC64BE(block +   0);
    h[1] = state[1] = n[1] ^ DEC64BE(block +   8);
    h[2] = state[2] = n[2] ^ DEC64BE(block +   16);
    h[3] = state[3] = n[3] ^ DEC64BE(block +   24);
    h[4] = state[4] = n[4] ^ DEC64BE(block +   32);
    h[5] = state[5] = n[5] ^ DEC64BE(block +   40);
    h[6] = state[6] = n[6] ^ DEC64BE(block +   48);
    h[7] = state[7] = n[7] ^ DEC64BE(block +   56);


    n[0] = DEC64BE(block +  64);
    n[1] = DEC64BE(block +  72);
    n[1] &= 0x00000000FFFFFFFF;
    n[1] ^= ((sph_u64) gid) << 32;
    n[3] = n[4] = n[5] = n[6] = 0;
    n[2] = 0x0000000000000080;
    n[7] = 0x8002000000000000;
    sph_u64 temp0,temp1,temp2,temp7;
    temp0 = n[0];
    temp1 = n[1];
    temp2 = n[2];
    temp7 = n[7];

    n[0] ^= h[0];
    n[1] ^= h[1];
    n[2] ^= h[2];
    n[3] ^= h[3];
    n[4] ^= h[4];
    n[5] ^= h[5];
    n[6] ^= h[6];
    n[7] ^= h[7];

    whirlpool_round(n, h);

    hash.h8[0] = state[0] ^ n[0] ^ temp0;
    hash.h8[1] = state[1] ^ n[1] ^ temp1;
    hash.h8[2] = state[2] ^ n[2] ^ temp2;
    hash.h8[3] = state[3] ^ n[3];
    hash.h8[4] = state[4] ^ n[4];
    hash.h8[5] = state[5] ^ n[5];
    hash.h8[6] = state[6] ^ n[6];
    hash.h8[7] = state[7] ^ n[7] ^ temp7;
  }
