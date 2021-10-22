library IEEE;
use IEEE.std_logic_1164.all;
use ieee.numeric_std.all;
use WORK.DLX_constants.all;
use WORK.DLX_functions.all;

entity DRAM is
    generic ( NBIT: integer := data_size;
	      NREG: integer := num_reg);
    port (CLK: 		IN  std_logic;
	  RESET: 		IN  std_logic;
	  ENABLE: 		IN  std_logic;
 	  RD:	 		IN  std_logic;	--(RnW)
	  data_size: 	IN  std_logic_vector( 1 downto 0);			-- singals towards the memory. one bit for each byte of the word. This way we enable byte by byte	
	  ADDR: 		IN  std_logic_vector(Log2(NREG)-1 downto 0);
	  DATA_IN: 		IN  std_logic_vector(NBIT-1 downto 0);
	  DATA_OUT: 	OUT std_logic_vector(NBIT-1 downto 0));
end DRAM;

architecture Behavioral of DRAM is

	subtype REG_ADDR is natural range 0 to NREG-1; -- REG_ADDR is a subset of natural with values from 0 to 31. This will be the number of registers of the register file and it will be used as row number in the Register array
	type REG_ARRAY is array(REG_ADDR) of std_logic_vector(7 downto 0); -- this is a type consisting in an array of many elements of NBIT bits as many as the REG_ADDR range
	signal MEMORY : REG_ARRAY; -- this is the signal that will represent the MEM



begin 

    process (CLK,RESET) 										--this process is activated only when the clock changes
    begin
		
        if (RESET = '0') then 									-- synch. reset is the highest priority event active low

            	for i in 0 to NREG - 1 loop
                	MEMORY(i) <= (others=>'0');					-- all locations are set to 0
            	end loop;
                
            	DATA_OUT <= (others=>'0'); 						-- also outputs are set to 0, since the only possible output is zero
        
        elsif(falling_edge(CLK))then							-- no concurrent read/write is possible
        	if(ENABLE ='1') then				 			
				if(RD='1') then       									-- it works as a read notWrite
					for i in 0 to (NBIT/8)-1 loop
						DATA_OUT(NBIT-i*8-1 downto NBIT-i*8-8) <= MEMORY(to_integer(unsigned(ADDR))+i);  --Big endian
					end loop;
				else							
					if(unsigned(DATA_size) = 0) then																	--byte
						MEMORY(to_integer(unsigned(ADDR))) <= DATA_IN(7 downto 0);
					elsif(unsigned(DATA_size) = 1) then																	--lower halfword
						for i in 0 to (NBIT/16)-1 loop
							MEMORY(to_integer(unsigned(ADDR)+i)) <= DATA_IN(NBIT/2 -i*8 -1 downto NBIT/2-i*8-8);
						end loop;
					elsif(unsigned(DATA_size) = 2) then																	--higher halfword
						for i in 0 to (NBIT/16)-1 loop
							MEMORY(to_integer(unsigned(ADDR)+i)) <= DATA_IN(NBIT -i*8 -1 downto NBIT-i*8-8);
						end loop;
					elsif(unsigned(DATA_size) = 3) then																	--word
						for i in 0 to (NBIT/8)-1 loop
							MEMORY(to_integer(unsigned(ADDR)+i)) <= DATA_IN(NBIT -i*8 -1 downto NBIT-i*8-8);
						end loop;
					end if;
				end if;			
     		end if; 
     	end if;      

    end process;
    
      
   
  
end Behavioral;
