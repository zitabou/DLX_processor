library ieee; 
use ieee.std_logic_1164.all; 

-- Entity declaration
entity nand41 is
    port (in1: in  std_logic;
          in2: in  std_logic;
          in3: in  std_logic;
          in4: in  std_logic;
          o  : out std_logic);
end nand41;

-- Behavioral description
architecture behavioral of nand41 is
begin

    process (in1, in2, in3, in4)
    begin
        o <= not (in1 and in2 and in3 and in4);
    end process;
    
end behavioral;
