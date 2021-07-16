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

#include "tileset.h"

#include <sys/types.h>
#include <SFML/Graphics.hpp>
#include <SFML/System.hpp>
#include <cstdlib>
#include <cstdio>
#include <cstring>
#include <cmath>
#include <climits>

bool ITileSet::LoadTileTextures(const char * base_dir) {
	for (unsigned int i = 0; i < NumTiles(); ++i) {
		char filename[32];
		snprintf(filename, sizeof(filename), "%s/%s", base_dir, BaseFileName(i));
		printf("Loading '%s'\n", filename);
		if (!TileRuntimeData[i].Texture.loadFromFile(filename)) {
			return false;
		}
		TileRuntimeData[i].Texture.setSmooth(false);
		TileRuntimeData[i].Sprite = sf::Sprite(TileRuntimeData[i].Texture);
	}
	return true;
}


const TileSet::TileConfig TileSet::TileData_Config[] = {
	// FileName         SolidFlags          EdgeUp       EdgeDown     EdgeLeft     EdgeRight    Fill
	{ "A1.png",  BE+BEU+BED+BER+BEL, EMPTY,       EMPTY,       EMPTY,       EMPTY       ,   0 }, // 00 " "
	{ "A2.png",  BS+BSU+BSD+BSR+BSL, SOLID,       SOLID,       SOLID,       SOLID       , 100 }, // 01 "█"
	{ "B1.png",  BEU+BSD,            EMPTY,       SOLID,       HALF_DOWN,   HALF_DOWN   ,  50 }, // 02 "▄"
	{ "B2.png",  BER+BSL,            HALF_LEFT,   HALF_LEFT,   SOLID,       EMPTY       ,  50 }, // 03 "▌"
	{ "B3.png",  BED+BSU,            SOLID,       EMPTY,       HALF_UP,     HALF_UP     ,  50 }, // 04 "▀"
	{ "B4.png",  BEL+BSR,            HALF_RIGHT,  HALF_RIGHT,  EMPTY,       SOLID       ,  50 }, // 05 "▐"
	{ "C11.png", BEU+BEL,            EMPTY,       HALF_RIGHT,  EMPTY,       HALF_DOWN   ,  25 }, // 06 "▗"
	{ "C12.png", BEU+BER,            EMPTY,       HALF_LEFT,   HALF_DOWN,   EMPTY       ,  25 }, // 07 "▖"
	{ "C13.png", BED+BER,            HALF_LEFT,   EMPTY,       HALF_UP,     EMPTY       ,  25 }, // 08 "▘"
	{ "C14.png", BED+BEL,            HALF_RIGHT,  EMPTY,       EMPTY,       HALF_UP     ,  25 }, // 09 "▝"
	{ "C21.png", BSU+BSL,            SOLID,       HALF_LEFT,   SOLID,       HALF_UP     ,  75 }, // 10 "▛"
	{ "C22.png", BSU+BSR,            SOLID,       HALF_RIGHT,  HALF_UP,     SOLID       ,  75 }, // 11 "▜"
	{ "C23.png", BSD+BSR,            HALF_RIGHT,  SOLID,       HALF_DOWN,   SOLID       ,  75 }, // 12 "▟"
	{ "C24.png", BSD+BSL,            HALF_LEFT,   SOLID,       SOLID,       HALF_DOWN   ,  75 }, // 13 "▙"

	// Open Corners
	{ "D11.png", BSD+BEU,            EMPTY,       SCOR_LEFTN,  ECOR_DOWNN,  HALF_DOWN   ,  35 }, // 14
	{ "D12.png", BSD+BEU,            EMPTY,       SCOR_RIGHTN, HALF_DOWN,   ECOR_DOWNN  ,  35 }, // 15
	{ "D13.png", BSL+BER,            ECOR_LEFTN,  HALF_LEFT,   SCOR_UPN,    EMPTY       ,  35 }, // 16
	{ "D14.png", BSL+BER,            HALF_LEFT,   ECOR_LEFTN,  SCOR_DOWNN,  EMPTY       ,  35 }, // 17
	{ "D15.png", BSU+BED,            SCOR_RIGHTN, EMPTY,       HALF_UP,     ECOR_UPN    ,  35 }, // 18
	{ "D16.png", BSU+BED,            SCOR_LEFTN,  EMPTY,       ECOR_UPN,    HALF_UP     ,  35 }, // 19
	{ "D17.png", BSR+BEL,            HALF_RIGHT,  ECOR_RIGHTN, EMPTY,       SCOR_DOWNN  ,  35 }, // 20
	{ "D18.png", BSR+BEL,            ECOR_RIGHTN, HALF_RIGHT,  EMPTY,       SCOR_UPN    ,  35 }, // 21
	{ "D21.png", BED+BSU,            SOLID,       ECOR_LEFTN,  SCOR_DOWNN,  HALF_UP     ,  65 }, // 22
	{ "D22.png", BED+BSU,            SOLID,       ECOR_RIGHTN, HALF_UP,     SCOR_UPN    ,  65 }, // 23
	{ "D23.png", BEL+BSR,            SCOR_LEFTN,  HALF_RIGHT,  ECOR_UPN,    SOLID       ,  65 }, // 24
	{ "D24.png", BEL+BSR,            HALF_RIGHT,  SCOR_LEFTN,  ECOR_DOWNN,  SOLID       ,  65 }, // 25
	{ "D25.png", BEU+BSD,            ECOR_RIGHTN, SOLID,       HALF_DOWN,   SCOR_UPN    ,  65 }, // 26
	{ "D26.png", BEU+BSD,            ECOR_LEFTN,  SOLID,       SCOR_UPN,    HALF_DOWN   ,  65 }, // 27
	{ "D27.png", BER+BSL,            HALF_LEFT,   SCOR_RIGHTN, SOLID,       ECOR_DOWNN  ,  65 }, // 28
	{ "D28.png", BER+BSL,            SCOR_RIGHTN, HALF_LEFT,   SOLID,       ECOR_UPN    ,  65 }, // 29

	// Oblique Tiles
	{ "E1.png",  BEU+BSR+BSD+BEL,    ECOR_RIGHTN, SCOR_LEFTN,  ECOR_DOWNN,  SCOR_UPN    ,  50 }, // 30
	{ "E2.png",  BEU+BER+BSD+BSL,    ECOR_LEFTN,  SCOR_RIGHTN, SCOR_UPN,    ECOR_DOWNN  ,  50 }, // 31
	{ "E3.png",  BSU+BER+BED+BSL,    SCOR_RIGHTN, ECOR_LEFTN,  SCOR_DOWNN,  ECOR_UPN    ,  50 }, // 32
	{ "E4.png",  BSU+BSR+BED+BEL,    SCOR_LEFTN,  ECOR_RIGHTN, ECOR_UPN,    SCOR_DOWNN  ,  50 }, // 33
	{ "F11.png", BE+BEU+BED+BER+BEL, ECOR_LEFTT,  EMPTY,       ECOR_UPT,    EMPTY       ,   5 }, // 34 "⦍"
	{ "F12.png", BE+BEU+BED+BER+BEL, ECOR_RIGHTT, EMPTY,       EMPTY,       ECOR_UPT    ,   5 }, // 35 "⦐"
	{ "F13.png", BE+BEU+BED+BER+BEL, EMPTY,       ECOR_RIGHTT, EMPTY,       ECOR_DOWNT  ,   5 }, // 36 "⦎"
	{ "F14.png", BE+BEU+BED+BER+BEL, EMPTY,       ECOR_LEFTT,  ECOR_DOWNT,  EMPTY       ,   5 }, // 37 "⦏"
	{ "F15.png", BE+BEU+BED+BER+BEL, ECOR_LEFTT,  ECOR_RIGHTT, ECOR_UPT,    ECOR_DOWNT  ,  10 }, // 38
	{ "F16.png", BE+BEU+BED+BER+BEL, ECOR_RIGHTT, ECOR_LEFTT,  ECOR_DOWNT,  ECOR_UPT    ,  10 }, // 39
	{ "F21.png", BS+BSU+BSD+BSR+BSL, SCOR_LEFTT,  SOLID,       SCOR_UPT,    SOLID       ,  95 }, // 40 "⦍"
	{ "F22.png", BS+BSU+BSD+BSR+BSL, SCOR_RIGHTT, SOLID,       SOLID,       SCOR_UPT    ,  95 }, // 41 "⦐"
	{ "F23.png", BS+BSU+BSD+BSR+BSL, SOLID,       SCOR_RIGHTT, SOLID,       SCOR_DOWNT  ,  95 }, // 42 "⦎"
	{ "F24.png", BS+BSU+BSD+BSR+BSL, SOLID,       SCOR_LEFTT,  SCOR_DOWNT,  SOLID       ,  95 }, // 43 "⦏"
	{ "F25.png", BS+BSU+BSD+BSR+BSL, SCOR_LEFTT,  SCOR_RIGHTT, SCOR_UPT,    SCOR_DOWNT  ,  90 }, // 44
	{ "F26.png", BS+BSU+BSD+BSR+BSL, SCOR_RIGHTT, SCOR_LEFTT,  SCOR_DOWNT,  SCOR_UPT    ,  90 }, // 45

	// Close Corners
	{ "G11.png", BEU+BER+BEL,        EMPTY,       HCOR_LEFTN,  ECOR_DOWNN,  EMPTY       ,  15 }, // 46
	{ "G12.png", BEU+BER+BEL,        EMPTY,       HCOR_RIGHTN, EMPTY,       ECOR_DOWNN  ,  15 }, // 47
	{ "G13.png", BER+BED+BEU,        ECOR_LEFTN,  EMPTY,       HCOR_UPN,    EMPTY       ,  15 }, // 48
	{ "G14.png", BER+BED+BEU,        EMPTY,       ECOR_LEFTN,  HCOR_DOWNN,  EMPTY       ,  15 }, // 49
	{ "G15.png", BED+BEL+BER,        HCOR_RIGHTN, EMPTY,       EMPTY,       ECOR_UPN    ,  15 }, // 50
	{ "G16.png", BED+BEL+BER,        HCOR_LEFTN,  EMPTY,       ECOR_UPN,    EMPTY       ,  15 }, // 51
	{ "G17.png", BEL+BEU+BED,        EMPTY,       ECOR_RIGHTN, EMPTY,       SCOR_DOWNN  ,  15 }, // 52
	{ "G18.png", BEL+BEU+BED,        ECOR_RIGHTN, EMPTY,       EMPTY,       SCOR_UPN    ,  15 }, // 53
	{ "G21.png", BSU+BSR+BSL,        SOLID,       OCOR_LEFTN,  SCOR_DOWNN,  SOLID       ,  85 }, // 54
	{ "G22.png", BSU+BSR+BSL,        SOLID,       OCOR_RIGHTN, SOLID,       SCOR_DOWNN  ,  85 }, // 55
	{ "G23.png", BSR+BSD+BSU,        SCOR_LEFTN,  SOLID,       OCOR_UPN,    SOLID       ,  85 }, // 56
	{ "G24.png", BSR+BSD+BSU,        SOLID,       SCOR_LEFTN,  OCOR_DOWNN,  SOLID       ,  85 }, // 57
	{ "G25.png", BSD+BSL+BSR,        OCOR_RIGHTN, SOLID,       SOLID,       SCOR_UPN    ,  85 }, // 58
	{ "G26.png", BSD+BSL+BSR,        OCOR_LEFTN,  SOLID,       SCOR_UPN,    SOLID       ,  85 }, // 59
	{ "G27.png", BSL+BSU+BSD,        SOLID,       SCOR_RIGHTN, SOLID,       OCOR_DOWNN  ,  85 }, // 60
	{ "G28.png", BSL+BSU+BSD,        SCOR_RIGHTN, SOLID,       SOLID,       OCOR_UPN    ,  85 }, // 61
	{ "H11.png", BER,                HCOR_LEFTT,  HALF_LEFT,   SCOR_UPT,    EMPTY       ,  45 }, // 62
	{ "H12.png", BEL,                HCOR_RIGHTT, HALF_RIGHT,  EMPTY,       SCOR_UPT    ,  45 }, // 63
	{ "H13.png", BED,                SCOR_RIGHTT, EMPTY,       HALF_UP,     HCOR_UPT    ,  45 }, // 64
	{ "H14.png", BEU,                EMPTY,       SCOR_RIGHTT, HALF_DOWN,   HCOR_DOWNT  ,  45 }, // 65
	{ "H15.png", BEL,                HALF_RIGHT,  HCOR_RIGHTT, EMPTY,       SCOR_DOWNT  ,  45 }, // 66
	{ "H16.png", BER,                HALF_LEFT,   HCOR_LEFTT,  SCOR_DOWNT,  EMPTY       ,  45 }, // 67
	{ "H17.png", BEU,                EMPTY,       SCOR_LEFTT,  HCOR_DOWNT,  HALF_DOWN   ,  45 }, // 68
	{ "H18.png", BED,                SCOR_LEFTT,  EMPTY,       HCOR_UPT,    HALF_UP     ,  45 }, // 69
	{ "H21.png", BSR,                OCOR_LEFTT,  HALF_RIGHT,  ECOR_UPT,    SOLID       ,  55 }, // 70
	{ "H22.png", BSL,                OCOR_RIGHTT, HALF_LEFT,   SOLID,       ECOR_UPT    ,  55 }, // 71
	{ "H23.png", BSD,                ECOR_RIGHTT, SOLID,       HALF_DOWN,   OCOR_UPT    ,  55 }, // 72
	{ "H24.png", BSU,                SOLID,       ECOR_RIGHTT, HALF_UP,     OCOR_DOWNT  ,  55 }, // 73
	{ "H25.png", BSL,                HALF_LEFT,   OCOR_RIGHTT, SOLID,       ECOR_DOWNT  ,  55 }, // 74
	{ "H26.png", BSR,                HALF_RIGHT,  OCOR_LEFTT,  ECOR_DOWNT,  SOLID       ,  55 }, // 75
	{ "H27.png", BSU,                SOLID,       ECOR_LEFTT,  OCOR_DOWNT,  HALF_UP     ,  55 }, // 76
	{ "H28.png", BSD,                ECOR_LEFTT,  SOLID,       OCOR_UPT,    HALF_DOWN   ,  55 }, // 77

	// Oblique Corners
	{ "I11.png", BEU+BER+BSD+BEL,    EMPTY,       SBICORNERN,  ECOR_DOWNN,  ECOR_DOWNN  ,  20 }, // 78
	{ "I12.png", BEU+BER+BED+BSL,    ECOR_LEFTN,  ECOR_LEFTN,  SBICORNERN,  EMPTY       ,  20 }, // 79
	{ "I13.png", BSU+BER+BED+BEL,    SBICORNERN,  EMPTY,       ECOR_UPN,    ECOR_UPN    ,  20 }, // 80
	{ "I14.png", BEU+BSR+BED+BEL,    ECOR_RIGHTN, ECOR_RIGHTN, EMPTY,       SBICORNERN  ,  20 }, // 81
	{ "I21.png", BSU+BSR+BED+BSL,    SOLID,       EBICORNERN,  SCOR_DOWNN,  SCOR_DOWNN  ,  80 }, // 82
	{ "I22.png", BSU+BSR+BSD+BEL,    SCOR_LEFTN,  SCOR_LEFTN,  EBICORNERN,  SOLID       ,  80 }, // 83
	{ "I23.png", BEU+BSR+BSD+BSL,    EBICORNERN,  SOLID,       SCOR_UPN,    SCOR_UPN    ,  80 }, // 84
	{ "I24.png", BSU+BER+BSD+BSL,    ECOR_RIGHTN, ECOR_RIGHTN, SOLID,       EBICORNERN  ,  80 }, // 85
	{ "J11.png", BE,                 SBICORNERT,  SOLID,       SCOR_UPT,    SCOR_UPT    ,  90 }, // 86
	{ "J12.png", BE,                 SCOR_RIGHTT, SCOR_RIGHTT, SOLID,       SBICORNERT  ,  90 }, // 87
	{ "J13.png", BE,                 SOLID,       SBICORNERT,  SCOR_DOWNT,  SCOR_DOWNT  ,  90 }, // 88
	{ "J14.png", BE,                 SCOR_LEFTT,  SCOR_LEFTT,  SBICORNERT,  SOLID       ,  90 }, // 89
	{ "J21.png", BS,                 EBICORNERT,  EMPTY,       ECOR_UPT,    ECOR_UPT    ,  10 }, // 90
	{ "J22.png", BS,                 ECOR_RIGHTT, ECOR_RIGHTT, EMPTY,       EBICORNERT  ,  10 }, // 91
	{ "J23.png", BS,                 EMPTY,       EBICORNERT,  ECOR_DOWNT,  ECOR_DOWNT  ,  10 }, // 92
	{ "J24.png", BS,                 ECOR_LEFTT,  ECOR_LEFTT,  EBICORNERT,  EMPTY       ,  10 }, // 93

	// Singularities
	{ "K1.png",  BE,                 EBICORNERT,  EBICORNERT,  EBICORNERT,  EBICORNERT  ,  80 }, // 94
	{ "K2.png",  BS,                 SBICORNERT,  SBICORNERT,  SBICORNERT,  SBICORNERT  ,  20 }, // 95
	{ "L11.png", BSD,                EBICORNERT,  SOLID,       OCOR_UPT,    OCOR_UPT    ,  60 }, // 96
	{ "L12.png", BSL,                OCOR_RIGHTT, OCOR_RIGHTT, SOLID,       EBICORNERT  ,  60 }, // 97
	{ "L13.png", BSU,                SOLID,       EBICORNERT,  OCOR_DOWNT,  OCOR_DOWNT  ,  60 }, // 98
	{ "L14.png", BSR,                OCOR_LEFTT,  OCOR_LEFTT,  EBICORNERT,  SOLID       ,  60 }, // 99
	{ "L21.png", BED,                SBICORNERT,  EMPTY,       HCOR_UPT,    HCOR_UPT    ,  40 }, // 100
	{ "L22.png", BEL,                HCOR_RIGHTT, HCOR_RIGHTT, EMPTY,       SBICORNERT  ,  40 }, // 101
	{ "L23.png", BEU,                EMPTY,       SBICORNERT,  HCOR_DOWNT,  HCOR_DOWNT  ,  40 }, // 102
	{ "L24.png", BER,                HCOR_LEFTT,  HCOR_LEFTT,  SBICORNERT,  EMPTY       ,  40 }, // 103
	{ NULL,      0,                  0,           0,           0,           0           ,   0 }, // EOL
};

int TileSet::EdgesMatchError(int e1, int e2) const {
	if (e1 <= SYMMETRIC_EDGES_MAX || e2 <= SYMMETRIC_EDGES_MAX) {
		if (e1 == e2)
			return 0;
		return 100;
	}

	if (e1 <= COMPLEMENTARY_EDGES_MAX || e2 <= COMPLEMENTARY_EDGES_MAX) {
		if (e1 == e2)
			return 50;
		if ((e1 & 254) == (e2 & 254))
			return 0;
		return 100;
	}

	return 100;
}

// env is a binary number representing flags that describe the environment:
// 0b(ul)(u)(ur)(l)(c)(r)(dl)(d)(dr)
unsigned int TileSet::InitialTileGuess(uint32_t env) const {
	switch (env) {
		case 0b000000111: return TILE_HALF_U;
		case 0b111000000: return TILE_HALF_D;
		case 0b001001001: return TILE_HALF_R;
		case 0b100100100: return TILE_HALF_L;
		case 0b110100000: return TILE_HALF_DL;
		case 0b011001000: return TILE_HALF_DR;
		case 0b000100110: return TILE_HALF_UL;
		case 0b000001011: return TILE_HALF_UR;
		case 0b000000001: return TILE_ECOR_DL;
		case 0b000000100: return TILE_ECOR_DR;
		case 0b001000000: return TILE_ECOR_UL;
		case 0b100000000: return TILE_ECOR_UR;
		case 0b111100100: return TILE_SCOR_DL;
		case 0b111001001: return TILE_SCOR_DR;
		case 0b100100111: return TILE_SCOR_UL;
		case 0b001001111: return TILE_SCOR_UR;
		case 0b010000000: return TILE_OUT_U;
		case 0b000000010: return TILE_OUT_D;
		case 0b000001000: return TILE_OUT_L;
		case 0b000100000: return TILE_OUT_R;
		case 0b000101111: return TILE_IN_U;
		case 0b111101000: return TILE_IN_D;
		case 0b110100110: return TILE_IN_L;
		case 0b011001011: return TILE_IN_R;
		default:          return (env & 0b000010000) != 0 ? TILE_SOLID : TILE_EMPTY;
	}
}

