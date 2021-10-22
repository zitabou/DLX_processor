library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use WORK.DLX_constants.all;
use WORK.DLX_functions.all;



entity MEM is
	generic(MEMORY_SIZE: integer:=512);
    Port(
        CLK:    IN std_logic;						
        RST:    IN std_logic;
        ALUout: IN std_logic_vector(data_size-1 downto 0);					-- result of the EXE stage
        MEout:  IN std_logic_vector(data_size-1 downto 0);					-- value to be written in memory in case of a store instruction
        RDin:  	IN std_logic_vector(Log2(num_reg)-1 downto 0);				-- destination address, in register file, taken from the EXE/MEM pipeline register
        DRAM_data_out: IN std_logic_vector(data_size-1 downto 0);
        
        --control
		LnS:    IN std_logic;						-- control signal from the CU
		Wrd:	IN std_logic;						-- control signal from the CU
    	BHU1:   IN std_logic;						-- control signal from the CU
    	BHU0:   IN std_logic; 						-- control signal from the CU
        EN3:    IN std_logic;						-- control signal from the CU
        
        --to DRAM memory
        DRAM_addr: 		OUT std_logic_vector(log2(MEMORY_SIZE*4)- 1 downto 0);	-- address in which to access the DRAM
        DRAM_data_in:  	OUT std_logic_vector(data_size-1 downto 0);				-- value to be written in DRAM
        
        MMU_out: OUT std_logic_vector(1 downto 0);								-- control signals for the byte addressable DRAM
        output:  OUT std_logic_vector(data_size-1 downto 0);					-- data read from the memory
        alu_out: OUT std_logic_vector(data_size-1 downto 0);					-- the result of the previous stage, in case of an non load/store instruction
        RDout:   OUT std_logic_vector(Log2(num_reg)-1 downto 0));				-- destination address passed to the MEM/WB pipeline register

end MEM;

architecture Structural of MEM is

component MMU is
    GENERIC(WORD_size: integer:= data_size);
    Port(
	Wrd:	 IN std_logic;
    BHU0:	 IN std_logic;   	
	wdata_size: OUT std_logic_vector( 1 downto 0));
end component;

component MUX51_GENERIC is
  GENERIC(NBIT: integer:= 4);      
  PORT(A:   in  std_logic_vector(NBIT-1 downto 0);
       B:   in  std_logic_vector(NBIT-1 downto 0);
       C:   in  std_logic_vector(NBIT-1 downto 0);
       D:   in  std_logic_vector(NBIT-1 downto 0);
       E:   in  std_logic_vector(NBIT-1 downto 0);
       SEL: In	std_logic_vector(2 downto 0);
       Y:   out std_logic_vector(NBIT-1 downto 0));
end component;

signal s_MemOut, s_B, s_H, s_BU, s_HU: std_logic_vector(data_size-1 downto 0);
signal s_byte_EN:std_logic_vector(1 downto 0);
signal s_sel: std_logic_vector(2 downto 0);

begin

s_BU(data_size-1 downto 8 )	<= (others=>'0');
s_BU(7 downto 0)  		<= DRAM_data_out(data_size-1 downto data_size-8);  --unsigned Byte

s_HU(data_size-1 downto 16) 	<=(others=>'0');
s_HU(15 downto 0) 		<= DRAM_data_out(data_size-1 downto data_size-16); --unsigned Half Word

s_B(data_size-1 downto 8)  	<=(others=>DRAM_data_out(data_size-1));
s_B(7 downto 0)  		<= DRAM_data_out(data_size-1 downto data_size-8);  --signed Byte

s_H(data_size-1 downto 16) 	<=(others=>DRAM_data_out(data_size-1));
s_H(15 downto 0)		<= DRAM_data_out(data_size-1 downto data_size-16); --signed Half Word

s_sel  	  			<= (2=>Wrd, 1=> BHU1, 0=> BHU0);



mem_MU: MMU
generic map(WORD_size => data_size)
port map(
	Wrd	=>Wrd,
    BHU0	=>BHU0,  	
	wdata_size =>MMU_out
);

mux: MUX51_GENERIC
generic map(NBIT => data_size)    
port map(A	  => s_BU,	--unsigned Byte
     	B	  => s_HU,	--unsigned Half Word
     	C	  => s_B,  	--signed Byte
     	D	  => s_H, 	--signed Half Word
     	E	  => DRAM_data_out,  --Word
     	SEL   => s_sel,
     	Y	  => output
);
	     
alu_out		<= ALUout;
RDout		<= RDin;
DRAM_addr	<= ALUout(log2(MEMORY_SIZE*4)-1 downto 0);
DRAM_data_in<= MEout;

end Structural;
