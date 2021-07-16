// Copyright (c) 2013, Miriam Ruiz <miriam@debian.org> - All rights reserved
//
// Redistribution and use in source and binary forms, with or without
// modification, are permitted provided that the following conditions are met:
//
// 1. Redistributions of source code must retain the above copyright notice,
// this list of conditions and the following disclaimer.
//
// 2. Redistributions in binary form must reproduce the above copyright notice,
//    this list of conditions and the following disclaimer in the documentation
//    and/or other materials provided with the distribution. 
//
// THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
// AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
// IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
// ARE DISCLAIMED.
//
// IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE LIABLE FOR ANY
// DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
// (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
// LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
// ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
// (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF
// THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

#ifndef TILESET_H_D0E4AD5C_90C1_11E2_BDF1__525400DA3F0D
#define TILESET_H_D0E4AD5C_90C1_11E2_BDF1__525400DA3F0D

#include <SFML/Graphics.hpp>
#include <SFML/System.hpp>

class ITileSet {
public:
	struct TileConfig {
		const char * FileName;
		uint32_t SolidFlags;
		int EdgeUp;
		int EdgeDown;
		int EdgeLeft;
		int EdgeRight;
		int Fill;
	};

	struct TileRuntime {
		sf::Texture Texture;
		sf::Sprite Sprite;
	};

	ITileSet(const TileConfig * config_data) :
			NumberOfTiles(0),
			TileConfigData(config_data),
			TileRuntimeData(NULL) {
		for (const TileConfig * tile = config_data; tile->FileName != NULL; ++tile) {
			++NumberOfTiles;
		}
		TileRuntimeData = new TileRuntime[NumberOfTiles];
	}

	virtual ~ITileSet() {
		if (TileRuntimeData) delete[] TileRuntimeData;
	}

	virtual int HMirrorEdge(int edge) const {
		return edge;
	}

	virtual int VMirrorEdge(int edge) const {
		return edge;
	}

	virtual int EdgesMatchError(int e1, int e2) const = 0;
	virtual unsigned int SolidTile() const = 0;
	virtual unsigned int EmptyTile() const = 0;

	// env is a binary number representing flags that describe the environment:
	// 0b(ul)(u)(ur)(l)(c)(r)(dl)(d)(dr)
	virtual unsigned int InitialTileGuess(uint32_t env) const = 0;

	// Load the sprite images and create the sprites
	bool LoadTileTextures(const char * base_dir);

	inline unsigned int NumTiles() const {
		return NumberOfTiles;
	}
	inline const TileConfig &GetTileConfig(unsigned int index) const {
		return TileConfigData[index];
	}
	inline const char * BaseFileName(unsigned int index) const {
		return TileConfigData[index].FileName;
	}
	inline uint32_t SolidFlags(unsigned int index) const {
		return TileConfigData[index].SolidFlags;
	}
	inline int EdgeUp(unsigned int index) const {
		return TileConfigData[index].EdgeUp;
	}
	inline int EdgeDown(unsigned int index) const {
		return TileConfigData[index].EdgeDown;
	}
	inline int EdgeLeft(unsigned int index) const {
		return TileConfigData[index].EdgeLeft;
	}
	inline int EdgeRight(unsigned int index) const {
		return TileConfigData[index].EdgeRight;
	}
	inline int Fill(unsigned int index) const {
		return TileConfigData[index].Fill;
	}
	inline TileRuntime & GetTileRuntimeData(unsigned int index) {
		return TileRuntimeData[index];
	}
	inline sf::Texture & GetTexture(unsigned int index) {
		return TileRuntimeData[index].Texture;
	}
	inline sf::Sprite & GetSprite(unsigned int index) {
		return TileRuntimeData[index].Sprite;
	}

protected:
	unsigned int NumberOfTiles;
	const TileConfig * TileConfigData;
	TileRuntime * TileRuntimeData;
};

class TileSet : public ITileSet {
public:
	TileSet() : ITileSet(TileData_Config) {
	}

	virtual ~TileSet() {
	}

	enum {
		// B(lock) + S(olid)/E(mpty) + U(p)/D(own)/L(eft)/R(ight)
		BS = 1 << 0, BSU = 1 << 1, BSD = 1 << 2, BSL = 1 << 3, BSR = 1 << 4,
		BE = 1 << 5, BEU = 1 << 6, BED = 1 << 7, BEL = 1 << 8, BER = 1 << 9,
	};

	enum {
		EMPTY, SOLID,
		HALF_UP, HALF_DOWN, HALF_LEFT, HALF_RIGHT,

		SYMMETRIC_EDGES_MAX = HALF_RIGHT,

		// E(mpty)/S(olid)/H(alf)/O(ppositehalf) + COR(ner) + _ + UP/DOWN/LEFT/RIGHT + T(angential)/N(ormal)
		ECOR_UPT = ((SYMMETRIC_EDGES_MAX + 1) & 254),
		ECOR_UPN,    SCOR_UPT,    SCOR_UPN,    HCOR_UPT,    HCOR_UPN,    OCOR_UPT,    OCOR_UPN,
		ECOR_DOWNT,  ECOR_DOWNN,  SCOR_DOWNT,  SCOR_DOWNN,  HCOR_DOWNT,  HCOR_DOWNN,  OCOR_DOWNT,  OCOR_DOWNN,
		ECOR_LEFTT,  ECOR_LEFTN,  SCOR_LEFTT,  SCOR_LEFTN,  HCOR_LEFTT,  HCOR_LEFTN,  OCOR_LEFTT,  OCOR_LEFTN,
		ECOR_RIGHTT, ECOR_RIGHTN, SCOR_RIGHTT, SCOR_RIGHTN, HCOR_RIGHTT, HCOR_RIGHTN, OCOR_RIGHTT, OCOR_RIGHTN,

		// E(mpty)/S(olid) + BI + CORNER + T(angential)/N(ormal)
		EBICORNERT,  EBICORNERN,  SBICORNERT,  SBICORNERN,

		COMPLEMENTARY_EDGES_MAX = SBICORNERN,
	};

	virtual int HMirrorEdge(int edge) const {
		return edge;
	}

	virtual int VMirrorEdge(int edge) const {
		return edge;
	}

	virtual int EdgesMatchError(int e1, int e2) const;

	enum {
		TILE_EMPTY = 0,
		TILE_SOLID = 1,

		TILE_HALF_U = 4,
		TILE_HALF_D = 2,
		TILE_HALF_L = 3,
		TILE_HALF_R = 5,

		TILE_HALF_UL = 32,
		TILE_HALF_UR = 33,
		TILE_HALF_DL = 31,
		TILE_HALF_DR = 30,

		TILE_ECOR_UL = 6,
		TILE_ECOR_UR = 7,
		TILE_ECOR_DL = 8,
		TILE_ECOR_DR = 9,

		TILE_SCOR_UL = 10,
		TILE_SCOR_UR = 11,
		TILE_SCOR_DL = 13,
		TILE_SCOR_DR = 12,

		TILE_OUT_U = 78,
		TILE_OUT_D = 80,
		TILE_OUT_L = 81,
		TILE_OUT_R = 79,

		TILE_IN_U = 82,
		TILE_IN_D = 84,
		TILE_IN_L = 85,
		TILE_IN_R = 83,
	};

	virtual unsigned int SolidTile() const {
		return TILE_SOLID;
	}

	virtual unsigned int EmptyTile() const {
		return TILE_EMPTY;
	}

	// env is a binary number representing flags that describe the environment:
	// 0b(ul)(u)(ur)(l)(c)(r)(dl)(d)(dr)
	virtual unsigned int InitialTileGuess(uint32_t env) const;

private:
	static const TileConfig TileData_Config[];
};

#endif // TILESET_H_D0E4AD5C_90C1_11E2_BDF1__525400DA3F0D

