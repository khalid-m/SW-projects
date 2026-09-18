/****************************************************************************
 * AMOS2
 *
 * Author: (c) 2006 Tore Risch, UDBL
 * $RCSfile: binary.c,v $
 * $Revision: 1.15 $ $Date: 2013/03/14 15:01:19 $
 * $State: Exp $ $Locker:  $
 *
 * Description: Management of binary data
 *
 * ==========================================================================
 * $Log: binary.c,v $
 * Revision 1.15  2013/03/14 15:01:19  torer
 * 32/64 bits neutral code
 *
 * Revision 1.14  2011/12/29 20:12:48  torer
 * Wrong result type
 *
 * Revision 1.13  2011/05/04 18:44:18  torer
 * Use declaration size_t for byte array sizes
 *
 * Revision 1.12  2010/12/17 13:30:42  zeitler
 * fixed skip trailing whitespace
 *
 * Revision 1.11  2009/09/20 22:11:46  zeitler
 * Binary allocation bug in bulkread
 *
 * Revision 1.10  2009/02/23 16:33:48  torer
 * Readable display on standard output stream
 *
 * Revision 1.9  2007/02/02 19:50:21  torer
 * Compact representation of kind of type BINARY
 *
 * Revision 1.8  2007/02/02 19:24:42  torer
 * Type BINARY changed so that
 * 1: Print header contains total number of bytes in object
 * 2: The user specified size in bytes preserved exactly (no longerword adjusted)
 *
 * Revision 1.7  2007/02/02 07:36:53  torer
 * Reverted to old code
 *
 * Revision 1.5  2007/02/01 16:08:21  torer
 * new_binary moved here
 *
 * Revision 1.4  2007/01/29 22:41:20  zeitler
 * Added access functions
 *
 * Revision 1.3  2006/06/05 12:39:56  torer
 * Using include for type BINARY
 *
 * Revision 1.2  2006/02/08 15:29:00  zeitler
 * - binary: annoying printouts eliminated
 * - lispfns: generator return types are on the move...
 *
 * Revision 1.1  2006/02/04 11:32:43  torer
 * Separated binary data management extensions into new file
 *    system/C/binary.c
 *
 ***************************************************************************/

#include "amos.h"
#include "binary.h"

/***************************************************************************/
/*              Management of binary data blocks                           */
/***************************************************************************/

EXPORT oidtype new_binary(size_t size, int init)
     /* size is required size in bytes of cont area. 
        init is contents of each word */
{
  struct binarycell *dres;
  oidtype res;
  /* Total object size adjusted for word limits: */
  int bytes = size+sizeof(*dres)-sizeof(dres->cont);
  int i;
  int words = size/WORD_SIZE;

  res = new_aligned_object(bytes,BINARYTYPE);
  dres = dr(res,binarycell);
  dres->binkind = 0;
  for(i=0;i<words;i++)
    {
      dres->cont[i]=init;
    }
  return res;
}

void print_binary(oidtype x,oidtype stream,int princflg)
     /*** Bulk write binary array to streams ***/
{
  struct binarycell *dx = dr(x,binarycell);
  unsigned int size = dx->bytes;        
  /* Content bytes */
  char *buff=(char *)dx;
  if(stream==stdoutstream || stream==stderrstream)
    {
      unsigned int i, words;

      words = size/WORD_SIZE;
      if(size%WORD_SIZE) words++;
      a_puts("#[BINVECTOR ",stream);
      a_puts(IntegerToString(words),stream);
      a_puts("] ",stream);
      for(i=0; i<words;i++)
	{
	  a_puts(IntegerToString(dx->cont[i]), stream);
	  a_putc(' ', stream);
	}
      return;
    }
  a_puts("#[BINARY ",stream);
  a_puts(IntegerToString(size),stream);
  a_puts("] ",stream);
  a_writebytes(stream,(void *)buff,size);
  a_putc(' ',stream); /* delimiter */
  return;
}

extern int read_word(oidtype str);
oidtype read_binary(bindtype env, oidtype tag, oidtype x, oidtype stream)
     /*** Bulk read binary array from streams ***/
{
  int bytes;
  oidtype res;
  oidtype size = hd(x);
  struct binarycell *dres;
  char *buff;
  objtags tags;

  IntoInteger(size, bytes, env); /* Total size in bytes */

  res = new_aligned_object(bytes,BINARYTYPE);
  dres = dr(res,binarycell);
  tags = dres->tags;
  buff = (char *)dres;
  a_getc(stream); /* Skip space after ] */
  a_readbytes(stream, buff, bytes);
  a_getc(stream);
  dres->tags = tags; /* restore initialized tags */
  return res;
}

EXPORT oidtype binary_sizefn(bindtype env, oidtype b)
     /*** External Lisp function to get the size of a binary array ***/
{
  struct binarycell *db;

  OfType(b,BINARYTYPE,env);
  db = dr(b,binarycell);
  return mkinteger(binary_size(db));
}

/***************************************************************************/
/*                Access functions for type BINARY                         */
/***************************************************************************/

EXPORT oidtype get_float(bindtype env, oidtype b, int ind)
     /*** Get a single precision float from binary array ***/
{
  int  q;
  float res;
  struct binarycell *db;
  unsigned int size;

  OfType(b,BINARYTYPE,env);
  db = dr(b,binarycell);
  size = binary_size(db);
  q = ind*sizeof(res);
  if(ind<0 || (q+sizeof(res))>size) return lerror(ARRAY_BOUNDS,
                                                  mkinteger(ind),env);
  memcpy(&res,(char *)(db->cont)+q,sizeof(res));
  return mkreal(res);
}

oidtype get_floatfn(bindtype env, oidtype b, oidtype i)
     /*** External Lisp function to 
          get single precision float from binary array ***/
{
  int ind;
  IntoInteger(i,ind,env);
  return get_float(env,b,ind);
}

EXPORT oidtype put_float(bindtype env, oidtype b, int ind, oidtype v)
     /*** Put a single precision float into binary array ***/
{
  int q;
  float val;
  struct binarycell *db;
  unsigned int size;

  val = (float)coerce_real(env, v);
  OfType(b,BINARYTYPE,env);
  db = dr(b,binarycell);
  size = binary_size(db);
  q = ind*sizeof(val);
  if(ind<0 || (q+sizeof(val))>size) return lerror(ARRAY_BOUNDS,
                                                  mkinteger(ind),env);
  memcpy((char *)(db->cont)+q,&val,sizeof(val));
  return v;
}

oidtype put_floatfn(bindtype env, oidtype b, oidtype i, oidtype v)
     /*** External Lisp function to
          put a single precision float into binary array ***/
{
  int ind;
  IntoInteger(i,ind,env);
  return put_float(env, b, ind, v);
}

EXPORT oidtype get_value(bindtype env, oidtype b, void* res, int elemsize, 
                         int ind)
     /*** Get a res from binary array of res ***/
{
  int  q;
  struct binarycell *db;
  unsigned int size;

  OfType(b,BINARYTYPE,env);
  db = dr(b,binarycell);
  size = binary_size(db);
  q = ind*elemsize;
  if(ind<0 || (q+sizeof(res))>size) return lerror(ARRAY_BOUNDS,
                                                  mkinteger(ind),env);
  memcpy(res,(char *)(db->cont)+q,elemsize);
  return nil;
}

EXPORT oidtype put_value(bindtype env, oidtype b, void* val, int elemsize, 
                         int ind)
     /*** Put a single precision float into binary array ***/
{
  unsigned int q;
  struct binarycell *db;
  unsigned int size;

  OfType(b,BINARYTYPE,env);
  db = dr(b,binarycell);
  size = binary_size(db);
  q = ind*elemsize;
  if(ind<0 || (q+elemsize)>size) return lerror(ARRAY_BOUNDS,
                                                  mkinteger(ind),env);
  memcpy((char *)(db->cont)+q,val,elemsize);
  return nil;
}

/***************************************************************************/
/*                linearize objects in the image buffer                    */
/***************************************************************************/

oidtype _image_buffer_ = NULLH;
int imgbuflen = 0;

oidtype a_get_image_buffer_textstream(int reqlen)
     /*** Get the image buffer textstream holding at least reqlen bytes ***/
{
  /* textstream holding the variable _IMAGE-BUFFER_: */
  oidtype ib;

  if(_image_buffer_ == NULLH) /* First call */ 
    _image_buffer_ = mksymbol("_image-buffer_");
  ib = globval(_image_buffer_); /* value will be text stream */
  if(a_datatype(ib)!=TEXTSTREAMTYPE || dr(ib,textstreamcell)->size < reqlen)
    { /* No _IMAGE-BUFFER_ set in image or image buffer too small
	 => allocate new image buffer */
      ib = new_textstream(reqlen);
      imgbuflen = reqlen;
      a_setf(globval(_image_buffer_),ib);
    }
  return ib;
}

EXPORT void *a_get_image_buffer(int len)
     /*** Get freshend image buffer with size at least reqlen bytes ***/
{
  struct textstreamcell *txt;

  if (_image_buffer_ == NULLH || len > imgbuflen) {
    a_get_image_buffer_textstream(len);
  }

  txt = dr(globval(_image_buffer_),textstreamcell);
  txt->pos = 0;
  txt->end = len;
  return dr(txt->buffer,binarycell)->cont;
}

EXPORT oidtype a_read_from_image_buffer(void) 
{
  /*** Read one form from the image buffer ***/
  oidtype tstream = (_image_buffer_==NULLH ? a_get_image_buffer_textstream(0) 
                     : globval(_image_buffer_));
  dr(tstream,textstreamcell)->pos = 0;
  return readfn(varstack,tstream);
  /* Example:
     {
     void* rbuf;
     unsigned int buflen;
     oidtype form2 = nil;
     char *str = "((1)(1.1)(a))";

     buflen = strlen(str)+1;
     rbuf = a_get_image_buffer(buflen);

     printf("string is %s\n",str);
     printf("buflen %d\n",buflen);

     memcpy(rbuf,str,buflen);
  
     printf("new string is %s\n",rbuf);
     form2 = a_read_from_image_buffer();
     a_print(form2);
     }
  */
}

EXPORT void a_print_to_buffer(oidtype obj, void **buffer, unsigned int *length)
     /*** Linearize Amos II object to C buffer inside image.
          Return pointer to the buffer and its length ***/
{
  oidtype txtstream = a_get_image_buffer_textstream(1024);

  dr(txtstream,textstreamcell)->pos = 0; /* Reset buffer print position */
  prin1fn(varstack,obj,txtstream);
  *buffer = textstreambuffer(txtstream);
  *length = dr(txtstream,textstreamcell)->pos;
  /* Example:
     {
     void *buffer;
     unsigned int buflen;
     oidtype form = nil, form2 = nil;

     a_setf(form,a_read_from_string("((1)(1.1)(a))"));
     a_print_to_buffer(form, &buffer, &buflen);
     a_setf(form2,a_read_from_buffer(buffer,buflen));
     a_print(form2);
     a_free(form);
     a_free(form2);
     }
  */
}

/***************************************************************************/
/*              Bulk text stream management                                */
/***************************************************************************/

size_t text_readbytes(oidtype tstream, void *outbuff, size_t len)
     /*** Read len bytes from textream tstream to outbuff ***/
{
  struct textstreamcell *s=dr(tstream,textstreamcell);
  char *inbuff = (char *)textstreambuffer(tstream);
  int len1 = len;

  if(s->pos + len1 > s->size) 
    /* not enough bytes remain in text stream */
    return EOF; 
  memcpy(outbuff,inbuff+s->pos,len1);
  s->pos = s->pos + len1;
  return TRUE;
}

void register_binary(void)
{
  extfunction2("get-float",get_floatfn);
  extfunction3("put-float",put_floatfn);
  extfunction1("binary-size",binary_sizefn);
  typefns[BINARYTYPE].printfn = print_binary;
  type_reader_function("BINARY", read_binary);
 
  stream_implementations[TEXTSTREAMTYPE].readbytes = text_readbytes;
}
