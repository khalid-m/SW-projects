#include "bglpersonality.h"

int rts_get_personality(BGLPersonality* dst, unsigned size) {
	NT_init_BGLPersonality(dst);
	return 0;
}

void NT_init_BGLPersonality(BGLPersonality* dst) {
	dst->xCoord = 0;
	dst->xCoord = 0;
	dst->xCoord = 0;
}

unsigned int BGLPersonality_xCoord(BGLPersonality* p) {
    return p->xCoord;
}

unsigned int BGLPersonality_yCoord(BGLPersonality* p) {
    return p->xCoord;
}

unsigned int BGLPersonality_zCoord(BGLPersonality* p) {
    return p->xCoord;
}

