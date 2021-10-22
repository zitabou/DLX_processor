library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use std.textio.all;
use ieee.std_logic_textio.all;

use WORK.DLX_constants.all;
use WORK.DLX_functions.all;


-- Instruction memory for DLX
-- Memory filled by a process which reads from a file
-- file name is "iram.mem" and it is placed in the simulation directory
entity IRAM is
  generic (
    RAM_DEPTH : integer := 64;
    I_SIZE : integer := 32);
  port (
    Rst  : in  std_logic;
    Addr : in  std_logic_vector(log2(RAM_DEPTH*4) - 1 downto 0);
    Dout : out std_logic_vector(I_SIZE - 1 downto 0)
    );

end IRAM;

architecture IRam_Bhe of IRAM is

  subtype RAMaddrs is natural range 0 to RAM_DEPTH*4 - 1;				-- range of addresses. The 4 is needed because the mem is byte addressable and we convert the mem_size from #words to #bytes
  type RAM_ARRAY is array(RAMaddrs) of std_logic_vector(7 downto 0);	-- size of data per address
  signal IRAM_mem : RAM_ARRAY;											-- the memory is a signal because it is a RAM


begin  

-- The RAM is byte addressable but the bus is 32 bits.
-- the 32 bit output is formed by collecting the bytes from addiacent addresses placed following a Big-Endian policy(MSB to lowest address)
  Dout(I_SIZE-1 downto I_SIZE-8) <= std_logic_vector(IRAM_mem(to_integer(unsigned(Addr))));
  Dout(I_SIZE-9 downto I_SIZE-16) <= std_logic_vector(IRAM_mem(to_integer(unsigned(Addr))+1));
  Dout(I_SIZE-17 downto I_SIZE-24) <= std_logic_vector(IRAM_mem(to_integer(unsigned(Addr))+2));
  Dout(I_SIZE-25 downto I_SIZE-32) <= std_logic_vector(IRAM_mem(to_integer(unsigned(Addr))+3));

  -- purpose: This process is in charge of filling the Instruction RAM with the firmware
  -- type   : combinational
  -- inputs : Rst
  -- outputs: IRAM_mem
  -- IRam_Bhe
  FILL_MEM_P: process (Rst)
    file mem_fp: text;
    variable file_line : line;
    variable index : integer := 0;
    variable tmp_data_u : std_logic_vector(I_SIZE-1 downto 0);
  begin  -- process FILL_MEM_P
    if (Rst = '0') then
      file_open(mem_fp, IRAM_PATH, READ_MODE);
      while (not endfile(mem_fp)) loop
        readline(mem_fp,file_line);
        hread(file_line,tmp_data_u);
        --as already said for the output data also the input data is 32 bits but stored in bytes
        IRAM_mem(index) <= tmp_data_u(I_SIZE-1 downto I_SIZE-8);
        IRAM_mem(index+1) <= tmp_data_u(I_SIZE-9 downto I_SIZE-16);
        IRAM_mem(index+2) <= tmp_data_u(I_SIZE-17 downto I_SIZE-24);
        IRAM_mem(index+3) <= tmp_data_u(I_SIZE-25 downto I_SIZE-32);        
        index := index + 4;
      end loop;



    end if;
  end process FILL_MEM_P;

end IRam_Bhe;
