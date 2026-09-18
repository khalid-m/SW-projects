### ============================================================
### AMOS2
### 
### Author: 2012 Robert Kajic, UDBL
###
### Description: Join algorithms implemented in Python
### =============================================================
### $Log: join.py,v $
### Revision 1.1  2012/02/15 10:17:06  torer
### Join algorithms in Python
###
### =============================================================

import array, math
import amos2

def nestedloopjoin(l, r, pos):
  for x in l:
    for y in r:
      if x[pos]==y[pos]:
        yield x+y

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
