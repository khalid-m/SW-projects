"""*************************************************************
* AMOS2
* 
* Author: (c) 2011 Robert Kajic, UDBL
* $RCSfile: callout.py,v $
* $Revision: 1.15 $ $Date: 2011/05/05 16:27:56 $
* $State: Exp $ $Locker:  $
* 
* Description: Python foreign functions used by callout 
*              regression tests.
* =============================================================
* $Log: callout.py,v $
* Revision 1.15  2011/05/05 16:27:56  roka4241
* removed old python callin from cvs, to make place for new callin/callout
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

import array, math, numpy
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
  amos2.amos_mapf(mapper, "NUMBER.NUMBER.IOTA->INTEGER", start, stop)
  return l

def callf_iota(start, stop):
  return amos2.amos_callf("NUMBER.NUMBER.IOTA->INTEGER", start, stop)

  
def callf_plus(a, b):
  return amos2.amos_callf("NUMBER.NUMBER.PLUS->NUMBER", a, b)

non_func = 1