
// whirlpool
  {
    __local sph_u64 LT0[256], LT1[256], LT2[256], LT3[256], LT4[256], LT5[256], LT6[256], LT7[256];
    sph_u64 n0, n1, n2, n3, n4, n5, n6, n7;
    sph_u64 h0, h1, h2, h3, h4, h5, h6, h7;
    sph_u64 state[8];

    n0 = (hash.h8[0]);
    n1 = (hash.h8[1]);
    n2 = (hash.h8[2]);
    n3 = (hash.h8[3]);
    n4 = (hash.h8[4]);
    n5 = (hash.h8[5]);
    n6 = (hash.h8[6]);
    n7 = (hash.h8[7]);

    h0 = h1 = h2 = h3 = h4 = h5 = h6 = h7 = 0;

    n0 ^= h0;
    n1 ^= h1;
    n2 ^= h2;
    n3 ^= h3;
    n4 ^= h4;
    n5 ^= h5;
    n6 ^= h6;
    n7 ^= h7;

    #pragma unroll 10
    for (unsigned r = 0; r < 10; r ++)
    {
      sph_u64 tmp0, tmp1, tmp2, tmp3, tmp4, tmp5, tmp6, tmp7;

      ROUND_KSCHED(plain_T, h, tmp, plain_RC[r]);
      TRANSFER(h, tmp);
      ROUND_WENC(plain_T, n, h, tmp);
      TRANSFER(n, tmp);
    }

    state[0] = n0 ^ (hash.h8[0]);
    state[1] = n1 ^ (hash.h8[1]);
    state[2] = n2 ^ (hash.h8[2]);
    state[3] = n3 ^ (hash.h8[3]);
    state[4] = n4 ^ (hash.h8[4]);
    state[5] = n5 ^ (hash.h8[5]);
    state[6] = n6 ^ (hash.h8[6]);
    state[7] = n7 ^ (hash.h8[7]);

    n0 = 0x80;
    n1 = n2 = n3 = n4 = n5 = n6 = 0;
    n7 = 0x2000000000000;

    h0 = state[0];
    h1 = state[1];
    h2 = state[2];
    h3 = state[3];
    h4 = state[4];
    h5 = state[5];
    h6 = state[6];
    h7 = state[7];

    n0 ^= h0;
    n1 ^= h1;
    n2 ^= h2;
    n3 ^= h3;
    n4 ^= h4;
    n5 ^= h5;
    n6 ^= h6;
    n7 ^= h7;

    #pragma unroll 10
    for (unsigned r = 0; r < 10; r ++)
    {
      sph_u64 tmp0, tmp1, tmp2, tmp3, tmp4, tmp5, tmp6, tmp7;

      ROUND_KSCHED(LT, h, tmp, plain_RC[r]);
      TRANSFER(h, tmp);
      ROUND_WENC(plain_T, n, h, tmp);
      TRANSFER(n, tmp);
    }

    state[0] ^= n0 ^ 0x80;
    state[1] ^= n1;
    state[2] ^= n2;
    state[3] ^= n3;
    state[4] ^= n4;
    state[5] ^= n5;
    state[6] ^= n6;
    state[7] ^= n7 ^ 0x2000000000000;

    for (unsigned i = 0; i < 8; i ++)
      hash.h8[i] = state[i];
  }
