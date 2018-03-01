
// shabal
  {
    sph_u32 A00 = A_init_512[0], A01 = A_init_512[1], A02 = A_init_512[2],
            A03 = A_init_512[3], A04 = A_init_512[4], A05 = A_init_512[5],
            A06 = A_init_512[6], A07 = A_init_512[7], A08 = A_init_512[8],
            A09 = A_init_512[9], A0A = A_init_512[10],A0B = A_init_512[11];
    sph_u32 B0 = B_init_512[0], B1 = B_init_512[1], B2 = B_init_512[2],
            B3 = B_init_512[3], B4 = B_init_512[4], B5 = B_init_512[5],
            B6 = B_init_512[6], B7 = B_init_512[7], B8 = B_init_512[8],
            B9 = B_init_512[9], BA = B_init_512[10], BB = B_init_512[11],
            BC = B_init_512[12], BD = B_init_512[13], BE = B_init_512[14],
            BF = B_init_512[15];
    sph_u32 C0 = C_init_512[0], C1 = C_init_512[1], C2 = C_init_512[2],
            C3 = C_init_512[3], C4 = C_init_512[4], C5 = C_init_512[5],
            C6 = C_init_512[6], C7 = C_init_512[7], C8 = C_init_512[8],
            C9 = C_init_512[9], CA = C_init_512[10], CB = C_init_512[11],
            CC = C_init_512[12], CD = C_init_512[13], CE = C_init_512[14],
            CF = C_init_512[15];
    sph_u32 M0, M1, M2, M3, M4, M5, M6, M7, M8, M9, MA, MB, MC, MD, ME, MF;
    sph_u32 Wlow = 1, Whigh = 0;

    M0 = DEC32BE(block +   0);
    M1 = DEC32BE(block +   4);
    M2 = DEC32BE(block +   8);
    M3 = DEC32BE(block +  12);
    M4 = DEC32BE(block +  16);
    M5 = DEC32BE(block +  20);
    M6 = DEC32BE(block +  24);
    M7 = DEC32BE(block +  28);
    M8 = DEC32BE(block +  32);
    M9 = DEC32BE(block +  36);
    MA = DEC32BE(block +  40);
    MB = DEC32BE(block +  44);
    MC = DEC32BE(block +  48);
    MD = DEC32BE(block +  52);
    ME = DEC32BE(block +  56);
    MF = DEC32BE(block +  60);

    INPUT_BLOCK_ADD;
    XOR_W;
    APPLY_P;
    INPUT_BLOCK_SUB;
    SWAP_BC;
    INCR_W;

    M0 = DEC64BE(block +  64);
    M1 = DEC64BE(block +  68);
    M2 = DEC64BE(block +  72);
    M3 = SWAP4(gid);
    M4 = 0x8000000000000000;
    M5 = M6 = M7 = M8 = M9 = MA = MB = MC = MD = ME = MF = 0;

    INPUT_BLOCK_ADD;
    XOR_W;
    APPLY_P;

    for (unsigned i = 0; i < 3; i ++)
    {
        SWAP_BC;
        XOR_W;
        APPLY_P;
    }

    hash.h4[0] = B0;
    hash.h4[1] = B1;
    hash.h4[2] = B2;
    hash.h4[3] = B3;
    hash.h4[4] = B4;
    hash.h4[5] = B5;
    hash.h4[6] = B6;
    hash.h4[7] = B7;
    hash.h4[8] = B8;
    hash.h4[9] = B9;
    hash.h4[10] = BA;
    hash.h4[11] = BB;
    hash.h4[12] = BC;
    hash.h4[13] = BD;
    hash.h4[14] = BE;
    hash.h4[15] = BF;
  }
