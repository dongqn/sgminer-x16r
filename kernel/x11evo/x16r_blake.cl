
// blake
	{
		sph_u64 H0 = SPH_C64(0x6A09E667F3BCC908), H1 = SPH_C64(0xBB67AE8584CAA73B);
		sph_u64 H2 = SPH_C64(0x3C6EF372FE94F82B), H3 = SPH_C64(0xA54FF53A5F1D36F1);
		sph_u64 H4 = SPH_C64(0x510E527FADE682D1), H5 = SPH_C64(0x9B05688C2B3E6C1F);
		sph_u64 H6 = SPH_C64(0x1F83D9ABFB41BD6B), H7 = SPH_C64(0x5BE0CD19137E2179);
		sph_u64 S0 = 0, S1 = 0, S2 = 0, S3 = 0;
		sph_u64 T0 = SPH_C64(0xFFFFFFFFFFFFFC00) + (64 << 3), T1 = 0xFFFFFFFFFFFFFFFF;;

		if ((T0 = SPH_T64(T0 + 1024)) < 1024)
		{
			T1 = SPH_T64(T1 + 1);
		}
		sph_u64 M0, M1, M2, M3, M4, M5, M6, M7;
		sph_u64 M8, M9, MA, MB, MC, MD, ME, MF;
		sph_u64 V0, V1, V2, V3, V4, V5, V6, V7;
		sph_u64 V8, V9, VA, VB, VC, VD, VE, VF;
		M0 = hash.h8[0];
		M1 = hash.h8[1];
		M2 = hash.h8[2];
		M3 = hash.h8[3];
		M4 = hash.h8[4];
		M5 = hash.h8[5];
		M6 = hash.h8[6];
		M7 = hash.h8[7];
		M8 = 0x8000000000000000;
		M9 = 0;
		MA = 0;
		MB = 0;
		MC = 0;
		MD = 1;
		ME = 0;
		MF = 0x200;

		COMPRESS64;

		hash.h8[0] = H0;
		hash.h8[1] = H1;
		hash.h8[2] = H2;
		hash.h8[3] = H3;
		hash.h8[4] = H4;
		hash.h8[5] = H5;
		hash.h8[6] = H6;
		hash.h8[7] = H7;
	}
