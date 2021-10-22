library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

entity shl1 is
	generic(NBIT: integer:=16);
	port (	A :	in	std_logic_vector(NBIT-1 downto 0);  -- NBIT bit inputs value
		Y :	out	std_logic_vector(NBIT-1 downto 0)); -- NBIT output value(shited input by 1bits)
end shl1;

architecture datafl of shl1 is
begin

		Y <= A(NBIT-2 downto 0) & '0';

end datafl;
