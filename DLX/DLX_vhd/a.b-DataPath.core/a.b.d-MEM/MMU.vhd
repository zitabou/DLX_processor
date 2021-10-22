library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use WORK.DLX_constants.all;
use WORK.DLX_functions.all;



entity MMU is
    GENERIC(WORD_size: integer:= data_size);
    Port(
	Wrd:	 IN std_logic;
    BHU0:	 IN std_logic;   
	
	wdata_size: OUT std_logic_vector( 1 downto 0)    -- singals towards the memory. 00->byte, 01->lower_halfword, 10->higher_halfword, 11->word

	);

end MMU;

architecture Behavioral of MMU is

begin


logic: process(Wrd, BHU0)
begin	
	if(Wrd ='1') then											
		wdata_size <= "11";
	elsif(BHU0 = '1') then
		wdata_size <= "01";
	elsif(BHU0 = '0') then
		wdata_size <= "00";
	end if;
	--should add something for the higher halfword

end process logic;



end Behavioral;
