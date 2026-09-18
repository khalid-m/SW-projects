"""*************************************************************
* AMOS2
* 
* Author: (c) 2011 Robert Kajic, UDBL
* $RCSfile: callout.py,v $
* $Revision: 1.10 $ $Date: 2011/10/19 07:20:58 $
* $State: Exp $ $Locker:  $
* 
* Description: Python foreign functions used by callout 
*              regression tests.
* =============================================================
* $Log: callout.py,v $
* Revision 1.10  2011/10/19 07:20:58  torer
* numpy package not reguired for regression test
*
* Revision 1.9  2011/08/30 01:11:32  roka4241
* Sum with and without using a callback.
*
* Revision 1.8  2011/06/01 15:11:00  roka4241
* AmosObj objects containing any kind of oidtype are now hashable and comparable. Made NumPy optional by PYAMOS_NUMPY flag.
*
* Revision 1.7  2011/05/31 15:19:04  roka4241
* Fixed amos_map_func in callin. Record to dict conversion.
*
* Revision 1.6  2011/05/24 16:19:20  roka4241
* Fixed errors in MVC settings. Added support for skipping in an python mapper (return nothing). Also added support for premature breaking. Simplified some regression tests.
*
* Revision 1.5  2011/05/18 15:03:46  roka4241
* Fast nested loop join implemented using mapping over generators.
*
* Revision 1.4  2011/05/16 15:56:16  roka4241
* Implemented and tested nested loop join and mergejoin as python foreign functions. Started with a mapped nested loop join.
*
* Revision 1.3  2011/05/12 17:55:09  roka4241
* create two separate streams over the same bag
*
* Revision 1.2  2011/05/11 18:26:26  roka4241
* Opening of streams over amos functions, queries and generators (bags). Implicit and explicit iteration over bag streams from python (either by explicitly opening a stream over the bag and iterating over the stream, or by iterating over the bag directly).
*
* Revision 1.1  2011/05/05 16:44:19  roka4241
* moved the whole project down one directory
*
* Revision 1.14  2011/04/26 17:53:00  roka4241
* Merged PyAmosOid, PyAmosScan and PyAmosConn into a single python type PyAmosObj. Will simplify addition of amos generator wrapper.
*
* Revision 1.13  2011/04/20 17:16:26  roka4241
* Returning of scans from amos to python. Calling and mapping over amos functions from python.
*
* Revision 1.12  2011/04/07 17:48:21  roka4241
* Calling of python functions with amos scans and iterating over the scan transparently in python.
*
* Revision 1.11  2011/02/24 23:06:04  roka4241
* Embedding of NumPy. Foreign function definition and calling of python function that returns the NumPy ndarray datatype.
*
* Revision 1.10  2011/02/21 17:18:18  roka4241
* Initial testing of multidirectional foreign functions defined in python.
*
* Revision 1.9  2011/02/01 18:45:03  roka4241
* Added regression tests for much of the current callout functionality.
*
*
*************************************************************"""

import array, math
import amos2


#C:\Program Files (x86)\MiKTeX 2.9\miktex\bin;C:\Program Files\Common Files\Microsoft Shared\Windows Live;C:\Program Files (x86)\Common Files\Microsoft Shared\Windows Live;%SystemRoot%\system32;%SystemRoot%;%SystemRoot%\System32\Wbem;%SYSTEMROOT%\System32\WindowsPowerShell\v1.0\;C:\Program Files\Intel\DMIX;C:\Program Files (x86)\Windows Live\Shared;C:\Program Files (x86)\utils;C:\Program Files (x86)\emacs-23.2\bin;C:\AmosNT\bin;C:\Program Files (x86)\Java\jdk1.6.0_22\bin;C:\Program Files\TortoiseSVN\bin;C:\Program Files\Mimer SQL 10.0\;C:\Program Files (x86)\Mimer SQL 10.0 32-bit Client;C:\Program Files (x86)\PuTTY;C:\Program Files (x86)\Microsoft Visual Studio\VC98\Bin;C:\Program Files\Microsoft Windows Performance Toolkit\;C:\Program Files (x86)\QuickTime\QTSystem\;C:\wamp\bin\mysql\mysql5.0.45\bin;;C:\Program Files (x86)\NTP\bin

#C:\Program Files (x86)\Microsoft Visual Studio\Common\Tools\WinNT;C:\Program Files (x86)\Microsoft Visual Studio\Common\MSDev98\Bin;C:\Program Files (x86)\Microsoft Visual Studio\Common\Tools;C:\Program Files (x86)\Microsoft Visual Studio\VC98\bin;C:\Program Files\Mimer SQL 10.0\

def plus(a, b):
    return a+b;

def minus(a, b):
    return a-b;

def plus_bbf(a, b):
    return plus(a, b)

def plus_bfb(a, b):
    return minus(b, a)

def plus_fbb(a, b):
    return plus_bfb(a, b)

def iota(start, stop):
    return xrange(start, stop+1)

def iota_list(start, stop):
    return range(start, stop+1)

def iota_tuple(start, stop):
    return tuple(range(start, stop+1))

def iota_dict(start, stop):
    return dict(zip(range(start, stop+1), range(start, stop+1)))

def dict_get(d, key):
  return d.get(key, None)

def iota_array(start, stop):
    return array.array('i', range(start, stop+1))

def iota_pow(start, stop, exp):
    for i in xrange(start, stop+1):
        yield math.pow(i, exp)

def bounce(obj):
  return obj

def numpy_square(size): 
    return numpy.arange(size*size).reshape(size, size)

def yield_scan(scan):
    for item in scan:
        yield item


def mapf_iota(start, stop):
  l = []
  def mapper(tpl):
    l.append(tpl)
  amos2.amos_map_func(mapper, "NUMBER.NUMBER.IOTA->INTEGER", start, stop)
  return l

def callf_iota(start, stop):
  return amos2.amos_call_func("NUMBER.NUMBER.IOTA->INTEGER", start, stop)

  
def callf_plus(a, b):
  return amos2.amos_call_func("NUMBER.NUMBER.PLUS->NUMBER", a, b)

non_func = 1




def stream_func_iota(start, stop):
  stream = amos2.amos_stream_func("NUMBER.NUMBER.IOTA->INTEGER", start, stop)
  for item in stream:
    yield item

def stream_query_iota(start, stop):
  stream = amos2.amos_stream_query("iota(%i, %i);" % (start, stop))
  for item in stream:
    yield item

def stream_gen(bag):
  stream = amos2.amos_stream_gen(bag)
  for item in stream:
    yield item

def iterate_gen(bag):
  for item in bag:
    yield item

def stream_gen2(bag):
  stream = amos2.amos_stream_gen(bag)
  stream2 = amos2.amos_stream_gen(bag)
  for item in stream:
    yield item
  for item in stream2:
    yield item





def mergejoin(l, r, pos):
  s1 = amos2.amos_stream_gen(l)
  s2 = amos2.amos_stream_gen(r)
  x = s1.next()
  y = s2.next()
  while x and y:
    if cmp(x[pos], y[pos]) == -1:
      x = s1.next()
    elif cmp(x[pos], y[pos]) == 1:
      y = s2.next()
    else:
      yield x+y
      x = s1.next()
      y = s2.next()

def nestedloopjoin(l, r, pos):
  for x in l:
    for y in r:
      if x[pos]==y[pos]:
        yield x+y


def fastnestedloopjoin3(l, m, r, pos):
  def lmap(x):
    def mmap(z):
      def rmap(y):
        if x[pos]==z[pos]==y[pos]:
          return x+z+y

      amos2.amos_map_gen(rmap, r)
    amos2.amos_map_gen(mmap, m)
  amos2.amos_map_gen(lmap, l)


def map_gen_ret(b):
  l = []
  def mapper(tpl):
    l.append(tpl)
  amos2.amos_map_gen(mapper, b)
  return l

def map_gen_even(b):
  def mapper(tpl):
    if not tpl % 2:
      return tpl
  amos2.amos_map_gen(mapper, b)


def map_gen_firstn(b, n):
  l = [0]
  def mapper(item):
    if l[0] == n:
      raise StopIteration()
    l[0] += 1 
    return item
  amos2.amos_map_gen(mapper, b)


d = {}
def dict_get(key):
  return d[key]

def dict_put(key, value):
  d[key] = value
  return value

def oidtype_cmp(oid1, oid2):
  return cmp(oid1, oid2)

def mysum(b):
    return sum([i[0] for i in b])
    #return sum(map(lambda i: i[0], b))
    #return reduce(lambda s, i: s+i[0], b, 0)

def mysum_fast(b):
    s = [0]
    def mysum_cb(x):
        s[0] += x
    amos2.amos_map_gen(mysum_cb, b)
    return s[0]
