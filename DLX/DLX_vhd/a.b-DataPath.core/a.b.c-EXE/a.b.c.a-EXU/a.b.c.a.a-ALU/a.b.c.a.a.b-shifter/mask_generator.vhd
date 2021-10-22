library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;


entity mask_generator is
generic(NBITS: integer := 32);
port(R1: IN std_logic_vector(NBITS-1 downto 0);					--operand 1 to be shifted
	 R2: IN std_logic_vector(NBITS-1 downto 0);					--operand 2 that indicate the amount to shift
	 LnR: IN std_logic;											--signal indicating a shift left(1) or a shift right(0)			(left notRight)
	 AnL: IN std_logic;											--signal indicating an arithmetic shift(1) or a logic shift(0)	(arithmetic notLogic)
	 RnS: IN std_logic;											--signal indicating a rotate_right(1) or a shift(0)				(Rotate notShift)
	 mask0: OUT std_logic_vector(NBITS+8-1 downto 0);			-- alternatively it is possible to use a global array to make the interface generic ***
	 mask8: OUT std_logic_vector(NBITS+8-1 downto 0);
	 mask16: OUT std_logic_vector(NBITS+8-1 downto 0);
	 mask24: OUT std_logic_vector(NBITS+8-1 downto 0)			
);
end mask_generator;

architecture structural of mask_generator is 


component MUX21_GENERIC is
  GENERIC(NBIT: integer:= 4);      
  PORT(A:   in  std_logic_vector(NBIT-1 downto 0);
       B:   in  std_logic_vector(NBIT-1 downto 0);
       SEL: in  std_logic;
       Y:   out std_logic_vector(NBIT-1 downto 0));
end component;

component MUX41_GENERIC is
  GENERIC(NBIT: integer:= 4);      
  PORT(A:   in  std_logic_vector(NBIT-1 downto 0);
       B:   in  std_logic_vector(NBIT-1 downto 0);
       C:   in  std_logic_vector(NBIT-1 downto 0);
       D:   in  std_logic_vector(NBIT-1 downto 0);
       SEL:	In	std_logic_vector(1 downto 0);
       Y:   out std_logic_vector(NBIT-1 downto 0));
end component;

-- defining an array of masks to make it generic
subtype masks_range is natural range 0 to NBITS/8-1;
type mask_array is array(masks_range) of std_logic_vector(NBITS+8-1 downto 0);

signal masks: mask_array;																-- array of masks
signal sign, shr_new_block: std_logic_vector(7 downto 0);
signal rotate_sel: std_logic_vector(1 downto 0);										-- selection for the 4to1 mux to implement the ROR

-- blocks are blocks of bytes

begin

	
	sign <= R1(NBITS-1)&R1(NBITS-1)&R1(NBITS-1)&R1(NBITS-1)&R1(NBITS-1)&R1(NBITS-1)&R1(NBITS-1)&R1(NBITS-1);		-- generating the sign extension byte, used for the arith shift
	rotate_sel <= LnR & RnS;																						-- generating 4to1 mux sel signal

-- block used to decide in case of a right shift the content of the new block that comes from the left of the word. It will be zero, if logic, sign extension, if arithm
	MUX_shift_type: MUX21_generic   --0->A, 1->B
	generic map(NBIT=>8)
	port map(A	=>x"00",
			 B	=>sign,
			 SEL=>AnL,
			 Y	=>shr_new_block
	);
-- the output of the mux above will be ised to fill the additional MSByte block. So only for Right shifts




	-- j: mask level, Number of masks.
	-- i: index of byte in mask from LSByte to MSByte
	
	-- the number of mask levels are equal to the number of bytes of the value to be shifted, R1
	--we create j masks. for each mask we scan the previous mask and place each byte of the previous mask to the current(new) one properly 


	-- generate all NBITS/8 masks
	masks_gen: for j in 0 to NBITS/8-1 generate	
		
		
		-- Generation of mask zero that will be used as a base for all the others	
		gen_mask0: if(j = 0) generate								-- control that we are generating mask 0
			mask0_block: for i in 0 to (NBITS/8+1)-1 generate		-- scan R1 bloc by block
	
				mask0_LSByte: if(i = 0)  generate				--first mux takes either the LSByte of R1, if SHR, or zeros, if SHL. ad puts it to the additional block which LSByte of mask
					MUX_mask0_LSB: MUX21_generic
					generic map(NBIT=>8)	
					port map(
						A	=>R1(7 downto 0),
						B	=>"00000000",
						SEL	=>LnR,
						Y	=>masks(j)(7 downto 0)
					);
				end generate mask0_LSByte;  --if
			
				-- there is no "-1" because masks are bigger by one byte
				mask0_MSByte: if(i = NBITS/8) generate				-- last mux takes either zeros, if SHR, sign of R1, if ASHR, LSByte of R1, if rotate, or MSByte of R1, if SHL. 
					
					MUX_mask_MSB: MUX41_generic
						generic map(NBIT=>8)	
						port map(
							A	=>shr_new_block,						-- shift right, either logic or arithmetic
							B	=>R1(7 downto 0),						-- rotate right
							C	=>R1(NBITS-1 downto NBITS-8),			-- shift left
							D	=>R1(NBITS-1 downto NBITS-8),			-- shift left
							SEL	=>rotate_sel,
							Y	=>masks(j)(NBITS+8-1 downto NBITS)
						);
					
																	
					
				end generate mask0_MSByte;  --if
			
				mask0_otherBytes: if(i/=0 AND i/=NBITS/8) generate	-- the rest of the muxes are used to place the R1 bytes at the same position or one byte right to add the additional byte either left or right
					MUX_mask0: MUX21_generic
					generic map(NBIT=>8)	
					port map(
						A	=>R1(8*(i+1)-1 downto i*8),
						B	=>R1(8*i-1 downto (i-1)*8),
						SEL	=>LnR,
						Y	=>masks(j)(8*(i+1)-1 downto i*8)
					);
				end generate mask0_otherBytes;  --if	
			end generate mask0_block;	--for
		end generate gen_mask0; -- if
	
	
		
		
		-- rest of the masks
		gen_other_masks: if(j/=0) generate								-- scan previous mask byte by byte
			mask_gen_block: for i in 0 to (NBITS/8+1)-1 generate	
				mask_LSByte: if(i = 0)  generate						--same as for mask 0 but now the position of the source is not right above but it is taken diagonally
					MUX_mask_LSB: MUX21_generic
					generic map(NBIT=>8)	
					port map(
						A	=>masks(j-1)(15 downto 8),
						B	=>"00000000",
						SEL	=>LnR,
						Y	=>masks(j)(7 downto 0)
					);
				end generate mask_LSByte;  --if
			
				mask_MSByte: if(i = NBITS/8) generate					--same as for mask 0 but now the position of the source is not right above but is take diagonally				
						
						MUX_mask_MSB: MUX41_generic
						generic map(NBIT=>8)	
						port map(
							A	=>shr_new_block,								-- shift right, either logic or arithmetic
							B	=>masks(j-1)(15 downto 8),						-- rotate right
							C	=>masks(j-1)(NBITS-1 downto NBITS-8),			-- shift left
							D	=>masks(j-1)(NBITS-1 downto NBITS-8),			-- shift left
							SEL	=>rotate_sel,
							Y	=>masks(j)(NBITS+8-1 downto NBITS)
						);
						
				end generate mask_MSByte;  --if
			
				mask_otherBytes: if(i/=0 AND i/=NBITS/8) generate		-- other muxes
						MUX_mask: MUX21_generic
						generic map(NBIT=>8)	
						port map(
							A	=>masks(j-1)(8*(i+2)-1 downto (i+1)*8),
							B	=>masks(j-1)(8*i-1 downto (i-1)*8),
							SEL	=>LnR,
							Y	=>masks(j)(8*(i+1)-1 downto i*8)
						);
				end generate mask_otherBytes;  --if	
			end generate mask_gen_block;	--for
		end generate gen_other_masks; -- if
	
	
	
	end generate masks_gen; --for
	
	
	
	
	mask0<=masks(0);
	mask8<=masks(1);
	mask16<=masks(2);
	mask24<=masks(3);



--

end structural;
