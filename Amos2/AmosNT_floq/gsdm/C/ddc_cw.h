////////////////////////////////////////////////////////////////////////////
// 
// HSP50016 DDC (digital down converter) control words
// For UDP producer by Arsenij Vodjanov
//
////////////////////////////////////////////////////////////////////////////

#ifndef DDC_CW__H_
#define DDC_CW__H_

#include <math.h>

// base-2 log is frequently used to calc CW params
#define log2(x) ((double)log((double)(x)) / (double)log(2.0))

////////////////////////////////////////////////////////////////////////////
// There are 7 registers and 8 control words.  Control words are
// shifted MSB first in the DCC.
//
// Control words 1-7 are for registers 1-7.
//
// Control word 0 is only used to force all buffered control words to
// be loaded in respective control registers. This has the same effect
// as setting bit 36 (update) to 1 in any control word.
////////////////////////////////////////////////////////////////////////////

#define CW0ADDR 0
#define CW1ADDR 1
#define CW2ADDR 2
#define CW3ADDR 3
#define CW4ADDR 4
#define CW5ADDR 5
#define CW6ADDR 6
#define CW7ADDR 7


////////////////////////////////////////////////////////////////////////////
// A control word is a 40-bit bitfield.
//

#define CWDEF(CWNAME, CWDEFINITION) \
typedef struct CWNAME { \
  CWDEFINITION \
} CWNAME ## _t


////////////////////////////////////////////////////////////////////////////
// 
// Control Word 0: used to update all seven control registers
/////////////////
CWDEF(ddc_cw0, 
      // 31-0  
      unsigned int filler    : 32; // not used
      // 35-32 
      unsigned int reserved  : 4;  // All zeroes
      // 36
      unsigned int update    : 1;  // 0 = update only this control register (???)
      // 39-37                        1 = update all control registers
      unsigned int address   : 3;  // 000 = Control Word 0
      );
//
////////


////////////////////////////////////////////////////////////////////////////
// 
// Control Word 1: Phase generator/Test enable/Output Register
/////////////////
CWDEF(ddc_cw1,
      // 2-0   Phase Generator Mode
      unsigned int pgm       : 3;  // 001 = normal (CW)
      // 3     Enable Test Features
      unsigned int test      : 1;  // 0 = disable, 1 = enable
      // 35-4  Minimum Phase Increment (for oscillator frequency setting)
      unsigned int minincr   : 32; // minincr = INT[ (Fc/Fs)*2^33 ]
      unsigned int update    : 1;  // 0 = update only this control register
      // 39-37                        1 = update all control registers
      unsigned int address   : 3;  // 001 = Control Word 1
      );
//
////////


////////////////////////////////////////////////////////////////////////////
// 
// Control Word 2: Phase Generator Register
/////////////////
CWDEF(ddc_cw2, 
      // 31-0  Maximum Phase Increment
      unsigned int maxincr   : 32; // Used in CHIRP mode, set to 0 in Filter/CW modes
      // 35-32 
      unsigned int reserved  : 4;  // All zeroes
      // 36
      unsigned int update    : 1;  // 0 = update only this control register
      // 39-37                        1 = update all control registers
      unsigned int address   : 3;  // 010 = Control Word 2
      );
//
////////


////////////////////////////////////////////////////////////////////////////
// 
// Control Word 3: Phase Generator/Output Time Slot Register
/////////////////
CWDEF(ddc_cw3, 
      // 17-0  Phase Offset
      unsigned int offset    : 18; // 0x000 = 0, 0x2000= pi, 0x3fff = 2*pi
      // 31-18 Time Slot Length
      unsigned int tsl       : 14; // TSL = [ [ (NumOutputBits + 2) * Mode  ] + 1 ]
      // 35-32                        Mode: 2 (if Real or I followed by Q) or 1 (else) 
      unsigned int reserved  : 4;  // All zeroes
      // 36
      unsigned int update    : 1;  // 0 = update only this control register
      // 39-37                        1 = update all control registers
      unsigned int address   : 3;  // 011 = Control Word 3
      );
//
////////


////////////////////////////////////////////////////////////////////////////
// 
// Control Word 4: Phase Generation/HDF Output Register
/////////////////
CWDEF(ddc_cw4, 
      // 0     Spectral Reverse
      unsigned int rev       : 1;  // 0 = Normal Output, 1 = Spectrally Reversed
      // 6-1   HDF Data Shift (shift factor)
      unsigned int shift     : 6;  // shift = 75 - ceil(5 * log2(R)),  0<shift<55
      // 30-7  Delta Phase Increment
      unsigned int dpi       : 24; // 0 < dpi < pi*(2^-8 - 2^-32)
      // 32-31 Output Spectrum
      unsigned int spectrum  : 2;  // 00 = No up conversion,    Complex Output
                                   // 01 = Up convert by f''/4, Real Output
                                   // 10 = Up convert by f''/2, Complex Output
                                   // 11 = reserved mode
      // 35-33
      unsigned int reserved  : 3;  // All zeroes
      // 36
      unsigned int update    : 1;  // 0 = update only this control register
      // 39-37                        1 = update all control registers
      unsigned int address   : 3;  // 100 = Control Word 4
      );
//
////////


////////////////////////////////////////////////////////////////////////////
// 
// Control Word 5: HDF/Output Register
/////////////////
CWDEF(ddc_cw5, 
      // 0     Output Sense
      unsigned int sense     : 1;  // 0 = LSB First, 1 = MSB First
      // 2-1   Number of Output bits
      unsigned int numbits   : 2;  // 00 = 16 bits
                                   // 01 = 24 bits
                                   // 10 = 32 bits
                                   // 11 = 38 bits
      // 4-3   Output Format
      unsigned int outformat : 2;  // 00 = Two's complement
                                   // 01 = Offset binary
                                   // 10 = Sign magnitude
                                   // 11 = Single precision floating point (float)
      // 20-5  Scaling Multiplier Gain (scale factor)
      unsigned int sf        : 16; // sf = 2^ceiling(5*log2(R)) / R^5),  1 =< sf =< 2
                                   // Format: 2^0.2^-1...2^-15
      // 35-21 HDF Decimation Counter Preload (HDF DCP)
      unsigned int hdfdcp    : 15; // HDFdcp = R-1, R is decimation factor (defines BW)
      // 36
      unsigned int update    : 1;  // 0 = update only this control register
      // 39-37                        1 = update all control registers
      unsigned int address   : 3;  // 101 = Control Word 5
      );
//
////////


////////////////////////////////////////////////////////////////////////////
// 
// Control Word 6: Input and Output Format Register
/////////////////
CWDEF(ddc_cw6, 
      // 12-0  IQCLK Rate Counter Preload
      unsigned int rcp       : 13; // rcp = floor( (R*4)/TSL ) - 1,  2 =< rcp =< 1701
      // 13    Input Format
      unsigned int informat  : 1;  // 0 = Offset Binary, 1 = Two's Complement
      // 15-14 Q Three-State Control
      unsigned int qts       : 2;  // 00 = Three-state Q 
                                   // 01 = Enable Q 
                                   // 1x = Auto Three-state enable Q (during timeslot)
      // 16    Q Polarity
      unsigned int qpol      : 1;  // 0 = True Data, 1 = Inverted Data
      // 18-17 I Three-State Control
      unsigned int its       : 2;  // As for Q Three State Control
      // 19    I Polarity
      unsigned int ipol      : 1;  // 0 = True Data, 1 = Inverted Data
      // 21-20 IQSTB Three State Control
      unsigned int iqstbts   : 2;  // As for Q Three State Control
      // 22    IQSTB Location
      unsigned int           : 1;  // see manual
      // 23    IQSTB Polarity
      unsigned int iqstbpol  : 1;  // 0 = Active High, 1 = Active Low
      // 25-24 IQCLK Three State Control
      unsigned int iqclkts   : 2;  // As for Q Three State Control
      // 26    IQCLK Duration
      unsigned int iqclkdur  : 1;  // see manual
      // 27    IQCLK Duty Cycle
      unsigned int iqclkcycle: 1;  // see manual
      // 28    IQCLK Polarity
      unsigned int iqclkpol  : 1;  // see manual
      // 34-29 Time Slot Number (for multiplexing channels)
      unsigned int slot      : 6;  // 0 < slot < 63
      // 35    I followed by Q
      unsigned int iqfollow  : 1;  // 0 = I and Q Output Separately
                                   // 1 = I and Q Data output on I
      // 36
      unsigned int update    : 1;  // 0 = update only this control register
      // 39-37                        1 = update all control registers
      unsigned int address   : 3;  // 110 = Control Word 6
      );
//
////////


////////////////////////////////////////////////////////////////////////////
// 
// Control Word 7: Phase Offset Register
/////////////////
CWDEF(ddc_cw7, 
      // 0     Disable Overflow Protection
      unsigned int overflow  : 1;  // 0 = Normal, 1 = Disable Overflow Protection
      // 1     Wait for RAM FULL before output after reset
      unsigned int ramfull   : 1;  // 0 = Normal, 1 = wait until enough data written
      // 2
      unsigned int reserved1 : 1;  // Zero for proper operation with Test Features
      // 3     Scaling Multiplier Bypass
      unsigned int sfbypass  : 1;  // 0 = Normal, 1 = use Scale Factor of 1
      // 4     Sin/Cos Generator Bypass
      unsigned int scbypass  : 1;  // 0 = Normal, 1 = use Sin=Cos=0.fffff (approx 1)
      // 5     Q Forced Data
      unsigned int forceq    : 1;  // 0 = Normal, 1 = Force if bit 9 is 1
      // 6     I Forced Data
      unsigned int forcei    : 1;  // 0 = Normal, 1 = Force if bit 9 is 1
      // 7     IQSTB Forced Data
      unsigned int forceiqstb: 1;  // 0 = Normal, 1 = Force if bit 9 is 1
      // 8     IQCLK Forced Data
      unsigned int forceiqclk: 1;  // 0 = Normal, 1 = Force if bit 9 is 1
      // 9     Force Outputs
      unsigned int forceout  : 1;  // 0 = Normal, 1 = Force Outputs (bits 8-5)
      // 10    Q Strobe Roll Over
      unsigned int qstrobe   : 1;  // 0 = Normal, 1 = Q strobes when Phase Generator roll over
      // 12-11 FIR Accumulator Control
      unsigned int firacc    : 2;  // 00 = Normal Accumulation
                                   // 01 = No Accumulation, accumulator disabled
                                   // 10 = Continuous Accumulation, no reset
                                   // 11 = Reserved
      // 13    Data
      unsigned int data      : 1;  // 0 = Normal Data Input, 1 = force input to 0x8000
      // 35-14
      unsigned int reserved2 : 22; // All zeroes
      // 36
      unsigned int update    : 1;  // 0 = update only this control register
      // 39-37                        1 = update all control registers
      unsigned int address   : 3;  // 111 = Control Word 7
      );
//
////////


////////////////////////////////////////////////////////////////////////////
//
// Control word union for easier handling
////
union ddc_cw {
  char buf[5]; // 40 bits
  ddc_cw0_t cw0;
  ddc_cw1_t cw1;
  ddc_cw2_t cw2;
  ddc_cw3_t cw3;
  ddc_cw4_t cw4;
  ddc_cw5_t cw5;
  ddc_cw6_t cw6;
  ddc_cw7_t cw7;
};

typedef union ddc_cw ddc_cw_t;


////////////////////////////////////////////////////////////////////////////
//
// UDP radio control packet format 
////
struct udp_cwpacket {
  char type[2];      // ID, SA, SC, MS
  ddc_cw_t cw;       // only used with MS type
  char padto8;
};

typedef struct udp_cwpacket udp_cwpacket_t;


#endif
