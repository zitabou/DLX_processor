library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

entity enc33 is
	port (	A :	in	std_logic_vector(2 downto 0);  -- 3 bit inputs (Y+1,Y0,Y-1)
		Y :	out	std_logic_vector(2 downto 0)); -- 3 bit output to select between 5 mux inputs(0,A,-A,2A,-2A)
end enc33;

architecture behavioral of enc33 is
begin

	process(A)
	begin
		CASE A is
			WHEN "001"|"010" => Y<="001";   --   A
			WHEN "101"|"110" => Y<="010";   --  -A
			WHEN "011"	 => Y<="011";   --  2A
			WHEN "100" 	 => Y<="100";   -- -2A
			WHEN others 	 => Y<="000";   --   0
		end case;
	end process;

end behavioral;
