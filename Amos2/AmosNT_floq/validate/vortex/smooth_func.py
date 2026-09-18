import numpy as np
def amos_smooth(data, half_width):
    size = int(half_width)
    x = np.arange(-size,size+1)
    g = np.exp(-(x**2/float(size)))
    g = g / g.sum()
    return list(np.convolve(data, g, mode='same'))

def amos_loc_max(data):
    DEBUG_FLAG = False
    if DEBUG_FLAG:
        #print("amos_loc_max_smooth debug output")
        #print("Input data type is: %s" % type(data))
        if np.isscalar(data):
            print("Input is scalar")
        else:
            s = ""
            for d in data:
                s += str(type(d)) + ", "
            s = s[0:-2]
            #print("The type of all entering data are: %s" % s)
        #print(" < Data in: %s" % str(data))
        diff1 = np.diff(data)
        #print(" > diff 1: %s" % str(diff1))
        sign_res = np.sign(diff1)
        #print(" > sign  : %s" % str(sign_res))
        diff2 = np.diff(sign_res)
        #print(" > diff 2: %s" % str(diff2))
        test_res = diff2 < 0
        #print(" > test  : %s" % str(test_res))
        n_zero_res = test_res.nonzero()
        #print(" > nzero : %s" % str(n_zero_res))
        n_zero_res = n_zero_res[0]
        #print(" > nzero : %s" % str(n_zero_res))
        result = n_zero_res + 1
        #print(" > result: %s" % str(result))
        result = map(float, result)
        result = list(result)

        #print("Output data type is: %s" % type(result))
        if np.isscalar(result):
            print("Output is scalar")
        else:
            s = ""
            for d in result:
                s += str(type(d)) + ", "
            s = s[0:-2]
            #print("The type of all output data are: %s" % s)
        return result
    else:
        return list(map(float,(np.diff(np.sign(np.diff(data))) < 0).nonzero()[0] + 1))

def amos_loc_max_smooth(data, half_width):
    return amos_loc_max(amos_smooth(data, half_width))
