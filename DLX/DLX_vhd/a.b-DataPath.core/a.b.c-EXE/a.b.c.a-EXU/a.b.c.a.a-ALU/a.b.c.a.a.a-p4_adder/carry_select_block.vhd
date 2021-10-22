library ieee; 
use ieee.std_logic_1164.all; 
use ieee.std_logic_unsigned.all;

entity carry_select_block is
	generic (n: integer := 4); --number of bits per RCA	 
	Port (	A:	In	std_logic_vector(n-1 downto 0);  --inputA to the RCA
		B:	In	std_logic_vector(n-1 downto 0);	 --inputB to the RCA
		C_sel:	In	std_logic;
		S:	Out	std_logic_vector(n-1 downto 0));

end carry_select_block;

architecture STRUCTURAL of carry_select_block is

	component RCA_GEN
		generic (NBIT:          Integer:=1);
		Port (	A:	In	std_logic_vector(n-1 downto 0);
			B:	In	std_logic_vector(n-1 downto 0);
			Ci:	In	std_logic;
			S:	Out	std_logic_vector(n-1 downto 0);
			Co:	Out	std_logic);
	end component RCA_GEN; 
	
	component MUX21_generic
	generic (NBIT: integer:= 4);
	Port (	A:	In	std_logic_vector(n-1 downto 0); 
		B:	In	std_logic_vector(n-1 downto 0);
		SEL:	In	std_logic;
		Y:	Out	std_logic_vector(n-1 downto 0));
	end component MUX21_generic ;

	signal sum0,sum1 : std_logic_vector(n-1 downto 0);

begin
	--Co is not used. By using open keyword the synthesis will remove it. Avoiding leaving it floating
  	RCA0: RCA_GEN   generic map(NBIT => n)	    
  	     	   	port map( A => A,  B => B, Ci => '0', S => sum0, Co => open); 
	RCA1: RCA_GEN   generic map(NBIT => n)
  	    	   	port map( A => A,  B => B, Ci => '1', S => sum1, Co => open);
	mux: MUX21_generic generic map(NBIT => n)
			   port map( A => sum0,  B => sum1, SEL => C_sel, Y => S);


end architecture STRUCTURAL;
