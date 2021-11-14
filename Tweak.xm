#include "substrate.h"
#include <string>
#include <cstdio>
#include <chrono>
#include <memory>
#include <vector>
#include <mach-o/dyld.h>
#include <stdint.h>
#include <cstdlib>
#include <sys/mman.h>
#include <random>
#include <cstdint>
#include <unordered_map>
#include <map>
#include <functional>
#include <cmath>
#include <chrono>
#include <libkern/OSCacheControl.h>
#include <cstddef>
#include <tuple>
#include <mach/mach.h>
#include <mach-o/getsect.h>
#include <mach-o/loader.h>
#include <mach-o/nlist.h>
#include <mach-o/reloc.h>

#include <dlfcn.h>

#import <Foundation/Foundation.h>
#import "UIKit/UIKit.h"

struct Level;
struct BlockSource;

struct BlockEntity {
	uintptr_t** vtable;
};

struct SignBlockEntity :public BlockEntity {
	uintptr_t** vtable;
};

struct MinecraftClient {
	char filler[560];
	uintptr_t* gui;
};

struct MinecraftScreenModel {
	uintptr_t** vtable;
	char filler[0x1F0];
};

struct Entity {
	char filler[64];
	Level* level;
	char filler2[104];
	BlockSource* region;
};

struct Player :public Entity {
	char filler[4400];

	uintptr_t* inventory;
};

struct BlockID {
	unsigned char value;

	BlockID() {
		this->value = 1;
	}

	BlockID(unsigned char val) {
		this->value = val;
	}

	BlockID(BlockID const& other) {
		this->value = other.value;
	}

	bool operator==(char v) {
		return this->value == v;
	}

	bool operator==(int v) {
		return this->value == v;
	}

	bool operator==(BlockID v) {
		return this->value == v.value;
	}

	BlockID& operator=(const unsigned char& v) {
		this->value = v;
		return *this;
	}

	operator unsigned char() {
		return this->value;
	}
};

MinecraftClient* model;

//SignBlockEntity
std::string& (*SignBlockEntity$getMessage)(SignBlockEntity*, int);

//MinecraftScreenModel
MinecraftScreenModel* (*MinecraftScreenModel$MinecraftScreenModel)(MinecraftScreenModel*, MinecraftClient&);

void (*MinecraftClient$executeCommand)(MinecraftScreenModel*, const std::string&);

//BlockSource
BlockEntity* (*BlockSource$getBlockEntity)(BlockSource*, int, int, int);
BlockID (*BlockSource$getBlockID)(BlockSource*, int, int, int);

BlockSource& (*Entity$getRegion)(Entity*);

void (*MinecraftClient_update)(MinecraftClient*);
void _MinecraftClient_update(MinecraftClient* self) {

	MinecraftClient_update(self);

	model = self;
}

MinecraftScreenModel* temp;

bool (*Item_useOn)(uintptr_t*, uintptr_t*, Player*, int, int, int, signed char, float, float, float);
bool _Item_useOn(uintptr_t* self, uintptr_t* inst, Player* player, int x, int y, int z, signed char side, float xx, float yy, float zz) {

	SignBlockEntity* sign = (SignBlockEntity*)BlockSource$getBlockEntity(&Entity$getRegion(player), x, y, z);

	if(BlockSource$getBlockID(player->region, x, y, z) == 63) {

		if(model != nullptr) {
			if(temp == nullptr) {
				temp = new MinecraftScreenModel();
				MinecraftScreenModel$MinecraftScreenModel(temp, *model);
			}
		}

		if(sign != nullptr) {
			for(int i = 0; i < 4; i++) {
				std::string str = SignBlockEntity$getMessage(sign, i);
				if(str.find("/") != std::string::npos) {
					MinecraftClient$executeCommand(temp, str);
				}
			}
		}
	}

	return Item_useOn(self, inst, player, x, y, z, side, xx, yy, zz);
}

%ctor {
	MSHookFunction((void*)(0x10008182c + _dyld_get_image_vmaddr_slide(0)), (void*)&_MinecraftClient_update, (void**)&MinecraftClient_update);

	//MSHookFunction((void*)(0x100081b20 + _dyld_get_image_vmaddr_slide(0)), (void*)&_MinecraftClient_startFrame, (void**)&MinecraftClient_startFrame);
	MSHookFunction((void*)(0x100746be0 + _dyld_get_image_vmaddr_slide(0)), (void*)&_Item_useOn, (void**)&Item_useOn);

	SignBlockEntity$getMessage = (std::string&(*)(SignBlockEntity*, int))(0x1008430c4 + _dyld_get_image_vmaddr_slide(0));

	MinecraftScreenModel$MinecraftScreenModel = (MinecraftScreenModel*(*)(MinecraftScreenModel*, MinecraftClient&))(0x10029a2cc + _dyld_get_image_vmaddr_slide(0));

	MinecraftClient$executeCommand = (void(*)(MinecraftScreenModel*, const std::string&))(0x1002a3290 + _dyld_get_image_vmaddr_slide(0));

	BlockSource$getBlockEntity = (BlockEntity*(*)(BlockSource*, int, int, int))(0x10079fd7c + _dyld_get_image_vmaddr_slide(0));

	BlockSource$getBlockID = (BlockID(*)(BlockSource*, int, int, int))(0x10079c2d0 + _dyld_get_image_vmaddr_slide(0));

	Entity$getRegion = (BlockSource&(*)(Entity*))(0x100658034 + _dyld_get_image_vmaddr_slide(0));
}
