library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use WORK.DLX_constants.all;
use WORK.DLX_functions.all;

entity boothmul is
	generic(NBIT_in: integer:=32);  --input bits
	port (	A 		: in std_logic_vector(NBIT_in-1 downto 0);  -- NBIT_in bit inputs value
			B 		: in std_logic_vector(NBIT_in-1 downto 0);
			mulin_flag	: in std_logic;
			CLK		: in std_logic;
			RST		: in std_logic;
			MULready: out std_logic;
			P 		: out std_logic_vector( (2*NBIT_in)-1 downto 0)); -- output need double NUMBIT
end boothmul;



architecture structural of boothmul is

component negate is  --make_positive or make_negative
	generic (NBIT: integer:=8);	
	port (	A :	in	std_logic_vector(NBIT-1 downto 0);  -- value to be converted			
			Y :	out	std_logic_vector(NBIT-1 downto 0)); -- negative value of input
end component;

component shl1 is --shifter
	generic(NBIT: integer:=16);
	port (	A :	in	std_logic_vector(NBIT-1 downto 0);  -- NBIT bit inputs value
			Y :	out	std_logic_vector(NBIT-1 downto 0)); -- NBIT output value(shited input by 1bits)
end component;

component shl2 is --shifter
	generic(NBIT: integer:=16);
	port (	A :	in	std_logic_vector(NBIT-1 downto 0);  -- NBIT bit inputs value
			Y :	out	std_logic_vector(NBIT-1 downto 0)); -- NBIT output value(shited input by 1bits)
end component;

component shl3 is --shifter
	generic(NBIT: integer:=16);
	port (	A :	in	std_logic_vector(NBIT-1 downto 0);  -- NBIT bit inputs value
			Y :	out	std_logic_vector(NBIT-1 downto 0)); -- NBIT output value(shited input by 1bits)
end component;

component enc33 is  --LUT
	port (	A :	in	std_logic_vector(2 downto 0);  -- 3 bit inputs (Y+1,Y0,Y-1)
			Y :	out	std_logic_vector(2 downto 0)); -- 3 bit output to select between 5 mux inputs(0,A,-A,2A,-2A)
end component;

component mux51_gen is --MUX
	generic (NBIT :		integer := 32); --when generic mapping it we will use 2*NBIT
	port (	A0 :	in	std_logic_vector(NBIT-1 downto 0);
		A1 :	in	std_logic_vector(NBIT-1 downto 0);
		A2 :	in	std_logic_vector(NBIT-1 downto 0);
		A3 :	in	std_logic_vector(NBIT-1 downto 0);
		A4 :	in	std_logic_vector(NBIT-1 downto 0);
		SEL:    in	std_logic_vector(2 downto 0);		
		Y  :	out	std_logic_vector(NBIT-1 downto 0));
end component;

component P4_ADDER is
	generic (NBIT :		integer := 32);
	port (	
		A    :	in	std_logic_vector(NBIT-1 downto 0);			-- operand_1
		B    :	in	std_logic_vector(NBIT-1 downto 0);			-- operand_2
		Cin  :	in	std_logic;									-- carry in. Cin=1->sub, Cin=0->add
		S    :	out	std_logic_vector(NBIT-1 downto 0);			-- result of the p4 adder
		Cout :	out	std_logic;									-- carry out of the operation
		ovf  : out std_logic);									-- overflow signal
end component; 

-----------
--registers
-----------

--pipe stage 1 regs
signal flag_reg1: std_logic;
signal mux1_reg1: std_logic_vector(NBIT_in-1 downto 0);
signal mux2_reg1: std_logic_vector(NBIT_in-1 downto 0);
signal A4_reg1: std_logic_vector(NBIT_in-1 downto 0);

--pipe stage 2 regs
signal flag_reg2: std_logic;
signal mux_reg2: std_logic_vector(NBIT_in-1 downto 0);
signal sum_reg2: std_logic_vector(2*NBIT_in-1 downto 0);
signal A4_reg2: std_logic_vector(NBIT_in-1 downto 0);

--pipe stage 3 regs
signal flag_reg3: std_logic;
signal mux_reg3: std_logic_vector(NBIT_in-1 downto 0);
signal sum_reg3: std_logic_vector(2*NBIT_in-1 downto 0);

--encoder regs
signal enc_reg21, enc_reg31, enc_reg32: std_logic_vector(2 downto 0);





-------------
--connections
-------------

--stage 1
signal s_A_neg, s_2A_1, s_2A_1_neg, s_4A_1, s_4A_1_neg, s_8A_1, s_8A_1_neg	: std_logic_vector(NBIT_in-1 downto 0);
signal mux1_out, mux2_out													: std_logic_vector(NBIT_in-1 downto 0);
 
--stage 2
signal mux1_reg1_out_x2, mux2_reg1_out_x2									: std_logic_vector(2*NBIT_in-1 downto 0);
signal s_A_2, s_A_2_neg, s_2A_2, s_2A_2_neg									: std_logic_vector(NBIT_in-1 downto 0);
signal mux_2_out															: std_logic_vector(NBIT_in-1 downto 0);

--stage 3
signal s_A_3, s_A_3_neg, s_2A_3, s_2A_3_neg									: std_logic_vector(NBIT_in-1 downto 0);
signal mux_reg2_out_x2														: std_logic_vector(2*NBIT_in-1 downto 0);
signal mux_3_out															: std_logic_vector(NBIT_in-1 downto 0);
signal sum_2_out															: std_logic_vector(2*NBIT_in-1 downto 0);

--stage 4
signal mux_reg3_out_x2														: std_logic_vector(2*NBIT_in-1 downto 0);
signal sum_3_out															: std_logic_vector(2*NBIT_in-1 downto 0);

--encoder signals
signal bb: std_logic_vector(NBIT_in downto 0);	--vector B which also includes index b-1
type sel_Arr is array (3 downto 0) of std_logic_vector(2 downto 0); --selection signals for each enc-mux
signal s_sel: sel_Arr;	 --this is the selection signal, the length is based on the radix we use(4). so we will use B values in groups of 3 and the select signal of the mux is in 3 bits to select between 5 inputs
signal s_sel31_32: std_logic_vector(2 downto 0);



begin


clk_proc: process(CLK,RST)
begin
	if(RST='0') then
		flag_reg1 	<= '0';
		mux1_reg1	<= (others=>'0');
		mux2_reg1	<= (others=>'0');
		A4_reg1		<= (others=>'0');
		
		flag_reg2 	<= '0';
		mux_reg2	<= (others=>'0');
		sum_reg2	<= (others=>'0');
		A4_reg2		<= (others=>'0');
		
		flag_reg3 	<= '0';
		mux_reg3	<= (others=>'0');
		sum_reg3	<= (others=>'0');
		
		enc_reg21	<= (others=>'0');
		enc_reg31	<= (others=>'0');
		enc_reg32	<= (others=>'0');
		
	
	elsif(rising_edge(CLK)) then
	
		flag_reg1	<= mulin_flag;
		mux1_reg1	<= mux1_out;
		mux2_reg1	<= mux2_out;
		A4_reg1		<= s_8A_1;
		
		flag_reg2 	<= flag_reg1;
		mux_reg2	<= mux_2_out; 
		sum_reg2	<= sum_2_out;
		A4_reg2		<= s_2A_2;
		
		flag_reg3 	<= flag_reg2;
		mux_reg3	<= mux_3_out;
		sum_reg3	<= sum_3_out;
		
		enc_reg21	<= s_sel(2);
		enc_reg31  	<= s_sel(3);
		enc_reg32	<= s_sel31_32;
	
	end if;
	


end process clk_proc;

-- this will include index b-1.
bb <= B & '0';

--generation of all encoders in stage1. 
encoders: for i in 0 to 3 generate
	enc: enc33
	port map(A=>bb((2*i+1)+1 downto (2*i+1)-1),Y=>s_sel(i));
end generate;

s_sel31_32<= enc_reg31;  -- this signal just connects the encoder registers of stage3 (Two registers are used)	


-----------------
--stage1
----------------

	shift2A: shl1
	generic map(NBIT=>NBIT_in)
	port map(A=>A, Y=> s_2A_1);
	
	shift4A: shl2
	generic map(NBIT=>NBIT_in)
	port map(A=>A, Y=> s_4A_1);
	
	shift8A: shl3
	generic map(NBIT=>NBIT_in)
	port map(A=>A, Y=> s_8A_1);
	
	neg1: negate
	generic map(NBIT=>NBIT_in)
	port map(A=>A, Y=>s_A_neg);

	neg2: negate
	generic map(NBIT=>NBIT_in)
	port map(A=>s_2A_1, Y=>s_2A_1_neg);
	
	neg3: negate
	generic map(NBIT=>NBIT_in)
	port map(A=>s_4A_1, Y=>s_4A_1_neg);
	
	neg4: negate
	generic map(NBIT=>NBIT_in)
	port map(A=>s_8A_1, Y=>s_8A_1_neg);

	mux1: mux51_gen
	generic map(NBIT=>NBIT_in)
	port map(A0=>(others=>'0'), A1=>A, A2=>s_A_neg, A3=>s_2A_1, A4=>s_2A_1_neg, SEL=>s_sel(0),Y=>mux1_out);
	
	mux2: mux51_gen
	generic map(NBIT=>NBIT_in)
	port map(A0=>(others=>'0'), A1=>s_4A_1, A2=>s_4A_1_neg, A3=>s_8A_1, A4=>s_8A_1_neg, SEL=>s_sel(1),Y=>mux2_out);
	
	
-----------------
--stage2
-----------------

	shift2A_2: shl1
	generic map(NBIT=>NBIT_in)
	port map(A=>A4_reg1, Y=> s_A_2);
	
	shift4A_2: shl2
	generic map(NBIT=>NBIT_in)
	port map(A=>A4_reg1, Y=> s_2A_2);
	
	neg5: negate
	generic map(NBIT=>NBIT_in)
	port map(A=>s_A_2, Y=>s_A_2_neg);
	
	neg6: negate
	generic map(NBIT=>NBIT_in)
	port map(A=>s_2A_2, Y=>s_2A_2_neg);
	
	mux3: mux51_gen
	generic map(NBIT=>NBIT_in)
	port map(A0=>(others=>'0'), A1=>s_A_2, A2=>s_A_2_neg, A3=>s_2A_2, A4=>s_2A_2_neg, SEL=>enc_reg21,Y=>mux_2_out);
	
	
	--32->64 bits
	mux1_reg1_out_x2(2*NBIT_in-1 downto NBIT_in)<=(others=>mux1_reg1(NBIT_in-1));  -- MAYBE IT IS BETTER TO USE AN EXTENDER INSTEAD
	mux1_reg1_out_x2(NBIT_in-1 downto 0)<=mux1_reg1;
	mux2_reg1_out_x2(2*NBIT_in-1 downto NBIT_in)<=(others=>mux2_reg1(NBIT_in-1));
	mux2_reg1_out_x2(NBIT_in-1 downto 0)<=mux2_reg1;
	
	
	SUM1: P4_ADDER
	generic map(NBIT=>2*NBIT_in)
	port map(A=>mux1_reg1_out_x2,B=>mux2_reg1_out_x2,Cin=>'0',S=>sum_2_out,Cout=>open,ovf=>open);

	
-----------------
--stage3
-----------------

	shift2A_3: shl1
	generic map(NBIT=>NBIT_in)
	port map(A=>A4_reg2, Y=> s_A_3);
	
	shift4A_3: shl2
	generic map(NBIT=>NBIT_in)
	port map(A=>A4_reg2, Y=> s_2A_3);
	
	neg7: negate
	generic map(NBIT=>NBIT_in)
	port map(A=>s_A_3, Y=>s_A_3_neg);
	
	neg8: negate
	generic map(NBIT=>NBIT_in)
	port map(A=>s_2A_3, Y=>s_2A_3_neg);
	
	mux4: mux51_gen
	generic map(NBIT=>NBIT_in)
	port map(A0=>(others=>'0'), A1=>s_A_3, A2=>s_A_3_neg, A3=>s_2A_3, A4=>s_2A_3_neg, SEL=>enc_reg32,Y=>mux_3_out);
	
	
	--32->64 bits
	mux_reg2_out_x2(2*NBIT_in-1 downto NBIT_in)<=(others=>mux_reg2(NBIT_in-1));
	mux_reg2_out_x2(NBIT_in-1 downto 0)<=mux_reg2;
	
	
	SUM2: P4_ADDER
	generic map(NBIT=>2*NBIT_in)
	port map(A=>sum_reg2,B=>mux_reg2_out_x2,Cin=>'0',S=>sum_3_out,Cout=>open,ovf=>open);


-----------------
--stage4
-----------------

	--32->64 bits
	mux_reg3_out_x2(2*NBIT_in-1 downto NBIT_in)<=(others=>mux_reg3(NBIT_in-1));
	mux_reg3_out_x2(NBIT_in-1 downto 0)<=mux_reg3;
	
	SUM3: P4_ADDER
	generic map(NBIT=>2*NBIT_in)
	port map(A=>sum_reg3,B=>mux_reg3_out_x2,Cin=>'0',S=>P,Cout=>open,ovf=>open);
	
	MULready <= flag_reg3;
	
	
end Structural;
