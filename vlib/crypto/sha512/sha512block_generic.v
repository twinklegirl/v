// Copyright (c) 2019 Alexander Medvednikov. All rights reserved.
// Use of this source code is governed by an MIT license
// that can be found in the LICENSE file.

// SHA512 block step.
// This is the generic version with no architecture optimizations.
// In its own file so that an architecture
// optimized verision can be substituted

module sha512

const(
	_K = [
		0x428a2f98d728ae22,
		0x7137449123ef65cd,
		0xb5c0fbcfec4d3b2f,
		0xe9b5dba58189dbbc,
		0x3956c25bf348b538,
		0x59f111f1b605d019,
		0x923f82a4af194f9b,
		0xab1c5ed5da6d8118,
		0xd807aa98a3030242,
		0x12835b0145706fbe,
		0x243185be4ee4b28c,
		0x550c7dc3d5ffb4e2,
		0x72be5d74f27b896f,
		0x80deb1fe3b1696b1,
		0x9bdc06a725c71235,
		0xc19bf174cf692694,
		0xe49b69c19ef14ad2,
		0xefbe4786384f25e3,
		0x0fc19dc68b8cd5b5,
		0x240ca1cc77ac9c65,
		0x2de92c6f592b0275,
		0x4a7484aa6ea6e483,
		0x5cb0a9dcbd41fbd4,
		0x76f988da831153b5,
		0x983e5152ee66dfab,
		0xa831c66d2db43210,
		0xb00327c898fb213f,
		0xbf597fc7beef0ee4,
		0xc6e00bf33da88fc2,
		0xd5a79147930aa725,
		0x06ca6351e003826f,
		0x142929670a0e6e70,
		0x27b70a8546d22ffc,
		0x2e1b21385c26c926,
		0x4d2c6dfc5ac42aed,
		0x53380d139d95b3df,
		0x650a73548baf63de,
		0x766a0abb3c77b2a8,
		0x81c2c92e47edaee6,
		0x92722c851482353b,
		0xa2bfe8a14cf10364,
		0xa81a664bbc423001,
		0xc24b8b70d0f89791,
		0xc76c51a30654be30,
		0xd192e819d6ef5218,
		0xd69906245565a910,
		0xf40e35855771202a,
		0x106aa07032bbd1b8,
		0x19a4c116b8d2d0c8,
		0x1e376c085141ab53,
		0x2748774cdf8eeb99,
		0x34b0bcb5e19b48a8,
		0x391c0cb3c5c95a63,
		0x4ed8aa4ae3418acb,
		0x5b9cca4f7763e373,
		0x682e6ff3d6b2b8a3,
		0x748f82ee5defb2fc,
		0x78a5636f43172f60,
		0x84c87814a1f0ab72,
		0x8cc702081a6439ec,
		0x90befffa23631e28,
		0xa4506cebde82bde9,
		0xbef9a3f7b2c67915,
		0xc67178f2e372532b,
		0xca273eceea26619c,
		0xd186b8c721c0c207,
		0xeada7dd6cde0eb1e,
		0xf57d4f7fee6ed178,
		0x06f067aa72176fba,
		0x0a637dc5a2c898a6,
		0x113f9804bef90dae,
		0x1b710b35131c471b,
		0x28db77f523047d84,
		0x32caab7b40c72493,
		0x3c9ebe0a15c9bebc,
		0x431d67c49c100d4c,
		0x4cc5d4becb3e42b6,
		0x597f299cfc657e2a,
		0x5fcb6fab3ad6faec,
		0x6c44198c4a475817,
	]
)

fn block_generic(dig mut Digest, p_ []byte) {
	mut p := p_
	
	mut w := [u64(0); 80]
	
	mut h0 := dig.h[0]
	mut h1 := dig.h[1]
	mut h2 := dig.h[2]
	mut h3 := dig.h[3]
	mut h4 := dig.h[4]
	mut h5 := dig.h[5]
	mut h6 := dig.h[6]
	mut h7 := dig.h[7]
	
	for p.len >= Chunk {
		for i := 0; i < 16; i++ {
			j := i * 8
			w[i] = u64(u64(u64(p[j])<<u64(56)) | u64(u64(p[j+1])<<u64(48)) | u64(u64(p[j+2])<<u64(40)) | u64(u64(p[j+3])<<u64(32)) |
				u64(u64(p[j+4])<<u64(24)) | u64(u64(p[j+5])<<u64(16)) | u64(u64(p[j+6])<<u64(8)) | u64(p[j+7]))
		}
		for i := 16; i < 80; i++ {
			v1 := w[i-2]
			t1 := (u64(v1>>u64(19)) | u64(v1<<u64(64-19))) ^ u64(u64(v1>>u64(61)) | u64(v1<<u64(64-61))) ^ u64(v1 >> u64(6))
			v2 := w[i-15]
			t2 := (u64(v2>>u64(1)) | u64(v2<<u64(64-1))) ^ u64(u64(v2>>u64(8)) | u64(v2<<u64(64-8))) ^ u64(v2 >> u64(7))

			w[i] = t1 + w[i-7] + t2 + w[i-16]
		}

		mut a := h0
		mut b := h1
		mut c := h2
		mut d := h3
		mut e := h4
		mut f := h5
		mut g := h6
		mut h := h7

		for i := 0; i < 80; i++ {
			t1 := h + (u64(u64(e>>u64(14)) | u64(e<<u64(64-14))) ^ u64(u64(e>>u64(18)) | u64(e<<u64(64-18))) ^ u64(u64(e>>u64(41)) | u64(e<<u64(64-41)))) + ((e & f) ^ (~e & g)) + _K[i] + w[i]
			t2 := (u64(u64(a>>u64(28)) | u64(a<<u64(64-28))) ^ u64(u64(a>>u64(34)) | u64(a<<u64(64-34))) ^ u64(u64(a>>u64(39)) | u64(a<<u64(64-39)))) + ((a & b) ^ (a & c) ^ (b & c))
			h = g
			g = f
			f = e
			e = d + t1
			d = c
			c = b
			b = a
			a = t1 + t2
		}

		h0 += a
		h1 += b
		h2 += c
		h3 += d
		h4 += e
		h5 += f
		h6 += g
		h7 += h

		if Chunk >= p.len {
			p = []byte
		} else {
			p = p.right(Chunk)
		}
	}

	dig.h[0] = h0
	dig.h[1] = h1
	dig.h[2] = h2
	dig.h[3] = h3
	dig.h[4] = h4
	dig.h[5] = h5
	dig.h[6] = h6
	dig.h[7] = h7
}
