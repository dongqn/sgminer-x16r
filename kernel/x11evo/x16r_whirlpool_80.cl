
// whirlpool
  {
    sph_u64 n[8];
    sph_u64 h[8];
    sph_u64 state[8];
    sph_u64 t0, t1, t2, t3, t4, t5, t6, t7;

    h[0] = h[1] = h[2] = h[3] = h[4] = h[5] = h[6] = h[7] = 0;

    n[0] =  h[0] ^ DEC64BE(block +    0);
    n[1] =  h[1] ^ DEC64BE(block +    8);
    n[2] =  h[2] ^ DEC64BE(block +   16);
    n[3] =  h[3] ^ DEC64BE(block +   24);
    n[4] =  h[4] ^ DEC64BE(block +   32);
    n[5] =  h[5] ^ DEC64BE(block +   40);
    n[6] =  h[6] ^ DEC64BE(block +   48);
    n[7] =  h[7] ^ DEC64BE(block +   56);

    for (unsigned r = 0; r < 10; r ++) {
        t0 = (ROUND_ELT(h, 0, 7, 6, 5, 4, 3, 2, 1) ^ rc[r]);
        t1 = (ROUND_ELT(h, 1, 0, 7, 6, 5, 4, 3, 2) ^ 0 );
        t2 = (ROUND_ELT(h, 2, 1, 0, 7, 6, 5, 4, 3) ^ 0 );
        t3 = (ROUND_ELT(h, 3, 2, 1, 0, 7, 6, 5, 4) ^ 0 );
        t4 = (ROUND_ELT(h, 4, 3, 2, 1, 0, 7, 6, 5) ^ 0 );
        t5 = (ROUND_ELT(h, 5, 4, 3, 2, 1, 0, 7, 6) ^ 0 );
        t6 = (ROUND_ELT(h, 6, 5, 4, 3, 2, 1, 0, 7) ^ 0 );
        t7 = (ROUND_ELT(h, 7, 6, 5, 4, 3, 2, 1, 0) ^ 0 );

        h[0] = t0;
        h[1] = t1;
        h[2] = t2;
        h[3] = t3;
        h[4] = t4;
        h[5] = t5;
        h[6] = t6;
        h[7] = t7;

        t0 = ROUND_ELT(n, 0, 7, 6, 5, 4, 3, 2, 1) ^ h[0];
        t1 = ROUND_ELT(n, 1, 0, 7, 6, 5, 4, 3, 2) ^ h[1];
        t2 = ROUND_ELT(n, 2, 1, 0, 7, 6, 5, 4, 3) ^ h[2];
        t3 = ROUND_ELT(n, 3, 2, 1, 0, 7, 6, 5, 4) ^ h[3];
        t4 = ROUND_ELT(n, 4, 3, 2, 1, 0, 7, 6, 5) ^ h[4];
        t5 = ROUND_ELT(n, 5, 4, 3, 2, 1, 0, 7, 6) ^ h[5];
        t6 = ROUND_ELT(n, 6, 5, 4, 3, 2, 1, 0, 7) ^ h[6];
        t7 = ROUND_ELT(n, 7, 6, 5, 4, 3, 2, 1, 0) ^ h[7];

        n[0] = t0;
        n[1] = t1;
        n[2] = t2;
        n[3] = t3;
        n[4] = t4;
        n[5] = t5;
        n[6] = t6;
        n[7] = t7;
    }

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

    for (unsigned r = 0; r < 10; r ++) {
        t0 = (ROUND_ELT(h, 0, 7, 6, 5, 4, 3, 2, 1) ^ rc[r]);
        t1 = (ROUND_ELT(h, 1, 0, 7, 6, 5, 4, 3, 2) ^ 0 );
        t2 = (ROUND_ELT(h, 2, 1, 0, 7, 6, 5, 4, 3) ^ 0 );
        t3 = (ROUND_ELT(h, 3, 2, 1, 0, 7, 6, 5, 4) ^ 0 );
        t4 = (ROUND_ELT(h, 4, 3, 2, 1, 0, 7, 6, 5) ^ 0 );
        t5 = (ROUND_ELT(h, 5, 4, 3, 2, 1, 0, 7, 6) ^ 0 );
        t6 = (ROUND_ELT(h, 6, 5, 4, 3, 2, 1, 0, 7) ^ 0 );
        t7 = (ROUND_ELT(h, 7, 6, 5, 4, 3, 2, 1, 0) ^ 0 );

        h[0] = t0;
        h[1] = t1;
        h[2] = t2;
        h[3] = t3;
        h[4] = t4;
        h[5] = t5;
        h[6] = t6;
        h[7] = t7;

        t0 = ROUND_ELT(n, 0, 7, 6, 5, 4, 3, 2, 1) ^ h[0];
        t1 = ROUND_ELT(n, 1, 0, 7, 6, 5, 4, 3, 2) ^ h[1];
        t2 = ROUND_ELT(n, 2, 1, 0, 7, 6, 5, 4, 3) ^ h[2];
        t3 = ROUND_ELT(n, 3, 2, 1, 0, 7, 6, 5, 4) ^ h[3];
        t4 = ROUND_ELT(n, 4, 3, 2, 1, 0, 7, 6, 5) ^ h[4];
        t5 = ROUND_ELT(n, 5, 4, 3, 2, 1, 0, 7, 6) ^ h[5];
        t6 = ROUND_ELT(n, 6, 5, 4, 3, 2, 1, 0, 7) ^ h[6];
        t7 = ROUND_ELT(n, 7, 6, 5, 4, 3, 2, 1, 0) ^ h[7];

        n[0] = t0;
        n[1] = t1;
        n[2] = t2;
        n[3] = t3;
        n[4] = t4;
        n[5] = t5;
        n[6] = t6;
        n[7] = t7;
    }

    hash.h8[0] = state[0] ^ n[0] ^ temp0;
    hash.h8[1] = state[1] ^ n[1] ^ temp1;
    hash.h8[2] = state[2] ^ n[2] ^ temp2;
    hash.h8[3] = state[3] ^ n[3];
    hash.h8[4] = state[4] ^ n[4];
    hash.h8[5] = state[5] ^ n[5];
    hash.h8[6] = state[6] ^ n[6];
    hash.h8[7] = state[7] ^ n[7] ^ temp7;
  }
