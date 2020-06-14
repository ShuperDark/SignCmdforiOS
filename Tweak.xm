#import "../substrate.h"
#import <UIKit/UIKit.h>
#import <mach-o/dyld.h>
#import <initializer_list>
#import <vector>
#import <map>
#import <mach-o/dyld.h>
#import <string>
#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <initializer_list>
#import <vector>
#import <mach-o/dyld.h>
#import <UIKit/UIKit.h>
#import <iostream>
#import <stdio.h>
#include <sstream>
#include <sys/sysctl.h>
#include <net/if.h>
#include <net/if_dl.h>
#include <sys/socket.h>
#include <sys/types.h>
#include <string.h>
#include <algorithm>
#include <fstream>
#include <ifaddrs.h>
#include <stdint.h>
#include <dlfcn.h>

typedef struct {
	uintptr_t** vtable;
} BlockEntity;

struct SignBlockEntity :public BlockEntity {
	uintptr_t** vtable;
};

typedef struct {
	char filler[560];
	uintptr_t* gui;
} MinecraftClient;

typedef struct {
	uintptr_t** vtable;
} MinecraftScreenModel;

typedef struct {
	char filler[64];
	uintptr_t* level;
	char filler2[104];
	uintptr_t* region;
} Entity;

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
static const std::string& (*SignBlockEntity$getMessage)(SignBlockEntity*, int);

//MinecraftScreenModel
static MinecraftScreenModel* (*MinecraftScreenModel$MinecraftScreenModel)(MinecraftScreenModel*, MinecraftClient&);

static void (*MinecraftClient$executeCommand)(MinecraftScreenModel*, const std::string&);

//BlockSource
static BlockEntity* (*BlockSource$getBlockEntity)(uintptr_t*, int, int, int);
static BlockID (*BlockSource$getBlockID)(uintptr_t*, int, int, int);

void (*MinecraftClient_update)(MinecraftClient*);
void _MinecraftClient_update(MinecraftClient* self) {

	MinecraftClient_update(self);

	model = self;
}

MinecraftScreenModel* temp;

//実行はできるけど、コマンドが実行された途端にクラッシュする。

bool (*Item_useOn)(uintptr_t*, uintptr_t*, Player*, int, int, int, signed char, float, float, float);
bool _Item_useOn(uintptr_t* self, uintptr_t* inst, Player* player, int x, int y, int z, signed char side, float xx, float yy, float zz) {

	////SignBlockEntity* sign = (SignBlockEntity*)BlockSource$getBlockEntity(player->region, x, y, z);

	if(BlockSource$getBlockID(player->region, x, y, z) == 63) {

		if(model != nullptr) {
			if(temp == nullptr) {

				//おそらく、メモリ解放でクラッシュしてる？
				temp = new MinecraftScreenModel();
				MinecraftScreenModel$MinecraftScreenModel(temp, *model);
			}
		}

		SignBlockEntity* sign = (SignBlockEntity*)BlockSource$getBlockEntity(player->region, x, y, z);
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

	SignBlockEntity$getMessage = (const std::string&(*)(SignBlockEntity*, int))(0x1008430c4 + _dyld_get_image_vmaddr_slide(0));

	MinecraftScreenModel$MinecraftScreenModel = (MinecraftScreenModel*(*)(MinecraftScreenModel*, MinecraftClient&))(0x10029a2cc + _dyld_get_image_vmaddr_slide(0));

	MinecraftClient$executeCommand = (void(*)(MinecraftScreenModel*, const std::string&))(0x1002a3290 + _dyld_get_image_vmaddr_slide(0));

	BlockSource$getBlockEntity = (BlockEntity*(*)(uintptr_t*, int, int, int))(0x10079fd7c + _dyld_get_image_vmaddr_slide(0));

	BlockSource$getBlockID = (BlockID(*)(uintptr_t*, int, int, int))(0x10079c2d0 + _dyld_get_image_vmaddr_slide(0));
}