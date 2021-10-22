library ieee; 
use ieee.std_logic_1164.all; 
use WORK.DLX_constants.all;


-- Entity declaration
entity nand31 is
    port (in1: in  std_logic;
          in2: in  std_logic;
          in3: in  std_logic;
          o  : out std_logic);
end nand31;

-- Behavioral description
architecture behavioral of nand31 is
begin

    process (in1, in2, in3)
    begin
        o <= not (in1 and in2 and in3);
    end process;
    
end behavioral;
