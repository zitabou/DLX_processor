library IEEE;
use IEEE.std_logic_1164.all; --  libreria IEEE con definizione tipi standard logic

entity MUX51 is
	Port (	A:	In	std_logic;
		B:	In	std_logic;
		C:	In	std_logic;
		D:	In	std_logic;
		E:	In	std_logic;
		S:	In	std_logic_vector(2 downto 0);
		Y:	Out	std_logic);
end MUX51;


-- in all the behavioral descriptions we added the delays. But we used the BEHAVIORAL_1 in the mux_generic.
architecture BEHAVIORAL of MUX51 is

begin
	WITH s SELECT
    y<= A WHEN "000",
        B WHEN "001",
        C WHEN "010",
        D WHEN "011",
        E WHEN OTHERS;  -- all selects with MSB to one are packed.

end BEHAVIORAL;
