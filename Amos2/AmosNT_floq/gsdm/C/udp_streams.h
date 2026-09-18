////////////////////////////////////////////////////////////////////////////
//
// UDP Streams C/Lisp interface functions
// by  Arsenij Vodjanov
//
////////////////////////////////////////////////////////////////////////////

#ifndef UDP_STREAMS_H__
#define UDP_STREAMS_H__

#include "../../C/alisp.h"
#include "../../C/storage.h"

#define UDP_MAXBUFLEN 4096   // max size (in bytes) of one udp packet
#define UDP_QUEUESIZE 2000   // max number of udp packets in one stream's queue

// Storage for one UDP packet.
struct udp_indata {
  char buf[UDP_MAXBUFLEN];   // packet data
  int  size;                 // size in bytes of data in buf[]
  char sourceip[16];         // IPv4 addr in standard dot-notation
  unsigned long ulip;        // IP as 32-bit unsigned, host byte-order (for faster comparision)
  unsigned short sourceport; // port as 16-bit unsigned, host byte order
};
typedef struct udp_indata udp_indata_t;



////////////////////////////////////////////////////////////////////////////
// Creates and opens a new stream.
// If local port is 0, uses any available port to bind socket.
//
// If remote hostname/ip and port is specified, resolves the host and
// saves the address info as the default destination address.  Fails
// if remote host can't be resolved.
//
// Returns:
//   On success: ID of the new stream
//   On failure: 0
//
extern int udp_stream_open(int localport, 
			   char *hostname, int remoteport, 
			   int readaccess, int writeaccess);


////////////////////////////////////////////////////////////////////////////
//
// udp_stream_close
//
// Closes the socket associated with the stream with specified ID and
// invalidates the stream.
//
// Returns:
//   On success: 1
//   On failure: 0
extern int udp_stream_close( int id );


////////////////////////////////////////////////////////////////////////////
//
// udp_stream_get
//
// Returns the first queued udp packet as pointer to a udp_indata_t.
// The pointer must not be freed.
//
// Returns:
//   On success: Pointer to udp_indata_t structure
//   On failure: NULL
extern udp_indata_t *udp_stream_get( int id );


////////////////////////////////////////////////////////////////////////////
//
// udp_stream_put
//
// Sends data to default destination address.
//
// Returns:
//   On success: 1
//   On failure: 0
extern int udp_stream_put( int id, char *data, unsigned int size );


////////////////////////////////////////////////////////////////////////////
//
// udp_stream_redirect
//
// Reassigns default destination address.
//
// Returns:
//   On success: 1
//   On failure: 0
extern int udp_stream_redirect( int id, char *hostname, int port );



////////////////////////////////////////////////////////////////////////////////
//
// udp_check_descriptors
// 
// FOR NON-THREADED UDP-STREAMS IMPLEMENTATION ONLY
// DO NOT CALL THIS FUNCTION WHEN RECEIVER-THREAD IS RUNNING
//
// Polls socket descriptors for all udp streams, and receives one udp
// packet on each one that won't block.  If the in-queue of a stream
// is full, that stream's socket is not checked.
//
// Time-out is given in seconds and microseconds. 5 us is good.
//
// Returns: 
//   On success: number of streams that received data, 0 if none.
//   On error:  -1
//
extern int udp_check_descriptors( long sec, long usec );


////////////////////////////////////////////////////////////////////////////////
// C-function to register the lisp functions.
extern void udp_register_stream_functions();


//
//
// Wrapper functions called from Lisp:
//
//


// Enable/disable debug output (non-zero arg enables)
//
// UDP-DEBUG (int OnOff) -> int Result
extern oidtype udp_debugfn(bindtype env, oidtype toggle);

// UDP-START-SYSTEM () -> int Result
extern oidtype udp_startfn(bindtype env);

// UDP-STOP-SYSTEM () -> int Result
extern oidtype udp_stopfn(bindtype env);

// UDP-OPEN (int LocalPort, string RemoteHost, int RemotePort, string AccessMode)-> int StreamID
extern oidtype udp_openfn( bindtype env, oidtype localport, 
			   oidtype remoteaddr, oidtype remoteport, 
			   oidtype mode);

// UDP-CLOSE (int StreamID) -> int Result
extern oidtype udp_closefn(bindtype env, oidtype id);

// UDP-GET (int StreamID) -> bin-array Data
//
// Note: size of binary arrays is always rounded up to nearest
// multiple of 4, so if you need to know the exact number of bytes in
// the received udp packet, use function udp-get-from instead.
extern oidtype udp_getfn(bindtype env, oidtype id);

// UDP-GET-FROM (int StreamID) -> list (string RemoteHost, int RemotePort, int ActualByteSize, bin-array Data)
extern oidtype udp_getfromfn(bindtype env, oidtype id);

// UDP-PUT (int StreamID, bin-array Data) -> int Result
extern oidtype udp_putfn(bindtype env, oidtype id, oidtype elems);

// UDP-REDIRECT (int StreamID, string Hostname, int Port) -> int Result
extern oidtype udp_redirectfn(bindtype env, oidtype id, oidtype addr, oidtype port);

//
// If udp-thread is not running, this function can be used to pump udp
// messages.  It returns number of streams with data available for reading.
//
// UDP-CHECK-DESCRIPTORS ( real Timeout ) -> int Count
extern oidtype udp_check_descriptorsfn(bindtype env, oidtype timeout_sec);


// bin array to int array
extern oidtype udp_bintoarr(bindtype env, oidtype elems);

// int array to bin array
extern oidtype udp_arrtobin(bindtype env, oidtype a);


#endif
