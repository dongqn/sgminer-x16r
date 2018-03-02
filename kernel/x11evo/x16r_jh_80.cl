
// jh
	{
		sph_u64 h0h = C64e(0x6fd14b963e00aa17), h0l = C64e(0x636a2e057a15d543), h1h = C64e(0x8a225e8d0c97ef0b), h1l = C64e(0xe9341259f2b3c361), h2h = C64e(0x891da0c1536f801e), h2l = C64e(0x2aa9056bea2b6d80), h3h = C64e(0x588eccdb2075baa6), h3l = C64e(0xa90f3a76baf83bf7);
		sph_u64 h4h = C64e(0x0169e60541e34a69), h4l = C64e(0x46b58a8e2e6fe65a), h5h = C64e(0x1047a7d0c1843c24), h5l = C64e(0x3b6e71b12d5ac199), h6h = C64e(0xcf57f6ec9db1f856), h6l = C64e(0xa706887c5716b156), h7h = C64e(0xe3c2fcdfe68517fb), h7l = C64e(0x545a4678cc8cdd4b);
		sph_u64 tmp;

		for (int i = 0; i < 4; i++)
		{
			if (i == 0) {
				h0h ^= DEC64BE(block +  0);
				h0l ^= DEC64BE(block +  8);
				h1h ^= DEC64BE(block + 16);
				h1l ^= DEC64BE(block + 24);
				h2h ^= DEC64BE(block + 32);
				h2l ^= DEC64BE(block + 40);
				h3h ^= DEC64BE(block + 48);
				h3l ^= DEC64BE(block + 56);
			}
			else if (i == 1) {
				h4h ^= DEC64BE(block +  0);
				h4l ^= DEC64BE(block +  8);
				h5h ^= DEC64BE(block + 16);
				h5l ^= DEC64BE(block + 24);
				h6h ^= DEC64BE(block + 32);
				h6l ^= DEC64BE(block + 40);
				h7h ^= DEC64BE(block + 48);
				h7l ^= DEC64BE(block + 56);
			}
			else if (i == 3) {
				h0h ^= DEC64E(block + 64);
				h0l ^= (DEC64E(block + 72) & 0xFFFFFFFF00000000) ^ SWAP4(gid);
				h1h ^= 0x80;
			}
			else if (i == 4) {
				h4h ^= DEC64E(block + 64);
				h4l ^= (DEC64E(block + 72) & 0xFFFFFFFF00000000) ^ SWAP4(gid);
				h5h ^= 0x80;
				h3l ^= 0x8002000000000000U;
			}
			E8;
		}

		h7l ^= 0x8002000000000000U;

		hash.h8[0] = DEC64E(h4h);
		hash.h8[1] = DEC64E(h4l);
		hash.h8[2] = DEC64E(h5h);
		hash.h8[3] = DEC64E(h5l);
		hash.h8[4] = DEC64E(h6h);
		hash.h8[5] = DEC64E(h6l);
		hash.h8[6] = DEC64E(h7h);
		hash.h8[7] = DEC64E(h7l);
	}
