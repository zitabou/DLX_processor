library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity MUX81_GENERIC is
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
end MUX81_GENERIC;

    
architecture structural of MUX81_GENERIC is

component MUX81 is
	Port (	A:	In	std_logic;
		B:	In	std_logic;
		C:	In	std_logic;
		D:	In	std_logic;
		E:	In	std_logic;
		F:	In	std_logic;
		G:	In	std_logic;
		H:	In	std_logic;
		S:	In	std_logic_vector(2 downto 0);
		Y:	Out	std_logic);
end component;

  
begin


  multiplexer: for I in 0 to NBIT-1 generate
    MUXES : MUX81
	  Port Map (A=>A(i), B=>B(i), C=>C(i), D=>D(i), E=>E(i), F=>F(i), G=>G(i), H=>H(i), S=>SEL, Y=>Y(i)); 
  end generate;

end structural;



