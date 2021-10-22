library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

entity shl2 is
	generic(NBIT: integer:=16);
	port (	A :	in	std_logic_vector(NBIT-1 downto 0);  -- NBIT bit inputs value
		Y :	out	std_logic_vector(NBIT-1 downto 0)); -- NBIT output value(shited input by 1bits)
end shl2;

architecture behavioral of shl2 is
begin

		Y <= A(NBIT-3 downto 0) & "00";

end behavioral;
