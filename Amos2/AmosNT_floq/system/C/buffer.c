/*****************************************************************************
 * AMOS2
 *
 * Author: (c) 2009 Lars Melander, UDBL
 * $RCSfile: buffer.c,v $
 * $Revision: 1.9 $ $Date: 2012/08/23 13:05:06 $
 * $State: Exp $ $Locker:  $
 *
 * Description: A simple, array-based FIFO buffer
 * ===========================================================================
 * $Log: buffer.c,v $
 * Revision 1.9  2012/08/23 13:05:06  larme597
 * Buffer takes optional timeout argument.
 *
 * Revision 1.8  2012/06/28 11:07:20  torer
 * Streamed buffer serialization
 *
 * Revision 1.7  2012/06/26 12:32:47  larme597
 * Improved read and print, receiving or sending an array.
 *
 * Revision 1.6  2012/06/19 16:14:12  larme597
 * Removed arraysize variable, using a_arraysize() instead.
 *
 * Revision 1.5  2012/06/04 14:36:19  larme597
 * More error checking. Print, read, clear functions.
 *
 * Revision 1.4  2009/11/27 09:53:04  larme597
 * Bug fix
 *
 * Revision 1.3  2009/09/02 19:37:07  torer
 * Remove debug call to a_print
 *
 * Revision 1.2  2009/09/02 12:48:33  torer
 * Removed memory leak
 *
 * Revision 1.1  2009/08/19 14:20:51  larme597
 * A simple, array-based FIFO buffer. To keep it light-weight, there is no
 * error checking; buffer over/underflow is not checked.
 *
 *
 ****************************************************************************/

#include "alisp.h"
#include <time.h>

int buffertype;

struct buffer
{
  objtags tags;
  oidtype array;
  int arraycount, arraypush, arraypop;
  clock_t timeout, started;
};

void free_buffer(oidtype b)
{
  a_free(dr(b, buffer)->array);
  dealloc_object(b);
}

oidtype make_bufferfn(bindtype env, oidtype buffersize, oidtype timeout)
{
  oidtype b;
  int size;
  double time;

  OfType(buffersize, INTEGERTYPE, env);
  if (timeout != nil)
    IntoDouble(timeout, time, env);
  size = getinteger(buffersize);
  b = new_object(sizeof (struct buffer), buffertype);
  a_let(dr(b, buffer)->array, new_array(size, nil));
  dr(b, buffer)->arraycount = dr(b, buffer)->arraypush = dr(b, buffer)->arraypop = 0;
  if (timeout != nil)
    {
      dr(b, buffer)->timeout = (clock_t) (time * CLOCKS_PER_SEC);
      dr(b, buffer)->started = clock();
    }
  else
    dr(b, buffer)->started = 0;
  return b;
}

oidtype buffer_clearfn(bindtype env, oidtype b)
{
  OfType(b, buffertype, env);
  dr(b, buffer)->arraycount = dr(b, buffer)->arraypush = dr(b, buffer)->arraypop = 0;
  return nil;
}

oidtype buffer_emptypfn(bindtype env, oidtype b)
{
  OfType(b, buffertype, env);
  if (dr(b, buffer)->arraycount == 0)
    return t;
  return nil;
}

oidtype buffer_onepfn(bindtype env, oidtype b)
{
  OfType(b, buffertype, env);
  if (dr(b, buffer)->arraycount < 2)
    return t;
  return nil;
}

oidtype buffer_fullpfn(bindtype env, oidtype b)
{
  struct buffer *db = dr(b, buffer);
  OfType(b, buffertype, env);

  if (db->started > 0 && db->started + db->timeout < clock() && db->arraycount)
    {
      db->started = clock();
      return t;
    }
  if (db->arraycount == a_arraysize(db->array))
    return t;
  return nil;
}

oidtype buffer_pushfn(bindtype env, oidtype b, oidtype o)
{
  OfType(b, buffertype, env);
  a_seta(dr(b, buffer)->array, dr(b, buffer)->arraypush, o);
  if (++dr(b, buffer)->arraypush == a_arraysize(dr(b, buffer)->array))
    dr(b, buffer)->arraypush = 0;
  ++dr(b, buffer)->arraycount;
  return o;
}

oidtype buffer_popfn(bindtype env, oidtype b)
{
  oidtype v;

  OfType(b, buffertype, env);
  v = a_elt(dr(b, buffer)->array, dr(b, buffer)->arraypop);
  if (++dr(b, buffer)->arraypop == a_arraysize(dr(b, buffer)->array))
    dr(b, buffer)->arraypop = 0;
  --dr(b, buffer)->arraycount;
  return v;
}

oidtype buffer_peekfn(bindtype env, oidtype b)
{
  OfType(b, buffertype, env);
  return a_elt(dr(b, buffer)->array, dr(b, buffer)->arraypop);
}

void print_buffer(oidtype b, oidtype stream, int princflg)
{
  int arraycount = dr(b, buffer)->arraycount;
  int arraysize = a_arraysize(dr(b, buffer)->array);
  int arraypop = dr(b, buffer)->arraypop;
  oidtype array = dr(b, buffer)->array;
  char ibuff[20];

  a_puts("#[buffer ", stream);
  sprintf(ibuff, "%d", arraycount);
  a_puts(ibuff, stream);
  a_puts("] ", stream);
  for (; arraycount > 0; --arraycount)
    {
      a_prin1(a_elt(array, arraypop), stream, princflg);
      if (++arraypop == arraysize)
	arraypop = 0;
      a_putc(' ', stream);
    }
}

oidtype read_buffer(bindtype env, oidtype tag, oidtype lst, oidtype stream)
{
  oidtype b;
  oidtype arr;
  int size, i;

  IntoInteger(hd(lst), size, env);
  b = new_object(sizeof (struct buffer), buffertype);
  arr = new_array(size, nil);
  a_let(dr(b, buffer)->array, arr);
  dr(b, buffer)->arraycount = size;
  dr(b, buffer)->arraypush = dr(b, buffer)->arraypop = 0;
  for (i = 0; i < size; ++i)
    {
      a_seta(arr, i, a_read(stream));
    }
  return b;
}

void register_buffer(void)
{
  buffertype = a_definetype("buffer", free_buffer, print_buffer);
  type_reader_function("BUFFER", read_buffer);
  extfunction2("make-buffer", make_bufferfn);
  extfunction1("buffer-clear", buffer_clearfn);
  extfunction1("buffer-emptyp", buffer_emptypfn);
  extfunction1("buffer-onep", buffer_onepfn);
  extfunction1("buffer-fullp", buffer_fullpfn);
  extfunction2("buffer-push", buffer_pushfn);
  extfunction1("buffer-pop", buffer_popfn);
  extfunction1("buffer-peek", buffer_peekfn);
}
