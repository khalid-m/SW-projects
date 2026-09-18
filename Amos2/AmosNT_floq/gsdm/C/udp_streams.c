////////////////////////////////////////////////////////////////////////////////
//
// UDP Streams C-implementation and interface to Lisp
// by  Arsenij Vodjanov
//
////////////////////////////////////////////////////////////////////////////////

#include "udp_common.h"

#include "udp_streams.h"
#include "udp_hashtab.h"

static int udp_streams_debug = 0;

#define DBG(x) if (udp_streams_debug) udp_log_message x
#define ERR(x) udp_log_error x



////////////////////////////////////////////////////////////////////////////
//
// Registers foreign ALisp functions for UDP-streams manipulation
//
void udp_register_stream_functions() {
  extfunction1("UDP-DEBUG", udp_debugfn);
  extfunction0("UDP-START-THREAD", udp_startfn);
  extfunction0("UDP-STOP-THREAD", udp_stopfn);
  extfunction4("UDP-OPEN", udp_openfn);
  extfunction1("UDP-CLOSE", udp_closefn);
  extfunction2("UDP-PUT", udp_putfn);
  extfunction1("UDP-GET", udp_getfn);
  extfunction1("UDP-GET-FROM", udp_getfromfn);
  extfunction3("UDP-REDIRECT", udp_redirectfn);
  extfunction1("UDP-CHECK-DESCRIPTORS", udp_check_descriptorsfn);

  // bin array conversion
  extfunction1("BIN-TO-ARR", udp_bintoarr);
  extfunction1("ARR-TO-BIN", udp_arrtobin);
}



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
// converts binary array to int-array, one int/byte
//
// Returns: 
//   new array or NIL
//
oidtype udp_bintoarr(bindtype env, oidtype elems)
{
  int size;

  DBG(("%s()\n", __FUNCTION__));
  OfType(elems, BINARYTYPE, env);
  size = (binary_size( dr(elems, binarycell) ));

  if (size > 0) {
    oidtype res = nil;
    char *src = (char *) (dr(elems,binarycell)->cont);
    int i;

    // create array
    a_setf(res, new_array(size, 0));

    for (i=0; i<size; i++) {
      char elem = *(src++);
      a_seta(res, i, mkinteger((int)elem));
    }

    a_return(res);
  }

  return nil;
}


////////////////////////////////////////////////////////////////////////////
// convert an intarray (each element byte-ranged) to binary array
//
// Returns: 
//   new binary array
//
oidtype udp_arrtobin(bindtype env, oidtype a)
{
  int size;

  DBG(("%s()\n", __FUNCTION__));
  if (!arrayp(a)) return lerror( ILLEGAL_ARGUMENT, a, env );
  size = a_arraysize(a);

  if (size > 0) { 
    oidtype res = nil;
    char *tgt;
    int i;

    // create binary array
    a_setf(res, new_binary(size, 0));
    tgt = (char *) (dr(res,binarycell)->cont);

    for (i=0; i<size; i++) {
      int elem = 0;
      if (integerp(a_elt(a,i))) IntoInteger(a_elt(a,i), elem, env);
      *(tgt++) = (char)elem;
    }

    a_return(res);
  }

  return nil;
}



////////////////////////////////////////////////////////////////////////////
// enable/disable debug print-outs
//
// Returns: 
//
//   On debug printing enabled: 1
//   On disabled: 0
//
oidtype udp_debugfn(bindtype env, oidtype toggle)
{
  int iToggle;

  DBG(("%s()\n", __FUNCTION__));

  IntoInteger(toggle, iToggle, env);
  udp_streams_debug = (iToggle>0);

  return mkinteger(iToggle);
}


////////////////////////////////////////////////////////////////////////////
// Wrapper to start udp handler thread
//
// TODO: this is a good place to restore system state, i.e. re-open
// streams that were saved in previous sessions, etc.
//
// Returns: 
//
//   On success: 1
//   On failure: nil
//
oidtype udp_startfn(bindtype env)
{
  DBG(("%s()\n", __FUNCTION__));

  if (udp_streams_start() == 1)
    return mkinteger(1);

  return nil;
}


////////////////////////////////////////////////////////////////////////////
// Wrapper to stop udp handler thread
//
// TODO: this is a good place to save system state for next session,
// i.e. loop through all streams and store remote address, local port,
// etc.
//
// Returns: 
//
//   On success: 1
//   On failure: nil
//
oidtype udp_stopfn(bindtype env)
{
  DBG(("%s()\n", __FUNCTION__));

  if (udp_streams_stop() == 1)
    return mkinteger(1);

  return nil;
}


////////////////////////////////////////////////////////////////////////////
// Wrapper to open new udp streams
//
// Returns: 
//
//   On success: id-number (not OID) of the new stream (non-negative)
//   On failure: nil
//
oidtype udp_openfn( bindtype env, 
		    oidtype localport,
		    oidtype remoteaddr,
		    oidtype remoteport,
		    oidtype mode)
{
  char *pAddr, *pMode;
  int iLocalPort, iRemotePort, iReadAccess, iWriteAccess, iID;

  DBG(("%s()\n", __FUNCTION__));

  IntoInteger(localport, iLocalPort, env);
  IntoString(remoteaddr, pAddr, env);
  IntoInteger(remoteport, iRemotePort, env);
  IntoString(mode, pMode, env);

  // get access mode
  if (pMode && *pMode) {
    iReadAccess = ((strchr(pMode, 'r') != NULL) || (strchr(pMode, 'R') != NULL));
    iWriteAccess = ((strchr(pMode, 'w') != NULL) || (strchr(pMode, 'W') != NULL));
  }
  
  // if neither read or write access is specified, set read-only by default
  if (!iReadAccess && !iWriteAccess) {
    iReadAccess = 1;
  }
  
  iID = udp_stream_open(iLocalPort, pAddr, iRemotePort, iReadAccess, iWriteAccess);
  if ( ! (iID < 0))
    return mkinteger(iID);

  return nil;
}



////////////////////////////////////////////////////////////////////////////
// Wrapper to close open udp streams
//
// Returns: 
//
//   On success: 1
//   On failure: nil
//
oidtype udp_closefn(bindtype env, oidtype id)
{
  int iID;
  DBG(("%s()\n", __FUNCTION__));

  IntoInteger(id, iID, env);
  if (udp_stream_close( iID ) == 1)
    return mkinteger(1);

  return nil;
}



////////////////////////////////////////////////////////////////////////////
// Wrapper to get first queued packet from an udp stream open for reading
//
// Returns: 
//
//   On success: bytearray of data
//   On failure: nil
//
oidtype udp_getfn(bindtype env, oidtype id)
{
  int iID;
  udp_indata_t *pData;

  DBG(("%s()\n", __FUNCTION__));
  
  IntoInteger(id, iID, env);
  pData = udp_stream_get( iID );
  
  if (pData != NULL && 
      pData->size > 0 && 
      pData->size <= UDP_MAXBUFLEN) {
    
    oidtype elems = nil;
    a_setf( elems, new_binary( pData->size, 0 ) );
    memcpy((char*)&(dr(elems,binarycell)->cont), pData->buf, pData->size);
/*
    for (i=0; i<pData->size; i++) {
      ( ((char*)&(dr(elems,binarycell)->cont))[i] ) = pData->buf[i];
    }
*/
    a_return( elems );
  }

  return nil;
}



////////////////////////////////////////////////////////////////////////////
// Wrapper to get first queued packet and sender's address from an udp
// stream open for reading.
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
oidtype udp_getfromfn(bindtype env, oidtype id)
{
  int iID;
  udp_indata_t *pData;

  DBG(("%s()\n", __FUNCTION__));

  IntoInteger(id, iID, env);
  pData = udp_stream_get( iID );
  
  if (pData != NULL && 
      pData->size > 0 && 
      pData->size <= UDP_MAXBUFLEN) {
    
    oidtype elems = nil, res = nil;
    
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



////////////////////////////////////////////////////////////////////////////
// Wrapper to write data to an udp stream open for writing.
// Data is a binary array of max size UDP_MAXBUFLEN.
//
// Returns: 
//
//   On success: 1
//   On failure: nil
//
oidtype udp_putfn(bindtype env, oidtype id, oidtype elems)
{
  int iID, barr_size;

  DBG(("%s()\n", __FUNCTION__));

  OfType(elems, BINARYTYPE, env);
  IntoInteger(id, iID, env);

  barr_size = binary_size( dr(elems, binarycell) );

  if (barr_size>0 && barr_size <= UDP_MAXBUFLEN) {
/*
    int i;
    char buf[UDP_MAXBUFLEN];
    for (i=0; i<barr_size; i++)
      buf[i] = (char) ( ((char*)&(dr(elems,binarycell)->cont))[i] ) ;
*/    
    char *buf = (char*)&(dr(elems,binarycell)->cont);
    if (udp_stream_put( iID, buf, barr_size ) == 1)
      return mkinteger(1); // success
  }

  return nil;
}



////////////////////////////////////////////////////////////////////////////
//
// Wrapper to "redirect" a stream to the specified hostname:port.
// Subsequent "puts" will send data to this host.
//
// Returns: 
//
//   On success: 1
//   On failure: nil
//
oidtype udp_redirectfn(bindtype env, oidtype id, oidtype addr, oidtype port)
{
  int iID;
  char *pAddr;
  int iPort;
  
  DBG(("%s()\n", __FUNCTION__));
  
  IntoInteger(id, iID, env);
  IntoString(addr, pAddr, env);
  IntoInteger(port, iPort, env);
  if ( pAddr && *pAddr && iPort) {
    if ( udp_stream_redirect( iID, pAddr, iPort ) == 1 )
      return mkinteger(1); // success
  }

  return nil;
}


////////////////////////////////////////////////////////////////////////////
// Wrapper to receive data on udp streams that are open for reading
//
// FOR NON-THREADED UDP-STREAMS OPERATION ONLY
// DO NOT CALL THIS FUNCTION WHEN RECEIVER-THREAD IS RUNNING
//
// Returns: 
//
//   On success: number of streams with data to get.
//   On failure: nil
//
oidtype udp_check_descriptorsfn(bindtype env, oidtype timeout_sec)
{
  unsigned long count, sec, usec;
  double timeout;
  
  DBG(("%s()\n", __FUNCTION__));
  
  IntoDouble(timeout_sec, timeout, env);

  sec = (long)timeout;
  usec = (long)( ((double)timeout - (double)sec) * (double)1000000.0 );

  DBG(("Timeout: %ul s %ul us\n", sec, usec));

  count = udp_check_descriptors( sec, usec );
  
  if (count>=0)
    return mkinteger(count);
 
  return nil;
}




////////////////////////////////////////////////////////////////////////////////
//
//
//
//           C-implementation of the UDP streams starts here
//
//
//
////////////////////////////////////////////////////////////////////////////////







////////////////////////////
// Stream status as bitfield
struct udp_stream_status {
  unsigned open     : 1; // 1 if udp socket is created and bound to a port
  unsigned read     : 1; // 1 if stream allows read access (packets can be received)
  unsigned write    : 1; // 1 if stream allows write access (packets can be sent)
  unsigned closeme  : 1; // for thread-version, marks stream for closing
  unsigned deleteme : 1; // for thread-version, marks stream for deallocation
  unsigned          : 5; // padding to 8 bits
};
typedef struct udp_stream_status udp_stream_status_t;


//////////////////////////////////
// In-data queue, circular buffer.
struct udp_inqueue {
  udp_indata_t data[UDP_QUEUESIZE];  // data
  int head;             // first element
  int tail;             // first free location for a newly arriving packet
};
typedef struct udp_inqueue udp_inqueue_t;


/////////////////////
// Stream descriptor.
struct udp_stream {
  // Pointers to next & prev streams in global linked list
  struct udp_stream    *prev;
  struct udp_stream    *next;

  // Stream status
  udp_stream_status_t   status;

  int                   id;                    // ID of the stream
  
  udp_inqueue_t         queue;                 // queue for incoming data

  // Address & port info of the remote host associated with this udp
  // stream.  Filled in by udp_stream_connect(), this will be the only
  // host from which packets can be received, and the target host to
  // which packets will be sent by default.
  char                  hostname[256];
  struct sockaddr_in    addr;
  int                   port;

  // Address & port info of the local host. Initialized by udp_stream_init()
  struct sockaddr_in    my_addr;
  int                   my_port;

  // Comm socket, initialized by udp_stream_init()
  SOCKET                sockfd;
};
typedef struct udp_stream udp_stream_t;


///////////////////////////////////////////////////////////////
// This macro declares a hashtable for udp_stream_t * type, and
// functions to access/create/delete elements in the table.
//
//                PREFIX        ELEM TYPE      TABLE SIZE (#buckets)
MM_DEF_HASHTABLE( udp_streams,  udp_stream_t,  64 )




////////////////////////////////////////////////////////////////////////////
//                                 
static HANDLE hThread;             // Thread handle
static int udp_thread_active = 0;  // 1 if handler thread is active


////////////////////////////////////////////////////////////////////////////
// internal functions prototypes
//
static  int  udp_stream_init(udp_stream_t *, int, int, int);
static  int  udp_stream_shutdown( udp_stream_t * );
static void  udp_stream_post_shutdown( udp_stream_t * );
static void  udp_stream_post_delete( udp_stream_t * );
static  int  udp_stream_connect(udp_stream_t *, char *, int);
static int   udp_stream_senddata( udp_stream_t *, char *, unsigned int );
static int   udp_stream_senddata_to( udp_stream_t *, char *, unsigned int, struct sockaddr *, socklen_t );
static udp_indata_t *udp_stream_getdata( udp_stream_t * );
#ifdef PLATFORM_LINUX
static void *udp_handler_thread(void *);
#endif
#ifdef PLATFORM_WINDOWS
static DWORD udp_handler_thread(LPVOID *);
#endif
//
////////////////////////////////////////////////////////////////////////////



////////////////////////////////////////////////////////////////////////////
// Creates and opens a new stream.
//
// If local port is 0, uses any available port to bind socket.
//
// If remote hostname/ip and port is specified, resolves the host and
// saves the address info.  Fails if remote host is specified, but
// can't be resolved.
//
// Returns:
//   On success: ID of the new stream (non-negative)
//   On failure: -1
//
int udp_stream_open(int localport, 
		    char *hostname, int remoteport, 
		    int readaccess, int writeaccess)
{
  udp_stream_t *stream;

  DBG(("%s()\n", __FUNCTION__));

  stream = udp_streams_create_elem();
  if (stream != NULL) {
    int ok=0;

    if ( udp_stream_init( stream, localport, readaccess, writeaccess ) == 1 ) {
      // If an address was given, try to connect to it.
      if ( hostname && *hostname )
	ok = ( udp_stream_connect( stream, hostname, remoteport ) == 1 );
      else 
	ok = 1;
    } 
    if (ok)
      return stream->id;
    
    udp_stream_shutdown( stream );
    udp_streams_delete_elem( stream );
  }

  return -1;
}
//
////////////////////////////////////////////////////////////////////////////


////////////////////////////////////////////////////////////////////////////
// Closes the socket associated with the stream with specified ID and
// invalidates the stream.
//
// Returns:
//   On success: 1
//   On failure: 0
int udp_stream_close( int id )
{
  udp_stream_t *stream;

  DBG(("%s()\n", __FUNCTION__));

  stream = udp_streams_find_elem( id );
  if (stream != NULL) {
    if (udp_thread_active) {
      udp_stream_post_shutdown( stream );
      udp_stream_post_delete( stream );
    } else {
      udp_stream_shutdown( stream );
      udp_streams_delete_elem( stream );
      stream = NULL;
    }
    return 1;
  }
  return 0;
}
//
////////////////////////////////////////////////////////////////////////////


////////////////////////////////////////////////////////////////////////////
// Returns the first queued udp packet as pointer to a udp_indata_t.
// The pointer must not be freed.
//
// Returns:
//   On success: Pointer to udp_indata_t structure
//   On failure: NULL
udp_indata_t *udp_stream_get( int id )
{
  udp_stream_t *stream;

  DBG(("%s()\n", __FUNCTION__));

  stream = udp_streams_find_elem( id );
  if (stream != NULL) {
    return udp_stream_getdata( stream );
  }
  return NULL;
}
//
////////////////////////////////////////////////////////////////////////////


////////////////////////////////////////////////////////////////////////////
// Sends data to default destination address.
//
// Returns:
//   On success: 1
//   On failure: 0
int udp_stream_put( int id, char *data, unsigned int size )
{
  udp_stream_t *stream;

  DBG(("%s()\n", __FUNCTION__));

  stream = udp_streams_find_elem( id );
  if (stream != NULL) {
    if (udp_stream_senddata( stream, data, size ) == 1)
      return 1;
  }
  return 0;
}
//
////////////////////////////////////////////////////////////////////////////


////////////////////////////////////////////////////////////////////////////
// Reassigns default destination address.
//
// Returns:
//   On success: 1
//   On failure: 0
int udp_stream_redirect( int id, char *hostname, int port )
{
  udp_stream_t *stream;

  DBG(("%s()\n", __FUNCTION__));

  stream = udp_streams_find_elem( id );
  if (stream != NULL) {
    if (udp_stream_connect( stream, hostname, port ) == 1)
      return 1;
  }
  return 0;
}
//
////////////////////////////////////////////////////////////////////////////


////////////////////////////////////////////////////////////////////////////
// Starts the udp handler thread
//
// Returns:
//   On success: 1
//   On failure: 0
//
int udp_streams_start() 
{
#ifdef PLATFORM_WINDOWS
  DWORD threadID;
#endif
  DWORD thread_arg = 0;

  DBG(("%s()\n", __FUNCTION__));

  if (!udp_thread_active) {

    udp_thread_active = 1;
    
#ifdef PLATFORM_LINUX
    // posix thread, non-zero return value indicates error
    if ( pthread_create(&hThread, NULL, &udp_handler_thread, &thread_arg) !=0 ) {
      ERR(("Couldn't create udp handler thread.\n"));
      udp_thread_active = 0;
      return 0;
    }
#endif
#ifdef PLATFORM_WINDOWS
    // windows thread
    hThread = CreateThread(NULL, 0,
			   (LPTHREAD_START_ROUTINE)udp_handler_thread, 
			   &thread_arg, 0, &threadID);
#endif
    return 1;
  }
  return 0;
}


////////////////////////////////////////////////////////////////////////////
// Stops the udp handler thread.
//
// Returns:
//   On success: 1
//   On failure: 0
//
int udp_streams_stop() 
{
#ifdef PLATFORM_WINDOWS
  int msTimout = 5000;    // thread timeout
#endif

  DBG(("%s()\n", __FUNCTION__));

  if (udp_thread_active) {
    udp_thread_active = 0;

#ifdef PLATFORM_LINUX
    pthread_join(hThread, NULL);
#endif
#ifdef PLATFORM_WINDOWS
    WaitForSingleObject (hThread, msTimout);
#endif
    return 1;
  }
  
  return 0;
}



////////////////////////////////////////////////////////////////////////////
// network errors output
//
static int sockerror(char * msg)
{       
  int err = sockerrno;
  ERR(("UDP Streams error: %s (errno %u) \n", msg, err));
  return err;
}
//
////////////////////////////////////////////////////////////////////////////




////////////////////////////////////////////////////////////////////////////////
// Marks a stream for deletion by udp_handler_thread.
//
// After this function returns, the stream structure should no longer
// be accessed, and all pointers to it should be considered invalid.
//
static void udp_stream_post_delete( udp_stream_t *stream )
{
  DBG(("%s()\n", __FUNCTION__));

  if (stream!=NULL) {
    if (stream->status.open)
      stream->status.closeme = 1;
    stream->status.deleteme = 1;
  }
}



////////////////////////////////////////////////////////////////////////////////
// Marks a stream for closing by udp_handler_thread.
//
// After this function returns, the stream should be considered closed.
//
static void udp_stream_post_shutdown( udp_stream_t *stream )
{
  DBG(("%s()\n", __FUNCTION__));

  if (stream!=NULL) {
    if (stream->status.open)
      stream->status.closeme = 1;
  }
}


////////////////////////////////////////////////////////////////////////////////
// Fills in local address info, creates an udp socket for a stream and
// binds it to given localport.  If localport is 0, binds socket to
// any available port.  Sets
//
// Stream must not be already open.
// Puts stream in OPEN status.
//
// Returns:
//   1 if successful, a negative value on error
//  -1 if socket error occured
//  -2 if stream pointer is NULL
//  -3 if stream is already open
//
static int udp_stream_init(udp_stream_t *stream, int localport,
			   int readaccess, int writeaccess)
{
  DBG(("%s()\n", __FUNCTION__));

  if (stream == NULL)
    return -2;
  else if (stream->status.open)
    return -3;
  else {

    int yes = 1;

#ifdef PLATFORM_WINDOWS
    /*Winsock2 specific part */
    WORD wVersionRequested;
    WSADATA wsaData;
    int err;
    
    // We can call WSAStartup as many times as we want, as long as we
    // call WSACleanup for each WSAStartup
    
    wVersionRequested = MAKEWORD( 2, 2 );  
    err = WSAStartup( wVersionRequested, &wsaData );
    if ( err != 0 ) {
      /* Tell the user that we could not find a usable */
      /* WinSock DLL.                                  */
      fprintf(stderr, "Could not find a usable WinSock DLL\n");
      return -1;
    }
    /* Confirm that the WinSock DLL supports 2.2.*/
    if ( LOBYTE( wsaData.wVersion ) != 2 ||
	 HIBYTE( wsaData.wVersion ) != 2 ) {
      WSACleanup( );
      fprintf(stderr, "WinSock DLL does not support 2.2\n");
      return -1;
    }
    /* The Winsock DLL is acceptable. Proceed. */
#endif
    
    stream->sockfd = socket(AF_INET, SOCK_DGRAM, 0);
    if (stream->sockfd == INVALID_SOCKET) {
      sockerror("udp_streams_init(), socket");
#ifdef PLATFORM_WINDOWS
      WSACleanup( );
#endif /* PLATFORM_WINDOWS */
      return -1;
    }
    
    // local address info
    stream->my_addr.sin_family = AF_INET;         // host byte order BIG ENDIAN
    stream->my_addr.sin_port = htons(localport);  // if 0, use any available port
    stream->my_addr.sin_addr.s_addr = INADDR_ANY; // automatically fill with my IP
    memset(&(stream->my_addr.sin_zero), '\0', 8); // zero the rest of the struct
    
    if ( bind( stream->sockfd, 
	       (struct sockaddr *)&(stream->my_addr), 
	       sizeof(struct sockaddr) ) == SOCKET_ERROR ) {
      sockerror("udp_streams_init(), bind");
#ifdef PLATFORM_WINDOWS
      WSACleanup( );
#endif /* PLATFORM_WINDOWS */
      return -1;
    }
    
    // no errors, we are ready to send and receive packets

#ifdef PLATFORM_LINUX
    // enable broadcast
    setsockopt(stream->sockfd, SOL_SOCKET, SO_BROADCAST, &yes, sizeof(int));
#endif
    
    stream->my_port = (int)ntohs(stream->addr.sin_port);
    stream->status.read = (readaccess > 0);
    stream->status.write = (writeaccess > 0);
    stream->status.open = 1;
    
    // return 1 on success
    return 1;
  }
}


////////////////////////////////////////////////////////////////////////////////
// Fills in remote address info and port to allow writing to stream
// without explicitly specifying a target.
//
// If specified port is 0, uses default value 4096.
//
// Stream must be already open
//
// Returns:
//   1 if successful, a negative value on error
//  -1 if hostname can't be resolved
//  -2 if stream pointer is NULL
//  -3 if stream is not open
//
static int udp_stream_connect(udp_stream_t *stream, char *hostname, int port)
{
  DBG(("%s()\n", __FUNCTION__));

  if (stream == NULL)
    return -2;
  
  if (!stream->status.open)
    return -3;
  
  // fill in remote address info if hostname is given
  if (hostname!=NULL && *hostname!=0) { 
    struct hostent * he;
    he = gethostbyname(hostname);
    if (he != NULL) {
      stream->addr.sin_family = AF_INET;              // host byte order
      stream->addr.sin_port = htons(port==0 ? 4096 : (unsigned short)port);  // default remote port is 4096
      stream->addr.sin_addr = *((struct in_addr *)he->h_addr);
      memset(&(stream->addr.sin_zero), '\0', 8);      // zero the rest of the struct

      strncpy(stream->hostname, hostname, sizeof(stream->hostname)-1);
      stream->port = (unsigned short)ntohs(stream->addr.sin_port);

      // Don't want to use connect(), because it filters traffic from/to
      // everywhere except the connected host.
/*
      if ( connect( stream->sockfd, 
		    (struct sockaddr *)&(stream->addr), 
		    sizeof(struct sockaddr_in) ) != SOCKET_ERROR ) {
	// no errors
	strncpy(stream->hostname, hostname, sizeof(stream->hostname)-1);
	stream->port = (int)ntohs(stream->addr.sin_port);
	return 1;
      } else {
	sockerror("udp_stream_connect(), connect");
	memset(&stream->addr, 0, sizeof(struct sockaddr_in));
      }
*/
      return 1;
    } else
      ERR(("UDP Streams error: udp_stream_connect(), gethostbyname\n"));
  }
  return -1;
}



////////////////////////////////////////////////////////////////////////////////
// Closes an open udp stream.  All data is reset to initial values.
//
// Stream must be open.
//
// Returns:
//   1 if successful, a negative value on error
//  -2 if stream pointer is NULL
//  -3 if stream is not open
//
static int udp_stream_shutdown( udp_stream_t *stream )
{
  DBG(("%s()\n", __FUNCTION__));

  if (stream==NULL)
    return -2;

  if (!stream->status.open)
    return -3;

  stream->status.open = 0;
  close(stream->sockfd);
  stream->queue.head = stream->queue.tail = 0;
  memset(&stream->my_addr, 0, sizeof(struct sockaddr_in));
  stream->my_port = 0;
  stream->sockfd = INVALID_SOCKET;

#ifdef PLATFORM_WINDOWS
  WSACleanup( );
#endif /* PLATFORM_WINDOWS */

  return 1;
}




////////////////////////////////////////////////////////////////////////////////
// Gets a pointer to the first packet waiting in receive-queue of the
// stream, and moves to the next packet in queue.  If there are no
// packets in queue, this funciton has no effect.
//
// Stream must be open for reading. 
//
// Returns: 
//   Pointer to udp_indata structure that contains the first packet in queue.
//   NULL if no packets are left in the queue or if stream is not open for reading.
//
static udp_indata_t *udp_stream_getdata( udp_stream_t *stream )
{
  udp_indata_t *ret;

  DBG(("%s()\n", __FUNCTION__));

  if (stream==NULL)
    return NULL;

  if ( !(stream->status.open && stream->status.read) )
    return NULL;
  
  if (stream->queue.head == stream->queue.tail)
    return NULL;

  ret = &( stream->queue.data[ stream->queue.head ] );
  stream->queue.head = (stream->queue.head + 1) % UDP_QUEUESIZE;

  return ret;
}



////////////////////////////////////////////////////////////////////////////////
// Send an udp packet to default recipent.  If there is no default
// recipent, this function produces an error.
//
// Stream must be open for writing. 
//
// Returns: 
//   On success: 1
//   On failure:
//    -1 if socket error occured
//    -2 if stream pointer is NULL
//    -3 if stream is not open for writing
//    -4 if there is no default recipent for the data
//
static int udp_stream_senddata( udp_stream_t *stream, 
				char *data, unsigned int len )
{
  DBG(("%s()\n", __FUNCTION__));

  if (stream==NULL)
    return -2;
  if ( !(stream->addr.sin_addr.s_addr) )
    return -4;

  return udp_stream_senddata_to( stream, data, len, 
				 (struct sockaddr *)&(stream->addr), 
				 sizeof(struct sockaddr_in) );
}


////////////////////////////////////////////////////////////////////////////////
// Send an udp packet to specified recipent.
//
// Stream must be open for writing. 
//
// Returns: 
//   On success: 1
//   On failure:
//    -1 if socket error occured
//    -2 if stream pointer is NULL
//    -3 if stream is not open for writing
//
static int udp_stream_senddata_to( udp_stream_t *stream, 
				   char *data, unsigned int len,
				   struct sockaddr *to, socklen_t to_len)
{
  int res;

  DBG(("%s()\n", __FUNCTION__));

  if (stream==NULL)
    return -2;
  if ( !(stream->status.open && stream->status.write) )
    return -3;

  res = sendto(stream->sockfd, (char*) data, len, 0,
	       (struct sockaddr *)to, to_len);

  if (res == len)
    return 1; // success
  else {
    if (res == SOCKET_ERROR)
      sockerror("udp_stream_senddata_to(), sendto failed");
    else
      sockerror("udp_stream_senddata_to(), short send ");
  }
  return -1;  // net error
}



////////////////////////////////////////////////////////////////////////////////
//
// FOR NON-THREADED UDP-STREAMS OPERATION ONLY
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
int udp_check_descriptors( long sec, long usec )
{
  int maxfd = 0, retval, errors=0;
  fd_set fds; // descriptor set
  struct timeval timeout;
  udp_stream_t *stream;

  DBG(("%s()\n", __FUNCTION__));

  // are there any udp streams at all?
  if (udp_streams_num_elements==0)
    return 0;
  
  FD_ZERO(&fds);
  
  // Add each stream's socket descriptor to the set
  for(stream = udp_streams_first_elem(); stream != NULL; stream = udp_streams_next_elem( stream )) {
    // Only add streams that are open for reading and have space left in queue
    if ( stream->status.open && stream->status.read ) {
      if ( stream->queue.head != (stream->queue.tail+1) % UDP_QUEUESIZE ) {
	FD_SET(stream->sockfd, &fds);
	if (stream->sockfd > maxfd)
	  maxfd = stream->sockfd;
      }
    }
  }

  // if none of existing udp streams can receive data, abort
  if (maxfd==0)
    return 0;

  maxfd++; // select() needs (largest numbered descriptor + 1)

  if (usec + sec >= 0) {
    timeout.tv_sec = sec;
    timeout.tv_usec = usec;
  } else {
    timeout.tv_sec = 0;
    timeout.tv_usec = 5;
  }

  retval = select(maxfd, &fds, NULL, NULL, &timeout);

  // select returns non-zero if there's data
  if (retval > 0) {

    // Data is available on one or more sockets, let's receive it.
    for(stream = udp_streams_first_elem(); stream != NULL; stream = udp_streams_next_elem( stream )) {

      // data available on this socket?
      if ( FD_ISSET(stream->sockfd, &fds) ) {
	int numbytes;
	struct sockaddr_in from;
	socklen_t from_len = sizeof(struct sockaddr_in);
	udp_indata_t *dst = &( stream->queue.data[ stream->queue.tail ] );
	
	// receive data and source address info
	numbytes = recvfrom(stream->sockfd, (char*)(dst->buf), UDP_MAXBUFLEN, 0,
			    (struct sockaddr *)&(from),
			    (socklen_t *)&(from_len));
	
	if (numbytes != SOCKET_ERROR) {
	  char *ip = inet_ntoa(from.sin_addr);
	  dst->size = numbytes;
	  strncpy(dst->sourceip, ip, 16);
	  dst->sourceport = (unsigned short)ntohs(from.sin_port);
	  stream->queue.tail = (stream->queue.tail + 1) % UDP_QUEUESIZE;
	} else {
	  sockerror("udp_check_descriptors(), recvfrom");
	  retval = -1;
	}
      }
    }
  } else
    if (retval==-1)
      sockerror("udp_check_descriptors(), select");
  
  return retval;
}


////////////////////////////////////////////////////////////////////////////////
//
// This is the thread-version of udp_check_descriptors.  It does all
// the things as udp_check_descriptors, but doesn't print any errors.
// The loop terminates when the value of udp_thread_active becomes 0.
//
// In addition, this function takes care of deallocating streams (that
// are marked for deletion) and removing references to them from the
// global stream list.
//
// The thread sleeps at most 5 microseconds in each loop iteration.
//
// Returns: nothing
//
#ifdef PLATFORM_LINUX
static void *udp_handler_thread(void *arg)
#endif
#ifdef PLATFORM_WINDOWS
static DWORD udp_handler_thread(LPVOID *arg)
#endif
{
  unsigned int errors=0;
  struct timeval timeout;

  DBG(("%s()\n", __FUNCTION__));

  timeout.tv_sec = 0;
  timeout.tv_usec = 5;

  while (udp_thread_active) {

    fd_set fds; // descriptor set
    int i = 0, maxfd = 0, retval = 0;
    udp_stream_t *stream;

    // are the any udp streams at all?
    if (udp_streams_num_elements>0) {

      FD_ZERO(&fds);

      // Add each stream's socket descriptor to the set.
      i=0;
      stream = udp_streams_first_elem();
      while( i<udp_streams_num_elements && stream != NULL ) {

	// Close stream if it's marked for closing 
	if ( stream->status.closeme ) {
	  udp_stream_shutdown( stream );
	}
	// Delete stream if it's marked for deallocation
	if ( stream->status.deleteme ) {
	  udp_stream_t *next = udp_streams_next_elem( stream );
	  udp_streams_delete_elem( stream );
	  stream = next;
	} else {
	  // Only add streams that are open for reading and have space left in queue.
	  // Let the OS handle overflow.
	  if ( stream->status.open && stream->status.read ) {
	    if ( stream->queue.head != (stream->queue.tail+1) % UDP_QUEUESIZE ) {
	      FD_SET(stream->sockfd, &fds);
	      if (stream->sockfd > maxfd)
		maxfd = stream->sockfd;
	    }
	  }
	  stream = udp_streams_next_elem( stream );
	  i++; // only count streams that haven't been removed
	}
      }
    }

    // need at least one socket descriptor to poll
    if (maxfd>0) {

      maxfd++; // select() needs (largest numbered descriptor + 1)
      retval = select(maxfd, &fds, NULL, NULL, &timeout);

      // select returns non-zero if there's data
      if (retval > 0) {

	// Data is available on one or more sockets, let's receive it.
	for(stream = udp_streams_first_elem(); stream != NULL; stream = udp_streams_next_elem( stream )) {
	  
	  // data available on this socket?
	  if ( FD_ISSET(stream->sockfd, &fds) ) {
	    int numbytes;
	    struct sockaddr_in from;
	    //socklen_t from_len = sizeof(struct sockaddr_in);
	    socklen_t from_len = sizeof(struct sockaddr);
	    udp_indata_t *dst = &( stream->queue.data[ stream->queue.tail ] );

	    // receive data and source address info
	    numbytes = recvfrom(stream->sockfd, (char*)(dst->buf), UDP_MAXBUFLEN, 0,
				(struct sockaddr *)&(from),
				(socklen_t *)&(from_len));
	    
	    if (numbytes != SOCKET_ERROR) {
	      char *ip = inet_ntoa(from.sin_addr);
	      dst->size = numbytes;
	      strncpy(dst->sourceip, ip, 16);
	      dst->sourceport = (unsigned short)ntohs(from.sin_port);
	      stream->queue.tail = (stream->queue.tail + 1) % UDP_QUEUESIZE;
	    } else 
	      errors++;
	  } // if (FD_ISSET)

	} // for()
      } else // select() returned less than 1
	if (retval<0)
	  errors++;
    } // if (maxfd)

    // No data received?
    if (maxfd==0 || retval==0) {
      // sleep 5us to avoid massive cpu usage
#ifdef PLATFORM_LINUX
      unsigned long usec = 5;
      usleep(usec);
#endif
#ifdef PLATFORM_WINDOWS
      // I don't know how to suspend execution with microsecond
      // precision in windows
#endif
    }
  } // while(udp_thread_active)

  DBG(("UDP handler-thread exiting. Errors during execution: %i  ", errors));
  DBG(("Remaining undeleted streams: %i\n", udp_streams_num_elements));

#ifdef PLATFORM_LINUX
  return arg;
#endif
#ifdef PLATFORM_WINDOWS
  return 1;
#endif
}
