library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use WORK.DLX_constants.all;
use WORK.DLX_functions.all;

entity EXU is
	generic(N: integer:=32);  --input bits
	port ( DATA1, DATA2: IN std_logic_vector(N-1 downto 0);			-- operands
  		   FUNC: 		IN std_logic_vector(FUN_BITS-1 downto 0);		-- operation to be executed
  		   RD_in: 		IN std_logic_vector(log2(num_reg)-1 downto 0);
  		   SN: 			IN std_logic;         							-- indicator of signed(1)/unsigned(0) operation
  		   CLK:			IN std_logic;
  		   RST:			IN std_logic;
           OVF:			OUT std_logic;
           stall_flag: 	OUT std_logic;
		   RD_sel_flag: OUT std_logic;									-- overflow signal
           OUTPUT: 		OUT std_logic_vector(N-1 downto 0);
           RD_stall:	OUT std_logic_vector(log2(num_reg)-1 downto 0);
           RD_out: 		OUT std_logic_vector(log2(num_reg)-1 downto 0);
           H_MULOUT: 	OUT std_logic_vector(N-1 downto 0));			-- result of the operation
end EXU;



architecture structural of EXU is

component ALU is
  generic (N : integer := 8);
  port 	 ( DATA1, DATA2: IN std_logic_vector(N-1 downto 0);			-- operands
  		   FUNC: 	IN std_logic_vector(FUN_BITS-1 downto 0);		-- operation to be executed
  		   SN: 		IN std_logic;         							-- indicator of signed(1)/unsigned(0) operation
           OVF:		OUT std_logic;									-- overflow signal
           OUTALU: 	OUT std_logic_vector(N-1 downto 0));			-- result of the operation
end component;

component boothmul is
	generic(NBIT_in: integer:=32);  --input bits
	port (	A 		: in std_logic_vector(NBIT_in-1 downto 0);  -- NBIT_in bit inputs value
			B 		: in std_logic_vector(NBIT_in-1 downto 0);
			mulin_flag	: in std_logic;
			CLK		: in std_logic;
			RST		: in std_logic;
			MULready		: out std_logic;
			P 		: out std_logic_vector( (2*NBIT_in)-1 downto 0)); -- output need double NUMBIT
end component;

component MUX21_GENERIC is
  GENERIC(NBIT: integer:= 4);      
  PORT(A:   in  std_logic_vector(NBIT-1 downto 0);
       B:   in  std_logic_vector(NBIT-1 downto 0);
       SEL:	In	std_logic;
       Y:   out std_logic_vector(NBIT-1 downto 0));
end component;


	signal s_flag_in, s_MULready	: std_logic;
	signal s_mul_out	: std_logic_vector(2*N-1 downto 0);
	signal s_ALUout		: std_logic_vector(N-1 downto 0);
	signal s_RD_in		: std_logic_vector(log2(num_reg)-1 downto 0);
	
	--RD_pipe regs
	signal RD_reg1, RD_reg2, RD_reg3 : std_logic_vector(log2(num_reg)-1 downto 0);
	signal mul_flag_reg1, mul_flag_reg2:std_logic;

begin


	RD_pipe_proc: process(CLK,RST)
	begin
		if(RST='0') then
		
			RD_reg1<=(others=>'0');
			RD_reg2<=(others=>'0');
			RD_reg3<=(others=>'0');
			
			mul_flag_reg1 <='0';
			mul_flag_reg2 <='0';
			
		elsif(rising_edge(CLK)) then
		
			RD_reg1<=s_RD_in;
			mul_flag_reg1<=s_flag_in;
			
			RD_reg2<=RD_reg1;
			mul_flag_reg2<=mul_flag_reg1;
			
			RD_reg3<=RD_reg2;
		end if;
	
	
	end process RD_pipe_proc;

	
	s_flag_in<= '1' when unsigned(func)=unsigned(MUL) else
				'0';
	s_RD_in<= RD_in when unsigned(func)=unsigned(MUL) else
			  (others=>'0');
	
	ALU1: ALU
	generic map(N=>N)
	port map(DATA1=>DATA1, DATA2=>DATA2, FUNC=>FUNC, SN=>SN, OVF=>OVF, OUTALU=>s_ALUout);
	
	
	MUL: BOOTHMUL
	generic map(NBIT_in=>N)
	port map(A=>DATA1, B=>DATA2, mulin_flag => s_flag_in, CLK=>CLK, RST=>RST, MULready=>s_MULready, P=>s_mul_out);
	
	OUTPUT_MUX: MUX21_GENERIC
	generic map(NBIT=>N)
	port map(A=>s_ALUout, B=>s_mul_out(N-1 downto 0), SEL=>s_MULready, Y=>OUTPUT);   --a->0, b->1, ...
	
	H_MULOUT <= s_mul_out(2*N-1 downto N);
	
	RD_stall 	<= RD_reg1;
	stall_flag 	<= mul_flag_reg2;
	RD_out	 	<= RD_reg3;
	RD_sel_flag <= s_MULready;

	
end Structural;
