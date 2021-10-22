library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use WORK.DLX_constants.all;
use WORK.DLX_functions.all;

entity tb_DLX is
end tb_DLX;

architecture Behavioral of tb_DLX is


component DLX is
    GENERIC(MEM_SIZE: integer:= 512;
    		INSTR_RAM_size: integer:= 48;
            WORD_size: integer:= 32;
            NREG: integer:= 32);
    PORT(CLK: IN std_logic;
         RST: IN std_logic;
         
         from_DRAM_data: IN std_logic_vector(WORD_size-1 downto 0);
         IRAM_data: 	 IN std_logic_vector(WORD_size-1 downto 0);   
         
         DRAM_addr: 	 OUT std_logic_vector(log2(MEM_SIZE*4)- 1 downto 0);
         IRAM_addr: 	 OUT std_logic_vector(log2(INSTR_RAM_size*4) - 1 downto 0);
         to_DRAM_data: 	 OUT std_logic_vector(WORD_size-1 downto 0);
         
         DRAM_EN:		 OUT std_logic;
         DRAM_LnS:		 OUT std_logic;
         MMU_out:		 OUT std_logic_vector(1 downto 0)
              
         );
    
end component;


component IRAM is
  generic (
    RAM_DEPTH : integer := 64;
    I_SIZE : integer := 32);
  port (
    Rst  : in  std_logic;
    Addr : in  std_logic_vector(RAM_DEPTH*4 - 1 downto 0);
    Dout : out std_logic_vector(I_SIZE - 1 downto 0)
    );

end component;


component DRAM is
  generic (
    RAM_DEPTH : integer := 512;   	-- 512 addresses(it is byte addressable so 512 bytes or 64 words)			
    NBIT : integer := 32);
  port (
  		CLK	 		: IN  std_logic;
    	RESET		: IN  std_logic;
    	ENABLE		: IN  std_logic;
    	RnW			: IN  std_logic;										--(RnW)
    	wdata_size	: IN  std_logic_vector( 1 downto 0);			-- singals towards the memory. one bit for each byte of the word. This way we enable byte by byte	
    	Addr 		: IN  std_logic_vector(log2(RAM_DEPTH*4)- 1 downto 0);
    	DATA_IN		: IN  std_logic_vector(NBIT - 1 downto 0);
    	DATA_OUT 	: OUT std_logic_vector(NBIT - 1 downto 0)
    );
end component;


signal s_CLK:    	std_logic:= '0';
signal s_RST:    	std_logic:= '1';
signal s_DRAM_LnS:	std_logic;
signal s_DRAM_EN:	std_logic;
signal s_IRAM_addr: std_logic_vector(log2(IRAM_size*4)-1 downto 0);
signal s_instr: 	std_logic_vector(IR_size-1 downto 0);
signal s_data_out: 	std_logic_vector(data_size-1 downto 0);
signal s_mmu_out: 	std_logic_vector(1 downto 0);
signal s_DRAM_addr: std_logic_vector(log2(DRAM_size*4)- 1 downto 0);
signal s_DRAM_data_in: 	std_logic_vector(data_size-1 downto 0);
signal s_from_DRAM_data:std_logic_vector(data_size-1 downto 0);


begin
    

       
		s_clk <= not s_clk after 1 ns;
		s_rst <= '0', '1' after 2 ns;
		   
		DLX_test: DLX
		generic map(	MEM_SIZE=>DRAM_size,
				INSTR_RAM_size=>IRAM_size,
			    WORD_size=>data_size,
		        NREG=>num_reg)
		port map(clk			=>s_clk,
				 rst			=>s_rst,
				 from_DRAM_data	=>s_from_DRAM_data,
				 IRAM_data		=>s_instr,
				 DRAM_addr		=>s_DRAM_addr,
				 IRAM_addr		=>s_IRAM_addr,
				 to_DRAM_data	=>s_DRAM_data_in,
				 DRAM_EN		=>s_DRAM_EN,
				 DRAM_LnS		=>s_DRAM_LnS,
				 MMU_out		=>s_mmu_out
				 );
	   
		instr_mem: IRAM
		generic map(RAM_DEPTH => IRAM_size, I_SIZE => IR_size)
		port map(
			Rst  => s_RST,
			Addr => s_IRAM_addr,
			Dout => s_instr
		);

		main_mem: DRAM
		generic map(RAM_DEPTH => DRAM_size, NBIT => data_size)
		port map (
		 		CLK			=> s_CLK,
				RESET		=> s_RST,
				ENABLE		=> s_DRAM_EN,
				RnW			=> s_DRAM_LnS,									
				wdata_size	=> s_mmu_out,
				Addr 		=> s_DRAM_addr, 
				DATA_IN		=> s_DRAM_data_in,
				DATA_OUT 	=> s_from_DRAM_data
		);

end Behavioral;


configuration test_DLX_cfg of tb_DLX is
  for Behavioral
  end for;
end configuration;
