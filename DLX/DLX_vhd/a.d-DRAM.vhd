library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use std.textio.all;
use ieee.std_logic_textio.all;

use WORK.DLX_constants.all;
use WORK.DLX_functions.all;


-- main memory for DLX
-- this memory is accessed for the read/write operations
entity DRAM is
  generic (
    RAM_DEPTH : integer := 64;   	-- 64 WORDS and 512 addresses(it is byte addressable so 512 bytes or 64 words)			
    NBIT : integer := 32);
  port (
  		CLK	 		: IN  std_logic;
    	RESET		: IN  std_logic;
    	ENABLE		: IN  std_logic;
    	RnW			: IN  std_logic;										-- (RnW)
    	wdata_size	: IN  std_logic_vector( 1 downto 0);					-- control signals for the memory. It will manage the byte addressable memory with 32 bit data	
    	Addr 		: IN  std_logic_vector(log2(RAM_DEPTH*4)- 1 downto 0);  
    	DATA_IN		: IN  std_logic_vector(NBIT - 1 downto 0);
    	DATA_OUT 	: OUT std_logic_vector(NBIT - 1 downto 0)
    );

end DRAM;

architecture DRam_Bhe of DRAM is

  	subtype MEM_ADDR is natural range 0 to RAM_DEPTH*4 -1; 				-- range of addresses of the memory
	type MEM_ARRAY is array(MEM_ADDR) of std_logic_vector(7 downto 0); 	-- this is a type consisting in an array of many elements of NBIT bits as many as the REG_ADDR range
	signal MEMORY : MEM_ARRAY; 											-- this is the signal that will represent the MEM and it is defined as such because it is a RAM

  	signal update: std_logic;											-- signal used just to activate the write to memory file process

begin  -- DRam_Bhe


	laod_store_proc: process (CLK,RESET) 										--reading only when the clock changes, reset asyncronous
		file mem_fp: text;
    	variable file_line : line;
    	variable index : integer := 0;
    	variable tmp_data_u : std_logic_vector(NBIT-1 downto 0);
    begin
		
        if (RESET = '0') then 											-- asynch. reset is active low
			--read the data from an existing memory and place it in an array
			file_open(mem_fp, DRAM_PATH, READ_MODE);					-- start file operation READ
      		while (not endfile(mem_fp) AND (index < RAM_DEPTH*4-1)) loop
        		readline(mem_fp,file_line);
        		hread(file_line,tmp_data_u);
        		--placing bytes to form a 32 bit word      
        		MEMORY(index) <= tmp_data_u(NBIT-1 downto NBIT-8);
        		MEMORY(index+1) <= tmp_data_u(NBIT-9 downto NBIT-16);
        		MEMORY(index+2) <= tmp_data_u(NBIT-17 downto NBIT-24);
        		MEMORY(index+3) <= tmp_data_u(NBIT-25 downto NBIT-32);        
        		index := index + 4;
        	end loop;
        	file_close(mem_fp);											-- file operation complete
                
            DATA_OUT <= (others=>'0'); 									-- output updated to zero
            update<='0';												-- no need to update the memory file
        
        elsif(falling_edge(CLK))then																					-- no concurrent read/write is possible
        	if(ENABLE ='1') then
        	update<='0';				 																				-- reset update signal to be able to trigger a new update mem file
				if(RnW='1') then       																					-- it works as a read notWrite. So if(read)
					for i in 0 to (NBIT/8)-1 loop
						DATA_OUT(NBIT-i*8-1 downto NBIT-i*8-8) <= MEMORY(to_integer(unsigned(ADDR))+i);  				--Big endian
					end loop;
				else							
					if(unsigned(wDATA_size) = 0) then																	--write a byte
						MEMORY(to_integer(unsigned(ADDR))) <= DATA_IN(7 downto 0);
					elsif(unsigned(wDATA_size) = 1) then																--write lower halfword
						for i in 0 to (NBIT/16)-1 loop
							MEMORY(to_integer(unsigned(ADDR)+i)) <= DATA_IN(NBIT/2 -i*8 -1 downto NBIT/2-i*8-8);
						end loop;
					elsif(unsigned(wDATA_size) = 2) then																--write higher halfword
						for i in 0 to (NBIT/16)-1 loop
							MEMORY(to_integer(unsigned(ADDR)+i)) <= DATA_IN(NBIT -i*8 -1 downto NBIT-i*8-8);
						end loop;
					elsif(unsigned(wDATA_size) = 3) then																--write word
						for i in 0 to (NBIT/8)-1 loop
							MEMORY(to_integer(unsigned(ADDR)+i)) <= DATA_IN(NBIT -i*8 -1 downto NBIT-i*8-8);
						end loop;
					end if;
					update<='1';	-- signal that an update of file is ready				
				end if;			
     		end if; 
     	end if;      
    end process laod_store_proc;
    
    
    
    file_update_proc: process(update)
    file mem_fp: text;
    variable file_line : line;
    variable index : integer := 0;
    
    begin
    	--write into the file the updated memory if there is something to update
    	if(update='1') then
    		file_open(mem_fp, DRAM_PATH, WRITE_MODE);
      		while (index < RAM_DEPTH*4-1) loop
        		hwrite(file_line,MEMORY(index) & MEMORY(index+1) & MEMORY(index+2) & MEMORY(index+3));		--write MEMORY(i) into file_line, use bytes to form a word (not generic)
        		writeline(mem_fp,file_line);																--write file_line into the file
        		index:=index+4;
        	end loop;
        	file_close(mem_fp);		-- end of file access
        	index:=0;				-- get ready for next update
        end if;
    
    end process file_update_proc;


end DRam_Bhe;
