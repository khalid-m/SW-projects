struct lofarframe {
    short aaba;
    short version;
    long stationID;
    unsigned long sec;
    unsigned long slice;
    short data[32];
    char separator[9];
};

void register_lofardata(void);
