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

# aFmt test points
aS_values = [0,1]
aI_values = np.arange(-6,1+6)
aF_values = np.arange(-6,1+6)

# bFmt test points
bS_values = [0,1]
bI_values = np.arange(-6,1+6)
bF_values = np.arange(-6,1+6)

# shift test points
min_shift_values = np.arange(-4,1+4)
shift_range_values = np.arange(5)

###################################################################################################
# Run
###################################################################################################

test_aFmt = []
test_bFmt = []
test_rFmt = []
test_rnd = []
test_sat = []

########
# aFmt #
########
for aS in aS_values:
    for aI in aI_values:
        for aF in aF_values:
            # Skip unusable formats
            if aS+aI+aF < 1:
                continue
            
            aFmt = FixFormat(aS, aI, aF)
            
            amin = cl_fix_min_value(aFmt)
            amax = cl_fix_max_value(aFmt)
            
            ########
            # bFmt #
            ########
            for bS in bS_values:
                for bI in bI_values:
                    for bF in bF_values:
                        # Skip unusable formats
                        if bS+bI+bF < 1:
                            continue
                        
                        bFmt = FixFormat(bS, bI, bF)
                        
                        bmin = cl_fix_min_value(bFmt)
                        bmax = cl_fix_max_value(bFmt)
                        
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
                        rFmt = FixFormat.ForAdd(aFmt, bFmt)
                        
                        # Check int bits are sufficient
                        assert rmax <= cl_fix_max_value(rFmt), "add: Max value exceeded" \
                            + f" aFmt: {aFmt}, bFmt: {bFmt}, rFmt: {rFmt}, rmax: {rmax}, rmin: {rmin}"
                        assert rmin >= cl_fix_min_value(rFmt), "add: Min value exceeded" \
                            + f" aFmt: {aFmt}, bFmt: {bFmt}, rFmt: {rFmt}, rmax: {rmax}, rmin: {rmin}"
                        
                        # Check int bits are necessary
                        smallerFmt = FixFormat(rFmt.S, rFmt.I - 1, rFmt.F)
                        assert rmax > cl_fix_max_value(smallerFmt) or rmin < cl_fix_min_value(smallerFmt), "add: Format is excessively wide." \
                            + f" aFmt: {aFmt}, bFmt: {bFmt}, rFmt: {rFmt}, rmax: {rmax}, rmin: {rmin}"
                        
                        # The optimal number of frac bits is trivial: max(aFmt.F, bFmt.F)
                        assert rFmt.F == max(aFmt.F, bFmt.F), "add: Unexpected number of frac bits"
                        
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
                        rFmt = FixFormat.ForSub(aFmt, bFmt)
                        
                        # Check int bits are sufficient
                        assert rmax <= cl_fix_max_value(rFmt), "sub: Max value exceeded" \
                            + f" aFmt: {aFmt}, bFmt: {bFmt}, rFmt: {rFmt}, rmax: {rmax}, rmin: {rmin}"
                        assert rmin >= cl_fix_min_value(rFmt), "sub: Min value exceeded" \
                            + f" aFmt: {aFmt}, bFmt: {bFmt}, rFmt: {rFmt}, rmax: {rmax}, rmin: {rmin}"
                        
                        # Check int bits are necessary
                        smallerFmt = FixFormat(rFmt.S, rFmt.I - 1, rFmt.F)
                        assert rmax > cl_fix_max_value(smallerFmt) or rmin < cl_fix_min_value(smallerFmt), "sub: Format is excessively wide." \
                            + f" aFmt: {aFmt}, bFmt: {bFmt}, rFmt: {rFmt}, rmax: {rmax}, rmin: {rmin}"
                        
                        # The optimal number of frac bits is trivial: max(aFmt.F, bFmt.F)
                        assert rFmt.F == max(aFmt.F, bFmt.F), "sub: Unexpected number of frac bits"
                        
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
                        rFmt = FixFormat.ForAddsub(aFmt, bFmt)
                        
                        # Check int bits are sufficient
                        assert rmax <= cl_fix_max_value(rFmt), "addsub: Max value exceeded" \
                            + f" aFmt: {aFmt}, bFmt: {bFmt}, rFmt: {rFmt}, rmax: {rmax}, rmin: {rmin}"
                        assert rmin >= cl_fix_min_value(rFmt), "addsub: Min value exceeded" \
                            + f" aFmt: {aFmt}, bFmt: {bFmt}, rFmt: {rFmt}, rmax: {rmax}, rmin: {rmin}"
                        
                        # Check int bits are necessary
                        smallerFmt = FixFormat(rFmt.S, rFmt.I - 1, rFmt.F)
                        assert rmax > cl_fix_max_value(smallerFmt) or rmin < cl_fix_min_value(smallerFmt), "addsub: Format is excessively wide." \
                            + f" aFmt: {aFmt}, bFmt: {bFmt}, rFmt: {rFmt}, rmax: {rmax}, rmin: {rmin}"
                        
                        # The optimal number of frac bits is trivial: max(aFmt.F, bFmt.F)
                        assert rFmt.F == max(aFmt.F, bFmt.F), "addsub: Unexpected number of frac bits"
                        
                        ###############
                        # cl_fix_mult #
                        ###############
                        
                        # Calculate the max result
                        if aFmt.S == 1 and bFmt.S == 1:
                            rmax = amin * bmin  # -max*-max = +max
                        else:
                            rmax = amax * bmax
                        # Sanity check
                        assert rmax == np.amax([amin * bmin, amin * bmax, amax * bmin, amax * bmax])
                        
                        # Calculate the min result
                        if aFmt.S == 0 and bFmt.S == 0:
                            rmin = amin * bmin
                        elif aFmt.S == 0 and bFmt.S == 1:
                            rmin = amax * bmin
                        elif aFmt.S == 1 and bFmt.S == 0:
                            rmin = amin * bmax
                        elif aFmt.S == 1 and bFmt.S == 1:
                            rmin = min(amax * bmin, amin * bmax)
                        # Sanity check
                        assert rmin == np.amin([amin * bmin, amin * bmax, amax * bmin, amax * bmax])
                        
                        # Format to test
                        rFmt = FixFormat.ForMult(aFmt, bFmt)
                        
                        # Check int bits are sufficient
                        assert rmax <= cl_fix_max_value(rFmt), "mult: Max value exceeded" \
                            + f" aFmt: {aFmt}, bFmt: {bFmt}, rFmt: {rFmt}, rmax: {rmax}, rmin: {rmin}"
                        assert rmin >= cl_fix_min_value(rFmt), "mult: Min value exceeded" \
                            + f" aFmt: {aFmt}, bFmt: {bFmt}, rFmt: {rFmt}, rmax: {rmax}, rmin: {rmin}"
                        
                        # Check int bits are necessary
                        if rFmt.I + rFmt.F > 0:
                            smallerFmt = FixFormat(rFmt.S, rFmt.I - 1, rFmt.F)
                            assert rmax > cl_fix_max_value(smallerFmt) or rmin < cl_fix_min_value(smallerFmt), "mult: Format is excessively wide." \
                                + f" aFmt: {aFmt}, bFmt: {bFmt}, rFmt: {rFmt}, rmax: {rmax}, rmin: {rmin}"
                        
                        # The optimal number of frac bits is straightforward: aFmt.F + bFmt.F. For example,
                        # if we take +/- 1 LSB in each representation: (+/- 2**-aFmt.F) * (+/- 2**-bFmt.F)
                        # = +/- 2**-(aFmt.F + bFmt.F). No other inputs could need more frac bits.
                        assert rFmt.F == aFmt.F + bFmt.F, "mult: Unexpected number of frac bits"
                    
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
            rFmt = FixFormat.ForNeg(aFmt)
            
            # Check int bits are sufficient
            assert rmax <= cl_fix_max_value(rFmt), "neg: Max value exceeded" \
                + f" aFmt: {aFmt}, rFmt: {rFmt}, rmax: {rmax}, rmin: {rmin}"
            assert rmin >= cl_fix_min_value(rFmt), "neg: Min value exceeded" \
                + f" aFmt: {aFmt}, rFmt: {rFmt}, rmax: {rmax}, rmin: {rmin}"
            
            # Check int bits are necessary
            if rFmt.I + rFmt.F > 0:
                smallerFmt = FixFormat(rFmt.S, rFmt.I - 1, rFmt.F)
                assert rmax > cl_fix_max_value(smallerFmt) or rmin < cl_fix_min_value(smallerFmt), "neg: Format is excessively wide." \
                    + f" aFmt: {aFmt}, rFmt: {rFmt}, rmax: {rmax}, rmin: {rmin}"
            
            # The optimal number of frac bits is trivial: aFmt.F
            assert rFmt.F == aFmt.F, "neg: Unexpected number of frac bits"
            
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
            rFmt = FixFormat.ForAbs(aFmt)
            
            # Check int bits are sufficient
            assert rmax <= cl_fix_max_value(rFmt), "abs: Max value exceeded" \
                + f" aFmt: {aFmt}, rFmt: {rFmt}, rmax: {rmax}, rmin: {rmin}"
            assert rmin >= cl_fix_min_value(rFmt), "abs: Min value exceeded" \
                + f" aFmt: {aFmt}, rFmt: {rFmt}, rmax: {rmax}, rmin: {rmin}"
            
            # Check int bits are necessary
            smallerFmt = FixFormat(rFmt.S, rFmt.I - 1, rFmt.F)
            assert rmax > cl_fix_max_value(smallerFmt) or rmin < cl_fix_min_value(smallerFmt), "abs: Format is excessively wide." \
                + f" aFmt: {aFmt}, rFmt: {rFmt}, rmax: {rmax}, rmin: {rmin}"
            
            # The optimal number of frac bits is trivial: aFmt.F
            assert rFmt.F == aFmt.F, "abs: Unexpected number of frac bits"
            
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
                    rFmt = FixFormat.ForShift(aFmt, min_shift, max_shift)
                    
                    # Check int bits are sufficient
                    assert rmax <= cl_fix_max_value(rFmt), "shift: Max value exceeded" \
                        + f" aFmt: {aFmt}, rFmt: {rFmt}, rmax: {rmax}, rmin: {rmin}"
                    assert rmin >= cl_fix_min_value(rFmt), "shift: Min value exceeded" \
                        + f" aFmt: {aFmt}, rFmt: {rFmt}, rmax: {rmax}, rmin: {rmin}"
                    
                    # Check int bits are necessary
                    if rFmt.I + rFmt.F > 0:
                        smallerFmt = FixFormat(rFmt.S, rFmt.I - 1, rFmt.F)
                        assert rmax > cl_fix_max_value(smallerFmt) or rmin < cl_fix_min_value(smallerFmt), "shift: Format is excessively wide." \
                            + f" aFmt: {aFmt}, rFmt: {rFmt}, rmax: {rmax}, rmin: {rmin}, min_shift: {min_shift}, max_shift: {max_shift}"
                    
                    # The optimal number of frac bits is trivial: aFmt.F - min_shift
                    assert rFmt.F == aFmt.F - min_shift, "shift: Unexpected number of frac bits"
                    