### ============================================================
### AMOS2
### 
### Author: 2012 Tore Risch, UDBL
###
### Description: Foreign function definitions in Python (alpha)
### =============================================================

import array, math
import amos2

#Simple foreign function:
def plus(a, b):
    return a+b;

#Foreign table function returning a bag of integers:
def iota(start, stop):
    return xrange(int(start), int(stop+1))

#Foreign aggregate function implemented over bag:
def mysum(b):
    return sum([i[0] for i in b])

#Print on console from Python
def myprint(x):
    print x
    return 0;


     
