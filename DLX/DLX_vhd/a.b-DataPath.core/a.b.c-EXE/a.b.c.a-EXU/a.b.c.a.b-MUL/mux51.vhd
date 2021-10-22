library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use ieee.math_real.all;

entity mux51_gen is
	generic (
		NBIT :		integer := 32);
	port (
		A0 :	in	std_logic_vector(NBIT-1 downto 0);
		A1 :	in	std_logic_vector(NBIT-1 downto 0);
		A2 :	in	std_logic_vector(NBIT-1 downto 0);
		A3 :	in	std_logic_vector(NBIT-1 downto 0);
		A4 :	in	std_logic_vector(NBIT-1 downto 0);
		SEL:    in	std_logic_vector(2 downto 0);		
		Y  :	out	std_logic_vector(NBIT-1 downto 0));
end mux51_gen;

architecture data_fl of mux51_gen is
begin

	Y<= A0 WHEN (SEL = "000") ELSE
	    A1 WHEN (SEL = "001") ELSE
	    A2 WHEN (SEL = "010") ELSE
	    A3 WHEN (SEL = "011") ELSE
	    A4 WHEN (SEL = "100") ELSE
	    (others=>'0');

end data_fl;
