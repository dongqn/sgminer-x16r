
// whirlpool
	{
		__local sph_u64 LT0[256], LT1[256], LT2[256], LT3[256], LT4[256], LT5[256], LT6[256], LT7[256];
		sph_u64 n0, n1, n2, n3, n4, n5, n6, n7;
		sph_u64 h0, h1, h2, h3, h4, h5, h6, h7;
		sph_u64 state[8];

		h0 = h1 = h2 = h3 = h4 = h5 = h6 = h7 = 0;

		n0 = DEC64BE(block +    0);
		n1 = DEC64BE(block +    8);
		n2 = DEC64BE(block +   16);
		n3 = DEC64BE(block +   24);
		n4 = DEC64BE(block +   32);
		n5 = DEC64BE(block +   40);
		n6 = DEC64BE(block +   48);
		n7 = DEC64BE(block +   56);

		#pragma unroll 10
		for (unsigned r = 0; r < 10; r ++)
		{
			sph_u64 tmp0, tmp1, tmp2, tmp3, tmp4, tmp5, tmp6, tmp7;

			ROUND_KSCHED(plain_T, h, tmp, plain_RC[r]);
			TRANSFER(h, tmp);
			ROUND_WENC(plain_T, n, h, tmp);
			TRANSFER(n, tmp);
		}

		h0 = state[0] = n0 ^ DEC64BE(block +   0);
		h1 = state[1] = n1 ^ DEC64BE(block +   8);
		h2 = state[2] = n2 ^ DEC64BE(block +   16);
		h3 = state[3] = n3 ^ DEC64BE(block +   24);
		h4 = state[4] = n4 ^ DEC64BE(block +   32);
		h5 = state[5] = n5 ^ DEC64BE(block +   40);
		h6 = state[6] = n6 ^ DEC64BE(block +   48);
		h7 = state[7] = n7 ^ DEC64BE(block +   56);


		n0 = DEC64BE(block +  64);
		n1 = DEC64BE(block +  72);
		n1 &= 0xFFFFFFFF00000000;
		n1 ^= SWAP4(gid);
		n3 = n4 = n5 = n6 = 0;
		n2 = 0x8000000000000000;
		n7 = 0x280;
		sph_u64 temp0,temp1,temp2,temp7;
		temp0 = n0;
		temp1 = n1;
		temp2 = n2;
		temp7 = n7;

		n0 ^= h0;
		n1 ^= h1;
		n2 ^= h2;
		n3 ^= h3;
		n4 ^= h4;
		n5 ^= h5;
		n6 ^= h6;
		n7 ^= h7;

		#pragma unroll 10
		for (unsigned r = 0; r < 10; r ++)
		{
			sph_u64 tmp0, tmp1, tmp2, tmp3, tmp4, tmp5, tmp6, tmp7;

			ROUND_KSCHED(LT, h, tmp, plain_RC[r]);
			TRANSFER(h, tmp);
			ROUND_WENC(plain_T, n, h, tmp);
			TRANSFER(n, tmp);
		}

		hash.h8[0] = state[0] ^ n0 ^ temp0;
		hash.h8[1] = state[1] ^ n1 ^ temp1;
		hash.h8[2] = state[2] ^ n2 ^ temp2;
		hash.h8[3] = state[3] ^ n3;
		hash.h8[4] = state[4] ^ n4;
		hash.h8[5] = state[5] ^ n5;
		hash.h8[6] = state[6] ^ n6;
		hash.h8[7] = state[7] ^ n7 ^ temp7;
	}
