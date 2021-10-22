library IEEE;
use IEEE.std_logic_1164.all;
use ieee.numeric_std.all;
use WORK.DLX_constants.all;
use WORK.DLX_functions.all;


entity register_file is
    generic (
	NBIT: integer := data_size;
	NREG: integer := num_reg);
    port (
	  RESET: 	IN  std_logic;
	  ENABLE: 	IN  std_logic;
	  RD1: 		IN  std_logic;
	  RD2: 		IN  std_logic;
	  WR: 		IN  std_logic;
	  ADD_WR: 	IN  std_logic_vector(Log2(NREG)-1 downto 0);
	  ADD_RD1: 	IN  std_logic_vector(Log2(NREG)-1 downto 0);
	  ADD_RD2: 	IN  std_logic_vector(Log2(NREG)-1 downto 0);
	  DATAIN: 	IN  std_logic_vector(NBIT-1 downto 0);
	  OUT1: 	OUT std_logic_vector(NBIT-1 downto 0);
	  OUT2: 	OUT std_logic_vector(NBIT-1 downto 0));
end register_file;

architecture Behavioral of register_file is

	subtype REG_ADDR is natural range 0 to NREG-1; -- REG_ADDR is a subset of natural with values from 0 to 31. This will be the number of registers of the register file and it will be used as row number in the Register array
	type REG_ARRAY is array(REG_ADDR) of std_logic_vector(NBIT-1 downto 0); -- this is a type consisting in an array of many elements of NBIT bits as many as the REG_ADDR range
	signal REGISTERS : REG_ARRAY; -- this is the signal that will represent the whole RF




begin 

    process (REGISTERS,ENABLE,RESET,RD1,RD2,WR,ADD_WR,ADD_RD1,ADD_RD2,DATAIN) --this process is activated only when the clock changes
    begin 
        if (RESET = '0') then -- synch. reset is the highest priority event active low

            for i in 0 to NREG - 1 loop
                REGISTERS(i) <= (others=>'0');	-- all regs are set to 0
            end loop;
                
            OUT1 <= (others=>'0'); -- also outputs are set to 0, since the only possible output is zero
            OUT2 <= (others=>'0'); -- even thought the outputs should not be connected to any register
        
        else
            if(ENABLE = '1' AND RD1 = '1') then
                OUT1 <= REGISTERS(to_integer(unsigned(ADD_RD1))); -- register addressed by ADD_RD1 (given as input to RF) is assigned to output 1
            end if;    
            
            if (ENABLE = '1' AND RD2 = '1') then
			     OUT2 <= REGISTERS(to_integer(unsigned(ADD_RD2))); -- register addressed by ADD_RD2 (given as input to RF) is assigned to output 2
	    end if;
			if (unsigned(ADD_WR) = 0 ) then
				REGISTERS(to_integer(unsigned(ADD_WR))) <= (others=>'0'); -- writing to address zero results in writing zero because it is constant. This way the synthesis will not see it as a constant.
            elsif (WR = '1' ) then
			     REGISTERS(to_integer(unsigned(ADD_WR))) <= DATAIN; -- data given as input in DATAIN is assigned to register addressed by ADD_WR (given as input to RF)
	    end if;
			
         end if;       

    end process;
    
      
   
  
end Behavioral;
