
// hamsi
	{
		sph_u32 c0 = HAMSI_IV512[0], c1 = HAMSI_IV512[1], c2 = HAMSI_IV512[2], c3 = HAMSI_IV512[3];
		sph_u32 c4 = HAMSI_IV512[4], c5 = HAMSI_IV512[5], c6 = HAMSI_IV512[6], c7 = HAMSI_IV512[7];
		sph_u32 c8 = HAMSI_IV512[8], c9 = HAMSI_IV512[9], cA = HAMSI_IV512[10], cB = HAMSI_IV512[11];
		sph_u32 cC = HAMSI_IV512[12], cD = HAMSI_IV512[13], cE = HAMSI_IV512[14], cF = HAMSI_IV512[15];
		sph_u32 m0, m1, m2, m3, m4, m5, m6, m7;
		sph_u32 m8, m9, mA, mB, mC, mD, mE, mF;
		sph_u32 h[16] = { c0, c1, c2, c3, c4, c5, c6, c7, c8, c9, cA, cB, cC, cD, cE, cF };

		#define buf(u) hash.h1[i + u]
		for(int i = 0; i < 64; i += 8) {
			INPUT_BIG;
			P_BIG;
			T_BIG;
		}
		#undef buf
		#define buf(u) (u == 0 ? 0x80 : 0)
		INPUT_BIG;
		P_BIG;
		T_BIG;
		#undef buf
		#define buf(u) (u == 6 ? 2 : 0)
		INPUT_BIG;
		PF_BIG;
		T_BIG;
		#undef buf

		for (unsigned u = 0; u < 16; u ++)
			hash.h4[u] = h[u];
	}
