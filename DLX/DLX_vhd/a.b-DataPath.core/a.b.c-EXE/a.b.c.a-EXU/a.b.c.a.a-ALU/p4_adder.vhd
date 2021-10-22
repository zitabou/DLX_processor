library ieee; 
use ieee.std_logic_1164.all; 
use ieee.std_logic_unsigned.all;

entity P4_ADDER is
	generic (NBIT :		integer := 32);
	port (	
		A    :	in	std_logic_vector(NBIT-1 downto 0);			-- operand_1
		B    :	in	std_logic_vector(NBIT-1 downto 0);			-- operand_2
		Cin  :	in	std_logic;									-- carry in. Cin=1->sub, Cin=0->add
		S    :	out	std_logic_vector(NBIT-1 downto 0);			-- result of the p4 adder
		Cout :	out	std_logic;									-- carry out of the operation
		ovf  : out std_logic);									-- overflow signal
end P4_ADDER;

architecture STRUCTURAL of p4_adder is
	constant BPB: integer:=4;	--Bit per block
	
	component CARRY_GENERATOR is
		generic (NBIT :		integer := 32;
			NBIT_PER_BLOCK: integer := 4);
		port (
			A :	in	std_logic_vector(NBIT-1 downto 0);
			B :	in	std_logic_vector(NBIT-1 downto 0);
			Cin :	in	std_logic;
			Co :	out	std_logic_vector((NBIT/NBIT_PER_BLOCK)-1 downto 0) );
	end component;

	component sum_generator is
		generic (n_bit: integer := 32;
		 	n_CSB: integer := 8); -- 32/8=4(step width)	Csarry select blocks 
		Port (	A:	In	std_logic_vector(n_bit-1 downto 0);
			B:	In	std_logic_vector(n_bit-1 downto 0);
			C_in:	In	std_logic_vector(n_CSB-1 downto 0);
			S:	Out	std_logic_vector(n_bit-1 downto 0));
	end component;

	-- the xor will be used to obtain the real value of b, which will be different from the input one if we do a sub(cin = '1'). the cin is considered in the carry_generator and introduced in the equation in the first G_block
	component my_xor
		port (
			a   	:	in	std_logic;
			b   	:	in	std_logic;
			xor_out :	out	std_logic);
	end component;

	signal xor_b: std_logic_vector (NBIT-1 downto 0); --this signal will be used as the result of b XOR cin. It is a step before the pg network just to take into account the sub(cin=1)/add(cin=0) case	

	--CSB=8, BPB=4, NBIT=32 => BPB=NBIT/CSB, CSB=NBIT/BPB 
	signal carry:	std_logic_vector((NBIT/BPB)-1 downto 0);
	signal temp_c: 	std_logic_vector((NBIT/BPB)-1 downto 0);
	
	signal t_s: std_logic_vector(NBIT-1 downto 0);


	begin

	--this is the layer before the pg network which operates the xor between b and c so that we can complement b if we want to operate a sub
	xor_net: for i in NBIT-1 downto 0 generate
		bc_xor: my_xor 
		port map (a=>b(i), b=>Cin, xor_out=>xor_b(i));
	end generate;
	--()now we have the real b in xor_b




	CG: CARRY_GENERATOR
	generic map(NBIT => NBIT,
		    NBIT_PER_BLOCK => BPB)
	port map(A => A,
		 B => xor_b,
		 Cin => Cin,
		 Co => carry);	
----------
--this is done because the first carry of the carry gen is the carry of the fourth bit, not of the first. The last carry is not
--used in the sum but only for the carry out. That's why we shifted in the carry in to the result of the carry_gen
	temp_c<=carry((NBIT/BPB)-2 downto 0) & Cin;  
----------
	SG: sum_generator
	generic map(n_bit => NBIT,
		    n_CSB => NBIT/BPB)
	port map(A => A,
		 B => xor_b,
		 C_in => temp_c,
		 S=>t_s);
	
	Cout<=carry((NBIT/BPB)-1); --see comment for temp_c





















--The following code implements the ovf signal. This signal is high when the two operands of the sum have the same sign but the result has a different one. This is the case when adding two very big positive numbers that change the sign duw to the carry out. This will have as a result a wrong value but the cout will be low. So an indication of overflow is the ovf signal.

--It was NOT included in the P4_adder analysis because in the testebch provided the P4_adder entity did not have such signal.
--To enable it
--1) uncomment the two lines below and the t_s signal definition
--2) t_ovf must be the output in the sum_gen map
--3) add "ovf: out std_logic;" in entity definition AND in test bench.
------------

	S<=t_s;
	ovf<=( A(NBIT-1) XNOR xor_b(NBIT-1) ) AND ( A(NBIT-1) XOR t_s(NBIT-1) );


end architecture STRUCTURAL;



