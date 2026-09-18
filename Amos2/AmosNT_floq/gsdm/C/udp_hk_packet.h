////////////////////////////////////////////////////////////////////////////
// 
// Housekeeping packet format for UDP housekeeping stream producer 
// By Arsenij Vodjanov
//
// NOTES: 
//
// Counter used in info packets is the same as the counter of the
// latest radio data packet produced by the broadcaster.
//
// Server byte order:
// All integer values are stored and sent in server host's byte order.
// Clients should check "byteorder" field in the serverinfo packets.
//
////////////////////////////////////////////////////////////////////////////

#ifndef HK_PACKET__H_
#define HK_PACKET__H_


////////////////////////////////////////////////////////////////////////////
// General-use acknowledgement packet, can be used to ack all requests.
// 
struct hkp_ack_payload {
  unsigned long rid;                 // sequence number of request that is being acknowledged
};

typedef struct hkp_ack_payload hkp_ack_payload_t;


////////////////////////////////////////////////////////////////////////////
// Server's response to "ID" message from a client
struct hkp_rspid_payload {
  unsigned long rid;                 // sequence number of "ID" request that is being acknowledged
  unsigned long client_id;           // Client's unique ID assigned by server
};

typedef struct hkp_rspid_payload hkp_rspid_payload_t;


////////////////////////////////////////////////////////////////////////////
//
// "Set client options request" packet payload.
// Sent from clients to server.
//
// Note on rate fields: 
//
// Send housekeeping packets to client for every (2^rate) radio
// packets.  Rate==0 -> 2^0=1, send an info packet for every radio
// packet.
//
// All numeric fields are in NETWORK byte order (big endian, high byte
// first).  Clients must use the hton-family of functions.
//
struct hkp_clientopt {
  unsigned long rid;                // request id, network byte order
  // Flags
  unsigned int si_autosend  : 1;    // 1 = always send serverinfo packets automatically (at si_rate)
  unsigned int ts_autosend  : 1;    // 1 = always send timestamp packets automatically (at ts_rate)
  unsigned int si_onchange  : 1;    // 1 = send serverinfo when radio settings (freq, bw) change
  unsigned int reserved     : 5;
  // Rates
  unsigned long si_rate;            // serverinfo packets rate (autosend_si must be set)
  unsigned long ts_rate;            // timestamp packets rate (autosend_ts must be set)
};

typedef struct hkp_clientopt hkp_clientopt_t;


//
// Timestamp packet payload
// Contains the bare minimum, useful to conserve bandwidth.
//
// Clients can request timestamps for each radio packet, and query
// full serverinfo when needed, or request serverinfo to be sent at a
// lower rate or only on settings change.
//
struct hkp_timestamp {
  // Counter for association with radio stream packets
  unsigned short counter_hi;       // high 16 bits of the counter
  unsigned short counter_lo;       // low 16 bits of the counter
  // Timestamp
  unsigned long ts_sec;
  unsigned long ts_nsec;
};

typedef struct hkp_timestamp hkp_timestamp_t;


//
// Server info (full) payload, binary format
//
struct hkp_serverinfo_b {
  // Counter for association with radio stream packets
  unsigned short counter_hi;       // high 16 bits of the counter
  unsigned short counter_lo;       // low 16 bits of the counter
  // Timestamp
  unsigned long ts_sec;
  unsigned long ts_nsec;

  // Flags
  unsigned int byteorder     : 1;  // 0 = Little Endian, 1 = Big Endian
  unsigned int reserved      : 31; // reserved for flags

  // Net info
  unsigned long uptime;            // seconds elapsed since server was started
  unsigned long uptime2;           // seconds elapsed since last server reset

  unsigned short udp_clients;      // number of UDP clients that are receiving data
  unsigned short tcp_clients;      // number of TCP clients (Amos2 nodes) that are receiving data

  unsigned long udp_rate_in;       // incoming data rate (from radio), Bytes/second

  unsigned long udp_rate_out;      // outgoing data rate, Bytes/second
  unsigned long tcp_rate_out;      // outgoing data rate, Bytes/second

  unsigned long packets_lost;      // number of packets lost between radio and broadcast server
  unsigned char current_loss;      // approximated current packet loss in percent 

  // Radio settings (These must be decoded from control packets)
  unsigned long freq;              // center frequency (Hz)
  unsigned long red;               // bandwidth (Hz)
};

typedef struct hkp_serverinfo_b hkp_serverinfo_b_t;


////////////////////////////////////////////////////////////////////////////
//
// Payload 
//
union hk_packet_payload {
  char buf[1024];
  hkp_serverinfo_b_t sinfo;
  hkp_clientopt_t copt;  // client's options
};

typedef union hk_packet_payload hk_packet_payload_t;


////////////////////////////////////////////////////////////////////////////
//
// UDP housekeep packet format
// Client and server use same format, but different types.
////
struct udp_hk_packet {
  // HEADER START
  char type[2];              // ID (identify), CO (client options), SI (server info), QU (quit), PI (ping), PO (pong)
  unsigned short size;       // size of payload (size of header not included)
  // HEADER END

  // PAYLOAD
  hk_packet_payload_t data;
};

typedef struct udp_hk_packet udp_hk_packet_t;


#endif
