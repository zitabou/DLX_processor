library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;


entity mask_shifter is
generic(NBITS: integer := 32);
port(R1: IN std_logic_vector(NBITS-1 downto 0);					--input is the full mask
	 LnR: IN std_logic;											--signal indicating a shift left(1) or a shift right(0)
	 mask_sh0: OUT std_logic_vector(NBITS-8-1 downto 0);		-- the output is only part of the mask
	 mask_sh1: OUT std_logic_vector(NBITS-8-1 downto 0);
	 mask_sh2: OUT std_logic_vector(NBITS-8-1 downto 0);
	 mask_sh3: OUT std_logic_vector(NBITS-8-1 downto 0);
	 mask_sh4: OUT std_logic_vector(NBITS-8-1 downto 0);
	 mask_sh5: OUT std_logic_vector(NBITS-8-1 downto 0);
	 mask_sh6: OUT std_logic_vector(NBITS-8-1 downto 0);
	 mask_sh7: OUT std_logic_vector(NBITS-8-1 downto 0)			--result of the shift
);
end mask_shifter;

architecture structural of mask_shifter is 

--signal mask0, mask8, mask16, mask24: std_logic_vector(NBITS+8-1 downto 0);
subtype mask_sh_range is natural range 0 to 7;
type mask_sh_array is array(mask_sh_range) of std_logic_vector(NBITS-1 downto 0);

signal masks_sh: mask_sh_array;

begin

	-- 8 single bit shifts.  *** shift 32 doesn't do anything ***
	mask_sh0	<= 	R1(NBITS-8-1 downto 0) when LnR = '0' else
					R1(NBITS-1 downto 8);
	
	mask_sh1	<= 	R1(NBITS-8 downto 1) when LnR = '0' else
					R1(NBITS-1-1 downto 8-1);
					
	mask_sh2	<= 	R1(NBITS-8+1 downto 2) when LnR = '0' else
					R1(NBITS-1-2 downto 8-2);
					
	mask_sh3	<= 	R1(NBITS-8+2 downto 3) when LnR = '0' else
					R1(NBITS-1-3 downto 8-3);
					
	mask_sh4	<= 	R1(NBITS-8+3 downto 4) when LnR = '0' else
					R1(NBITS-1-4 downto 8-4);
		
	mask_sh5	<= 	R1(NBITS-8+4 downto 5) when LnR = '0' else
					R1(NBITS-1-5 downto 8-5);
					
	mask_sh6	<= 	R1(NBITS-8+5 downto 6) when LnR = '0' else
					R1(NBITS-1-6 downto 8-6);
					
	mask_sh7	<= 	R1(NBITS-8+6 downto 7) when LnR = '0' else
					R1(NBITS-1-7 downto 8-7);

end structural;
