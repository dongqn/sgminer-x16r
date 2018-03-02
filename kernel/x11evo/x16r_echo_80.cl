
// echo
	{
		sph_u64 W00, W01, W10, W11, W20, W21, W30, W31, W40, W41, W50, W51, W60, W61, W70, W71, W80, W81, W90, W91, WA0, WA1, WB0, WB1, WC0, WC1, WD0, WD1, WE0, WE1, WF0, WF1;
		sph_u64 Vb00, Vb01, Vb10, Vb11, Vb20, Vb21, Vb30, Vb31, Vb40, Vb41, Vb50, Vb51, Vb60, Vb61, Vb70, Vb71;
		Vb00 = Vb10 = Vb20 = Vb30 = Vb40 = Vb50 = Vb60 = Vb70 = 512UL;
		Vb01 = Vb11 = Vb21 = Vb31 = Vb41 = Vb51 = Vb61 = Vb71 = 0;

		sph_u32 K0 = 512;
		sph_u32 K1 = 0;
		sph_u32 K2 = 0;
		sph_u32 K3 = 0;

		W00 = Vb00;
		W01 = Vb01;
		W10 = Vb10;
		W11 = Vb11;
		W20 = Vb20;
		W21 = Vb21;
		W30 = Vb30;
		W31 = Vb31;
		W40 = Vb40;
		W41 = Vb41;
		W50 = Vb50;
		W51 = Vb51;
		W60 = Vb60;
		W61 = Vb61;
		W70 = Vb70;
		W71 = Vb71;
		W80 = DEC64BE(block +   0);
		W81 = DEC64BE(block +   8);
		W90 = DEC64BE(block +  16);
		W91 = DEC64BE(block +  24);
		WA0 = DEC64BE(block +  32);
		WA1 = DEC64BE(block +  40);
		WB0 = DEC64BE(block +  48);
		WB1 = DEC64BE(block +  56);
		WC0 = DEC64BE(block +  64);
		WC1 = DEC64BE(block +  72);
		WC1 &= 0xFFFFFFFF00000000;
		WC1 ^= SWAP4(gid);
		WD0 = 0x8000000000000000;
		WD1 = 0;
		WE0 = 0;
		WE1 = 0x200000000000000;
		WF0 = 0x280;
		WF1 = 0;

		for (unsigned u = 0; u < 10; u ++) {
				BIG_ROUND;
		}

		hash.h8[0] = DEC64BE(block +   0) ^ Vb00 ^ W00 ^ W80;
		hash.h8[1] = DEC64BE(block +   8) ^ Vb01 ^ W01 ^ W81;
		hash.h8[2] = DEC64BE(block +  16) ^ Vb10 ^ W10 ^ W90;
		hash.h8[3] = DEC64BE(block +  24) ^ Vb11 ^ W11 ^ W91;
		hash.h8[4] = DEC64BE(block +  32) ^ Vb20 ^ W20 ^ WA0;
		hash.h8[5] = DEC64BE(block +  40) ^ Vb21 ^ W21 ^ WA1;
		hash.h8[6] = DEC64BE(block +  48) ^ Vb30 ^ W30 ^ WB0;
		hash.h8[7] = DEC64BE(block +  56) ^ Vb31 ^ W31 ^ WB1;
	}
