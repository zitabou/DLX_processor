library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

entity shl3 is
	generic(NBIT: integer:=16);
	port (	A :	in	std_logic_vector(NBIT-1 downto 0);  -- NBIT bit inputs value
		Y :	out	std_logic_vector(NBIT-1 downto 0)); -- NBIT output value(shited input by 1bits)
end shl3;

architecture behavioral of shl3 is
begin

		Y <= A(NBIT-4 downto 0) & "000";

end behavioral;
