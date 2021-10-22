library IEEE;
use IEEE.std_logic_1164.all; --  libreria IEEE con definizione tipi standard logic
use IEEE.numeric_std.all;

entity MUX81 is
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
end MUX81;


-- in all the behavioral descriptions we added the delays. But we used the BEHAVIORAL_1 in the mux_generic.
architecture BEHAVIORAL_1 of MUX81 is

begin


    y<= A WHEN unsigned(s)=0 else
        B WHEN unsigned(s)=1 else
        C WHEN unsigned(s)=2 else
        D WHEN unsigned(s)=3 else
        E WHEN unsigned(s)=4 else
        F WHEN unsigned(s)=5 else
        G WHEN unsigned(s)=6 else
        H WHEN unsigned(s)=7 else
        A ;

end BEHAVIORAL_1;
