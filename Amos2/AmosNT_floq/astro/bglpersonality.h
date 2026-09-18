/* This should not be included in BG */
typedef struct BGLPersonality {
	int xCoord;
	int yCoord;
	int zCoord;
} BGLPersonality;

void NT_init_BGLPersonality(BGLPersonality* dst);

int rts_get_personality(BGLPersonality* dst, unsigned size);

unsigned int BGLPersonality_xCoord(BGLPersonality* p);

unsigned int BGLPersonality_yCoord(BGLPersonality*);

unsigned int BGLPersonality_zCoord(BGLPersonality*);