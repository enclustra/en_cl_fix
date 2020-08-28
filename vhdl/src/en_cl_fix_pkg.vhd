---------------------------------------------------------------------------------------------------
--  Copyright (c) 2010-2018 by Enclustra GmbH, Switzerland
--  All rights reserved.
--  Authors: Martin Heimlicher, Oliver Bründler
---------------------------------------------------------------------------------------------------

---------------------------------------------------------------------------------------------------
-- Libraries
---------------------------------------------------------------------------------------------------
--! ieee library
library ieee;
	--! logic package
	use ieee.std_logic_1164.all;
	--! package for conversions
	use ieee.numeric_std.all;
	--! package for real calculations 
	use ieee.math_real.all;

--! std library
library std;
	--! used for file I/O
	use std.textio.all;
	

---------------------------------------------------------------------------------------------------
-- Package Header
---------------------------------------------------------------------------------------------------
--! \brief 		Enclustra fix-point package 
--! \details 	<h2> Summary </h2>
--!				The en_cl_fix package provides commonly used fixed-point arithmetic and vector resizing
--!				operations implemented in VHDL and MATLAB code. The VHDL and MATLAB iimplementation deliver
--!				bit-true results, simplifying bit-true co-simulation.
--!
--!				<h2> Formats </h2>
--! 			Format are always given in the form (S,I,F) where S defines if there is a sign bit,
--! 			I defines the number of integer bits and F defines the number of fractional bits.\n
--!				en_cl_fix functions strictly operate on std_logic_vector (VHDL) or double (MATLAB)\n
--!				Examples:
--!				<ul>
--!					<li> (true,3,2) 6 bits, LSB = 0.25, min. = -8, max. = +7.75		</li>
--!					<li> (false,3,2) 5 bits, LSB = 0.25, min = 0, max. = +7.75		</li>
--!					<li> (false,-1,3) 2 bits, LSB = 0.125, min = 0, max = +0.375	</li>
--!     			<li> (false,3,-1) 2 bits, LSB = 2, min = 0, max = 6				</li>
--!				</ul>
--!				For further details see \link FixFormat_t \endlink.
--!
--!				<h2> Rounding </h2>
--!				Most operations provide rounding and saturation support. See \link FixRound_t \endlink and \link FixSaturate_t \endlink
--!				for details.
--!				
--!				<h2> Related Packages </h2>
--!				en_cl_bittrue_pkg: Used for data exchange between MATLAB and VHDL in bit-true testbenches \n
--!	
--!				<h2> Examples </h2>
--!				Variables are used in all examples but the syntax is exactly the same for signals.\n
--!				All examples are implemented as processes but the statements can also be used as concurrent statements.
--!
--!				<h3> Addition </h3>
--!				This example shows how a mathematical operation is implemented using the en_cl_fix library.\n
--!				Results are printed to the console to be easily readable.
--!				\verbatim
--!	addition_p : process
--!		-- Formats
--!		constant OpAFmt_c 	: FixFormat_t := (true, 3, 5);
--!		constant OpBFmt_c	: FixFormat_t := (false, -2, 8);
--!		constant ResFmt_c	: FixFormat_t := (true, 3, 3);
--!
--!		-- Variables
--!		variable OpA_v		: std_logic_vector(cl_fix_width(OpAFmt_c)-1 downto 0);
--!		variable OpB_v		: std_logic_vector(cl_fix_width(OpBFmt_c)-1 downto 0);
--!		variable Res_v		: std_logic_vector(cl_fix_width(ResFmt_c)-1 downto 0);
--!	begin
--!		OpA_v	:= cl_fix_from_real(-3.134, OpAFmt_c, Sat_s);
--!		OpB_v	:= cl_fix_from_real(0.1, OpBFmt_c, Sat_s);
--!		Res_v	:= cl_fix_add(	OpA_v, OpAFmt_c,
--!								OpB_v, OpBFmt_c,
--!								ResFmt_c, NonSymPos_s, Sat_s);
--!		report "Add: OpA is " & real'image(cl_fix_to_real(OpA_v, OpAFmt_c));
--!		report "Add: OpB is " & real'image(cl_fix_to_real(OpB_v, OpBFmt_c));
--!		report "Add: Res is " & real'image(cl_fix_to_real(Res_v, ResFmt_c));
--!		wait;
--!	end process;
--!				\endverbatim
--!
--!				<h3> Format Calculations </h3>
--!				This example shows how formats can be calculated based on other formats. It implements a multiplication.\n
--!				Results are printed to the console to be easily readable.
--!				\verbatim
--!	multiplication_p : process
--!		-- Formats
--!		constant OpAFmt_c 	: FixFormat_t := (true, 3, 5);
--!		constant OpBFmt_c	: FixFormat_t := (true, 2, 8);
--!		constant ResFmt_c	: FixFormat_t := (	OpAFmt_c.Signed or OpBFmt_c.Signed, 
--!												OpAFmt_c.IntBits + OpBFmt_c.IntBits + 1, 
--!												OpAFmt_c.FracBits + OpBFmt_c.FracBits);		-- Calculate format for exact multiplication without rounding
--!
--!		-- Variables
--!		variable OpA_v		: std_logic_vector(cl_fix_width(OpAFmt_c)-1 downto 0);
--!		variable OpB_v		: std_logic_vector(cl_fix_width(OpBFmt_c)-1 downto 0);
--!		variable Res_v		: std_logic_vector(cl_fix_width(ResFmt_c)-1 downto 0);
--!	begin
--!		OpA_v	:= cl_fix_from_real(-3.134, OpAFmt_c, Sat_s);
--!		OpB_v	:= cl_fix_from_real(0.1, OpBFmt_c, Sat_s);
--!		Res_v	:= cl_fix_mult(	OpA_v, OpAFmt_c,
--!								OpB_v, OpBFmt_c,
--!								ResFmt_c, Trunc_s, None_s);
--!		report "Mult: OpA is " & real'image(cl_fix_to_real(OpA_v, OpAFmt_c));
--!		report "Mult: OpB is " & real'image(cl_fix_to_real(OpB_v, OpBFmt_c));
--!		report "Mult: Res is " & real'image(cl_fix_to_real(Res_v, ResFmt_c));
--!		wait;
--!	end process;
--!				\endverbatim
package en_cl_fix_pkg is

	-----------------------------------------------------------------------------------------------
	-- Types
	-----------------------------------------------------------------------------------------------	
	--! \brief Fix-point format type
	--! <table>
	--! <tr><th> Field 		</th><th> Description 		</th><th> Notes 												</th></tr>
	--! <tr><td> Signed 	</td><td> Signed/Unsigned	</td><td> -														</td></tr>
	--! <tr><td> IntBits	</td><td> Integer bits		</td><td> Can be negative, IntBits+FracBits must be at least 1 	</td></tr>
	--! <tr><td> FracBits	</td><td> Fractional bits 	</td><td> Can be negative, IntBits+FracBits must be at least 1 	</td></tr>
	--! </table>
	--!
	--! unsigned examples (Signed = false) \n
	--! \verbatim	
	--!   III.FFF        IntBits = 3   FracBits = 3   Width = 6 --> std_logic_vector (5 downto 0)
	--!     0.FFF        IntBits = 0   FracBits = 3   Width = 3 --> std_logic_vector (2 downto 0)
	--!     0.00FFF      IntBits = -2  FracBits = 5   Width = 3 --> std_logic_vector (2 downto 0)
	--!   III.000        IntBits = 3   FracBits = 0   Width = 3 --> std_logic_vector (2 downto 0)
	--! III00.000        IntBits = 5   FracBits = -2  Width = 3 --> std_logic_vector (2 downto 0)
	--! \endverbatim
	--!
	--! signed examples (Signed = true) \n
	--! \verbatim	
	--!   SIII.FFF        IntBits = 3   FracBits = 3   Width = 7 --> std_logic_vector (6 downto 0)
	--!      S.FFF        IntBits = 0   FracBits = 3   Width = 4 --> std_logic_vector (3 downto 0)
	--!      0.0SFFF      IntBits = -2  FracBits = 5   Width = 4 --> std_logic_vector (3 downto 0)
	--!   SIII.000        IntBits = 3   FracBits = 0   Width = 4 --> std_logic_vector (3 downto 0)
	--! SIII00.000        IntBits = 5   FracBits = -2  Width = 4 --> std_logic_vector (3 downto 0)
	--! \endverbatim
	--!
	--! \note	All operations are performed with "infinite" precision and then rounded/saturated to 
	--!   		the result format.
	--!
	--! \note	The sign bit is always the bit left to the most significant integer bit.\n
	--!   		cl_fix_from_real (-16.0, cl_fix_format (true, 3, 0), None_s) --> "0000" (SIII) \n
	--!     		The sign bit is zero, even if the number is negative. 
	--!     		This is because the "infinite" precision -16.0 is
	--!      	 "11111...111110000" and the last 4 bits are taken as the result.
	--!
	type FixFormat_t is record
		Signed		: boolean;
		IntBits		: integer; -- can be negative, IntBits+FracBits must be at least 1.
		FracBits	: integer; -- can be negative, IntBits+FracBits must be at least 1.
	end record;
	
	--! \brief	Array of FixFormat_t
	--! \see 	FixFormat_t
	type FixFormatArray_t is array (natural range <>) of FixFormat_t;
	
	--! \brief Rounding mode
	--! <table>
	--! <tr><th rowspan = "2"> Value </th><th rowspan = "2"> Description 			</th><th colspan = "6"> Examples rounded to (true,2,0) 											</th></tr>
	--! <tr>																		     <th> 2.2 	</th><th> 2.7 	</th><th> -1.5 	</th><th> -0.5 	</th><th> 0.5 	</th><th> 1.5 	</th></tr>
	--! <tr><td> Trunc_s			</td><td> Cut off bits without any rounding		</td><td> 2		</td><td> 2		</td><td> -2	</td><td> -1	</td><td> 0		</td><td> 1		</td></tr>
	--! <tr><td> NonSymPos_s		</td><td> Non-symmetric rounding to positive	</td><td> 2		</td><td> 3		</td><td> -1	</td><td> 0		</td><td> 1		</td><td> 2		</td></tr>
	--! <tr><td> NonSymNeg_s		</td><td> Non-symmetric rounding to negative 	</td><td> 2		</td><td> 3		</td><td> -2	</td><td> -1	</td><td> 0		</td><td> 1		</td></tr>
	--! <tr><td> SymInf_s			</td><td> Symmetric rounding to infinity		</td><td> 2		</td><td> 3		</td><td> -2	</td><td> -1	</td><td> 1		</td><td> 2		</td></tr>
	--! <tr><td> SymZero_s			</td><td> Symmetric rounding to zero			</td><td> 2		</td><td> 3		</td><td> -1	</td><td> 0		</td><td> 0		</td><td> 1		</td></tr>
	--! <tr><td> ConvEven_s			</td><td> Convergent rounding to even numbers	</td><td> 2		</td><td> 3		</td><td> -2	</td><td> 0		</td><td> 0		</td><td> 2		</td></tr>
	--! <tr><td> ConvOdd_s			</td><td> Convertent rounding to odd numbers	</td><td> 2		</td><td> 3		</td><td> -1	</td><td> -1	</td><td> 1		</td><td> 1		</td></tr>
	--! </table>
	--! \note	Use Trunc_S or NonSymPos_s for wherever possible for lowest resource usage
	type FixRound_t is 
		(
			Trunc_s, 		-- cut off bits
			NonSymPos_s, 	-- non-symmetric rounding to positive
			NonSymNeg_s, 	-- non-symmetric rounding to negative
			SymInf_s, 		-- symmetric rounding to infinity
			SymZero_s, 		-- symmetric rounding to zero
			ConvEven_s, 	-- convergent rounding to even number
			ConvOdd_s		-- convergent rounding to odd number
		);
	--! \brief Alias for most common rounding mode
	constant Round_s	: FixRound_t	:= NonSymPos_s;
		
	--! \brief Saturation mode
	--! <table>
	--! <tr><th> Value		</th><th> Description 				</th></tr>
	--! <tr><td> None_s		</td><td> No saturation, no warning </td></tr>
	--! <tr><td> Warn_s		</td><td> No saturation, warning	</td></tr>
	--! <tr><td> Sat_s		</td><td> Saturation, no warning	</td></tr>
	--! <tr><td> SatWarn_s	</td><td> Saturation, warning		</td></tr>
	--! </table>
	type FixSaturate_t is
		(
			None_s,			-- no saturation, no warning
			Warn_s,			-- no saturation, warning
			Sat_s,			-- saturation, no warning
			SatWarn_s		-- saturation, warning
		);
	
	-----------------------------------------------------------------------------------------------
	-- Format Functions
	-----------------------------------------------------------------------------------------------		
	--! \brief 			Fills a FixFormat_t record with values (most useful in MATLAB)
	--! \param signed	Sign bit
	--! \param intBits	Integer bits
	--!	\param fracBits	Fractional bits
	--! \return			Created FixFormat_t format
	--! \see FixFormat_t
	function cl_fix_format (	signed 		: boolean;
								intBits		: integer;
								fracBits	: integer) 
								return FixFormat_t;
	
	
	--! \brief			Get the number of bits to represent a fix-point format
	--! \param fmt		Format to get the number of bits required for
	--! \return			Number of bits required to represent the format
	function cl_fix_width (	fmt 	: FixFormat_t) 
							return positive;

	--! \brief			Get the string representation of a fix-point format
	--! \details		The string is in the form "(true,3,4)"\n
	--!					This function is especially useful if the en_cl_bittrue_pkt package is used.
	--! \param fmt		Format to get the string representation for
	--! \return			String representation of the format
	function cl_fix_string_from_format (	fmt 	: FixFormat_t) 
											return string;
											
	--! \brief			Converts a string into a FixFormat_t
	--!	\details		This is very useful to pass formats as generics into simulations. Formats
	--!					cannot be passed as \link FixFormat_t \endlink since Modelsim only supports
	--!					Generics of types integer, string and boolean. Using this function, the formats
	--!					can be passed as string and then converted to \link FixFormat_t \endlink.
	--! \param Str		Format string in the form "(<IsSigned>,<IntBits>,<FracBits>)"
	--! \return			FixFormat_t
	function cl_fix_format_from_string(		Str	: string) 
											return FixFormat_t;											
	
	--! \brief			Zero in a given format
	--! \param fmt		Format to represent zero in
	--! \return			Fix-point representation of zero
	--! \see			cl_fix_max_value()
	--! \see			cl_fix_min_value()
	function cl_fix_zero_value (	fmt 	: FixFormat_t) 
									return std_logic_vector;

	--! \brief			Maximum value in a given format
	--!	\param fmt		Format to get the maximum value from
	--! \return			Fix-point representation of the maximum value representable in format fmt
	--! \see			cl_fix_zero_value()
	--! \see			cl_fix_min_value()
	function cl_fix_max_value (	fmt 	: FixFormat_t) 
								return std_logic_vector;
								
	--! \brief			Minimum value in a given format
	--! \param fmt		Format to get the minimum value from
	--! \return			Fix-point representation of the minimum value representable in format fmt
	--! \see			cl_fix_zero_value()
	--! \see			cl_fix_max_value()
	function cl_fix_min_value (	fmt 	: FixFormat_t) 
								return std_logic_vector;	

	--! \brief			Maximum value in a given format as real number
	--!	\param fmt		Format to get the maximum value from
	--! \return			Real representation of the maximum value representable in format fmt
	--! \see			cl_fix_min_real()
	function cl_fix_max_real (	fmt 	: FixFormat_t) 
								return real;								
	
	--! \brief			Minimum value in a given format as real number
	--! \param fmt		Format to get the minimum value from
	--! \return			Real representation of the minimum value representable in format fmt
	--! \see			cl_fix_max_real()
	function cl_fix_min_real (	fmt 	: FixFormat_t) 
								return real;						
		
	--! \brief			Extract sign bit from a fix-point number
	--! \param a		Number to extract sign bit from
	--! \param a_fmt	Format of a
	--! \return			Extracted sign bit
	--! \see			cl_fix_int()
	--! \see			cl_fix_frac()
	function cl_fix_sign (	a 		: std_logic_vector; 
							a_fmt 	: FixFormat_t) 
							return std_logic;
	
	--! \brief			Extract integer bits from fix-point number
	--! \param a		Number to extract integer bits from
	--! \param a_fmt	Format of a
	--! \return 		Extracted integer bits
	--! \see			cl_fix_sign()
	--! \see			cl_fix_frac()
	function cl_fix_int (	a 		: std_logic_vector; 
							a_fmt 	: FixFormat_t) 
							return std_logic_vector;
	
	--! \brief			Extract fractional bits from fix-point number
	--! \param a		Number to extract integer bits from
	--!	\param a_fmt	Format of a
	--! \see			cl_fix_sign()
	--! \see			cl_fix_int()
	function cl_fix_frac (	a 		: std_logic_vector; 
							a_fmt 	: FixFormat_t) 
							return std_logic_vector;

	--! \brief				Combine sign bit, integer bits and fractional bits to a fix-point number
	--! \param sign			Sign bit
	--!	\param int			Integer bits
	--! \param frac			Fractional bits
	--! \param result_fmt	Format of the returned fix-point number
	--! \return				Combined fix-point number
	function cl_fix_combine (	sign		: std_logic; 
								int			: std_logic_vector; 
								frac		: std_logic_vector;
								result_fmt	: FixFormat_t) 
								return std_logic_vector;

	-----------------------------------------------------------------------------------------------
	-- Bit Manipulation
	-----------------------------------------------------------------------------------------------	
	--! \brief			Get a given bit within a fix-point number (MSB based index)
	--! \param a		Fix-point number to get the bit from
	--! \param a_fmt	Format of a
	--! \param index	Index of the bit to get (start countintg at the MSB)\n
	--!					index = 0 retrieves the MSB
	--! \return			Extracted bit
	--! \note			index must be between 0 and cl_fix_width(a_fmt)-1	
	--! \see			cl_fix_get_lsb()
	function cl_fix_get_msb (	a		: std_logic_vector;
								a_fmt	: FixFormat_t;
								index	: natural) 
								return std_logic;
		
	--! \brief			Get a given bit within a fix-point number (LSB based index)
	--! \param a		Fix-point number to get the bit from
	--! \param a_fmt	Format of a
	--! \param index	Index of the bit to get (start counting at the LSB)\n
	--!					index = 0 retrieves the LSB
	--!	\return			Extracted bit
	--! \note			index must be between 0 and cl_fix_width(a_fmt)-1
	--! \see			cl_fix_get_msb()
	function cl_fix_get_lsb (	a		: std_logic_vector;
								a_fmt	: FixFormat_t;
								index	: natural) 
								return std_logic;
								
	--! \brief			Set a given bit within a fix-point number (MSB based index)
	--! \param a		Fix-point number to set the bit in
	--! \param a_fmt	Format of a
	--! \param index	Index of the bit to set (start countint at the MSB)\n
	--!					index = 0 sets the MSB
	--! \param value	Value to set the specified bit to
	--! \return			Value of the fix-point number after the manipulation
	--! \note			index must be between 0 and cl_fix_width(a_fmt)-1
	--! \see			cl_fix_get_lsb()
	function cl_fix_set_msb (	a			: std_logic_vector; 
								a_fmt		: FixFormat_t; 
								index		: natural;
								value		: std_logic) 
								return std_logic_vector;
								
	--! \brief			Set a given bit within a fix-point number (LSB based index)
	--! \param a		Fix-point number to set the bit in
	--! \param a_fmt	Format of a
	--! \param index	Index of the bit to set (start countint at the LSB)\n
	--!					index = 0 sets the LSB
	--! \param value	Value to set the specified bit to
	--! \return			Value of the fix-point number after the manipulation
	--! \note			index must be between 0 and cl_fix_width(a_fmt)-1	
	--! \see			cl_fix_set_msb()
	function cl_fix_set_lsb (	a			: std_logic_vector; 
								a_fmt		: FixFormat_t; 
								index		: natural;
								value		: std_logic) 
								return std_logic_vector;

	-----------------------------------------------------------------------------------------------
	-- Conversion To/From Other Formats
	-----------------------------------------------------------------------------------------------		
	--! \brief 				Convert integer to fix-point
	--! \param a			Integer number to convert to fix-point
	--! \param result_fmt	Fix-point format to convert the integer to
	--! \param saturate		Saturation mode
	--! \return				Fix-point representation of a
	--! \note				Fractional bits are always zero
	--! \see 				FixSaturate_t
	--! \see				cl_fix_to_int()
	function cl_fix_from_int (	a			: integer; 
								result_fmt	: FixFormat_t;
								saturate	: FixSaturate_t := SatWarn_s) 								
								return std_logic_vector;
								
	--! \brief				Convert fix-point number to integer.
	--! \details			Fractional bits are ignored.
	--! \param a			Fix-point number to convert to integer
	--! \param a_fmt		Format of a
	--! \return				Integer representation of a
	--! \note				Fractional bits are ignored (implicit usage of Trunc_s)
	--! \see				cl_fix_from_int()
	function cl_fix_to_int (	a 		: std_logic_vector; 
								a_fmt 	: FixFormat_t) 
								return integer;
	
	--! \brief				Convert real to fix-point
	--! \param a			Real number to convert to fixed-point
	--! \param result_fmt	Fix-point format to convert the real number to
	--! \param saturate		Saturation mode
	--! \return				Fix-point representation of a
	--! \note				Rounds symmetrically away from zero (implicit usage of SymInf_s)
	--! \see 				FixSaturate_t
	--! \see				cl_fix_to_real()
	function cl_fix_from_real (	a			: real; 
								result_fmt	: FixFormat_t;
								saturate	: FixSaturate_t := SatWarn_s) 
								return std_logic_vector;
	
	
	--! \brief				Convert fix-point to real
	--! \param a			Fix-point number to convert to real
	--! \param a_fmt		Format of a
	--! \return				Real representation of a
	--! \return				cl_fix_from_real()
	function cl_fix_to_real (	a 		: std_logic_vector; 
								a_fmt 	: FixFormat_t) 
								return real;
	
	--! \brief				Convert binary string to fix-point number
	--! \param a			Binary string to convert
	--! \param result_fmt	Format of the conversion result
	--! \return				Fix-point representation of a
	--! \see				cl_fix_to_bin()
	function cl_fix_from_bin (	a			: string; 
								result_fmt	: FixFormat_t) 
								return std_logic_vector;
								
	--! \brief 				Convert fix-point number to binary string
	--! \param a			Fix-point number to convert to binary string
	--! \param a_fmt		Format of a
	--! \return				Binary string representation of a\A8
	--!	\see				cl_fix_from_bin()
	function cl_fix_to_bin (	a			: std_logic_vector; 
								a_fmt		: FixFormat_t) 
								return string;
								
	--! \brief				Convert hex string to fix-point number
	--!	\param a			Hex string to convert
	--! \param result_fmt	Format of the conversion result
	--! \return				Fix-point representation of a
	--! \see				cl_fix_to_hex()
	function cl_fix_from_hex (	a			: string; 
								result_fmt	: FixFormat_t) 
								return std_logic_vector;
								
	--! \brief				Convert fix-point number to hex string
	--! \param a			Fix-point number to convert to hex string
	--! \param a_fmt		Format of a
	--! \return				Hex string representation of a
	--! \see 				cl_fix_from_hex()
	function cl_fix_to_hex (	a			: std_logic_vector; 
								a_fmt		: FixFormat_t) 
								return string;

	--! \brief				Get bits intereted as number (ignoring fractional bits). This is very useful
	--!						for writing fixed-point number to files efficiently.
	--! \param a			Fix-point number to get the bits from
	--! \param a_fmt		Format of a
	--! \return				Integer representation of the bits in a
	--! \see 				cl_fix_from_bits_as_int()			
	function cl_fix_get_bits_as_int(	a		: std_logic_vector;
										aFmt	: FixFormat_t)
										return integer;

	--! \brief				Create fixed-point number from bits stored in integer representation. This is very
	--!						useful for reading fixed-point numbers from files efficiently.
	--! \param a			Bits of a fixed-point number in integer representation
	--! \param a_fmt		Format of of the fixed-point number
	--! \return				Fixed-point number as std_logic_vector
	--! \see 				cl_fix_get_bits_as_int()										
	function cl_fix_from_bits_as_int(	a 		: integer;
										aFmt 	: FixFormat_t)
										return std_logic_vector;								

	-----------------------------------------------------------------------------------------------
	-- File Operations
	-----------------------------------------------------------------------------------------------	
	--! \brief				Read integer number from file and return it as fix-point number
	--! \param a			File to read integer from
	--! \param result_fmt	Fix-point format to return the result in
	--! \param saturate		Saturation mode
	--! \return				Fix-point representation of the integer read from the file
	--! \note				Fractional bits are always zero
	--! \warning			This function is deprecated, use en_cl_bittrue_pkg instead
	--! \see 				FixSaturate_t	
	--! \see 				cl_fix_write_int()
	impure function cl_fix_read_int (	file a		: text; 
										result_fmt	: FixFormat_t;
										saturate	: FixSaturate_t := SatWarn_s) 
										return std_logic_vector;
										
	--! \brief				Read real number from file and return it as fix-point number
	--! \param a			File to read real from
	--! \param result_fmt	Fix-point format to return the result in
	--! \param saturate		Saturation mode
	--! \return 			Fix-point representation of the real number read from the file
	--! \warning			This function is deprecated, use en_cl_bittrue_pkg instead
	--! \see 				FixSaturate_t	
	--! \see 				cl_fix_write_real()
	impure function cl_fix_read_real (	file a		: text; 
										result_fmt	: FixFormat_t;
										saturate	: FixSaturate_t := SatWarn_s) 
										return std_logic_vector;
										
	--! \brief				Read binary string from file and return it as fix-point number
	--! \param a			File to read binary string from
	--! \param result_fmt	Fix-point format to return the result in
	--! \return				Fix-point number read from file
	--! \warning			This function is deprecated, use en_cl_bittrue_pkg instead
	--! \see 				cl_fix_write_bin()
	impure function cl_fix_read_bin (	file a		: text; 
										result_fmt	: FixFormat_t) 
										return std_logic_vector;

	--! \brief				Read hex string from file and return it as fix-point number
	--! \param a			File to read hex string from
	--! \param result_fmt	Fix-point format to return the result in
	--! \return				Fix-pint number read from the file
	--! \warning			This function is deprecated, use en_cl_bittrue_pkg instead
	--! \see				cl_fix_write_hex()
	impure function cl_fix_read_hex (	file a		: text; 
										result_fmt	: FixFormat_t) 
										return std_logic_vector;
		
	--! \brief				Write fix-point number as integer into a file
	--! \param a			Fix-point number to write
	--! \param a_fmt		Format of a
	--! \param f			File to write the number into
	--! \param f_fmt		Format to write to file (see "notes" section)
	--! \param round		Rounding mode
	--! \param saturate		Saturation mode
	--! \note				1 corresponds to one LSB of the format f_fmt
	--! \warning			This function is deprecated, use en_cl_bittrue_pkg instead
	--! \see 				FixRound_t
	--! \see				FixSaturate_t
	--! \see				cl_fix_read_int()
	procedure cl_fix_write_int (	a			: std_logic_vector; 
									a_fmt		: FixFormat_t;
									file f		: text;
									f_fmt		: FixFormat_t;
									round		: FixRound_t	:= Trunc_s; 
									saturate	: FixSaturate_t	:= Warn_s);
									
	--! \brief				Write fix-point number as real into a file
	--! \param a			Fix-point number to write
	--! \param a_fmt		Format of a
	--! \param f			File to write the number into
	--! \param f_fmt		Format to write into the file (a is converted to f_fmt before writing)
	--! \param round		Rounding mode
	--! \param saturate		Saturation mode
	--! \warning			This function is deprecated, use en_cl_bittrue_pkg instead
	--! \see 				FixRound_t
	--! \see				FixSaturate_t
	--! \see				cl_fix_read_real()	
	procedure cl_fix_write_real (	a			: std_logic_vector; 
									a_fmt		: FixFormat_t;
									file f		: text;
									f_fmt		: FixFormat_t;
									round		: FixRound_t	:= Trunc_s; 
									saturate	: FixSaturate_t	:= Warn_s);
									
	--! \brief				Write fix-point number as binary string into a file
	--! \param a			Fix-point number to write
	--! \param a_fmt		Format of a
	--! \param f			File to write number into
	--! \param f_fmt		Format to write into the file (a is converted to f_fmt before writing)
	--! \param round		Rounding mode
	--! \param saturate		Saturation mode
	--! \warning			This function is deprecated, use en_cl_bittrue_pkg instead
	--! \see 				FixRound_t
	--! \see				FixSaturate_t	
	--! \see				cl_fix_read_bin()
	procedure cl_fix_write_bin (	a			: std_logic_vector; 
									a_fmt		: FixFormat_t;
									file f		: text;
									f_fmt		: FixFormat_t;
									round		: FixRound_t	:= Trunc_s; 
									saturate	: FixSaturate_t	:= Warn_s
		);
		
	--! \brief				Write fix-point number as hex string into a file
	--! \param a			Fix-point number to write
	--! \param a_fmt		Format of a
	--! \param f			File to write number into
	--! \param f_fmt		Format to write into the file (a is converted to f_fmt before writing)
	--! \param round		Rounding mode
	--! \param saturate		Saturation mode
	--! \warning			This function is deprecated, use en_cl_bittrue_pkg instead
	--! \see 				FixRound_t
	--! \see				FixSaturate_t	
	--! \see				cl_fix_read_hex()
	procedure cl_fix_write_hex (	a			: std_logic_vector; 
									a_fmt		: FixFormat_t;
									file f		: text;
									f_fmt		: FixFormat_t;
									round		: FixRound_t	:= Trunc_s; 
									saturate	: FixSaturate_t	:= Warn_s
		);

	-----------------------------------------------------------------------------------------------
	-- Resize and Rounding
	-----------------------------------------------------------------------------------------------	
	--! \brief				Change the format of a fix-point number
	--! \param a			Fix-point number to represent in a new format
	--! \param a_fmt		Old format of a
	--! \param result_fmt	Format of the result (new format)
	--! \param round		Rounding mode
	--! \param saturate		Saturation mode
	--! \return				Representation of a in the new format 
	--! \see 				FixRound_t
	--! \see				FixSaturate_t		
	function cl_fix_resize (	a			: std_logic_vector; 
								a_fmt		: FixFormat_t; 
								result_fmt	: FixFormat_t; 
								round		: FixRound_t	:= Trunc_s; 
								saturate	: FixSaturate_t := Warn_s) 
								return std_logic_vector;
	
	--! \brief				Convert fix-point number to integer (implicit usage of SymZero_s)
	--! \details			The result as the same format as the input but without fractional bits
	--! \param a			Fix-point number to convert to integer
	--! \param a_fmt		Format of a
	--! \return				Integer number generated represented as std_logic_vector
	--! \see 				FixRound_t
	--! \see				cl_fix_ceil()
	--! \see				cl_fix_floor()
	--! \see				cl_fix_round()	
	function cl_fix_fix (	a			: std_logic_vector; 
							a_fmt		: FixFormat_t) 
							return std_logic_vector;
							
	--! \brief				Convert fix-point number to integer (imiplicit usage of NonSymNeg_s)
	--! \details			The result as the same format as the input but without fractional bits
	--! \param a			Fix-point number to convert to integer
	--! \param a_fmt		Format of a
	--! \return				Integer number generated represented as std_logic_vector
	--! \see 				FixRound_t
	--! \see				cl_fix_ceil()
	--! \see				cl_fix_fix()
	--! \see				cl_fix_round()	
	function cl_fix_floor (	a			: std_logic_vector; 
							a_fmt		: FixFormat_t) 
							return std_logic_vector;
		
	--! \brief				Convert fix-point number to integer (implicit usage of NonSymPos_s)
	--! \details			The result as the same format as the input but without fractional bits
	--! \param a			Fix-point number to convert to integer
	--! \param a_fmt		Format of a
	--! \return				Integer number generated represented as std_logic_vector
	--! \see 				FixRound_t
	--! \see				cl_fix_floor()
	--! \see				cl_fix_fix()
	--! \see				cl_fix_round()	
	function cl_fix_ceil (	a			: std_logic_vector; 
							a_fmt		: FixFormat_t) 
							return std_logic_vector;
		
	--! \brief				Convert fix-point number to integer (implicit usage of SymInf_s)
	--! \details			The result as the same format as the input but without fractional bits
	--! \param a			Fix-point number to convert to integer
	--! \param a_fmt		Format of a
	--! \return				Integer number generated represented as std_logic_vector
	--! \see 				FixRound_t
	--! \see				cl_fix_ceil()
	--! \see				cl_fix_floor()
	--! \see				cl_fix_fix()
	function cl_fix_round (	a			: std_logic_vector; 
							a_fmt		: FixFormat_t) 
							return std_logic_vector;

	--! \brief				Check whether a fix-point number can be represented in a given format without clippling/saturation
	--! \param a			Fix-point number to check if it is reprensentable 
	--! \param a_fmt		Format of a
	--! \param result_fmt	Format to check whether the number can be represented in
	--! \param round		Rounding mode
	--! \return				True = a can be represented in result_fmt\n
	--!						False = a cannot be represented in result_fmt
	--! \see 				FixRound_t
	function cl_fix_in_range (	a			: std_logic_vector; 
								a_fmt		: FixFormat_t; 
								result_fmt	: FixFormat_t; 
								round		: FixRound_t	:= Trunc_s) 
								return boolean;
		
	-----------------------------------------------------------------------------------------------
	-- Math Functions
	-----------------------------------------------------------------------------------------------	
	--! \brief				Get absolute value of a fix-point number
	--! \param a			Fix-point number to get absolute value from
	--! \param a_fmt		Format of a
	--! \param result_fmt	Format of the absolute value returned
	--! \param round		Rounding mode
	--! \param saturate		Saturation mode
	--! \return				Absolute value of a
	--! \note				One additional integer bit is required to represent the absolute value of the most negative
	--!						value representable in signed fix-point formats
	--! \see 				FixRound_t
	--! \see				FixSaturate_t
	--! \see				cl_fix_sabs()
	function cl_fix_abs (	a			: std_logic_vector; 
							a_fmt		: FixFormat_t; 
							result_fmt	: FixFormat_t; 
							round		: FixRound_t	:= Trunc_s; 
							saturate	: FixSaturate_t := Warn_s) 
							return std_logic_vector;

	--!	\brief				Get simple absolute value of fix-point number 
	--! \details			This function delivery optimized timing and resouce usage compared to \link cl_fix_abs \endlink on the
	--!						cost of an additional error on the result (max. 1 LSB).
	--! \param a			Fix-point number to get absolute value from
	--! \param a_fmt		Format of a
	--! \param result_fmt	Format of the absolute value returned
	--! \param round		Rounding mode
	--! \param saturate		Saturation mode
	--! \return				Absolute value of a
	--! \note 				If a is negative, this function leads to an error of one LSB.\n
	--! \note				This function is a resource saving but less precise implementation of cl_fix_abs()
	--! \note				No additional integer bit is required for any input value
	--! \see 				FixRound_t
	--! \see				FixSaturate_t
	--! \see				cl_fix_abs()
	function cl_fix_sabs (	a			: std_logic_vector; 
							a_fmt		: FixFormat_t; 
							result_fmt	: FixFormat_t; 
							round		: FixRound_t	:= Trunc_s; 
							saturate	: FixSaturate_t := Warn_s) 
							return std_logic_vector;
		
	--! \brief				Negate a fix-point number
	--! \details			Negate a when enable = '1'
	--! \param a			Fix-point number to negate
	--! \param a_fmt		Format of a
	--! \param enable		Enable negation\n
	--!						'1' result = -a\n
	--!						'0' result = +a
	--! \param result_fmt	Format of the result
	--! \param round		Rounding mode
	--! \param saturate		Saturation mode
	--! \return				Negated (or not if enable = '0') a output
	--! \note				One additional integer bit is required to represent the negated value of the most negative
	--!						value representable in signed fix-point formats	
	--! \see 				FixRound_t
	--! \see				FixSaturate_t
	--! \see				cl_fix_sneg()	
	function cl_fix_neg (	a			: std_logic_vector; 
							a_fmt		: FixFormat_t; 
							enable		: std_logic		:= '1';
							result_fmt	: FixFormat_t; 
							round		: FixRound_t	:= Trunc_s; 
							saturate	: FixSaturate_t := Warn_s) 
							return std_logic_vector;
		
	--! \brief				Simple negate a fix-point number
	--! \details			Negate a when enable = '1'\n
	--! 					This function delivery optimized timing and resouce usage compared to \link cl_fix_neg \endlink on the
	--!						cost of an additional error on the result (max. 1 LSB).	
	--! \param a			Fix-point number to negate
	--! \param a_fmt		Format of a
	--! \param enable		Enable negation\n
	--!						'1' result = -a\n
	--!						'0' result = +a
	--! \param result_fmt	Format of the result
	--! \param round		Rounding mode
	--! \param saturate		Saturation mode
	--! \return				Negated (or not if enable = '0') a output
	--! \note 				This function leads to an error of one LSB.\n
	--! \note				This function is a resource saving but less precise implementation of cl_fix_neg()	
	--! \note				No additional integer bit is required for any input value
	--! \see 				FixRound_t
	--! \see				FixSaturate_t
	--! \see				cl_fix_neg()			
	function cl_fix_sneg (	a			: std_logic_vector; 
							a_fmt		: FixFormat_t; 
							enable		: std_logic		:= '1';
							result_fmt	: FixFormat_t; 
							round		: FixRound_t	:= Trunc_s; 
							saturate	: FixSaturate_t := Warn_s) 
							return std_logic_vector;

	--! \brief				Add two fix-point numbers (a + b)
	--! \details			The calculation is executed with inifinite precision and then rounded to the format
	--!						of the result.
	--!	\param a			Adder input a (addend)
	--! \param a_fmt		Format of a
	--! \param b			Adder input b (addend)
	--! \param b_fmt		Format of b
	--! \param result_fmt	Format of the result
	--! \param round		Rounding mode
	--! \param saturate		Saturation mode
	--! \return				Adder result (sum)
	--! \see 				FixRound_t
	--! \see				FixSaturate_t
	function cl_fix_add (	a			: std_logic_vector; 
							a_fmt		: FixFormat_t; 
							b			: std_logic_vector; 
							b_fmt		: FixFormat_t; 
							result_fmt	: FixFormat_t; 
							round		: FixRound_t	:= Trunc_s; 
							saturate	: FixSaturate_t := Warn_s) 
							return std_logic_vector;

	--! \brief				Subtract two fix-point numbers (a - b)
	--! \details			The calculation is executed with inifinite precision and then rounded to the format
	--!						of the result.
	--!	\param a			Subtractor input a (minuend)
	--! \param a_fmt		Format of a
	--! \param b			Subtractor input b (subtrahend)
	--! \param b_fmt		Format of b
	--! \param result_fmt	Format of the result
	--! \param round		Rounding mode
	--! \param saturate		Saturation mode
	--! \return				Subtractor result (difference)
	--! \see 				FixRound_t
	--! \see				FixSaturate_t
	function cl_fix_sub (	a			: std_logic_vector; 
							a_fmt		: FixFormat_t; 
							b			: std_logic_vector; 
							b_fmt		: FixFormat_t; 
							result_fmt	: FixFormat_t; 
							round		: FixRound_t	:= Trunc_s; 
							saturate	: FixSaturate_t := Warn_s) 
							return std_logic_vector;
		
	--! \brief				Adder/Subtractor for two fix-point numbers
	--! \details			The operation to be calculated can be selected via an input signal\n
	--!						The calculation is executed with inifinite precision and then rounded to the format
	--!						of the result.
	--! \param a			Input a
	--! \param a_fmt		Format of a
	--! \param b			Input b
	--! \param b_fmt		Format of b
	--! \param add			Operation select signal:\n
	--!						'1' = Addition\n
	--!						'0' = Subtraction
	--! \param result_fmt	Format of the result
	--! \param round		Rounding mode
	--! \param saturate		Saturation mode
	--! \return				Addition/Subtraction result
	--! \see 				FixRound_t
	--! \see				FixSaturate_t	
	function cl_fix_addsub (	a			: std_logic_vector; 
								a_fmt		: FixFormat_t; 
								b			: std_logic_vector; 
								b_fmt		: FixFormat_t; 
								add			: std_logic;
								result_fmt	: FixFormat_t; 
								round		: FixRound_t	:= Trunc_s; 
								saturate	: FixSaturate_t := Warn_s) 
								return std_logic_vector;

	--! \brief				Simple adder/subtrator for two fix-point numbers
	--! \details			The operation to be calculated can be selected via an input signal\n
	--!						The calculation is executed with inifinite precision and then rounded to the format
	--!						of the result.	
	--! 					This function delivery optimized timing and resouce usage compared to \link cl_fix_addsub \endlink on the
	--!						cost of an additional error on the result (max. 1 LSB).	
	--! \param a			Input a
	--! \param a_fmt		Format of a
	--! \param b			Input b
	--! \param b_fmt		Format of b
	--! \param add			Operation select signal:\n
	--!						'1' = Addition\n
	--!						'0' = Subtraction
	--! \param result_fmt	Format of the result
	--! \param round		Rounding mode
	--! \param saturate		Saturation mode
	--! \return				Addition/Subtraction result	
	--! \note 				This function leads to an error of one LSB if subtraction is selected.\n
	--! \note				This function is a resource saving but less precise implementation of cl_fix_addsub()		
	--! \see 				FixRound_t
	--! \see				FixSaturate_t		
	function cl_fix_saddsub (	a			: std_logic_vector; 
								a_fmt		: FixFormat_t; 
								b			: std_logic_vector; 
								b_fmt		: FixFormat_t; 
								add			: std_logic;
								result_fmt	: FixFormat_t; 
								round		: FixRound_t	:= Trunc_s; 
								saturate	: FixSaturate_t := Warn_s) 
								return std_logic_vector;
		
	--! \brief				Calculate the mean value of two fix-point numbers
	--! \details			The calculation is executed with inifinite precision and then rounded to the format
	--!						of the result.
	--! \param a			Input a
	--! \param a_fmt		Format of a
	--! \param b			Input b
	--! \param b_fmt		Format of b
	--! \param result_fmt	Format of the result
	--! \param round		Rounding mode
	--! \param saturate		Saturation mode
	--! \return				Mean value of a and b ((a+b)/2)
	--! \see 				FixRound_t
	--! \see				FixSaturate_t	
	function cl_fix_mean (	a			: std_logic_vector; 
							a_fmt		: FixFormat_t; 
							b			: std_logic_vector; 
							b_fmt		: FixFormat_t; 
							result_fmt	: FixFormat_t; 
							round		: FixRound_t	:= Trunc_s; 
							saturate	: FixSaturate_t := Warn_s) 
							return std_logic_vector;

	--! \brief				Calculate the mean value of two fix-point modulo numbers
	--! \details			Inputs are interpreted as angles or oder numbers with modulo property.\n
	--!						The calculation is executed with inifinite precision and then rounded to the format
	--!						of the result.
	--! \param a			Input a
	--! \param a_fmt		Format of a
	--! \param b			Input b
	--! \param b_fmt		Format of b
	--! \param precise		true = calculation is performed with full precision\n
	--!						false = modulo handling only takes into account the quadrants of a and b
	--! \param result_fmt	Format of the result
	--! \param round		Rounding mode
	--! \param saturate		Saturation mode
	--! \return				Mean value of a and b ((a+b)/2)
	--! \see 				FixRound_t
	--! \see				FixSaturate_t		
	function cl_fix_mean_angle (	a			: std_logic_vector; 
									a_fmt		: FixFormat_t; 
									b			: std_logic_vector; 
									b_fmt		: FixFormat_t; 
									precise		: boolean;
									result_fmt	: FixFormat_t; 
									round		: FixRound_t	:= Trunc_s; 
									saturate	: FixSaturate_t := Warn_s) 
									return std_logic_vector;
	--! \brief				Left shift of a fix-point number
	--! \details			Can be used to calculate 2^shift
	--! \param a			Input a
	--! \param a_fmt		Format of a
	--! \param shift		Number of bits to shift
	--! \param result_fmt	Format of the result
	--! \param round		Rounding mode
	--! \param saturate		Saturation mode
	--! \return				Result of the shift operation (a_fmt is used as format for the result)
	--! \see 				FixRound_t
	--! \see				FixSaturate_t	
	function cl_fix_shift (	a			: std_logic_vector; 
							a_fmt		: FixFormat_t; 
							shift		: integer;
							result_fmt	: FixFormat_t; 
							round		: FixRound_t	:= Trunc_s; 
							saturate	: FixSaturate_t := Warn_s) 
							return std_logic_vector;
		
	--! \brief				Multiplication of two fix-point numbers
	--! \details			The calculation is executed with inifinite precision and then rounded to the format
	--!						of the result.	
	--! \param a			Input a
	--! \param a_fmt		Format of a
	--! \param b			Input b
	--! \param b_fmt		Format of b	
	--! \param result_fmt	Format of the result	
	--! \param round		Rounding mode
	--! \param saturate		Saturation mode
	--! \return				Result of the multiplication
	--! \see 				FixRound_t
	--! \see				FixSaturate_t		
	function cl_fix_mult (	a			: std_logic_vector; 
							a_fmt		: FixFormat_t; 
							b			: std_logic_vector; 
							b_fmt		: FixFormat_t; 
							result_fmt	: FixFormat_t; 
							round		: FixRound_t	:= Trunc_s; 
							saturate	: FixSaturate_t := Warn_s) 
							return std_logic_vector;
							
	--! \brief				Compare two fixed point numbers (the format can be different)
	--! \param comparison	Type of the comparison ("a=b", "a<b", "a>b", "a<=b", "a>=b", "a!=b")
	--! \param a			Input A
	--! \param aFmt			Format of input A
	--! \param b 			Input B
	--! \param bFmt			Format of input B
	--! \return				Result of comparison 
	function cl_fix_compare(	comparison	: string;
								a			: std_logic_vector;
								aFmt		: FixFormat_t;
								b			: std_logic_vector;
								bFmt		: FixFormat_t) return boolean;							
		
end package;

---------------------------------------------------------------------------------------------------
-- Package Body
---------------------------------------------------------------------------------------------------
--! \brief Package Body
package body en_cl_fix_pkg is

	-----------------------------------------------------------------------------------------------
	-- Internally used constants
	-----------------------------------------------------------------------------------------------
	subtype HexCharacter_t is string (1 to 16);
	constant HexCharacter_c : HexCharacter_t := "0123456789ABCDEF";
	
	type StdLogicCharacter_t is array (natural range <>) of character;
	constant StdLogicCharacter_c : StdLogicCharacter_t (0 to 8) := 
		('U', 'X', '0', '1', 'Z', 'W', 'L', 'H', '-');
		
	-----------------------------------------------------------------------------------------------
	-- Internally used functions
	-----------------------------------------------------------------------------------------------
	
	-----------------------------------------------------------------------------------------------	
	--! max implementation
	function max (	a, b 	: integer) 
					return integer is
	begin
		if a >= b then
			return a;
		else
			return b;
		end if;
	end;
	
	-----------------------------------------------------------------------------------------------	
	--! min implementation	
	function min (	a, b 	: integer) 
					return integer is
	begin
		if a <= b then
			return a;
		else
			return b;
		end if;
	end;
	
	-----------------------------------------------------------------------------------------------	
	--! to01 implementation	
	function to01 (	sl 	: std_logic) 
					return std_logic is
		variable result_v : std_logic;
	begin
		if sl = '1' or sl = 'H' then
			result_v := '1';
		else
			result_v := '0';
		end if;
		return result_v;
	end;
	
	-----------------------------------------------------------------------------------------------	
	--! toInteger implementation		
	function toInteger (	bool 	: boolean) 
							return integer is
	begin
		if bool then
			return 1;
		else
			return 0;
		end if;
	end;

	-----------------------------------------------------------------------------------------------	
	--! string_find_next_match implementation (for character)	
	function string_find_next_match(	Str			: string;	
										Char		: character;
										StartIdx	: natural)
										return integer is
		variable CurrentIdx_v		: integer := StartIdx;
		variable Match_v			: boolean := false;
		variable MatchIdx_v			: integer := -1;
	begin
		-- Checks
		assert StartIdx <= Str'high and StartIdx >= Str'low report "string_find_next_match: StartIdx out of range" severity error;
		
		-- Implementation
		while (not Match_v) and (CurrentIdx_v <= Str'high) loop
			if Str(CurrentIdx_v) = Char then
				Match_v 	:= true;
				MatchIdx_v 	:= CurrentIdx_v;
			end if;
			CurrentIdx_v := CurrentIdx_v + 1;
		end loop;
		return MatchIdx_v;
	end function;

	-----------------------------------------------------------------------------------------------	
	--! string_find_next_match implementation (for string)	
	function string_find_next_match(	Str			: string;
										Pattern		: string;
										StartIdx	: natural)
											return integer is
		variable CurrentIdx_v		: integer := StartIdx;
		variable Match_v			: boolean := false;
		variable MatchIdx_v			: integer := -1;											
	begin
		-- Checks
		assert StartIdx <= Str'high and StartIdx >= Str'low report "string_find_next_match: StartIdx out of range" severity error;
		
		-- Implementation
		while (not Match_v) and (CurrentIdx_v-1 <= Str'length-Pattern'length) loop
			Match_v 	:= true;
			for Idx in 1 to Pattern'length loop
				if Str(CurrentIdx_v+Idx-1) /= Pattern(Idx) then
					Match_v := false;
					exit;
				end if;
			end loop;
			if Match_v then
				MatchIdx_v := CurrentIdx_v;
			end if;
			CurrentIdx_v := CurrentIdx_v + 1;
		end loop;
		return MatchIdx_v;
	end function;	
	
	-----------------------------------------------------------------------------------------------	
	--! string_parse_boolean implementation		
	function string_parse_boolean(	Str			: string;
									StartIdx	: natural)
									return boolean is
			variable TrueIdx_v	: integer;
			variable FalseIdx_v	: integer;
		begin
			-- Checks
			assert StartIdx <= Str'high and StartIdx >= Str'low report "en_cl_string_parse_boolean: StartIdx out of range" severity error;
			
			-- Implementation
			TrueIdx_v 	:= string_find_next_match(Str, "true", StartIdx);
			FalseIdx_v	:= string_find_next_match(Str, "false", StartIdx);
			if TrueIdx_v = -1 then
				if FalseIdx_v = -1 then
					report "string_parse_boolean: no boolean string found" severity error;
					return false;
				else
					return false;
				end if;
			elsif FalseIdx_v = -1 then
				return true;
			else
				return (TrueIdx_v < FalseIdx_v);
			end if;	
	end function;	
	
	-----------------------------------------------------------------------------------------------	
	--! string_int_from_char implementation	
	function string_int_from_char(	Char : character) 
											return integer is
	begin
		case Char is
			when '0'	=> return 0;
			when '1'	=> return 1;
			when '2'	=> return 2;
			when '3'	=> return 3;
			when '4' 	=> return 4;
			when '5'	=> return 5;
			when '6' 	=> return 6;
			when '7'	=> return 7;
			when '8'	=> return 8;
			when '9'	=> return 9;
			when others	=> return -1;
		end case;
		return 0;
	end function;
	
	-----------------------------------------------------------------------------------------------	
	--! string_char_is_numeric implementation
	function string_char_is_numeric(	Char : character)
											return boolean is
	begin
		return string_int_from_char(Char) /= -1;
	end function;	
	
	-----------------------------------------------------------------------------------------------	
	--! string_parse_int implementation		
	function string_parse_int(	Str			: string;
								StartIdx	: natural)
								return integer is
		variable CurrentIdx_v		: integer	:= StartIdx;
		variable IsNegative_v		: boolean	:= false;
		variable AbsoluteVal_v		: integer	:= 0;
	begin
		-- Checks
		assert StartIdx <= Str'high and StartIdx >= Str'low report "string_parse_int: StartIdx out of range" severity error;
		
		-- remove leading spaces
		while Str(CurrentIdx_v) = ' ' loop
			CurrentIdx_v := CurrentIdx_v + 1;
		end loop;
		
		-- Detect negative numbers
		if Str(CurrentIdx_v) = '-' then
			IsNegative_v := true;
			CurrentIdx_v := CurrentIdx_v + 1;
		end if;
		
		-- Parse absolute value
		while (CurrentIdx_v <= Str'high) loop
			if not string_char_is_numeric(Str(CurrentIdx_v)) then
				CurrentIdx_v := Str'high+1;
			else
				AbsoluteVal_v := AbsoluteVal_v * 10 + string_int_from_char(Str(CurrentIdx_v));
				CurrentIdx_v := CurrentIdx_v + 1;
			end if;
		end loop;
		
		-- Return number with correct sign
		if IsNegative_v then
			return -AbsoluteVal_v;
		else
			return AbsoluteVal_v;
		end if;		
	end function;	

	-----------------------------------------------------------------------------------------------	
	--! toString implementation			
	function toString (value : std_logic_vector) return string is
		variable s			: string (1 to value'length);
		variable value_i	: std_logic_vector (value'length-1 downto 0);
	begin
		value_i := value;
		for ptr in 1 to value'length loop
			s (ptr) := StdLogicCharacter_c (std_logic'pos (value_i (value'length-ptr)));
		end loop;
		return s;
	end;
	
	-----------------------------------------------------------------------------------------------	
	--! toHexString implementation			
	function toHexString (value : std_logic_vector) return string is
		variable s			: string (1 to (value'length-1)/4+1);
		variable value_i	: bit_vector ((value'length-1)/4*4+3 downto 0);
	begin
		value_i := (others => '0');
		value_i (value'length-1 downto 0) := to_bitvector (value);
		for ptr in 1 to s'length loop
			s (ptr) := HexCharacter_c (to_integer ('0' & unsigned (to_stdlogicvector (
				value_i ((s'length-ptr)*4+3 downto (s'length-ptr)*4)))+1));
		end loop;
		return s;
	end;	
	
	-----------------------------------------------------------------------------------------------
	-- Public Functions
	-----------------------------------------------------------------------------------------------	
	
	-----------------------------------------------------------------------------------------------	
	--! cl_fix_format implementation	
	function cl_fix_format (	signed 		: boolean;
								intBits		: integer;
								fracBits	: integer) 
								return FixFormat_t is
		variable result_v : FixFormat_t;
	begin
		assert intBits + fracBits >= 1
			report "cl_fix_format : The sum of 'intBits' and 'fracBits' must be at least 1!"
			severity failure;

		result_v.Signed := signed;
		result_v.IntBits := intBits;
		result_v.FracBits := fracBits;
		return result_v;
	end;
	
	-----------------------------------------------------------------------------------------------	
	--! cl_fix_width implementation	
	function cl_fix_width (	fmt 	: FixFormat_t) 
							return positive is
	begin
		assert (fmt.IntBits+fmt.FracBits) > 0
			report "cl_fix_width : The sum of 'IntBits' and 'FracBits' must be at least 1!"
			severity failure;

		return toInteger(fmt.Signed)+fmt.IntBits+fmt.FracBits;
	end;
	
	-----------------------------------------------------------------------------------------------	
	--! cl_fix_string_from_format implementation	
	function cl_fix_string_from_format (	fmt 	: FixFormat_t) 
											return string is
	begin
		return "(" & boolean'image(fmt.Signed) & "," & integer'image(fmt.IntBits) & "," & integer'image(fmt.FracBits) & ")";
	end;
	
	-----------------------------------------------------------------------------------------------	
	--! cl_fix_format_from_string Implementation
	function cl_fix_format_from_string(	Str	: string) 
										return FixFormat_t is
		variable Format_v 	: FixFormat_t;
		variable Index_v	: integer;
	begin
		-- Parse Format
		Index_v := Str'low;
		Index_v := string_find_next_match(Str, '(', Index_v);
		assert Index_v > 0 
			report "cl_fix_string_from_format: wrong Format, missing '('" 
			severity error;
		Format_v.Signed := string_parse_boolean(Str, Index_v+1);
		Index_v := string_find_next_match(Str, ',', Index_v+1);
		assert Index_v > 0 
			report "cl_fix_string_from_format: wrong Format, missing ',' between IsSigned and IntBits " 
			severity error;
		Format_v.IntBits := string_parse_int(Str, Index_v+1);
		Index_v := string_find_next_match(Str, ',', Index_v+1);
		assert Index_v > 0 
			report "cl_fix_string_from_format: wrong Format, missing ',' between IntBits and FracBits " 
			severity error;
		Format_v.FracBits := string_parse_int(Str, Index_v+1);
		Index_v := string_find_next_match(Str, ')', Index_v+1);
		assert Index_v > 0 
			report "cl_fix_string_from_format: wrong Format, missing ')'" 
			severity error;	
		return Format_v;
	end function;	
	
	-----------------------------------------------------------------------------------------------	
	--! cl_fix_zero_value implementation
	function cl_fix_zero_value (	fmt 	: FixFormat_t) 
									return std_logic_vector is
		variable result_v : std_logic_vector (cl_fix_width (fmt)-1 downto 0);
	begin
		result_v := (others => '0');
		return result_v;
	end;
	
	-----------------------------------------------------------------------------------------------	
	--! cl_fix_max_value implementation	
	function cl_fix_max_value (	fmt 	: FixFormat_t) 
								return std_logic_vector is
		variable result_v : std_logic_vector (cl_fix_width (fmt)-1 downto 0);
	begin
		result_v := (others => '1');
		if fmt.Signed then
			result_v (result_v'high) := '0';
		end if;
		return result_v;
	end;
	
	-----------------------------------------------------------------------------------------------	
	--! cl_fix_max_value implementation		
	function cl_fix_min_value (	fmt : FixFormat_t) 
								return std_logic_vector is 
		variable result_v : std_logic_vector (cl_fix_width (fmt)-1 downto 0);
	begin
		if fmt.Signed then
			result_v := (others => '0');
			result_v(result_v'left) := '1';
		else
			result_v := (others => '0');
		end if;
		return result_v;
	end;
	
	-----------------------------------------------------------------------------------------------	
	--! cl_fix_max_real	implementation		
	function cl_fix_max_real(	fmt 	: FixFormat_t)
								return real is
		variable Range_v, Lsb_v : real;
	begin
		if fmt.IntBits >= 0 then
			Range_v := real(2**fmt.IntBits);
		else
			Range_v := 1.0/(real(2**(-fmt.IntBits)));
		end if;
		if fmt.FracBits >= 0 then
			Lsb_v := 1.0/real(2**fmt.FracBits);
		else
			Lsb_v := real(2**(-fmt.FracBits));
		end if;		
		return Range_v-Lsb_v;
	end function;
		
	-----------------------------------------------------------------------------------------------	
	--! cl_fix_min_real implementation		
	function cl_fix_min_real(	fmt 	: FixFormat_t)
								return real is
		variable Range_v : real;
	begin
		if fmt.Signed then
			if fmt.IntBits >= 0 then
				Range_v := real(2**fmt.IntBits);
			else
				Range_v := 1.0/(real(2**(-fmt.IntBits)));
			end if;
			return -Range_v;
		else
			return 0.0;
		end if;
	end function;	
	
	-----------------------------------------------------------------------------------------------	
	--! cl_fix_sign implementation		
	function cl_fix_sign (	a 		: std_logic_vector; 
							a_fmt 	: FixFormat_t) 
							return std_logic is
		variable a_v : std_logic_vector (a'length-1 downto 0);
	begin
		a_v := a;
		if a_fmt.Signed then
			return a_v (a_v'high);
		else
			return '0';
		end if;
	end;
	
	-----------------------------------------------------------------------------------------------	
	--! cl_fix_int implementation		
	function cl_fix_int (	a 		: std_logic_vector; 
							a_fmt 	: FixFormat_t) 
			return std_logic_vector is
		variable a_v		: std_logic_vector (a'length-1 downto 0);
		variable result_v	: std_logic_vector (max (1, a_fmt.IntBits)-1 downto 0);
	begin
		a_v := a;
		result_v := (others => '0');
		if a_fmt.IntBits > 0 then
			if a_fmt.FracBits >= 0 then
				result_v (a_fmt.IntBits-1 downto 0) :=
					a_v (a_fmt.IntBits+a_fmt.FracBits-1 downto a_fmt.FracBits);
			else
				result_v (a_fmt.IntBits-1 downto -a_fmt.FracBits) :=
					a_v (a_fmt.IntBits-1 downto -a_fmt.FracBits);
			end if;
		end if;
		return result_v;
	end;
	
	-----------------------------------------------------------------------------------------------	
	--! cl_fix_frac implementation		
	function cl_fix_frac (	a 		: std_logic_vector; 
							a_fmt 	: FixFormat_t) 
			return std_logic_vector is
		variable a_v		: std_logic_vector (a'length-1 downto 0);
		variable result_v	: std_logic_vector (max (1, a_fmt.FracBits)-1 downto 0);
	begin
		a_v := a;
		result_v := (others => '0');
		if a_fmt.FracBits > 0 then
			if a_fmt.IntBits >= 0 then
				result_v (a_fmt.FracBits-1 downto 0) :=
					a_v (a_fmt.FracBits-1 downto 0);
			else
				result_v (a_fmt.FracBits+a_fmt.IntBits-1 downto 0) :=
					a_v (a_fmt.FracBits+a_fmt.IntBits-1 downto 0);
			end if;
		end if;
		return result_v;
	end;
	
	-----------------------------------------------------------------------------------------------	
	--! cl_fix_combine implementation		
	function cl_fix_combine (	sign		: std_logic; 
								int			: std_logic_vector; 
								frac		: std_logic_vector;
								result_fmt	: FixFormat_t) 
								return std_logic_vector is
		variable int_v : std_logic_vector (int'length-1 downto 0);
		variable frac_v : std_logic_vector (frac'length-1 downto 0);
		variable result_v : std_logic_vector (cl_fix_width (result_fmt)-1 downto 0);
	begin
		int_v := int;
		frac_v := frac;
		result_v := (others => '0');
		if result_fmt.Signed then
			if result_fmt.IntBits > 0 then
				if result_fmt.FracBits > 0 then
					result_v := sign & int_v (result_fmt.IntBits-1 downto 0) & 
						frac_v (result_fmt.FracBits-1 downto 0);
				else
					result_v := sign & int_v (result_fmt.IntBits-1 downto -result_fmt.FracBits);
				end if;
			else
				result_v := sign & frac_v (result_fmt.FracBits+result_fmt.IntBits-1 downto 0);
			end if;
		else
			assert sign = '0'
				report "cl_fix_combine : sign may not be set for an unsigned format!"
				severity failure;
			if result_fmt.IntBits > 0 then
				if result_fmt.FracBits > 0 then
					result_v := int_v (result_fmt.IntBits-1 downto 0) & 
						frac_v (result_fmt.FracBits-1 downto 0);
				else
					result_v := int_v (result_fmt.IntBits-1 downto -result_fmt.FracBits);
				end if;
			else
				result_v := frac_v (result_fmt.FracBits+result_fmt.IntBits-1 downto 0);
			end if;
		end if;
		return result_v;
	end;
	
	-----------------------------------------------------------------------------------------------	
	--! cl_fix_get_msb implementation	
	function cl_fix_get_msb (	a		: std_logic_vector;
								a_fmt	: FixFormat_t;
								index	: natural) 
								return std_logic is
	begin
		return a (a'high-index);
	end;
	
	-----------------------------------------------------------------------------------------------	
	--! cl_fix_get_lsb implementation		
	function cl_fix_get_lsb (	a		: std_logic_vector;
								a_fmt	: FixFormat_t;
								index	: natural) 
								return std_logic is
	begin
		return a (index);
	end;
	
	-----------------------------------------------------------------------------------------------	
	--! cl_fix_set_msb implementation		
	function cl_fix_set_msb (	a			: std_logic_vector; 
								a_fmt		: FixFormat_t; 
								index		: natural;
								value		: std_logic) 
								return std_logic_vector is
		variable a_v : std_logic_vector (a'length-1 downto 0);
	begin
		a_v := a;
		a_v (a_v'high-index) := value;
		return a_v;
	end;
	
	-----------------------------------------------------------------------------------------------	
	--! cl_fix_set_lsb implementation			
	function cl_fix_set_lsb (	a			: std_logic_vector; 
								a_fmt		: FixFormat_t; 
								index		: natural;
								value		: std_logic) 
								return std_logic_vector is
		variable a_v : std_logic_vector (a'length-1 downto 0);
	begin
		a_v := a;
		a_v (index) := value;
		return a_v;
	end;

	-----------------------------------------------------------------------------------------------	
	--! cl_fix_from_int implementation	
	function cl_fix_from_int (	a			: integer; 
								result_fmt	: FixFormat_t; 
								saturate	: FixSaturate_t := SatWarn_s) 
								return std_logic_vector is
		variable a_v		: integer;
		variable result_v	: std_logic_vector (cl_fix_width (result_fmt)-1 downto 0);
	begin
		result_v := (others => '0');
		a_v := a;
		if result_fmt.Signed then
			assert not ((saturate = Warn_s or saturate = SatWarn_s) and 
					(a_v >= 2**result_fmt.IntBits or a_v < -2**result_fmt.IntBits))
				report "cl_fix_from_int : Saturation Warning!" 
				severity warning;
			if saturate = Sat_s or saturate = SatWarn_s then
				a_v := max (min (a_v, 2**result_fmt.IntBits-1), -2**result_fmt.IntBits);
			end if;
			result_v (result_v'high downto result_fmt.FracBits) := 
				std_logic_vector (to_signed (a_v, result_fmt.IntBits+1));
		else
			assert not ((saturate = Warn_s or saturate = SatWarn_s) and (a_v >= 2**result_fmt.IntBits or a_v < 0))
				report "cl_fix_from_int : Saturation Warning!" 
				severity warning;
			if saturate = Sat_s or saturate = SatWarn_s then
				a_v := max (min (a_v, 2**result_fmt.IntBits-1), 0);
			end if;
			result_v (result_v'high downto result_fmt.FracBits) := 
				std_logic_vector(to_unsigned (a_v, result_fmt.IntBits));
		end if;
		return result_v;
	end;
	
	-----------------------------------------------------------------------------------------------	
	--! cl_fix_to_int implementation		
	function cl_fix_to_int (	a 		: std_logic_vector; 
								a_fmt 	: FixFormat_t) 
								return integer is
		variable a_v : std_logic_vector (a'length-1 downto 0);
	begin
		a_v := a;
		-- TODO: range check on a!
		if a_fmt.Signed then
			if a_fmt.IntBits > 0 then
				if a_fmt.FracBits >= 0 then
					return to_integer (signed (a_v (a_v'high downto a_fmt.FracBits)));
				else
					return to_integer (signed (a_v)) * 2**(-a_fmt.FracBits);
				end if;
			else
				return 0;
			end if;
		else
			if a_fmt.IntBits > 0 then
				if a_fmt.FracBits >= 0 then
					return to_integer (unsigned (a_v (a_v'high downto a_fmt.FracBits)));
				else
					return to_integer (unsigned (a_v)) * 2**(-a_fmt.FracBits);
				end if;
			else
				return 0;
			end if;
		end if;
	end;
	
	-----------------------------------------------------------------------------------------------	
	--! cl_fix_from_real implementation	
	function cl_fix_from_real (	a			: real; 
								result_fmt	: FixFormat_t;
								saturate	: FixSaturate_t := SatWarn_s) 
								return std_logic_vector is
		constant TempFmt_c 	: FixFormat_t := 
			(
				Signed		=> result_fmt.Signed,
				IntBits		=> result_fmt.IntBits+result_fmt.FracBits, 
				FracBits	=> 0
			);
		constant Fmt31Bits_c 	: FixFormat_t := 
			(
				Signed		=> result_fmt.Signed,
				IntBits		=> result_fmt.IntBits,
				FracBits	=> 31-toInteger(result_fmt.Signed)-result_fmt.IntBits
			);
		constant Appendix31Bits_c	: std_logic_vector(cl_fix_width(result_fmt)-31-1 downto 0) := (others => '0');
		variable temp_v : integer;
		variable frac_v : real;
		variable ASat_v : real; 
	begin
		-- In this case, the conversion can be done with full precision
		if (result_fmt.IntBits + result_fmt.FracBits <= 31) then
			-- Limit
			if a > cl_fix_max_real(result_fmt) then	
				ASat_v := cl_fix_max_real(result_fmt);
			elsif a < cl_fix_min_real(result_fmt) then
				ASat_v := cl_fix_min_real(result_fmt);
			else
				ASat_v := a;
			end if;		
			-- Convert to fixed
			temp_v := integer (ASat_v * 2.0**result_fmt.FracBits);	-- as, 
			if result_fmt.Signed then
				return std_logic_vector(to_signed(temp_v, cl_fix_width(result_fmt)));
			else
				return std_logic_vector(to_unsigned(temp_v, cl_fix_width(result_fmt)));
			end if;
		-- In this case, the higher 31 bits are converted correctly and the lower bits are filled with zeros
		-- ... this is not precise but at least roughly correct.
		else
			report "cl_fix_from_real : Word width > 31 bits leads to imprecise results" severity warning;
			return cl_fix_from_real(a, Fmt31Bits_c, saturate) & Appendix31Bits_c;
		end if;
	end;
	
	-----------------------------------------------------------------------------------------------	
	--! cl_fix_to_real implementation		
	function cl_fix_to_real (	a 		: std_logic_vector; 
								a_fmt 	: FixFormat_t) 
								return real is
		variable a_v		: std_logic_vector (a'length-1 downto 0);
		variable result_v	: real;
	begin
		a_v := a;
		if a_fmt.Signed then
			result_v := real (to_integer (signed (a_v))) * real (2.0**(-a_fmt.FracBits));
		else
			result_v := real (to_integer (unsigned (a_v))) * real (2.0**(-a_fmt.FracBits));
		end if;
		return result_v;
	end;
	
	-----------------------------------------------------------------------------------------------	
	--! cl_fix_from_bin implementation	
	function cl_fix_from_bin (	a			: string; 
								result_fmt	: FixFormat_t) 
								return std_logic_vector is
		variable a_v : string (1 to a'length);
		variable result_v : std_logic_vector (a'length-1 downto 0);
		variable pos_v : natural;
	begin
		a_v := a;
		pos_v := a'length;
		for i in 1 to a'length loop
			case a_v (i) is
			when '0' =>
				pos_v := pos_v - 1;
				result_v (pos_v) := '0';
			when '1' =>
				pos_v := pos_v - 1;
				result_v (pos_v) := '1';
			when 'b' | 'B'  =>
				if i = 2 and a_v (1) = '0' then
					pos_v := a'length;
				end if;
			when '_' =>
			when others =>
				report "cl_fix_from_bin : Illegal character in binary string!" 
					severity error;
			end case;
		end loop;
		assert a'length-pos_v = cl_fix_width (result_fmt);
			report "cl_fix_from_bin : The binary string doesn't have the correct length!" 
			severity error;
		return result_v (a'length-1 downto pos_v);
	end;
	
	-----------------------------------------------------------------------------------------------	
	--! cl_fix_to_bin implementation		
	function cl_fix_to_bin (	a			: std_logic_vector; 
								a_fmt		: FixFormat_t) 
								return string is
	begin
		return toString(a);
	end;
	
	-----------------------------------------------------------------------------------------------	
	--! cl_fix_from_hex implementation		
	function cl_fix_from_hex (	a			: string; 
								result_fmt	: FixFormat_t) 
								return std_logic_vector is
		constant ResultWidth_c : positive := cl_fix_width (result_fmt);
		variable a_v : string (1 to a'length);
		variable result_v : std_logic_vector (a'length*4-1 downto 0);
		variable pos_v : natural;
	begin
		a_v := a;
		pos_v := a'length;
		for i in 1 to a_v'length loop
			case a_v (i) is
			when '0'		=> result_v (pos_v*4+3 downto pos_v*4) := "0000"; pos_v := pos_v - 1;
			when '1'		=> result_v (pos_v*4+3 downto pos_v*4) := "0001"; pos_v := pos_v - 1;
			when '2'		=> result_v (pos_v*4+3 downto pos_v*4) := "0010"; pos_v := pos_v - 1;
			when '3'		=> result_v (pos_v*4+3 downto pos_v*4) := "0011"; pos_v := pos_v - 1;
			when '4'		=> result_v (pos_v*4+3 downto pos_v*4) := "0100"; pos_v := pos_v - 1;
			when '5'		=> result_v (pos_v*4+3 downto pos_v*4) := "0101"; pos_v := pos_v - 1;
			when '6'		=> result_v (pos_v*4+3 downto pos_v*4) := "0110"; pos_v := pos_v - 1;
			when '7'		=> result_v (pos_v*4+3 downto pos_v*4) := "0111"; pos_v := pos_v - 1;
			when '8'		=> result_v (pos_v*4+3 downto pos_v*4) := "1000"; pos_v := pos_v - 1;
			when '9'		=> result_v (pos_v*4+3 downto pos_v*4) := "1001"; pos_v := pos_v - 1;
			when 'a' | 'A'	=> result_v (pos_v*4+3 downto pos_v*4) := "1010"; pos_v := pos_v - 1;
			when 'b' | 'B'	=> result_v (pos_v*4+3 downto pos_v*4) := "1011"; pos_v := pos_v - 1;
			when 'c' | 'C'	=> result_v (pos_v*4+3 downto pos_v*4) := "1100"; pos_v := pos_v - 1;
			when 'd' | 'D'	=> result_v (pos_v*4+3 downto pos_v*4) := "1101"; pos_v := pos_v - 1;
			when 'e' | 'E'	=> result_v (pos_v*4+3 downto pos_v*4) := "1110"; pos_v := pos_v - 1;
			when 'f' | 'F'	=> result_v (pos_v*4+3 downto pos_v*4) := "1111"; pos_v := pos_v - 1;
			when 'x' | 'X'  =>
				if i = 2 and a_v (1) = '0' then
					pos_v := a'length;
				end if;
			when '_' =>
			when others =>
				report "cl_fix_from_hex : Illegal character in hexadecimal string!" 
					severity error;
			end case;
		end loop;
		assert 4*(a'length-pos_v) >= ResultWidth_c and 4*(a'length-pos_v-1) < ResultWidth_c;
			report "cl_fix_from_hex : The hexadecimal string doesn't have the correct length!" 
			severity error;
		if ResultWidth_c/4*4 < ResultWidth_c then
			assert unsigned (result_v (a'length*4-1 downto pos_v*4+ResultWidth_c)) = 0
				report "cl_fix_from_hex : The unused bits in the hexadecimal string are not all equal to zero!" 
				severity error;
		end if;
		return result_v (pos_v*4+ResultWidth_c-1 downto pos_v*4);
	end;
	
	-----------------------------------------------------------------------------------------------	
	--! cl_fix_to_hex implementation		
	function cl_fix_to_hex (	a			: std_logic_vector; 
								a_fmt		: FixFormat_t) 
								return string is
	begin
		return toHexString (a);
	end;
	
	-----------------------------------------------------------------------------------------------	
	--! cl_fix_from_bits_as_int implementation	
	function cl_fix_from_bits_as_int(	a 		: integer;
										aFmt 	: FixFormat_t)
										return std_logic_vector is
	begin
		if aFmt.Signed then
			return std_logic_vector(to_signed(a, cl_fix_width(aFmt)));
		else
			return std_logic_vector(to_unsigned(a, cl_fix_width(aFmt)));
		end if;
	end function;
	
	-----------------------------------------------------------------------------------------------	
	--! cl_fix_to_hex implementation	
	function cl_fix_get_bits_as_int(	a		: std_logic_vector;
										aFmt	: FixFormat_t)
										return integer is
	begin
		if aFmt.Signed then
			return to_integer(signed(a));
		else
			return to_integer(unsigned(a));
		end if;
	end function;	
	
	-----------------------------------------------------------------------------------------------	
	--! cl_fix_read_int implementation
	impure function cl_fix_read_int (	file a		: text; 
										result_fmt	: FixFormat_t;
										saturate	: FixSaturate_t := SatWarn_s) 
										return std_logic_vector is
		constant TempFmt_c 	: FixFormat_t := 
			(
				Signed		=> result_fmt.Signed,
				IntBits		=> result_fmt.IntBits+result_fmt.FracBits, 
				FracBits	=> 0
			);
		variable line_v		: line;
		variable ok_v		: boolean;
		variable temp_v		: integer;
		variable result_v	: std_logic_vector (cl_fix_width(result_fmt)-1 downto 0);
	begin
		readline(a, line_v);
		read(line_v, temp_v, ok_v);
		if ok_v then
			result_v := cl_fix_from_int (temp_v, TempFmt_c, saturate);
		else
			assert false 
				report "cl_fix_read_int : Could not read from stimuli file!" 
				severity error;
		end if;
		return result_v;
	end;
	
	-----------------------------------------------------------------------------------------------	
	--! cl_fix_read_real implementation	
	impure function cl_fix_read_real (	file a		: text; 
										result_fmt	: FixFormat_t;
										saturate	: FixSaturate_t := SatWarn_s) 
										return std_logic_vector is
		variable line_v		: line;
		variable ok_v		: boolean;
		variable temp_v		: real;
		variable result_v	: std_logic_vector (cl_fix_width (result_fmt)-1 downto 0);
	begin
		readline(a, line_v);
		read(line_v, temp_v, ok_v);
		if ok_v then
			result_v := cl_fix_from_real (temp_v, result_fmt, saturate);
		else
			assert false 
				report "cl_fix_read_real : Could not read from stimuli fil\EB!" 
				severity error;
		end if;
		return result_v;
	end;
	
	-----------------------------------------------------------------------------------------------	
	--! cl_fix_read_bin implementation		
	impure function cl_fix_read_bin (	file a		: text; 
										result_fmt	: FixFormat_t) 
										return std_logic_vector is
		variable line_v		: line;
		variable ok_v		: boolean;
		variable temp_v		: string (cl_fix_width (result_fmt)-1 downto 0);
		variable result_v	: std_logic_vector (cl_fix_width (result_fmt)-1 downto 0);
	begin
		readline(a, line_v);
		read(line_v, temp_v, ok_v);
		if ok_v then
			result_v := cl_fix_from_bin (temp_v, result_fmt);
		else
			assert false 
				report "cl_fix_read_bin : Could not read from stimuli fil\EB!" 
				severity error;
		end if;
		return result_v;
	end;
	
	-----------------------------------------------------------------------------------------------	
	--! cl_fix_read_hex implementation		
	impure function cl_fix_read_hex (	file a		: text; 
										result_fmt	: FixFormat_t) 
										return std_logic_vector is
		variable line_v		: line;
		variable ok_v		: boolean;
		variable temp_v		: string (cl_fix_width (result_fmt)-1 downto 0);
		variable result_v	: std_logic_vector (cl_fix_width (result_fmt)-1 downto 0);
	begin
		readline(a, line_v);
		read(line_v, temp_v, ok_v);
		if ok_v then
			result_v := cl_fix_from_hex (temp_v, result_fmt);
		else
			assert false 
				report "cl_fix_read_hex : Could not read from stimuli fil\EB!" 
				severity error;
		end if;
		return result_v;
	end;
	
	-----------------------------------------------------------------------------------------------	
	--! cl_fix_write_int implementation	
	procedure cl_fix_write_int (	a			: std_logic_vector; 
									a_fmt		: FixFormat_t;
									file f		: text;
									f_fmt		: FixFormat_t;
									round		: FixRound_t	:= Trunc_s; 
									saturate	: FixSaturate_t	:= Warn_s) is
		variable line_v 	: line;
		variable temp_v		: integer;
		variable f_v		: std_logic_vector (cl_fix_width (f_fmt)-1 downto 0);
	begin
		f_v := cl_fix_resize (a, a_fmt, f_fmt, round, saturate);
		if f_fmt.Signed then
			temp_v	:= to_integer (signed (f_v));
		else
			temp_v	:= to_integer (unsigned (f_v));
		end if;
		write (line_v, temp_v);
		writeline (f, line_v);
	end;
	
	-----------------------------------------------------------------------------------------------	
	--! cl_fix_write_real implementation		
	procedure cl_fix_write_real (	a			: std_logic_vector; 
									a_fmt		: FixFormat_t;
									file f		: text;
									f_fmt		: FixFormat_t;
									round		: FixRound_t	:= Trunc_s; 
									saturate	: FixSaturate_t	:= Warn_s) is
		variable line_v 	: line;
		variable temp_v		: real;
		variable f_v		: std_logic_vector (cl_fix_width (f_fmt)-1 downto 0);
	begin
		f_v := cl_fix_resize (a, a_fmt, f_fmt, round, saturate);
		temp_v	:= cl_fix_to_real (f_v, f_fmt);
		write (line_v, real'image(temp_v));
		writeline (f, line_v);
	end;
	
	-----------------------------------------------------------------------------------------------	
	--! cl_fix_write_bin implementation		
	procedure cl_fix_write_bin (	a			: std_logic_vector; 
									a_fmt		: FixFormat_t;
									file f		: text;
									f_fmt		: FixFormat_t;
									round		: FixRound_t	:= Trunc_s; 
									saturate	: FixSaturate_t	:= Warn_s) is
		variable line_v 	: line;
		variable temp_v		: string (1 to cl_fix_width (f_fmt));
		variable f_v		: std_logic_vector (cl_fix_width (f_fmt)-1 downto 0);
	begin
		f_v := cl_fix_resize (a, a_fmt, f_fmt, round, saturate);
		temp_v	:= cl_fix_to_bin (f_v, f_fmt);
		write (line_v, temp_v);
		writeline (f, line_v);
	end;
	
	-----------------------------------------------------------------------------------------------	
	--! cl_fix_write_hex implementation		
	procedure cl_fix_write_hex (	a			: std_logic_vector; 
									a_fmt		: FixFormat_t;
									file f		: text;
									f_fmt		: FixFormat_t;
									round		: FixRound_t	:= Trunc_s; 
									saturate	: FixSaturate_t	:= Warn_s) is
		variable line_v 	: line;
		variable temp_v		: string (1 to (cl_fix_width (a_fmt)-1)/4+1);
		variable f_v		: std_logic_vector (cl_fix_width (f_fmt)-1 downto 0);
	begin
		f_v := cl_fix_resize (a, a_fmt, f_fmt, round, saturate);
		temp_v	:= cl_fix_to_hex (f_v, f_fmt);
		write (line_v, temp_v);
		writeline (f, line_v);
	end;
	
	-----------------------------------------------------------------------------------------------	
	--! cl_fix_resize implementation			
	function cl_fix_resize (	a			: std_logic_vector; 
								a_fmt		: FixFormat_t; 
								result_fmt	: FixFormat_t; 
								round		: FixRound_t	:= Trunc_s; 
								saturate	: FixSaturate_t	:= Warn_s) 
								return std_logic_vector is
		constant LessFracBits_c	: integer := a_fmt.FracBits-result_fmt.FracBits;
		constant NeedRound_c 	: boolean := round /= Trunc_s and LessFracBits_c > 0;
		constant CarryBit_c : boolean := -- rounding addition performed with an additional integer bit
			NeedRound_c and saturate /= None_s;
		constant AddSignBit_c : boolean := ((a_fmt.Signed = false) and (result_fmt.Signed = false) and (saturate /= None_s));
		constant TempFmt_c 	: FixFormat_t := 
			(
				Signed		=> a_fmt.Signed or result_fmt.Signed, -- must stay like this!
				IntBits		=> max (a_fmt.IntBits+toInteger (CarryBit_c), result_fmt.IntBits)+toInteger(AddSignBit_c), 
				FracBits	=> max (a_fmt.FracBits, result_fmt.FracBits)
			);
		constant TempWidth_c		: positive := cl_fix_width (TempFmt_c);
		constant ResultWidth_c		: positive := cl_fix_width (result_fmt);
		constant MoreFracBits_c		: natural := TempFmt_c.FracBits-a_fmt.FracBits;
		constant CutFracBits_c		: natural := TempFmt_c.FracBits-result_fmt.FracBits;
		constant CutIntSignBits_c	: integer := TempWidth_c-(ResultWidth_c+CutFracBits_c);
		variable a_v		: std_logic_vector (a'length-1 downto 0);
		variable temp_v		: std_logic_vector (TempWidth_c-1 downto 0);
		variable sign_v		: std_logic;
		variable result_v	: std_logic_vector (ResultWidth_c-1 downto 0);
	begin
		-- TODO: Rounding addition could be less wide when result_fmt.IntBits > a_fmt.IntWidth
		-- TODO: saturate = Warn_s could use no carry bit for synthesis.
		a_v := a;
		temp_v := (others => '0');
		if a_fmt.Signed then
			temp_v (temp_v'high downto MoreFracBits_c) := std_logic_vector (resize (signed (a_v), TempWidth_c-MoreFracBits_c));
		else
			temp_v (temp_v'high downto MoreFracBits_c) := std_logic_vector (resize (unsigned (a_v), TempWidth_c-MoreFracBits_c));
		end if;
		if NeedRound_c then -- rounding required
			if a_fmt.Signed then
				sign_v := a_v (a_v'high);
			else
				sign_v := '0';
			end if;
			case round is
			when Trunc_s => null;
			when NonSymPos_s => temp_v (TempWidth_c-1 downto LessFracBits_c-1) := std_logic_vector (unsigned (temp_v (TempWidth_c-1 downto LessFracBits_c-1)) + 1);
--			when NonSymPos_s => temp_v := std_logic_vector (unsigned (temp_v) + 2**(LessFracBits_c-1));
			when NonSymNeg_s => temp_v := std_logic_vector (unsigned (temp_v) + (2**(LessFracBits_c-1) - 1));
			when SymInf_s => temp_v := std_logic_vector (unsigned (temp_v) + (2**(LessFracBits_c-1) - 1) + ("0" & not sign_v));
			when SymZero_s => temp_v := std_logic_vector (unsigned (temp_v) + (2**(LessFracBits_c-1) - 1) + ("0" & sign_v));
			when ConvEven_s => temp_v := std_logic_vector (unsigned (temp_v) + (2**(LessFracBits_c-1) - 1) + ("0" & a_v (LessFracBits_c)));
			when ConvOdd_s => temp_v := std_logic_vector (unsigned (temp_v) + (2**(LessFracBits_c-1) - 1) + ("0" & not a_v (LessFracBits_c)));
			end case;
		end if;
		if CutIntSignBits_c > 0 and saturate /= None_s then -- saturation required
			if result_fmt.Signed then -- signed output
				if unsigned (temp_v (temp_v'high downto temp_v'high-CutIntSignBits_c)) /= 0 and 
						unsigned (not temp_v (temp_v'high downto temp_v'high-CutIntSignBits_c)) /= 0 then
					assert saturate = Sat_s
						report "cl_fix_resize : Saturation Warning!"
						severity warning;
					if saturate /= Warn_s then
						temp_v (temp_v'high-1 downto 0):= (others => not temp_v (temp_v'high));
						temp_v (ResultWidth_c+CutFracBits_c-1) := temp_v (temp_v'high);
					end if;
				end if;
			else -- unsigned output
				if unsigned (temp_v (temp_v'high downto temp_v'high-CutIntSignBits_c+1)) /= 0 then
					assert saturate = Sat_s
						report "cl_fix_resize : Saturation Warning!"
						severity warning;
					if saturate /= Warn_s then
						temp_v := (others => not temp_v (temp_v'high));
					end if;
				end if;
			end if;
		end if;
		result_v := temp_v (ResultWidth_c+CutFracBits_c-1 downto CutFracBits_c);
		return result_v;
	end;
	
	-----------------------------------------------------------------------------------------------	
	--! cl_fix_fix implementation		
	function cl_fix_fix (	a			: std_logic_vector; 
							a_fmt		: FixFormat_t) 
							return std_logic_vector is
		constant ResultFmt_c 	: FixFormat_t := 
												(
													Signed		=> a_fmt.Signed,
													IntBits		=> a_fmt.IntBits, 
													FracBits	=> 0
												);
	begin
		return cl_fix_resize (a, a_fmt, ResultFmt_c, SymZero_s, None_s);
	end;
	
	-----------------------------------------------------------------------------------------------	
	--! cl_fix_floor implementation			
	function cl_fix_floor (	a			: std_logic_vector; 
							a_fmt		: FixFormat_t) 
							return std_logic_vector is
		constant ResultFmt_c 	: FixFormat_t := 
			(
				Signed		=> a_fmt.Signed,
				IntBits		=> a_fmt.IntBits, 
				FracBits	=> 0
			);
	begin
		return cl_fix_resize (a, a_fmt, ResultFmt_c, NonSymNeg_s, None_s);
	end;
	
	-----------------------------------------------------------------------------------------------	
	--! cl_fix_ceil implementation		
	function cl_fix_ceil (	a			: std_logic_vector; 
							a_fmt		: FixFormat_t) 
							return std_logic_vector is
		constant ResultFmt_c 	: FixFormat_t := 
			(
				Signed		=> a_fmt.Signed,
				IntBits		=> a_fmt.IntBits, 
				FracBits	=> 0
			);
	begin
		return cl_fix_resize (a, a_fmt, ResultFmt_c, NonSymPos_s, None_s);
	end;
	
	-----------------------------------------------------------------------------------------------	
	--! cl_fix_round implementation		
	function cl_fix_round (	a			: std_logic_vector; 
							a_fmt		: FixFormat_t) 
							return std_logic_vector is
		constant ResultFmt_c 	: FixFormat_t := 
			(
				Signed		=> a_fmt.Signed,
				IntBits		=> a_fmt.IntBits, 
				FracBits	=> 0
			);
	begin
		return cl_fix_resize (a, a_fmt, ResultFmt_c, SymInf_s, None_s);
	end;

	-----------------------------------------------------------------------------------------------	
	--! cl_fix_in_range implementation	
	function cl_fix_in_range (	a			: std_logic_vector; 
								a_fmt		: FixFormat_t; 
								result_fmt	: FixFormat_t; 
								round		: FixRound_t	:= Trunc_s) 
								return boolean is
		constant LessFracBits_c	: integer := a_fmt.FracBits-result_fmt.FracBits;
		constant NeedRound_c 	: boolean := round /= Trunc_s and LessFracBits_c > 0;
		constant TempFmt_c 	: FixFormat_t := 
			(
				Signed		=> a_fmt.Signed or result_fmt.Signed,
				IntBits		=> max (a_fmt.IntBits+toInteger (NeedRound_c), result_fmt.IntBits), 
				FracBits	=> max (a_fmt.FracBits, result_fmt.FracBits)
			);
		constant TempWidth_c		: positive := cl_fix_width (TempFmt_c);
		constant ResultWidth_c		: positive := cl_fix_width (result_fmt);
		constant MoreFracBits_c		: natural := TempFmt_c.FracBits-a_fmt.FracBits;
		constant CutFracBits_c		: natural := TempFmt_c.FracBits-result_fmt.FracBits;
		constant CutIntSignBits_c	: integer := TempWidth_c-(ResultWidth_c+CutFracBits_c);
		variable a_v		: std_logic_vector (a'length-1 downto 0);
		variable temp_v		: std_logic_vector (TempWidth_c-1 downto 0);
		variable result_v	: boolean;
		variable sign_v		: std_logic;
	begin
		result_v := true;
		if CutIntSignBits_c > 0 then -- saturation required
			a_v := a;
			temp_v := (others => '0');
			if a_fmt.Signed then
				temp_v (temp_v'high downto MoreFracBits_c) := std_logic_vector (resize (signed (a_v), TempWidth_c-MoreFracBits_c));
			else
				temp_v (temp_v'high downto MoreFracBits_c) := std_logic_vector (resize (unsigned (a_v), TempWidth_c-MoreFracBits_c));
			end if;
			if round /= Trunc_s and LessFracBits_c > 0 then -- rounding required
				if a_fmt.Signed then
					sign_v := a_v (a_v'high);
				else
					sign_v := '0';
				end if;
				case round is
				when Trunc_s => null;
				when NonSymPos_s => temp_v (TempWidth_c-1 downto LessFracBits_c-1) := std_logic_vector (unsigned (temp_v (TempWidth_c-1 downto LessFracBits_c-1)) + 1);
				when NonSymNeg_s => temp_v := std_logic_vector (unsigned (temp_v) + (2**(LessFracBits_c-1) - 1));
				when SymInf_s => temp_v := std_logic_vector (unsigned (temp_v) + (2**(LessFracBits_c-1) - 1) + ("0" & not sign_v));
				when SymZero_s => temp_v := std_logic_vector (unsigned (temp_v) + (2**(LessFracBits_c-1) - 1) + ("0" & sign_v));
				when ConvEven_s => temp_v := std_logic_vector (unsigned (temp_v) + (2**(LessFracBits_c-1) - 1) + ("0" & a_v (LessFracBits_c)));
				when ConvOdd_s => temp_v := std_logic_vector (unsigned (temp_v) + (2**(LessFracBits_c-1) - 1) + ("0" & not a_v (LessFracBits_c)));
				end case;
			end if;
			if result_fmt.Signed then -- (un)signed to signed
				if unsigned (temp_v (temp_v'high downto temp_v'high-CutIntSignBits_c)) /= 0 and 
						unsigned (not temp_v (temp_v'high downto temp_v'high-CutIntSignBits_c)) /= 0 then
					result_v := false;
				end if;
			elsif a_fmt.Signed then -- signed to unsigned
				if unsigned (temp_v (temp_v'high downto temp_v'high-CutIntSignBits_c+1)) /= 0 then
					result_v := false;
				end if;
			else -- unsigned to unsigned
				if unsigned (temp_v (temp_v'high downto temp_v'high-CutIntSignBits_c+1)) /= 0 then
					result_v := false;
				end if;
			end if;
		end if;
		return result_v;
	end;

	-----------------------------------------------------------------------------------------------	
	--! cl_fix_abs implementation	
	function cl_fix_abs (	a			: std_logic_vector; 
							a_fmt		: FixFormat_t; 
							result_fmt	: FixFormat_t; 
							round		: FixRound_t	:= Trunc_s; 
							saturate	: FixSaturate_t := Warn_s) 
							return std_logic_vector is
		constant TempFmt_c 	: FixFormat_t := 
			(
				Signed		=> a_fmt.Signed,
				IntBits		=> a_fmt.IntBits+toInteger (a_fmt.Signed),
				FracBits	=> a_fmt.FracBits
			);
		variable a_v		: std_logic_vector (a'length-1 downto 0);
		variable temp_v		: std_logic_vector (cl_fix_width (TempFmt_c)-1 downto 0);
	begin
		a_v := a;
		if a_fmt.Signed then
			temp_v := a_v (a_v'high) & a_v;
			if a_v (a_v'high) = '1' then
				temp_v := std_logic_vector (unsigned (not temp_v) + 1);
			end if;
		else
			temp_v := a_v;
		end if;
		return cl_fix_resize (temp_v, TempFmt_c, result_fmt, round, saturate);
	end;
	
	-----------------------------------------------------------------------------------------------	
	--! cl_fix_sabs implementation		
	function cl_fix_sabs (	a			: std_logic_vector; 
							a_fmt		: FixFormat_t; 
							result_fmt	: FixFormat_t; 
							round		: FixRound_t	:= Trunc_s; 
							saturate	: FixSaturate_t := Warn_s) 
							return std_logic_vector is
		constant TempFmt_c 	: FixFormat_t := 
			(
				Signed		=> a_fmt.Signed,
				IntBits		=> a_fmt.IntBits,
				FracBits	=> max (a_fmt.FracBits, result_fmt.FracBits)
			);
		variable a_v		: std_logic_vector (a'length-1 downto 0);
		variable temp_v		: std_logic_vector (cl_fix_width (TempFmt_c)-1 downto 0);
		variable result_v	: std_logic_vector (cl_fix_width (result_fmt)-1 downto 0);
	begin
		if a_fmt.Signed then
			temp_v := cl_fix_resize (a, a_fmt, TempFmt_c, Trunc_s, None_s);
			if temp_v (temp_v'high) = '1' then
				temp_v := not temp_v;
			end if;
			result_v := cl_fix_resize (temp_v, TempFmt_c, result_fmt, round, saturate);
		else
			result_v := cl_fix_resize (a, a_fmt, result_fmt, round, saturate);
		end if;
		return result_v;
	end;
		
	-----------------------------------------------------------------------------------------------	
	--! cl_fix_neg implementation		
	function cl_fix_neg (	a			: std_logic_vector; 
							a_fmt		: FixFormat_t; 
							enable		: std_logic		:= '1';
							result_fmt	: FixFormat_t; 
							round		: FixRound_t	:= Trunc_s; 
							saturate	: FixSaturate_t := Warn_s) 
							return std_logic_vector is
		constant AFullFmt_c	: FixFormat_t := (true, a_fmt.IntBits+ toInteger(a_fmt.Signed), a_fmt.FracBits);
		variable AFull_v	: std_logic_vector(cl_fix_width(AFullFmt_c)-1 downto 0);
		variable Neg_v		: std_logic_vector(cl_fix_width(AFullFmt_c)-1 downto 0);
	begin
		AFull_v := cl_fix_resize(a, a_fmt, AFullFmt_c);
		Neg_v	:= std_logic_vector(-signed(AFull_v));
		return cl_fix_resize(Neg_v, AFullFmt_c, result_fmt, round, saturate);
	end;
	
	-----------------------------------------------------------------------------------------------	
	--! cl_fix_sneg implementation		
	function cl_fix_sneg (	a			: std_logic_vector; 
							a_fmt		: FixFormat_t; 
							enable		: std_logic		:= '1';
							result_fmt	: FixFormat_t; 
							round		: FixRound_t	:= Trunc_s; 
							saturate	: FixSaturate_t := Warn_s) 
							return std_logic_vector is
		constant TempFmt_c 	: FixFormat_t := 
			(
				Signed		=> a_fmt.Signed,
				IntBits		=> a_fmt.IntBits,
				FracBits	=> max (a_fmt.FracBits, result_fmt.FracBits)
			);
		variable a_v		: std_logic_vector (a'length-1 downto 0);
		variable temp_v		: std_logic_vector (cl_fix_width (TempFmt_c)-1 downto 0);
		variable result_v	: std_logic_vector (cl_fix_width (result_fmt)-1 downto 0);
	begin
		assert a_fmt.Signed 
			report "cl_fix_sneg : Cannot negate an unsigned value." 
			severity failure;

		temp_v := cl_fix_resize (a, a_fmt, TempFmt_c, Trunc_s, None_s);
		if to01 (enable) = '1' then
			temp_v := not temp_v;
		end if;
		result_v := cl_fix_resize (temp_v, TempFmt_c, result_fmt, round, saturate);
		return result_v;
	end;
	
	-----------------------------------------------------------------------------------------------
	--! cl_fix_addsub_internal implementation (internal package use only)
	function cl_fix_addsub_internal(	a			: std_logic_vector;
										a_fmt		: FixFormat_t; 
										b			: std_logic_vector;
										b_fmt		: FixFormat_t;
										add			: std_logic) return std_logic_vector is
		constant IsSigned_c	: boolean := a_fmt.Signed or b_fmt.Signed;
		variable result_v	: std_logic_vector(a'range);
	begin
		-- Synthesis tools may create problems if correct signed/unsigned type
		-- is not used for addition.
		if to01 (add) = '1' then
			if IsSigned_c then
				result_v := std_logic_vector (  signed (a) +   signed (b));
			else
				result_v := std_logic_vector (unsigned (a) + unsigned (b));
			end if;
		else
			if IsSigned_c then
				result_v := std_logic_vector (  signed (a) -   signed (b));
			else
				result_v := std_logic_vector (unsigned (a) - unsigned (b));
			end if;
		end if;
		return result_v;
	end function;
	
	-----------------------------------------------------------------------------------------------	
	--! cl_fix_add implementation	
	function cl_fix_add (	a			: std_logic_vector; 
							a_fmt		: FixFormat_t; 
							b			: std_logic_vector; 
							b_fmt		: FixFormat_t; 
							result_fmt	: FixFormat_t; 
							round		: FixRound_t	:= Trunc_s; 
							saturate	: FixSaturate_t	:= Warn_s) 
							return std_logic_vector is
		constant CarryBit_c : boolean := -- addition performed with an additional integer bit
			result_fmt.IntBits > max (a_fmt.IntBits, b_fmt.IntBits) or (saturate = Sat_s or
		-- synthesis translate_off
			saturate = Warn_s or
		-- synthesis translate_on
			saturate = SatWarn_s);
			-- TODO: CarryBit in cl_fix_resize not needed in all cases
		constant TempFmt_c 	: FixFormat_t := 
			(
				Signed		=> a_fmt.Signed or b_fmt.Signed,
				IntBits		=> max (a_fmt.IntBits, b_fmt.IntBits) + toInteger (CarryBit_c), 
				FracBits	=> max (a_fmt.FracBits, b_fmt.FracBits)
			);
		constant TempWidth_c: positive := cl_fix_width (TempFmt_c);
		variable a_v		: std_logic_vector (TempWidth_c-1 downto 0);
		variable b_v		: std_logic_vector (TempWidth_c-1 downto 0);
		variable temp_v		: std_logic_vector (TempWidth_c-1 downto 0);
		variable result_v	: std_logic_vector (cl_fix_width (result_fmt)-1 downto 0);
	begin
		a_v := cl_fix_resize (a, a_fmt, TempFmt_c, Trunc_s, None_s);
		b_v := cl_fix_resize (b, b_fmt, TempFmt_c, Trunc_s, None_s);
		temp_v := cl_fix_addsub_internal(a_v, a_fmt, b_v, b_fmt, '1');
		result_v := cl_fix_resize (temp_v, TempFmt_c, result_fmt, round, saturate);
		return result_v;
	end;
	
	-----------------------------------------------------------------------------------------------	
	--! cl_fix_sub implementation	
	function cl_fix_sub (	a			: std_logic_vector; 
							a_fmt		: FixFormat_t; 
							b			: std_logic_vector; 
							b_fmt		: FixFormat_t; 
							result_fmt	: FixFormat_t; 
							round		: FixRound_t	:= Trunc_s; 
							saturate	: FixSaturate_t := Warn_s) 
							return std_logic_vector is
		constant CarryBit_c : boolean := -- addition performed with an additional integer bit
			result_fmt.IntBits > max (a_fmt.IntBits, b_fmt.IntBits) or (saturate = Sat_s or
		-- synthesis translate_off
			saturate = Warn_s or
		-- synthesis translate_on
			saturate = SatWarn_s);
		constant TempFmt_c 	: FixFormat_t := 
			(
				Signed		=> a_fmt.Signed or b_fmt.Signed,
				IntBits		=> max (a_fmt.IntBits, b_fmt.IntBits) + toInteger (CarryBit_c), 
				FracBits	=> max (a_fmt.FracBits, b_fmt.FracBits)
			);
		constant TempWidth_c: positive := cl_fix_width (TempFmt_c);
		variable a_v		: std_logic_vector (TempWidth_c-1 downto 0);
		variable b_v		: std_logic_vector (TempWidth_c-1 downto 0);
		variable temp_v		: std_logic_vector (TempWidth_c-1 downto 0);
		variable result_v	: std_logic_vector (cl_fix_width (result_fmt)-1 downto 0);
	begin
		a_v := cl_fix_resize (a, a_fmt, TempFmt_c, Trunc_s, None_s);
		b_v := cl_fix_resize (b, b_fmt, TempFmt_c, Trunc_s, None_s);
		temp_v := cl_fix_addsub_internal(a_v, a_fmt, b_v, b_fmt, '0');
		result_v := cl_fix_resize (temp_v, TempFmt_c, result_fmt, round, saturate);
		return result_v;
	end;
	
	-----------------------------------------------------------------------------------------------	
	--! cl_fix_addsub implementation	
	function cl_fix_addsub (	a			: std_logic_vector; 
								a_fmt		: FixFormat_t; 
								b			: std_logic_vector; 
								b_fmt		: FixFormat_t; 
								add			: std_logic;
								result_fmt	: FixFormat_t; 
								round		: FixRound_t	:= Trunc_s; 
								saturate	: FixSaturate_t := Warn_s) 
								return std_logic_vector is
		constant CarryBit_c : boolean := -- addition performed with an additional integer bit
			result_fmt.IntBits > max (a_fmt.IntBits, b_fmt.IntBits) or (saturate = Sat_s or
		-- synthesis translate_off
			saturate = Warn_s or
		-- synthesis translate_on
			saturate = SatWarn_s);
		constant TempFmt_c 	: FixFormat_t := 
			(
				Signed		=> a_fmt.Signed or b_fmt.Signed,
				IntBits		=> max (a_fmt.IntBits, b_fmt.IntBits) + toInteger (CarryBit_c), 
				FracBits	=> max (a_fmt.FracBits, b_fmt.FracBits)
			);
		constant TempWidth_c: positive := cl_fix_width (TempFmt_c);
		variable a_v		: std_logic_vector (TempWidth_c-1 downto 0);
		variable b_v		: std_logic_vector (TempWidth_c-1 downto 0);
		variable temp_v		: std_logic_vector (TempWidth_c-1 downto 0);
		variable result_v	: std_logic_vector (cl_fix_width (result_fmt)-1 downto 0);
	begin
		a_v := cl_fix_resize (a, a_fmt, TempFmt_c, Trunc_s, None_s);
		b_v := cl_fix_resize (b, b_fmt, TempFmt_c, Trunc_s, None_s);
		temp_v := cl_fix_addsub_internal(a_v, a_fmt, b_v, b_fmt, add);
		result_v := cl_fix_resize (temp_v, TempFmt_c, result_fmt, round, saturate);
		return result_v;
	end;
	
	-----------------------------------------------------------------------------------------------	
	--! cl_fix_saddsub implementation		
	function cl_fix_saddsub (	a			: std_logic_vector; 
								a_fmt		: FixFormat_t; 
								b			: std_logic_vector; 
								b_fmt		: FixFormat_t; 
								add			: std_logic;
								result_fmt	: FixFormat_t; 
								round		: FixRound_t	:= Trunc_s; 
								saturate	: FixSaturate_t := Warn_s) 
								return std_logic_vector is
		constant CarryBit_c : boolean := -- addition performed with an additional integer bit
			result_fmt.IntBits > max (a_fmt.IntBits, b_fmt.IntBits) or (saturate = Sat_s or
		-- synthesis translate_off
			saturate = Warn_s or
		-- synthesis translate_on
			saturate = SatWarn_s);
		constant TempFmt_c 	: FixFormat_t := 
			(
				Signed		=> a_fmt.Signed or b_fmt.Signed,
				IntBits		=> max (a_fmt.IntBits, b_fmt.IntBits) + toInteger (CarryBit_c), 
				FracBits	=> max (a_fmt.FracBits, b_fmt.FracBits)
			);
		constant TempWidth_c: positive := cl_fix_width (TempFmt_c);
		variable a_v		: std_logic_vector (TempWidth_c-1 downto 0);
		variable b_v		: std_logic_vector (TempWidth_c-1 downto 0);
		variable temp_v		: std_logic_vector (TempWidth_c-1 downto 0);
		variable result_v	: std_logic_vector (cl_fix_width (result_fmt)-1 downto 0);
	begin
		a_v := cl_fix_resize (a, a_fmt, TempFmt_c, Trunc_s, None_s);
		b_v := cl_fix_resize (b, b_fmt, TempFmt_c, Trunc_s, None_s);
		if to01 (add) = '0' then
			b_v := not b_v;
		end if;
		temp_v := cl_fix_addsub_internal(a_v, a_fmt, b_v, b_fmt, '1');
		result_v := cl_fix_resize (temp_v, TempFmt_c, result_fmt, round, saturate);
		return result_v;
	end;
	
	-----------------------------------------------------------------------------------------------	
	--! cl_fix_mean implementation	
	function cl_fix_mean (	a			: std_logic_vector; 
							a_fmt		: FixFormat_t; 
							b			: std_logic_vector; 
							b_fmt		: FixFormat_t; 
							result_fmt	: FixFormat_t; 
							round		: FixRound_t	:= Trunc_s; 
							saturate	: FixSaturate_t := Warn_s) 
							return std_logic_vector is
		constant TempFmt_c 	: FixFormat_t := 
			(
				Signed		=> a_fmt.Signed or b_fmt.Signed,
				IntBits		=> max (a_fmt.IntBits, b_fmt.IntBits) + 1, 
				FracBits	=> max (a_fmt.FracBits, b_fmt.FracBits)
			);
		constant TempWidth_c: positive := cl_fix_width (TempFmt_c);
		variable temp_v		: std_logic_vector (TempWidth_c-1 downto 0);
		variable result_v	: std_logic_vector (cl_fix_width (result_fmt)-1 downto 0);
	begin
		temp_v := cl_fix_add (a, a_fmt, b, b_fmt, TempFmt_c, Trunc_s, None_s);
		result_v := cl_fix_shift (temp_v, TempFmt_c, -1, result_fmt, round, saturate);
		return result_v;
	end;
	
	-----------------------------------------------------------------------------------------------	
	--! cl_fix_mean_angle implementation		
	function cl_fix_mean_angle (	a			: std_logic_vector; 
									a_fmt		: FixFormat_t; 
									b			: std_logic_vector; 
									b_fmt		: FixFormat_t; 
									precise		: boolean;
									result_fmt	: FixFormat_t; 
									round		: FixRound_t	:= Trunc_s; 
									saturate	: FixSaturate_t := Warn_s) 
									return std_logic_vector is
		constant TempFmt_c 	: FixFormat_t := 
			(
				Signed		=> a_fmt.Signed or b_fmt.Signed,
				IntBits		=> max (a_fmt.IntBits, b_fmt.IntBits) + 1, 
				FracBits	=> max (a_fmt.FracBits, b_fmt.FracBits)
			);
		constant TempWidth_c: positive := cl_fix_width (TempFmt_c);
		variable a_v		: std_logic_vector (cl_fix_width (a_fmt)-1 downto 0);
		variable b_v		: std_logic_vector (cl_fix_width (b_fmt)-1 downto 0);
		variable temp_v		: std_logic_vector (TempWidth_c-1 downto 0);
		variable result_v	: std_logic_vector (cl_fix_width (result_fmt)-1 downto 0);
		variable differentSigns_v	: boolean;
	begin
		assert a_fmt.Signed = b_fmt.Signed and a_fmt.IntBits = b_fmt.IntBits
			report "cl_fix_mean_angle : Signed and IntBits of 'a' and 'b' must be identical." 
			severity failure;
		assert cl_fix_width (a_fmt) >= 2 and cl_fix_width (b_fmt) >= 2
			report "cl_fix_mean_angle : The widths of 'a' and 'b' must be at least 2 bits each." 
			severity failure;

		a_v := a;
		b_v := b;
		differentSigns_v := a_v (a_v'high) /= b_v (b_v'high);
		if differentSigns_v and 
				a_v (a_v'high) /= a_v (a_v'high-1) and b_v (b_v'high) /= b_v (b_v'high-1) then
			a_v (a_v'high) := not a_v (a_v'high);
		end if;
		temp_v := cl_fix_add (a, a_fmt, b, b_fmt, TempFmt_c, Trunc_s, None_s);
		if precise and differentSigns_v and a_v (a_v'high-1) = b_v (b_v'high-1) and 
				temp_v (temp_v'high-2) = a_v (a_v'high-1) then
			temp_v (temp_v'high) := not temp_v (temp_v'high);
		end if;
		result_v := cl_fix_resize (temp_v, TempFmt_c, result_fmt, round, saturate);
		return result_v;
	end;
		
	-----------------------------------------------------------------------------------------------	
	--! cl_fix_shift implementation
	function cl_fix_shift (	a			: std_logic_vector; 
							a_fmt		: FixFormat_t; 
							shift		: integer;
							result_fmt	: FixFormat_t; 
							round		: FixRound_t	:= Trunc_s; 
							saturate	: FixSaturate_t := Warn_s) 
							return std_logic_vector is
		constant TempFmt_c 	: FixFormat_t := 
			(
				Signed		=> result_fmt.Signed,
				IntBits		=> result_fmt.IntBits - shift, 
				FracBits	=> result_fmt.FracBits + shift
			);
	begin
		return cl_fix_resize (a, a_fmt, TempFmt_c, round, saturate);
	end;
		
	-----------------------------------------------------------------------------------------------	
	--! cl_fix_mult implementation
	function cl_fix_mult (	a			: std_logic_vector; 
							a_fmt		: FixFormat_t; 
							b			: std_logic_vector; 
							b_fmt		: FixFormat_t; 
							result_fmt	: FixFormat_t; 
							round		: FixRound_t	:= Trunc_s; 
							saturate	: FixSaturate_t := Warn_s) 
							return std_logic_vector is
		constant TempSigned_c : boolean := a_fmt.Signed or b_fmt.Signed;
		constant TempFmt_c 	: FixFormat_t := 
			(
				Signed		=> TempSigned_c,
				IntBits		=> a_fmt.IntBits + b_fmt.IntBits + toInteger (TempSigned_c), 
				FracBits	=> a_fmt.FracBits + b_fmt.FracBits
			);
		variable a_v		: std_logic_vector (a'length-1 downto 0);
		variable b_v		: std_logic_vector (b'length-1 downto 0);
		variable temp_v		: std_logic_vector (cl_fix_width (TempFmt_c)-1 downto 0);
		variable result_v	: std_logic_vector (cl_fix_width (result_fmt)-1 downto 0);
	begin
		a_v := a;
		b_v := b;
		if a_fmt.Signed then
			if b_fmt.Signed then
				temp_v := std_logic_vector (signed (a_v) * signed (b_v));
			else
				temp_v := std_logic_vector (signed (a_v) * ("0" & signed (b_v)));
			end if;
		else
			if b_fmt.Signed then
				temp_v := std_logic_vector (("0" & signed (a_v)) * signed (b_v));
			else
				temp_v := std_logic_vector (unsigned (a_v) * unsigned (b_v));
			end if;
		end if;
		result_v := cl_fix_resize (temp_v, TempFmt_c, result_fmt, round, saturate);
		return result_v;
	end;
	
	-----------------------------------------------------------------------------------------------	
	--! cl_fix_compare implementation
	function cl_fix_compare(	comparison	: string;
							a			: std_logic_vector;
							aFmt		: FixFormat_t;
							b			: std_logic_vector;
							bFmt		: FixFormat_t) return boolean is
		constant FullFmt_c	: FixFormat_t	:= (aFmt.Signed or bFmt.Signed, max(aFmt.IntBits, bFmt.IntBits), max(aFmt.FracBits, bFmt.FracBits));
		variable AFull_v	: std_logic_vector(cl_fix_width(FullFmt_c)-1 downto 0);
		variable BFull_v	: std_logic_vector(cl_fix_width(FullFmt_c)-1 downto 0);
	begin
		-- Check operator
		-- Convert to same type
		AFull_v	:= cl_fix_resize(a, aFmt, FullFmt_c);
		BFull_v := cl_fix_resize(b, bFmt, FullFmt_c);
		-- Convert to unsigned representation with offset
		if FullFmt_c.Signed then
			AFull_v(AFull_v'high) := not AFull_v(AFull_v'high);
			BFull_v(BFull_v'high) := not BFull_v(BFull_v'high);
		end if;
		-- Copare
		if 		comparison = "a=b" 	then return unsigned(AFull_v) = unsigned(BFull_v);
		elsif 	comparison = "a<b" 	then return unsigned(AFull_v) < unsigned(BFull_v);
		elsif	comparison = "a>b"	then return unsigned(AFull_v) > unsigned(BFull_v);
		elsif	comparison = "a<=b" then return unsigned(AFull_v) <= unsigned(BFull_v);
		elsif	comparison = "a>=b" then return unsigned(AFull_v) >= unsigned(BFull_v);
		elsif	comparison = "a!=b"	then return unsigned(AFull_v) /= unsigned(BFull_v);
		else	report "###ERROR###: cl_fix_compare illegal comparison type [" & comparison & "]" severity error;
				return false;
		end if;
		
	end function;	
end;
