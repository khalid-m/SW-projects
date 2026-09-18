#include <callout.h> /* always include callout.h when defining foreign functions */
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <unistd.h>

void testcan(a_callcontext cxt, a_tuple tpl);
void canrelay(a_callcontext cxt, a_tuple tpl);

main(int argc,char **argv)
{
  dcl_connection(c); /* To hold connection to Amos */
  init_amos(argc,argv); /* Initialize embedded Amos */
  /* Bind C function 'sqrtbf' to Amos symbol 'sqrtbf': */
  a_extfunction("testcan",testcan);
  a_extfunction("canrelay",canrelay);
  a_connect(c,"",FALSE); /* Connect to embedded Amos */
  /* Define Amos II function 'sqrt(real x) -> real' as sqrtbf
  (can also be done separately in a script as explained below): */
  amos_toploop("Canrelay"); /* Enter interactive Amos II top loop */
  free_connection(c);
  exit(0);
}


void testcan(a_callcontext cxt, a_tuple tpl)
{
  double x;
  x = a_getintelem( tpl,0,FALSE ); /* Pick up the argument */

  
  a_setintelem( tpl,1, x+1, FALSE );
  a_emit(cxt,tpl,FALSE );

  a_setintelem( tpl,1, x+2, FALSE );
  a_emit(cxt,tpl,FALSE );

  return;
}

void canrelay(a_callcontext cxt, a_tuple tpl)
{
  FILE *read_fp;
  char buffer[ BUFSIZ + 1 ];
  int chars_read;
  memset( buffer, '\0', sizeof( buffer ) );
  
  char program_str[100];
  a_getstringelem( tpl, 0, program_str, sizeof(program_str), FALSE );
  
  read_fp = popen(program_str, "r" );
  if ( !read_fp )
    return;
  int count_rows=0;
  
  char *ok;
  ok = fgets( buffer, BUFSIZ, read_fp );
  while ( ok )
  {
    // ignore the first 13 lines
    if ( count_rows!= -1 )
    {
      count_rows++;
      if ( count_rows < 14 )
      {
	ok = fgets( buffer, BUFSIZ, read_fp );
	continue;
      }
      if ( count_rows == 14 )
	count_rows = -1;
    }
    
    buffer[ strlen(buffer)-1 ] = '\0';
    
    char *time, *bus, *id, *id_length, *data_length, *data;
    time = strtok(buffer, "\t");
    bus = strtok(NULL, "\t");
    bus = &bus[4]; //remove "bus="
    id = strtok(NULL, "\t");
    id = &id[3]; //remove "id="
    id_length = strtok(NULL, "\t");
    data_length = strtok(NULL, "\t");
    data = strtok(NULL, "");
    if ( data == NULL ) //empty strng fix
      data = "\0";

    // put the results in a tuple
    dcl_tuple(res);
    a_newtuple( res, 6, FALSE );
    a_setstringelem( res,0, time, FALSE );
    a_setintelem( res,1, atol(bus), FALSE );
    a_setintelem( res,2, atol(id), FALSE );
    a_setintelem( res,3, atol(id_length), FALSE );
    a_setintelem( res,4, atol(data_length), FALSE );
    a_setstringelem( res,5, data, FALSE );
    
    // and return the tuple
    a_setseqelem( tpl,1, res, FALSE );
    a_emit(cxt,tpl,FALSE );
    
    ok = fgets( buffer, BUFSIZ, read_fp );
  }
  
  // this part will never be executed since the canrelay program never exists
  pclose( read_fp );
  return;
}