library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity shifter is
generic(NBITS: integer := 32);
port(R1: IN std_logic_vector(NBITS-1 downto 0);				--operand 1 to be shifted
	 R2: IN std_logic_vector(NBITS-1 downto 0);				--operand 2 that indicate the amount to shift
	 LnR: IN std_logic;										--signal indicating a shift left(1) or a shift right(0)
	 AnL: IN std_logic;										--signal indicating an arithmetic shift(1) or a logic shift(0)
	 RnS: IN std_logic;										--signal indicating a rotate_right(1) or a shift(0)
	 Rout: OUT std_logic_vector(NBITS-1 downto 0)			--result of the shift
);
end shifter;

--LnR -> left notRight
--AnL -> Arithmetic notLogic
--RnS -> Rotate notShift

architecture structural of shifter is 


component MUX41_GENERIC is
  GENERIC(NBIT: integer:= 4);      
  PORT(A:   in  std_logic_vector(NBIT-1 downto 0);
       B:   in  std_logic_vector(NBIT-1 downto 0);
       C:   in  std_logic_vector(NBIT-1 downto 0);
       D:   in  std_logic_vector(NBIT-1 downto 0);
       SEL:	In	std_logic_vector(1 downto 0);
       Y:   out std_logic_vector(NBIT-1 downto 0));
end component;

component MUX81_GENERIC is
  GENERIC(NBIT: integer:= 4);      
  PORT(A:   in  std_logic_vector(NBIT-1 downto 0);
       B:   in  std_logic_vector(NBIT-1 downto 0);
       C:   in  std_logic_vector(NBIT-1 downto 0);
       D:   in  std_logic_vector(NBIT-1 downto 0);
       E:   in  std_logic_vector(NBIT-1 downto 0);
       F:   in  std_logic_vector(NBIT-1 downto 0);
       G:   in  std_logic_vector(NBIT-1 downto 0);
       H:   in  std_logic_vector(NBIT-1 downto 0);
       SEL:	In	std_logic_vector(2 downto 0);
       Y:   out std_logic_vector(NBIT-1 downto 0));
end component;


component mask_generator is
generic(NBITS: integer := 32);
port(R1: IN std_logic_vector(NBITS-1 downto 0);					--operand 1 to be shifted
	 R2: IN std_logic_vector(NBITS-1 downto 0);					--operand 2 that indicate the amount to shift
	 LnR: IN std_logic;											--signal indicating a shift left(1) or a shift right(0)
	 AnL: IN std_logic;											--signal indicating an arithmetic shift(1) or a logic shift(0)
	 RnS: IN std_logic;											--signal indicating a rotate_right(1) or a shift(0)
	 mask0: OUT std_logic_vector(NBITS+8-1 downto 0);			-- alternatively it is possible to use a global array to make the interface generic ***
	 mask8: OUT std_logic_vector(NBITS+8-1 downto 0);
	 mask16: OUT std_logic_vector(NBITS+8-1 downto 0);
	 mask24: OUT std_logic_vector(NBITS+8-1 downto 0)			
);
end component;

component mask_shifter is
generic(NBITS: integer := 32);
port(R1: IN std_logic_vector(NBITS-1 downto 0);				--input is the full mask
	 LnR: IN std_logic;										--signal indicating a shift left(1) or a shift right(0)
	 mask_sh0: OUT std_logic_vector(NBITS-8-1 downto 0);	--the output is part of the mask. We will always have 8 outs because it is the last stage (shift by 8) no matter the input size
	 mask_sh1: OUT std_logic_vector(NBITS-8-1 downto 0);
	 mask_sh2: OUT std_logic_vector(NBITS-8-1 downto 0);
	 mask_sh3: OUT std_logic_vector(NBITS-8-1 downto 0);
	 mask_sh4: OUT std_logic_vector(NBITS-8-1 downto 0);
	 mask_sh5: OUT std_logic_vector(NBITS-8-1 downto 0);
	 mask_sh6: OUT std_logic_vector(NBITS-8-1 downto 0);
	 mask_sh7: OUT std_logic_vector(NBITS-8-1 downto 0)			
);
end component;

--intermediate signals
signal s_mask0, s_mask8, s_mask16, s_mask24: std_logic_vector(NBITS+8-1 downto 0);				
signal s_sh0, s_sh1, s_sh2, s_sh3, s_sh4, s_sh5, s_sh6, s_sh7: std_logic_vector(NBITS-1 downto 0);
signal select2: std_logic_vector(1 downto 0);															-- selection signal fo stage 2 (byte shift)
signal select3: std_logic_vector(2 downto 0);															-- selection signal fo stage 3 (bit shift)
signal s_selected_mask: std_logic_vector(NBITS+8-1 downto 0);											-- output of the second stage (selection of the mask)
signal s_RnS: std_logic;																				-- used only to manage left rotation.

begin

	select2<= R2(4 downto 3);				-- generate selection signals for stage 2
	select3<= R2(2 downto 0);				-- generate selection signals for stage 3
	s_RnS<=RnS AND (NOT LnR);				--***** to avoid rotating left by mistake. In that case we do a shift left. it is also hardwired in the mask generation *********

	--stage 1
	mask_gen: mask_generator
	generic map(NBITS=>NBITS)
	port map(R1=>R1, R2=>R2, LnR=>LnR, AnL=>AnL, RnS=>s_RnS, mask0=>s_mask0, mask8=>s_mask8, mask16=>s_mask16, mask24=>s_mask24 );

	
	MUX_mask_select: MUX41_GENERIC
	generic map(NBIT=>NBITS+8)
	Port Map (A=>s_mask0, B=>s_mask8, C=>s_mask16, D=>s_mask24, SEL=>select2, Y=>s_selected_mask); 
	
	
	--stage 2
	mask_shift: mask_shifter
	generic map(NBITS=>NBITS+8)
	Port Map (
			R1=>s_selected_mask,
			LnR=>LnR,
			mask_sh0=>s_sh0,
			mask_sh1=>s_sh1,
			mask_sh2=>s_sh2,
			mask_sh3=>s_sh3,
			mask_sh4=>s_sh4,
			mask_sh5=>s_sh5,
			mask_sh6=>s_sh6,
			mask_sh7=>s_sh7
	); 
	
	--stage 3
	MUX_shift_select: MUX81_GENERIC
	generic map(NBIT=>NBITS)
	Port Map (A=>s_sh0,
			B=>s_sh1,
			C=>s_sh2,
			D=>s_sh3,
			E=>s_sh4,
			F=>s_sh5,
			G=>s_sh6,
			H=>s_sh7,
			SEL=>select3,
			Y=>Rout); 
	
-- the commented part below shows what part of the mask we extract to obtain the final value. It is different for shifte left and right	
	--Rout<=selected_mask(NBITS-1 downto 0) when LnR='0' else
	--      selected_mask(NBITS+8-1 downto 8);


end structural;
