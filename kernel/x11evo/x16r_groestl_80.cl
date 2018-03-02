
// groestl
	{
		sph_u64 H[16];
		for (unsigned int u = 0; u < 15; u ++)
				H[u] = 0;
		#if USE_LE
				H[15] = ((sph_u64)(512 & 0xFF) << 56) | ((sph_u64)(512 & 0xFF00) << 40);
		#else
				H[15] = (sph_u64)512;
		#endif

		sph_u64 g[16], m[16];
		m[0] = DEC64BE(block + 0 * 8);
		m[1] = DEC64BE(block + 1 * 8);
		m[2] = DEC64BE(block + 2 * 8);
		m[3] = DEC64BE(block + 3 * 8);
		m[4] = DEC64BE(block + 4 * 8);
		m[5] = DEC64BE(block + 5 * 8);
		m[6] = DEC64BE(block + 6 * 8);
		m[7] = DEC64BE(block + 7 * 8);
		m[8] = DEC64BE(block + 8 * 8);
		m[9] = DEC64BE(block + 9 * 8);
		m[9] &= 0xFFFFFFFF00000000;
		m[9] ^= SWAP4(gid);

		for (unsigned int u = 0; u < 16; u ++)
				g[u] = m[u] ^ H[u];
		m[10] = 0x80; g[10] = m[10] ^ H[10];
		m[11] = 0; g[11] = m[11] ^ H[11];
		m[12] = 0; g[12] = m[12] ^ H[12];
		m[13] = 0; g[13] = m[13] ^ H[13];
		m[14] = 0; g[14] = m[14] ^ H[14];
		m[15] = 0x100000000000000; g[15] = m[15] ^ H[15];
		PERM_BIG_P(g);
		PERM_BIG_Q(m);

		for (unsigned int u = 0; u < 16; u ++)
				H[u] ^= g[u] ^ m[u];
		sph_u64 xH[16];

		for (unsigned int u = 0; u < 16; u ++)
				xH[u] = H[u];
		PERM_BIG_P(xH);

		for (unsigned int u = 0; u < 16; u ++)
				H[u] ^= xH[u];

		for (unsigned int u = 0; u < 8; u ++)
				hash.h8[u] = H[u + 8];
	}
