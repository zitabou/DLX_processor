library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity MUX21_GENERIC is
  GENERIC(NBIT: integer:= 4);      
  PORT(A:   in  std_logic_vector(NBIT-1 downto 0);
       B:   in  std_logic_vector(NBIT-1 downto 0);
       SEL: in  std_logic;
       Y:   out std_logic_vector(NBIT-1 downto 0));
end MUX21_GENERIC;

    
architecture structural of MUX21_GENERIC is

  component MUX21
    	Port (	A:	In	std_logic;
		B:	In	std_logic;
		S:	In	std_logic;
		Y:	Out	std_logic);
  end component;
  
begin

-- generating a number of single bit 2:1 muxes equal to the number of bits in the bus mux. each bit couple of the same position are inputs of a mux21 and the output is the output bit at the same position 
    multiplexer: for I in 0 to NBIT-1 generate
    MUXES : MUX21
	  Port Map (A=>A(i), B=>B(i), S=>SEL, Y=>Y(i)); 
  end generate;

  end structural;



