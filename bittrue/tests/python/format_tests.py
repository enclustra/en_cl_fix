###################################################################################################
# Copyright (c) 2022 Enclustra GmbH, Switzerland (info@enclustra.com)
###################################################################################################

###################################################################################################
# Description:
#
# This script checks the FixFormat.For* functions to ensure they all provide optimal (sufficient
# and necessary) formats.
###################################################################################################

###################################################################################################
# Imports
###################################################################################################
import sys
import os
from os.path import join, dirname
root = dirname(__file__)
sys.path.append(join(root, "../../models/python"))
from en_cl_fix_pkg import *

import numpy as np

###################################################################################################
# Config
###################################################################################################

# a_fmt test points
aS_values = [0,1]
aI_values = np.arange(-6,1+6)
aF_values = np.arange(-6,1+6)

# b_fmt test points
bS_values = [0,1]
bI_values = np.arange(-6,1+6)
bF_values = np.arange(-6,1+6)

# shift test points
min_shift_values = np.arange(-4,1+4)
shift_range_values = np.arange(5)

###################################################################################################
# Run
###################################################################################################

test_a_fmt = []
test_b_fmt = []
test_r_fmt = []
test_rnd = []
test_sat = []

#########
# a_fmt #
#########
for aS in aS_values:
    for aI in aI_values:
        for aF in aF_values:
            # Skip unusable formats
            if aS+aI+aF < 1:
                continue
            
            a_fmt = FixFormat(aS, aI, aF)
            
            amin = cl_fix_min_value(a_fmt)
            amax = cl_fix_max_value(a_fmt)
            
            #########
            # b_fmt #
            #########
            for bS in bS_values:
                for bI in bI_values:
                    for bF in bF_values:
                        # Skip unusable formats
                        if bS+bI+bF < 1:
                            continue
                        
                        b_fmt = FixFormat(bS, bI, bF)
                        
                        bmin = cl_fix_min_value(b_fmt)
                        bmax = cl_fix_max_value(b_fmt)
                        
                        ##############
                        # cl_fix_add #
                        ##############
                        
                        # Calculate the extreme results
                        rmax = amax + bmax
                        rmin = amin + bmin
                        # Sanity checks
                        assert rmax == np.amax([amin + bmin, amin + bmax, amax + bmin, amax + bmax])
                        assert rmin == np.amin([amin + bmin, amin + bmax, amax + bmin, amax + bmax])
                        
                        # Format to test
                        r_fmt = FixFormat.for_add(a_fmt, b_fmt)
                        
                        # Check int bits are sufficient
                        assert rmax <= cl_fix_max_value(r_fmt), "add: Max value exceeded" \
                            + f" a_fmt: {a_fmt}, b_fmt: {b_fmt}, r_fmt: {r_fmt}, rmax: {rmax}, rmin: {rmin}"
                        assert rmin >= cl_fix_min_value(r_fmt), "add: Min value exceeded" \
                            + f" a_fmt: {a_fmt}, b_fmt: {b_fmt}, r_fmt: {r_fmt}, rmax: {rmax}, rmin: {rmin}"
                        
                        # Check int bits are necessary
                        smallerFmt = FixFormat(r_fmt.S, r_fmt.I - 1, r_fmt.F)
                        assert rmax > cl_fix_max_value(smallerFmt) or rmin < cl_fix_min_value(smallerFmt), "add: Format is excessively wide." \
                            + f" a_fmt: {a_fmt}, b_fmt: {b_fmt}, r_fmt: {r_fmt}, rmax: {rmax}, rmin: {rmin}"
                        
                        # The optimal number of frac bits is trivial: max(a_fmt.F, b_fmt.F)
                        assert r_fmt.F == max(a_fmt.F, b_fmt.F), "add: Unexpected number of frac bits"
                        
                        ##############
                        # cl_fix_sub #
                        ##############
                        
                        # Calculate the extreme results
                        rmax = amax - bmin
                        rmin = amin - bmax
                        # Sanity checks
                        assert rmax == np.amax([amin - bmin, amin - bmax, amax - bmin, amax - bmax])
                        assert rmin == np.amin([amin - bmin, amin - bmax, amax - bmin, amax - bmax])
                        
                        # Format to test
                        r_fmt = FixFormat.for_sub(a_fmt, b_fmt)
                        
                        # Check int bits are sufficient
                        assert rmax <= cl_fix_max_value(r_fmt), "sub: Max value exceeded" \
                            + f" a_fmt: {a_fmt}, b_fmt: {b_fmt}, r_fmt: {r_fmt}, rmax: {rmax}, rmin: {rmin}"
                        assert rmin >= cl_fix_min_value(r_fmt), "sub: Min value exceeded" \
                            + f" a_fmt: {a_fmt}, b_fmt: {b_fmt}, r_fmt: {r_fmt}, rmax: {rmax}, rmin: {rmin}"
                        
                        # Check int bits are necessary
                        smallerFmt = FixFormat(r_fmt.S, r_fmt.I - 1, r_fmt.F)
                        assert rmax > cl_fix_max_value(smallerFmt) or rmin < cl_fix_min_value(smallerFmt), "sub: Format is excessively wide." \
                            + f" a_fmt: {a_fmt}, b_fmt: {b_fmt}, r_fmt: {r_fmt}, rmax: {rmax}, rmin: {rmin}"
                        
                        # The optimal number of frac bits is trivial: max(a_fmt.F, b_fmt.F)
                        assert r_fmt.F == max(a_fmt.F, b_fmt.F), "sub: Unexpected number of frac bits"
                        
                        #################
                        # cl_fix_addsub #
                        #################
                        
                        # Calculate the extreme results
                        rmax = max(amax + bmax, amax - bmin)
                        rmin = min(amin + bmin, amin - bmax)
                        # Sanity checks
                        assert rmax == np.amax([amin + bmin, amin + bmax, amax + bmin, amax + bmax, amin - bmin, amin - bmax, amax - bmin, amax - bmax])
                        assert rmin == np.amin([amin + bmin, amin + bmax, amax + bmin, amax + bmax, amin - bmin, amin - bmax, amax - bmin, amax - bmax])
                        
                        # Format to test
                        r_fmt = FixFormat.for_addsub(a_fmt, b_fmt)
                        
                        # Check int bits are sufficient
                        assert rmax <= cl_fix_max_value(r_fmt), "addsub: Max value exceeded" \
                            + f" a_fmt: {a_fmt}, b_fmt: {b_fmt}, r_fmt: {r_fmt}, rmax: {rmax}, rmin: {rmin}"
                        assert rmin >= cl_fix_min_value(r_fmt), "addsub: Min value exceeded" \
                            + f" a_fmt: {a_fmt}, b_fmt: {b_fmt}, r_fmt: {r_fmt}, rmax: {rmax}, rmin: {rmin}"
                        
                        # Check int bits are necessary
                        smallerFmt = FixFormat(r_fmt.S, r_fmt.I - 1, r_fmt.F)
                        assert rmax > cl_fix_max_value(smallerFmt) or rmin < cl_fix_min_value(smallerFmt), "addsub: Format is excessively wide." \
                            + f" a_fmt: {a_fmt}, b_fmt: {b_fmt}, r_fmt: {r_fmt}, rmax: {rmax}, rmin: {rmin}"
                        
                        # The optimal number of frac bits is trivial: max(a_fmt.F, b_fmt.F)
                        assert r_fmt.F == max(a_fmt.F, b_fmt.F), "addsub: Unexpected number of frac bits"
                        
                        ###############
                        # cl_fix_mult #
                        ###############
                        
                        # Calculate the max result
                        if a_fmt.S == 1 and b_fmt.S == 1:
                            rmax = amin * bmin  # -max*-max = +max
                        else:
                            rmax = amax * bmax
                        # Sanity check
                        assert rmax == np.amax([amin * bmin, amin * bmax, amax * bmin, amax * bmax])
                        
                        # Calculate the min result
                        if a_fmt.S == 0 and b_fmt.S == 0:
                            rmin = amin * bmin
                        elif a_fmt.S == 0 and b_fmt.S == 1:
                            rmin = amax * bmin
                        elif a_fmt.S == 1 and b_fmt.S == 0:
                            rmin = amin * bmax
                        elif a_fmt.S == 1 and b_fmt.S == 1:
                            rmin = min(amax * bmin, amin * bmax)
                        # Sanity check
                        assert rmin == np.amin([amin * bmin, amin * bmax, amax * bmin, amax * bmax])
                        
                        # Format to test
                        r_fmt = FixFormat.for_mult(a_fmt, b_fmt)
                        
                        # Check int bits are sufficient
                        assert rmax <= cl_fix_max_value(r_fmt), "mult: Max value exceeded" \
                            + f" a_fmt: {a_fmt}, b_fmt: {b_fmt}, r_fmt: {r_fmt}, rmax: {rmax}, rmin: {rmin}"
                        assert rmin >= cl_fix_min_value(r_fmt), "mult: Min value exceeded" \
                            + f" a_fmt: {a_fmt}, b_fmt: {b_fmt}, r_fmt: {r_fmt}, rmax: {rmax}, rmin: {rmin}"
                        
                        # Check int bits are necessary
                        if r_fmt.I + r_fmt.F > 0:
                            smallerFmt = FixFormat(r_fmt.S, r_fmt.I - 1, r_fmt.F)
                            assert rmax > cl_fix_max_value(smallerFmt) or rmin < cl_fix_min_value(smallerFmt), "mult: Format is excessively wide." \
                                + f" a_fmt: {a_fmt}, b_fmt: {b_fmt}, r_fmt: {r_fmt}, rmax: {rmax}, rmin: {rmin}"
                        
                        # The optimal number of frac bits is straightforward: a_fmt.F + b_fmt.F. For example,
                        # if we take +/- 1 LSB in each representation: (+/- 2**-a_fmt.F) * (+/- 2**-b_fmt.F)
                        # = +/- 2**-(a_fmt.F + b_fmt.F). No other inputs could need more frac bits.
                        assert r_fmt.F == a_fmt.F + b_fmt.F, "mult: Unexpected number of frac bits"
                    
            ##############
            # cl_fix_neg #
            ##############
            
            # Calculate the extreme results
            rmax = -amin
            rmin = -amax
            # Sanity checks
            assert rmax == np.amax([-amax, -amin])
            assert rmin == np.amin([-amax, -amin])
            
            # Format to test
            r_fmt = FixFormat.for_neg(a_fmt)
            
            # Check int bits are sufficient
            assert rmax <= cl_fix_max_value(r_fmt), "neg: Max value exceeded" \
                + f" a_fmt: {a_fmt}, r_fmt: {r_fmt}, rmax: {rmax}, rmin: {rmin}"
            assert rmin >= cl_fix_min_value(r_fmt), "neg: Min value exceeded" \
                + f" a_fmt: {a_fmt}, r_fmt: {r_fmt}, rmax: {rmax}, rmin: {rmin}"
            
            # Check int bits are necessary
            if r_fmt.I + r_fmt.F > 0:
                smallerFmt = FixFormat(r_fmt.S, r_fmt.I - 1, r_fmt.F)
                assert rmax > cl_fix_max_value(smallerFmt) or rmin < cl_fix_min_value(smallerFmt), "neg: Format is excessively wide." \
                    + f" a_fmt: {a_fmt}, r_fmt: {r_fmt}, rmax: {rmax}, rmin: {rmin}"
            
            # The optimal number of frac bits is trivial: a_fmt.F
            assert r_fmt.F == a_fmt.F, "neg: Unexpected number of frac bits"
            
            ##############
            # cl_fix_abs #
            ##############
            
            # Calculate the extreme results
            rmax = max(amax, -amin)
            rmin = min(amin, -amax)
            # Sanity checks
            assert rmax == np.amax([amax, amin, -amax, -amin])
            assert rmin == np.amin([amax, amin, -amax, -amin])
            
            # Format to test
            r_fmt = FixFormat.for_abs(a_fmt)
            
            # Check int bits are sufficient
            assert rmax <= cl_fix_max_value(r_fmt), "abs: Max value exceeded" \
                + f" a_fmt: {a_fmt}, r_fmt: {r_fmt}, rmax: {rmax}, rmin: {rmin}"
            assert rmin >= cl_fix_min_value(r_fmt), "abs: Min value exceeded" \
                + f" a_fmt: {a_fmt}, r_fmt: {r_fmt}, rmax: {rmax}, rmin: {rmin}"
            
            # Check int bits are necessary
            smallerFmt = FixFormat(r_fmt.S, r_fmt.I - 1, r_fmt.F)
            assert rmax > cl_fix_max_value(smallerFmt) or rmin < cl_fix_min_value(smallerFmt), "abs: Format is excessively wide." \
                + f" a_fmt: {a_fmt}, r_fmt: {r_fmt}, rmax: {rmax}, rmin: {rmin}"
            
            # The optimal number of frac bits is trivial: a_fmt.F
            assert r_fmt.F == a_fmt.F, "abs: Unexpected number of frac bits"
            
            ################
            # cl_fix_shift #
            ################
            for min_shift in min_shift_values:
                for shift_range in shift_range_values:
                    max_shift = min_shift + shift_range
                    
                    # Calculate the extreme results
                    rmax = amax * 2.0**max_shift
                    if amin < 0:
                        rmin = amin * 2.0**max_shift
                    else:
                        rmin = amin * 2.0**min_shift
                    # Sanity checks
                    assert rmax == np.amax([amax * 2.0**max_shift, amax * 2.0**min_shift, amin * 2.0**max_shift, amin * 2.0**min_shift])
                    assert rmin == np.amin([amax * 2.0**max_shift, amax * 2.0**min_shift, amin * 2.0**max_shift, amin * 2.0**min_shift])
                    
                    # Format to test
                    r_fmt = FixFormat.for_shift(a_fmt, min_shift, max_shift)
                    
                    # Check int bits are sufficient
                    assert rmax <= cl_fix_max_value(r_fmt), "shift: Max value exceeded" \
                        + f" a_fmt: {a_fmt}, r_fmt: {r_fmt}, rmax: {rmax}, rmin: {rmin}"
                    assert rmin >= cl_fix_min_value(r_fmt), "shift: Min value exceeded" \
                        + f" a_fmt: {a_fmt}, r_fmt: {r_fmt}, rmax: {rmax}, rmin: {rmin}"
                    
                    # Check int bits are necessary
                    if r_fmt.I + r_fmt.F > 0:
                        smallerFmt = FixFormat(r_fmt.S, r_fmt.I - 1, r_fmt.F)
                        assert rmax > cl_fix_max_value(smallerFmt) or rmin < cl_fix_min_value(smallerFmt), "shift: Format is excessively wide." \
                            + f" a_fmt: {a_fmt}, r_fmt: {r_fmt}, rmax: {rmax}, rmin: {rmin}, min_shift: {min_shift}, max_shift: {max_shift}"
                    
                    # The optimal number of frac bits is trivial: a_fmt.F - min_shift
                    assert r_fmt.F == a_fmt.F - min_shift, "shift: Unexpected number of frac bits"
                    