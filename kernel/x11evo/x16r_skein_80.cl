
// skein
	{
		sph_u64 M0, M1, M2, M3, M4, M5, M6, M7;
		sph_u64 M8, M9;

		M0 = DEC64BE(block + 0);
		M1 = DEC64BE(block + 8);
		M2 = DEC64BE(block + 16);
		M3 = DEC64BE(block + 24);
		M4 = DEC64BE(block + 32);
		M5 = DEC64BE(block + 40);
		M6 = DEC64BE(block + 48);
		M7 = DEC64BE(block + 56);
		M8 = DEC64BE(block + 64);
		M9 = DEC64BE(block + 72);
		((uint*)&M9)[1] = SWAP4(gid);

		sph_u64 h0 = SPH_C64(0x4903ADFF749C51CE);
		sph_u64 h1 = SPH_C64(0x0D95DE399746DF03);
		sph_u64 h2 = SPH_C64(0x8FD1934127C79BCE);
		sph_u64 h3 = SPH_C64(0x9A255629FF352CB1);
		sph_u64 h4 = SPH_C64(0x5DB62599DF6CA7B0);
		sph_u64 h5 = SPH_C64(0xEABE394CA9D5C3F4);
		sph_u64 h6 = SPH_C64(0x991112C71A75B523);
		sph_u64 h7 = SPH_C64(0xAE18A40B660FCC33);
		sph_u64 h8 = SPH_C64(0xcab2076d98173ec4);

		sph_u64 t0 = 64;
		sph_u64 t1 = SPH_C64(0x7000000000000000);
		sph_u64 t2 = SPH_C64(0x7000000000000040); // t0 ^ t1;

		sph_u64 p0 = M0;
		sph_u64 p1 = M1;
		sph_u64 p2 = M2;
		sph_u64 p3 = M3;
		sph_u64 p4 = M4;
		sph_u64 p5 = M5;
		sph_u64 p6 = M6;
		sph_u64 p7 = M7;

		TFBIG_4e(0);
		TFBIG_4o(1);
		TFBIG_4e(2);
		TFBIG_4o(3);
		TFBIG_4e(4);
		TFBIG_4o(5);
		TFBIG_4e(6);
		TFBIG_4o(7);
		TFBIG_4e(8);
		TFBIG_4o(9);
		TFBIG_4e(10);
		TFBIG_4o(11);
		TFBIG_4e(12);
		TFBIG_4o(13);
		TFBIG_4e(14);
		TFBIG_4o(15);
		TFBIG_4e(16);
		TFBIG_4o(17);
		TFBIG_ADDKEY(p0, p1, p2, p3, p4, p5, p6, p7, h, t, 18);

		h0 = M0 ^ p0;
		h1 = M1 ^ p1;
		h2 = M2 ^ p2;
		h3 = M3 ^ p3;
		h4 = M4 ^ p4;
		h5 = M5 ^ p5;
		h6 = M6 ^ p6;
		h7 = M7 ^ p7;

		// second part with nonce
		p0 = M8;
		p1 = M9;
		p2 = p3 = p4 = p5 = p6 = p7 = 0;
		t0 = 80;
		t1 = SPH_C64(0xB000000000000000);
		t2 = SPH_C64(0xB000000000000050); // t0 ^ t1;
		h8 = h0 ^ h1 ^ h2 ^ h3 ^ h4 ^ h5 ^ h6 ^ h7 ^ SPH_C64(0x1BD11BDAA9FC1A22);

		TFBIG_4e(0);
		TFBIG_4o(1);
		TFBIG_4e(2);
		TFBIG_4o(3);
		TFBIG_4e(4);
		TFBIG_4o(5);
		TFBIG_4e(6);
		TFBIG_4o(7);
		TFBIG_4e(8);
		TFBIG_4o(9);
		TFBIG_4e(10);
		TFBIG_4o(11);
		TFBIG_4e(12);
		TFBIG_4o(13);
		TFBIG_4e(14);
		TFBIG_4o(15);
		TFBIG_4e(16);
		TFBIG_4o(17);
		TFBIG_ADDKEY(p0, p1, p2, p3, p4, p5, p6, p7, h, t, 18);
		h0 = p0 ^ M8;
		h1 = p1 ^ M9;
		h2 = p2;
		h3 = p3;
		h4 = p4;
		h5 = p5;
		h6 = p6;
		h7 = p7;

		// close
		t0 = 8;
		t1 = SPH_C64(0xFF00000000000000);
		t2 = SPH_C64(0xFF00000000000008); // t0 ^ t1;
		h8 = h0 ^ h1 ^ h2 ^ h3 ^ h4 ^ h5 ^ h6 ^ h7 ^ SPH_C64(0x1BD11BDAA9FC1A22);

		p0 = p1 = p2 = p3 = p4 = p5 = p6 = p7 = 0;

		TFBIG_4e(0);
		TFBIG_4o(1);
		TFBIG_4e(2);
		TFBIG_4o(3);
		TFBIG_4e(4);
		TFBIG_4o(5);
		TFBIG_4e(6);
		TFBIG_4o(7);
		TFBIG_4e(8);
		TFBIG_4o(9);
		TFBIG_4e(10);
		TFBIG_4o(11);
		TFBIG_4e(12);
		TFBIG_4o(13);
		TFBIG_4e(14);
		TFBIG_4o(15);
		TFBIG_4e(16);
		TFBIG_4o(17);
		TFBIG_ADDKEY(p0, p1, p2, p3, p4, p5, p6, p7, h, t, 18);

		hash.h8[0] = p0;
		hash.h8[1] = p1;
		hash.h8[2] = p2;
		hash.h8[3] = p3;
		hash.h8[4] = p4;
		hash.h8[5] = p5;
		hash.h8[6] = p6;
		hash.h8[7] = p7;
	}
