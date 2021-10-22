library ieee; 
use ieee.std_logic_1164.all; 
use ieee.std_logic_unsigned.all;

entity sum_generator is
	generic (n_bit: integer := 32;
		 n_CSB: integer := 8); -- 32/8->4(step width)
		 
	Port (	A:	In	std_logic_vector(n_bit-1 downto 0);
		B:	In	std_logic_vector(n_bit-1 downto 0);
		C_in:	In	std_logic_vector(n_CSB-1 downto 0);
		S:	Out	std_logic_vector(n_bit-1 downto 0));
end sum_generator;

architecture STRUCTURAL of sum_generator is

	component carry_select_block is
	generic (n: integer);		 
	Port (	A:	In	std_logic_vector(n-1 downto 0);
		B:	In	std_logic_vector(n-1 downto 0);
		C_sel:	In	std_logic;
		S:	Out	std_logic_vector(n-1 downto 0));

	end component carry_select_block;



	begin
	
	gen1: for i in 0 to n_CSB-1 generate
	begin
		csb: carry_select_block generic map(n => (n_bit/n_CSB)) 
  	     	   			port map( 
  	     	   			A => A(((n_bit/n_CSB)*(i+1)-1) downto ((n_bit/n_CSB)*i)),
						B => B(((n_bit/n_CSB)*(i+1)-1) downto ((n_bit/n_CSB)*i)),
						C_sel => C_in(i),
						S => S(((n_bit/n_CSB)*(i+1)-1) downto ((n_bit/n_CSB)*i)));
	end generate;

end architecture STRUCTURAL;

