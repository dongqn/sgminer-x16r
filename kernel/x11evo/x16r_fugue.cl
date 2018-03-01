
// fugue
  {
    sph_u32 *mixtab0 = AES0, *mixtab1 = AES1, *mixtab2 = AES2, *mixtab3 = AES3;
    sph_u32 S00, S01, S02, S03, S04, S05, S06, S07, S08, S09;
    sph_u32 S10, S11, S12, S13, S14, S15, S16, S17, S18, S19;
    sph_u32 S20, S21, S22, S23, S24, S25, S26, S27, S28, S29;
    sph_u32 S30, S31, S32, S33, S34, S35;

    ulong fc_bit_count = (sph_u64) 64 << 3;

    S00 = S01 = S02 = S03 = S04 = S05 = S06 = S07 = S08 = S09 = S10 = S11 = S12 = S13 = S14 = S15 = S16 = S17 = S18 = S19 = 0;
    S20 = SPH_C32(0x8807a57e); S21 = SPH_C32(0xe616af75); S22 = SPH_C32(0xc5d3e4db); S23 = SPH_C32(0xac9ab027);
    S24 = SPH_C32(0xd915f117); S25 = SPH_C32(0xb6eecc54); S26 = SPH_C32(0x06e8020b); S27 = SPH_C32(0x4a92efd1);
    S28 = SPH_C32(0xaac6e2c9); S29 = SPH_C32(0xddb21398); S30 = SPH_C32(0xcae65838); S31 = SPH_C32(0x437f203f);
    S32 = SPH_C32(0x25ea78e7); S33 = SPH_C32(0x951fddd6); S34 = SPH_C32(0xda6ed11d); S35 = SPH_C32(0xe13e3567);

    FUGUE512_3((hash.h4[0x0]), (hash.h4[0x1]), (hash.h4[0x2]));
    FUGUE512_3((hash.h4[0x3]), (hash.h4[0x4]), (hash.h4[0x5]));
    FUGUE512_3((hash.h4[0x6]), (hash.h4[0x7]), (hash.h4[0x8]));
    FUGUE512_3((hash.h4[0x9]), (hash.h4[0xA]), (hash.h4[0xB]));
    FUGUE512_3((hash.h4[0xC]), (hash.h4[0xD]), (hash.h4[0xE]));
    FUGUE512_3((hash.h4[0xF]), as_uint2(fc_bit_count).y, as_uint2(fc_bit_count).x);

    // apply round shift if necessary
    int i;

    for (i = 0; i < 32; i ++) {
      ROR3;
      CMIX36(S00, S01, S02, S04, S05, S06, S18, S19, S20);
      SMIX(S00, S01, S02, S03);
    }
    for (i = 0; i < 13; i ++) {
      S04 ^= S00;
      S09 ^= S00;
      S18 ^= S00;
      S27 ^= S00;
      ROR9;
      SMIX(S00, S01, S02, S03);
      S04 ^= S00;
      S10 ^= S00;
      S18 ^= S00;
      S27 ^= S00;
      ROR9;
      SMIX(S00, S01, S02, S03);
      S04 ^= S00;
      S10 ^= S00;
      S19 ^= S00;
      S27 ^= S00;
      ROR9;
      SMIX(S00, S01, S02, S03);
      S04 ^= S00;
      S10 ^= S00;
      S19 ^= S00;
      S28 ^= S00;
      ROR8;
      SMIX(S00, S01, S02, S03);
    }
    S04 ^= S00;
    S09 ^= S00;
    S18 ^= S00;
    S27 ^= S00;

    hash.h4[0] = SWAP4(S01);
    hash.h4[1] = SWAP4(S02);
    hash.h4[2] = SWAP4(S03);
    hash.h4[3] = SWAP4(S04);
    hash.h4[4] = SWAP4(S09);
    hash.h4[5] = SWAP4(S10);
    hash.h4[6] = SWAP4(S11);
    hash.h4[7] = SWAP4(S12);
    hash.h4[8] = SWAP4(S18);
    hash.h4[9] = SWAP4(S19);
    hash.h4[10] = SWAP4(S20);
    hash.h4[11] = SWAP4(S21);
    hash.h4[12] = SWAP4(S27);
    hash.h4[13] = SWAP4(S28);
    hash.h4[14] = SWAP4(S29);
    hash.h4[15] = SWAP4(S30);
  }
