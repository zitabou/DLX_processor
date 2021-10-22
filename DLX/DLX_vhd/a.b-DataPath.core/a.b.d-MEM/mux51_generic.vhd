library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity MUX51_GENERIC is
  GENERIC(NBIT: integer:= 4);      
  PORT(A:   in  std_logic_vector(NBIT-1 downto 0);
       B:   in  std_logic_vector(NBIT-1 downto 0);
       C:   in  std_logic_vector(NBIT-1 downto 0);
       D:   in  std_logic_vector(NBIT-1 downto 0);
       E:   in  std_logic_vector(NBIT-1 downto 0);
       SEL: In	std_logic_vector(2 downto 0);
       Y:   out std_logic_vector(NBIT-1 downto 0));
end MUX51_GENERIC;

    
architecture structural of MUX51_GENERIC is

  component MUX51
	Port (	A:	In	std_logic;
		B:	In	std_logic;
		C:	In	std_logic;
		D:	In	std_logic;
		E:	In	std_logic;
		S:	In	std_logic_vector(2 downto 0);
		Y:	Out	std_logic);
  end component;
  
begin

-- generating a number of single bit 2:1 muxes equal to the number of bits in the bus mux. each bit couple of the same position are inputs of a mux21 and the output is the output bit at the same position 
  multiplexer: for I in 0 to NBIT-1 generate
    MUXES : MUX51
	  Port Map (A=>A(i), B=>B(i), C=>C(i), D=>D(i), E=>E(i), S=>SEL, Y=>Y(i)); 
  end generate;

end structural;



