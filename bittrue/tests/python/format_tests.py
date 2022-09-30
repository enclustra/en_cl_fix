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
aIplusF = 4

# bFmt test points
bS_values = [0,1]
bI_values = np.arange(-6,1+6)
bIplusF = 4

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
        # Limit I+F (to keep simulation time reasonable)
        aF = aIplusF-aI
        aFmt = FixFormat(aS, aI, aF)
        
        amin = cl_fix_min_value(aFmt)
        amax = cl_fix_max_value(aFmt)
        
        ########
        # bFmt #
        ########
        for bS in bS_values:
            for bI in bI_values:
                # Limit I+F (to keep simulation time reasonable)
                bF = bIplusF-bI
                bFmt = FixFormat(bS, bI, bF)
                
                bmin = cl_fix_min_value(bFmt)
                bmax = cl_fix_max_value(bFmt)
                
                ##############
                # cl_fix_add #
                ##############
                
                # Calculate the extreme results
                rmax = amax + bmax
                rmin = amin + bmin
                
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
                
                ##############
                # cl_fix_sub #
                ##############
                
                # Calculate the extreme results
                rmax = amax - bmin
                rmin = amin - bmax
                
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
                smallerFmt = FixFormat(rFmt.S, rFmt.I - 1, rFmt.F)
                assert rmax > cl_fix_max_value(smallerFmt) or rmin < cl_fix_min_value(smallerFmt), "mult: Format is excessively wide." \
                    + f" aFmt: {aFmt}, bFmt: {bFmt}, rFmt: {rFmt}, rmax: {rmax}, rmin: {rmin}"
            
            ##############
            # cl_fix_neg #
            ##############
            
            # Calculate the extreme results
            rmax = -amin
            rmin = -amax
            
            # Format to test
            rFmt = FixFormat.ForNeg(aFmt)
            
            # Check int bits are sufficient
            assert rmax <= cl_fix_max_value(rFmt), "neg: Max value exceeded" \
                + f" aFmt: {aFmt}, bFmt: {bFmt}, rFmt: {rFmt}, rmax: {rmax}, rmin: {rmin}"
            assert rmin >= cl_fix_min_value(rFmt), "neg: Min value exceeded" \
                + f" aFmt: {aFmt}, bFmt: {bFmt}, rFmt: {rFmt}, rmax: {rmax}, rmin: {rmin}"
            
            # Check int bits are necessary
            smallerFmt = FixFormat(rFmt.S, rFmt.I - 1, rFmt.F)
            assert rmax > cl_fix_max_value(smallerFmt) or rmin < cl_fix_min_value(smallerFmt), "neg: Format is excessively wide." \
                + f" aFmt: {aFmt}, bFmt: {bFmt}, rFmt: {rFmt}, rmax: {rmax}, rmin: {rmin}"
            