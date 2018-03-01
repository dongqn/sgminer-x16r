// TODO: check
// bmw
  {
    sph_u64 BMW_H[16];
    for(unsigned u = 0; u < 16; u++)
        BMW_H[u] = BMW_IV512[u];

    sph_u64 BMW_h1[16], BMW_h2[16];
    sph_u64 mv[16];

    mv[ 0] = DEC64BE(block +   0);
    mv[ 1] = DEC64BE(block +   8);
    mv[ 2] = DEC64BE(block +  16);
    mv[ 3] = DEC64BE(block +  24);
    mv[ 4] = DEC64BE(block +  32);
    mv[ 5] = DEC64BE(block +  40);
    mv[ 6] = DEC64BE(block +  48);
    mv[ 7] = DEC64BE(block +  56);
    mv[ 8] = DEC64BE(block +  64);
    mv[ 9] = DEC64BE(block +  72);
    mv[ 9] &= 0xFFFFFFFF00000000;
    mv[ 9] ^= SWAP4(gid);
    mv[10] = 0x8000000000000000;
    mv[11] = 0;
    mv[12] = 0;
    mv[13] = 0;
    mv[14] = 0;
    mv[15] = 0x280;

    #define M(x)    (mv[x])
    #define H(x)    (BMW_H[x])
    #define dH(x)   (BMW_h2[x])

    FOLDb;

    #undef M
    #undef H
    #undef dH

    #define M(x)    (BMW_h2[x])
    #define H(x)    (final_b[x])
    #define dH(x)   (BMW_h1[x])

    FOLDb;

    #undef M
    #undef H
    #undef dH

    hash.h8[0] = SWAP8(BMW_h1[8]);
    hash.h8[1] = SWAP8(BMW_h1[9]);
    hash.h8[2] = SWAP8(BMW_h1[10]);
    hash.h8[3] = SWAP8(BMW_h1[11]);
    hash.h8[4] = SWAP8(BMW_h1[12]);
    hash.h8[5] = SWAP8(BMW_h1[13]);
    hash.h8[6] = SWAP8(BMW_h1[14]);
    hash.h8[7] = SWAP8(BMW_h1[15]);
}
