////////////////////////////////////////////////////////////////////////////////
//
// UDP Radio Source implementation & Lisp-interface functions
// by Arsenij Vodjanov
//
////////////////////////////////////////////////////////////////////////////////

// HOSTNAME "130.238.30.208"
// MYPORT 4096

#include "udp_common.h"

#include "ddc_cw.h" // digital down-converter (ddc) control words
#include "udp_radiosource.h"
#include "udp_streams.h"
#include "udp_hashtab.h"

static int udp_radiosource_debug = 0;

#define DBG(x) if (udp_radiosource_debug) udp_log_message x
#define ERR(x) udp_log_error x


////////////////////////////////////////////////////////////////////////////
// "raw" udp packet data received from udp radio source
struct udp_radiodata {
  unsigned short counter; // packet number (original protocol, low 16-bit)
  short data[122 * 2 * 3];  // sample * (real/img) * channel

  /* Extended packet counter (high 16 bits) */
  unsigned short counter_hi;
};
typedef struct udp_radiodata udp_radiodata_t;



////////////////////////////////////////////////////////////////////////////
// Decoded data, constructed from 2 udp radio packets
struct radiodata {
  float x[512];         // data x, pairs of real/imaginary
  float y[512];         // data y, pairs of real/imaginary
  float z[512];         // data z, pairs of real/imaginary
  int counter;          // last encoded udp packet number
};
typedef struct radiodata radiodata_t;



////////////////////////////////////////////////////////////////////////////
// UDP radio source descriptor
struct udp_radiosource {
  struct udp_radiosource *prev;
  struct udp_radiosource *next;

  int            id;        // id of this radiosource object
  int            streamid;  // id of the udp-stream to the source
  int            streaming; // 1 == receiving stream

  char           ip[16];    // IPv4 address of radio source
  int            port;      // port of radio source
  
  double         freq;      // Frequency, default 6120 KHz
  float	         red;       // Scale, default 12
  radiodata_t    converted; // last chunk of converted ("decoded") udp radiodata

  unsigned short first_packet; // set to 1 at creation, resets to 0 after recv first packet
  unsigned short radio_counter; // counter received from the radio source
  unsigned short counter_lo; // low 16 bit
  unsigned short counter_hi; // high 16 bit
};
typedef struct udp_radiosource udp_radiosource_t;


// This macro constructs the declarations and functions (with the
// prefix "udp_source") for a chained hashtable of (udp_radiosource_t
// *), with 8 buckets.  Current implementation of udp radio streaming
// handles only one radio source, but maybe there will be support for
// more than one, in the future.
MM_DEF_HASHTABLE(udp_source, udp_radiosource_t, 8)


// func proto
static int udp_radio_encoder( radiodata_t *dst, udp_radiodata_t *rData );



////////////////////////////////////////////////////////////////////////////
//
//
//
//               Lisp interface functions start here
//
//
//
////////////////////////////////////////////////////////////////////////////



////////////////////////////////////////////////////////////////////////////
//
// Registers foreign ALisp functions for UDP-radio source manipulation
//
void udp_register_radiosource_functions() {
  extfunction1("RADIO-DEBUG", udp_radiosource_debugfn);
  extfunction3("RADIO-OPEN", udp_radiosource_openfn);
  extfunction1("RADIO-CLOSE", udp_radiosource_closefn);
  extfunction1("RADIO-IDENT", udp_radiosource_identfn);
  extfunction3("RADIO-STARTSTOP", udp_radiosource_startstopfn);
  extfunction2("RADIO-SET-SCALE", udp_radiosource_setscalefn);
  extfunction2("RADIO-SET-FREQ", udp_radiosource_setfreqfn);
  extfunction1("RADIO-GET-FROM", udp_radiosource_getfromfn);
  extfunction2("RADIO-ENCODE-WIN", udp_encode_winfn);
}



oidtype udp_radiosource_debugfn(bindtype env, oidtype toggle)
{
  int iToggle;

  DBG(("%s()\n", __FUNCTION__));

  IntoInteger(toggle, iToggle, env);
  udp_radiosource_debug = (iToggle>0);

  return mkinteger(iToggle);
}



oidtype udp_radiosource_openfn( bindtype env, 
				oidtype streamid, 
				oidtype host, 
				oidtype port )
{
  int iStreamID, iPort;
  char *pHost;

  DBG(("%s()\n", __FUNCTION__));

  IntoInteger(streamid, iStreamID, env);
  IntoString(host, pHost, env);
  IntoInteger(port, iPort, env);

  if (pHost && *pHost && iPort>0 && iPort<65536) {
    int iRadioID = udp_radiosource_open( iStreamID, pHost, iPort );
    if (iRadioID != -1)
      return mkinteger(iRadioID);
  }
  return nil;
}


oidtype udp_radiosource_closefn( bindtype env, oidtype radioid )
{
  int iID;

  DBG(("%s()\n", __FUNCTION__));

  IntoInteger(radioid, iID, env);
  if (udp_radiosource_close(iID))
    return mkinteger(1);
  return nil;
}


oidtype udp_radiosource_identfn( bindtype env, oidtype radioid )
{
  int iID;

  DBG(("%s()\n", __FUNCTION__));

  IntoInteger(radioid, iID, env);
  if (udp_radiosource_ident(iID))
    return mkinteger(1);
  return nil;
}


oidtype udp_radiosource_startstopfn( bindtype env, oidtype radioid, oidtype onflag, oidtype broadcastflag )
{
  int iID, fOn, fBcast;

  DBG(("%s()\n", __FUNCTION__));

  IntoInteger(radioid, iID, env);
  IntoInteger(onflag, fOn, env);
  IntoInteger(broadcastflag, fBcast, env);
  if (udp_radiosource_startstop(iID, fOn, fBcast))
    return mkinteger(1);
  return nil;
}


oidtype udp_radiosource_setscalefn( bindtype env, oidtype radioid, oidtype red)
{
  int iID;
  double dRed;

  DBG(("%s()\n", __FUNCTION__));

  IntoInteger(radioid, iID, env);
  IntoDouble(red, dRed, env);
  if (udp_radiosource_setscale(iID, dRed))
    return mkinteger(1);
  return nil;
}


oidtype udp_radiosource_setfreqfn( bindtype env, oidtype radioid, oidtype freq)
{
  int iID;
  double dFreq;

  DBG(("%s()\n", __FUNCTION__));

  IntoInteger(radioid, iID, env);
  IntoDouble(freq, dFreq, env);
  if (udp_radiosource_setfreq(iID, dFreq))
    return mkinteger(1);
  return nil;
}


////////////////////////////////////////////////////////////////////////////
// Wrapper to get first queued packet and packet info (size, etc) from a
// radio-source's udp stream.
//
// This differs from udp_streams_getfromfn in that it changes data in
// the received packet before returning it to caller in the following
// way:
// Extended packet counter is appended after original data.
//
// Returns: 
//
//   On success: 
//      list of 4 elements: 
//         source ip (string)
//         source port (integer)
//         size in bytes (integer)
//         data (bytearray)
//
//   On failure: 
//      nil
//
oidtype udp_radiosource_getfromfn(bindtype env, oidtype id)
{
  int iRadioID;
  unsigned short rcounter_old;
  int delta;
  udp_radiosource_t *source;
  udp_indata_t *pData, pDataCopy;
  udp_radiodata_t *rData;
  oidtype elems, res;

  //  DBG(("%s()\n", __FUNCTION__));

  IntoInteger(id, iRadioID, env);

  // DBG(("%s() find elem\n", __FUNCTION__));
  source = udp_source_find_elem( iRadioID );

  if (!source)
    return nil;

  // DBG(("%s() stream get\n", __FUNCTION__));
  pData = udp_stream_get( source->streamid );

  if (pData != NULL && 
      pData->size > 0 && 
      pData->size <= UDP_MAXBUFLEN) {

    pData->size = sizeof(udp_radiodata_t);
    rData = (udp_radiodata_t *)(pData->buf);

    // figure out counter delta
    if (source->first_packet) {
      delta = 1;
      source->radio_counter = rData->counter;
    } else {
      rcounter_old = source->radio_counter;
      source->radio_counter = rData->counter;
      delta = (int)rcounter_old - (int)source->radio_counter;
    }

    source->counter_lo+=delta;
    if (source->counter_lo<delta)
      source->counter_hi++;
    
    rData->counter = source->counter_lo;
    rData->counter_hi = source->counter_hi;
    
    elems = nil;
    res = nil;
    
    a_setf( elems, new_binary( pData->size, 0 ) );

    memcpy((char*)&(dr(elems,binarycell)->cont), pData->buf, pData->size);
/*
    for (i=0; i<pData->size; i++) {
      ( ((char*)&(dr(elems,binarycell)->cont))[i] ) = pData->buf[i];
    }
*/
    // Add bin-data to result
    a_setf(res, cons( elems, res ));
    // Add data size (in bytes) to result
    a_setf(res, cons( mkinteger(pData->size), res ));
    // Add source port to result
    a_setf(res, cons( mkinteger( pData->sourceport ), res));
    // Add source IP to result
    a_setf(res, cons( mkstring( pData->sourceip ), res));
    // Release temporary ref
    a_free( elems );
    
    // Return result list
    a_return( res );
  }
  return nil;
}



////////////////////////////////////////////////////////////////////////////////
//
//
//                      C-implementation
//
//
////////////////////////////////////////////////////////////////////////////////




////////////////////////////////////////////////////////////////////////////////
// Data encoder
// Converts radio data from 16-bit signed ints to complex real (float)
// It takes 2 udp packets to create one set of complex numbers
//
static int udp_radio_encoder( radiodata_t *dst, udp_radiodata_t *src )
{
  int shift, i;

  if (src->counter % 2)
    shift = 244;
  else
    shift = 0;

  for(i=0;i<122;i++) {
    dst->x[i*2+12+shift]=(float)(src->data[i*6+0]);
    dst->x[i*2+13+shift]=(float)(src->data[i*6+1]);
    dst->y[i*2+12+shift]=(float)(src->data[i*6+2]);
    dst->y[i*2+13+shift]=(float)(src->data[i*6+3]);
    dst->z[i*2+12+shift]=(float)(src->data[i*6+4]);
    dst->z[i*2+13+shift]=(float)(src->data[i*6+5]);
  }

  // This seems to ensure correct packet ordering... ?
  if ((dst->counter + 1 == src->counter) && (shift)) {
    // Zero pad
    for(i=0;i<12;i++) dst->x[i] = dst->y[i] = dst->z[i] = 0.0;
    for(i=500;i<512;i++) dst->x[i] = dst->y[i] = dst->z[i] = 0.0;
    dst->counter++;
    return 1; // one set of 512 complex numbers ready to go
  } else {
    dst->counter = src->counter;
    return 0; // need one more udp radiopacket to finish encoding 512 cmplx nums
  }
}



////////////////////////////////////////////////////////////////////////////////
// sleeps/waits for delay ms
//
static void mssleep( int delay )
{
#ifdef PLATFORM_LINUX
  unsigned long usec = delay*1000;
  usleep(usec);
#endif
#ifdef PLATFORM_WINDOWS
  clock_t time;
  time=clock();  // gets the tics since program started
  while((clock()-time)*1000/CLOCKS_PER_SEC<delay);  // waits for delay ms
#endif
}




////////////////////////////////////////////////////////////////////////////////
// identifies user (direct radio stream to us)
//
// Returns:
//
//   On success: 1
//   On failure: 0
//
int udp_radiosource_ident( int radioid ) 
{
  udp_radiosource_t *source = udp_source_find_elem( radioid );

  DBG(("%s()\n", __FUNCTION__));

  if (source && udp_stream_redirect(source->streamid, source->ip, source->port)) {

    udp_cwpacket_t cwpkt;
    memset(&cwpkt, 0, sizeof(cwpkt));
    
    cwpkt.type[0]='I';
    cwpkt.type[1]='D';

    if (udp_stream_put( source->streamid, (char *)&cwpkt, sizeof(cwpkt) )) {
      mssleep(10);
      udp_stream_put( source->streamid, (char *)&cwpkt, sizeof(cwpkt) );
      mssleep(10);
      udp_stream_put( source->streamid, (char *)&cwpkt, sizeof(cwpkt) );

      // Send SY command after ID (to syncronize the 3 channels, I guess)
      cwpkt.type[0]='S';
      cwpkt.type[1]='Y';
      mssleep(10);
      udp_stream_put( source->streamid, (char *)&cwpkt, sizeof(cwpkt) );
      mssleep(10);
      udp_stream_put( source->streamid, (char *)&cwpkt, sizeof(cwpkt) );

      return 1;
    }
  }
  return 0;
}


////////////////////////////////////////////////////////////////////////////////
// starts or stops radio stream
//
// Returns:
//
//   On success: 1
//   On failure: 0
//
int udp_radiosource_startstop(int radioid, int fmode, int fbroadcast)
{
  udp_radiosource_t *source = udp_source_find_elem( radioid );
  int res;

  DBG(("%s()\n", __FUNCTION__));

  if (!source) return 0;
  if (!fbroadcast)
    res = udp_stream_redirect(source->streamid, source->ip, source->port);
  else
    res = udp_stream_redirect(source->streamid, "255.255.255.255", source->port);

  if (res) {
    udp_cwpacket_t cwpkt;    
    memset(&cwpkt, 0, sizeof(cwpkt));
    
    cwpkt.type[0]='S';
    if(fmode!=0) 
      cwpkt.type[1]='A';
    else 
      cwpkt.type[1]='C';

    if (udp_stream_put( source->streamid, (char *)&cwpkt, sizeof(cwpkt) )) {
      mssleep(10);
      udp_stream_put( source->streamid, (char *)&cwpkt, sizeof(cwpkt) );
      mssleep(10);
      udp_stream_put( source->streamid, (char *)&cwpkt, sizeof(cwpkt) );

      source->streaming = (fmode!=0);
      return 1;
    }
  }
  return 0;
}


////////////////////////////////////////////////////////////////////////////////
// changes the scale
//
// Returns:
//
//   On success: 1
//   On failure: 0
//
int udp_radiosource_setscale( int radioid, double red )
{
  udp_radiosource_t *source = udp_source_find_elem( radioid );

  DBG(("%s()\n", __FUNCTION__));

  if (source && udp_stream_redirect(source->streamid, source->ip, source->port)) {

    unsigned int HDFdcp,HDFg,r;
    udp_cwpacket_t cwpkt;
    memset(&cwpkt, 0, sizeof(cwpkt));
    
    if(red<6.25)red=6.25;
    if(red>12)red=12;
    
    source->red = red;
    
    r=pow(2.0,red);
    
    HDFdcp=r-1;
    HDFg=32768.0*pow(2.0,ceil(16.60964*log10((double)r))-16.60964*log10((double)r));
    
    // CW 4
    cwpkt.type[0]='M';
    cwpkt.type[1]='S';
    cwpkt.cw.cw4.rev = 1;
    cwpkt.cw.cw4.shift = (char) (75-ceil(5.0*3.32*log10(r)));
    cwpkt.cw.cw4.dpi = 0;
    cwpkt.cw.cw4.spectrum = 2; // up-convert by f''/2, complex output
    cwpkt.cw.cw4.reserved = 0;
    cwpkt.cw.cw4.update = 1;
    cwpkt.cw.cw4.address = 4;
    
    if (udp_stream_put( source->streamid, (char *)&cwpkt, sizeof(cwpkt) )) {

      // CW 5
      memset(&cwpkt, 0, sizeof(cwpkt));
      cwpkt.type[0]='M';
      cwpkt.type[1]='S';
      cwpkt.cw.cw5.sense = 1;
      cwpkt.cw.cw5.numbits = 0;     // 16 bits
      cwpkt.cw.cw5.outformat = 0;   // Two's complement
      cwpkt.cw.cw5.sf = HDFg;
      cwpkt.cw.cw5.hdfdcp = HDFdcp;
      cwpkt.cw.cw5.update = 1;
      cwpkt.cw.cw5.address = 5;
      
      mssleep(10);

      if (udp_stream_put( source->streamid, (char *)&cwpkt, sizeof(cwpkt) ))
	return 1;
    }
  }
  return 0;
}


////////////////////////////////////////////////////////////////////////////////
// sets frequency
//
// Returns:
//
//   On success: 1
//   On failure: 0
//
int udp_radiosource_setfreq( int radioid, double freq )
{
  udp_radiosource_t *source = udp_source_find_elem( radioid );

  DBG(("%s()\n", __FUNCTION__));

  if (source && udp_stream_redirect(source->streamid, source->ip, source->port)) {

    unsigned int DFreq;
    udp_cwpacket_t cwpkt;
    memset(&cwpkt, 0, sizeof(cwpkt));
    
    if(freq>12499.0) freq=12499.0;
    if(freq<1.0) freq=1.0;
    
    source->freq = freq;
    DFreq=(unsigned int)((double)freq*(double)Foffs*(double)1342.17728);
    
    // CW 1
    cwpkt.type[0]='M';
    cwpkt.type[1]='S';
    cwpkt.cw.cw1.pgm = 1;
    cwpkt.cw.cw1.test = 0;
    cwpkt.cw.cw1.minincr = DFreq;
    cwpkt.cw.cw1.update = 1;
    cwpkt.cw.cw1.address = 1;
    
    if (udp_stream_put( source->streamid, (char *)&cwpkt, sizeof(cwpkt) ))
      return 1;
  }
  return 0;
}




////////////////////////////////////////////////////////////////////////////////
// Creates new radiosource_t object and associates it with specified
// udp stream.  Redirects the stream to specified host:port of remote
// radio source and sends commands to set initial parameters and begin
// streaming radio data immediately.
//
// Returns:
//
//   On success: ID (non-negative) of the created radiosource_t object
//   On failure: -1
//
int udp_radiosource_open( int streamid, char *host, int port )
{
  udp_radiosource_t *source;

  DBG(("%s()\n", __FUNCTION__));

  if (streamid<0 || !host || !*host)
    return -1;
  
  source = udp_source_create_elem();
  if (source == NULL)
    return -1;

  source->streamid = streamid;
  strncpy(source->ip, host, 16);
  source->port = port;
  source->counter_lo = 0;
  source->counter_hi = 0;
  source->radio_counter = 0;
  source->first_packet = 1;
/*
  source->decode = 0;
  source->decoder = &RadioEncoder;
*/
  // init comm, init to right freq & scaling, start streaming
  if ( udp_radiosource_ident(source->id) &&
       udp_radiosource_setscale(source->id, Sred) &&
       udp_radiosource_setfreq(source->id, Sfrq) &&
       udp_radiosource_startstop(source->id, 1, 0) )
    return source->id;

  return -1;
}



////////////////////////////////////////////////////////////////////////////////
// Sends command to radio source with specified ID to stop streaming
// data.  Actual UDP stream associated with the radiousource is not
// closed.  The udp_radiosource_t object is deleted.
//
// Returns:
//
//   On success: 1
//   On failure: 0
//
int udp_radiosource_close( int radioid )
{
  udp_radiosource_t *source = udp_source_find_elem( radioid );

  DBG(("%s()\n", __FUNCTION__));

  if (source == NULL)
    return 0;
  
  // stop streaming
  udp_radiosource_startstop(source->id, 0, 0);

  // deallocate
  udp_source_delete_elem( source );

  return 1;
}


oidtype udp_encode_winfn(bindtype env, oidtype rd1, oidtype rd2)
{
  int size1, size2;

  DBG(("%s()\n", __FUNCTION__));
  OfType(rd1, BINARYTYPE, env);
  OfType(rd2, BINARYTYPE, env);
  size1 = (binary_size( dr(rd1, binarycell) ));
  size2 = (binary_size( dr(rd2, binarycell) ));

  if ((size1 > 0) && (size2 >0)){
    oidtype x=nil, y=nil, z=nil, res = nil;
    udp_radiodata_t *rData = (udp_radiodata_t *)(dr(rd1,binarycell)->cont);

    int i;

    // create arrays
    a_setf(res, new_array(4, 0));
    a_setf(x, new_array(256, 0));
    a_setf(y, new_array(256, 0));
    a_setf(z, new_array(256, 0));


    for(i=0;i<122;i++) {
    a_seta(x,i+6,new_complex((float)(rData->data[i*6+0]),
                             (float)(rData->data[i*6+1])));
    a_seta(y,i+6,new_complex((float)(rData->data[i*6+2]),
                             (float)(rData->data[i*6+3])));
    a_seta(z,i+6,new_complex((float)(rData->data[i*6+4]),
                             (float)(rData->data[i*6+5])));
   }

    rData = (udp_radiodata_t *)(dr(rd2,binarycell)->cont);
    for(i=0;i<122;i++) {
    a_seta(x,i+128,new_complex((float)(rData->data[i*6+0]),
                             (float)(rData->data[i*6+1])));
    a_seta(y,i+128,new_complex((float)(rData->data[i*6+2]),
                             (float)(rData->data[i*6+3])));
    a_seta(z,i+128,new_complex((float)(rData->data[i*6+4]),
                             (float)(rData->data[i*6+5])));
   }

   for(i=0;i<6;i++){
   a_seta(x,i,new_complex(0.0,0.0));
   a_seta(y,i,new_complex(0.0,0.0));
   a_seta(z,i,new_complex(0.0,0.0));
   a_seta(x,i+250,new_complex(0.0,0.0));
   a_seta(y,i+250,new_complex(0.0,0.0));
   a_seta(z,i+250,new_complex(0.0,0.0));
   }
    a_seta(res,0, mkinteger(0));
    a_seta(res,1,x);
    a_seta(res,2,y);
    a_seta(res,3,z);

    a_return(res);
  }

  return nil;
}

/*
void udp_radiosource_bin_to_real(a_callcontext cxt, a_tuple tpl)
{
  if (consumer_status==CONSUMER_OFF) {
    printf ("start the consumer first\n");
    return;
  } else {

    udp_stream_t *stream;
    stream = udp_stream_get_by_id( a_getintelem(tpl, 0, FALSE) );

    if (stream != NULL) {

      dcl_tuple(xdata);     //sequence of 256 complex numbers
      dcl_tuple(ydata);     //sequence of 256 complex numbers
      dcl_tuple(zdata);     //sequence of 256 complex numbers
      int i;
    
      if (stream->queue.head == stream->queue.tail) {
	callsfailed++;
	return;
      }

      a_newtuple(xdata,256, FALSE);
      a_newtuple(ydata,256, FALSE);
      a_newtuple(zdata,256, FALSE);
	
      for(i=0; i<512; i+=2) {
	oidtype cn;
	cn=new_complex(stream->queue.data[stream->queue.head].x[i],
		       stream->queue.data[stream->queue.head].x[i+1]);
	a_setelem(xdata,i/2,cn);
	cn=new_complex(stream->queue.data[stream->queue.head].y[i],
		       stream->queue.data[stream->queue.head].y[i+1]);
	a_setelem(ydata,i/2,cn);
	cn=new_complex(stream->queue.data[stream->queue.head].z[i],
		       stream->queue.data[stream->queue.head].z[i+1]);
	a_setelem(zdata,i/2,cn);
      }
      
      a_setseqelem(tpl,0,xdata,FALSE);
      a_setseqelem(tpl,1,ydata,FALSE);
      a_setseqelem(tpl,2,zdata,FALSE);
      
      a_emit(cxt,tpl,FALSE);
      free_tuple(xdata);
      free_tuple(ydata);
      free_tuple(zdata);
      stream->queue.head++;
      stream->queue.head %= UDP_QUEUESIZE;
    }
  }
}
*/
