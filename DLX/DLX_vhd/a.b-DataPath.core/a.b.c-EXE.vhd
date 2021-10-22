library IEEE;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use WORK.DLX_constants.all;
use WORK.DLX_functions.all;

entity EXE is
    PORT(
    	CLK:	IN std_logic;
    	RST:	IN std_logic;
    	
        IMM:  	IN std_logic_vector(data_size-1 downto 0);			-- immediate value taken from DEC/EXE pipeline register
        RA:   	IN std_logic_vector(data_size-1 downto 0);			-- operand_1 value taken from DEC/EXE pipeline register
        RB:   	IN std_logic_vector(data_size-1 downto 0);			-- operand_2 value taken from DEC/EXE pipeline register
        WA:   	IN std_logic_vector(log2(num_reg)-1 downto 0);		-- destination address taken from DEC/EXE pipeline register

        -- FORWARDING
        RSA:        IN std_logic_vector(log2(num_reg)-1 downto 0);	-- source of operand_1 taken from DEC/EXE pipeline register
        RSB:        IN std_logic_vector(log2(num_reg)-1 downto 0);  -- source of operand_2 taken from DEC/EXE pipeline register
        ALU_outmem: IN std_logic_vector(data_size-1 downto 0);		-- value from the EXE/MEM pipeline register containing the ALU value currently in MEM
        WB_out:     IN std_logic_vector(data_size-1 downto 0); 		-- value from the MEM/WB pipeline register containing the ALU value currently in WB
        MEM_RD:     IN std_logic_vector(log2(num_reg)-1 downto 0);	-- value from the EXE/MEM pipeline register containing destination addr. currently in MEM
        WB_RD:      IN std_logic_vector(log2(num_reg)-1 downto 0);	-- value from the EXE/MEM pipeline register containing destination addr. currently in WB
        LD_EN:      IN std_logic;									-- signal that tells if there is a load instruction in MEM stage
		WB_EN:      IN std_logic;        							-- signal that tells if the data in wb must be written in MEM (indicates a load instruction in WB stage)
		
        --control                      
        S1:    	IN std_logic;						-- control signal from the CU
        S2:    	IN std_logic; 						-- control signal from the CU
        ALU3:  	IN std_logic;						-- control signal from the CU
        ALU2:  	IN std_logic;						-- control signal from the CU
        ALU1:  	IN std_logic;						-- control signal from the CU
        ALU0:  	IN std_logic;						-- control signal from the CU
        SN:   	IN std_logic;						-- control signal from the CU
        
        --mul management
		RD_inmul:	OUT std_logic_vector(log2(num_reg)-1 downto 0);
		flag_structHzd:	OUT std_logic;
		flag_ismul:		OUT std_logic;
        
        OVF: 	OUT std_logic;										-- overflow signal set by the ALU operation
        output: OUT std_logic_vector(data_size-1 downto 0);			-- result from the ALU operation 
        ME: 	OUT std_logic_vector(data_size-1 downto 0);			-- value to be stored in case of a store instruction
        WAout: 	OUT std_logic_vector(log2(num_reg)-1 downto 0));	-- destination address to be passed to the next stage
        
end EXE;

architecture Structural of EXE is

component forwarding_unit
  GENERIC(WORD_size: integer:= data_size;
          NREG: integer:= num_reg);  
  PORT( RSA:        IN std_logic_vector(log2(NREG)-1 downto 0);	-- Source address of operand RA (needed for comparison)
        RSB:        IN std_logic_vector(log2(NREG)-1 downto 0); -- Source address of operand RB (needed for comparison)
        ALU_outmem: IN std_logic_vector(WORD_size-1 downto 0);  -- EXE stage output currently read from the MEM stage
        WB_out:     IN std_logic_vector(WORD_size-1 downto 0);	-- data that the WB stage is about to write in the register file
        MEM_RD:     IN std_logic_vector(log2(NREG)-1 downto 0); -- destination address of the instruction qurrently in mem stage
        WB_RD:      IN std_logic_vector(log2(NREG)-1 downto 0); -- destination address of the instruction qurrently in WB stage
        LD_EN:      IN std_logic;								-- indicates the presence of a load instruction in MEM stage (in that case the ALU_outmem is an address)
		WB_EN:      IN std_logic;								-- indicates the presence if a store instruction in the WB stage (no writeback is done in that case)
        S1:         IN std_logic;								-- selection signals coming from the CU related to IMM, RA
        S2:         IN std_logic;								-- selection signals coming from the CU related to RB, IMM
        SEL1:       OUT	std_logic_vector(1 downto 0);   		-- extended selection sigals to implement forwarding for RA 		IMM(00), RA(01),  ALU_outmem(10), WB_out(11)
        SEL2:       OUT	std_logic_vector(1 downto 0);   		-- extended selection sigals to implement forwarding for RB			RB(00),  IMM(01), ALU_outmem(10), WB_out(11)
        SEL3:       OUT	std_logic_vector(1 downto 0)); 			-- extended selection sigals to implement forwarding for ME			__(00),  RB(01),  ALU_outmem(10), WB_out(11)
end component;

component MUX21_GENERIC is
  GENERIC(NBIT: integer:= 4);      
  PORT(A:   in  std_logic_vector(NBIT-1 downto 0);
       B:   in  std_logic_vector(NBIT-1 downto 0);
       SEL:	In	std_logic;
       Y:   out std_logic_vector(NBIT-1 downto 0));
end component;

component MUX41_GENERIC is
  GENERIC(NBIT: integer:= 4);      
  PORT(A:   in  std_logic_vector(NBIT-1 downto 0);
       B:   in  std_logic_vector(NBIT-1 downto 0);
       C:   in  std_logic_vector(NBIT-1 downto 0);
       D:   in  std_logic_vector(NBIT-1 downto 0);
       SEL:	In	std_logic_vector(1 downto 0);
       Y:   out std_logic_vector(NBIT-1 downto 0));
end component;

component EXU is
	generic(N: integer:=32);  --input bits
	port ( DATA1, DATA2: IN std_logic_vector(N-1 downto 0);			-- operands
  		   FUNC: 		IN std_logic_vector(FUN_BITS-1 downto 0);		-- operation to be executed
  		   RD_in: 		IN std_logic_vector(log2(num_reg)-1 downto 0);
  		   SN: 			IN std_logic;         							-- indicator of signed(1)/unsigned(0) operation
  		   CLK:			IN std_logic;
  		   RST:			IN std_logic;
           OVF:			OUT std_logic;
           stall_flag: 	OUT std_logic;
		   RD_sel_flag: OUT std_logic;									-- overflow signal
           OUTPUT: 		OUT std_logic_vector(N-1 downto 0);
           RD_stall:	OUT std_logic_vector(log2(num_reg)-1 downto 0);
           RD_out: 		OUT std_logic_vector(log2(num_reg)-1 downto 0);
           H_MULOUT: 	OUT std_logic_vector(N-1 downto 0));			-- result of the operation
end component;

-- connection signals
signal MUX1out, MUX2out, MUX3out: 	std_logic_vector(data_size-1 downto 0);
signal ALUfunc: 					std_logic_vector(FUN_BITS-1 downto 0);
signal s_S1, s_S2, s_S3:    		std_logic_vector(1 downto 0);

signal s_ovf:											std_logic;
signal s_stall_flag:									std_logic;
signal s_RD_sel1, s_RD_sel2:							std_logic;
signal s_ALU_RD, s_mul_RD_out, s_RD_stall, s_final_RD:	std_logic_vector(log2(num_reg)-1 downto 0);
signal s_H_mul:											std_logic_vector(data_size-1 downto 0);


begin

ALUfunc		<=ALU3 & ALU2 & ALU1 & ALU0;		-- generate the function by concatenating the single ALU func bits provided by the control unit
s_RD_sel1	<= '1' when unsigned(ALUfunc)=unsigned(MUL) else
			   '0';
flag_ismul	<=s_RD_sel1;

FWU: forwarding_unit
generic map(WORD_size=>data_size, NREG=>num_reg)
port map(
	RSA			=>RSA,
	RSB			=>RSB,
	ALU_outmem	=>ALU_outmem,
	WB_out		=>WB_out,
	MEM_RD		=>MEM_RD,
	WB_RD		=>WB_RD,
	LD_EN		=>LD_EN,
	WB_EN		=>WB_EN,
	S1			=>S1,
	S2			=>S2,
	SEL1		=>s_S1,
	SEL2		=>s_S2,
	SEL3		=>s_S3
	);

-- forwarding RA multiplexer
FW_MUX1: MUX41_GENERIC
generic map(NBIT=>data_size)
port map(A=>IMM, B=>RA, C=>ALU_outmem, D=>WB_out, SEL=>s_S1, Y=>MUX1out);   --a->0, b->1, ...

-- forwarding RB multiplexer
FW_MUX2: MUX41_GENERIC
generic map(NBIT=>data_size)
port map(A=>RB, B=>IMM, C=>ALU_outmem, D=>WB_out, SEL=>s_S2, Y=>MUX2out);   --a->0, b->1, ...

-- forwarding ME multiplexer
FW_MUX3: MUX41_GENERIC
generic map(NBIT=>data_size)
port map(A=>IMM, B=>RB, C=>ALU_outmem, D=>WB_out, SEL=>s_S3, Y=>MUX3out);   --a->0, b->1, ...

RD_MUX1: MUX21_GENERIC
generic map(NBIT=>log2(num_reg))
port map(A=>WA, B=>(others=>'0'), SEL=>s_RD_sel1, Y=>s_ALU_RD);   --a->0, b->1, ...

EXUx: EXU
generic map(N=>data_size)
port map(DATA1			=>MUX1out,
		 DATA2			=>MUX2out,
  		 FUNC			=>ALUfunc,
  		 RD_in			=>WA,	
  		 SN				=>SN,
  		 CLK			=>CLK,
  		 RST			=>RST,
         OVF			=>s_ovf,
         stall_flag		=>s_stall_flag,
		 RD_sel_flag	=>s_RD_sel2,
         OUTPUT			=>output,
         RD_stall		=>s_RD_stall,
         RD_out			=>s_mul_RD_out,
         H_MULOUT		=>s_H_mul
         );


-- MUX that passes the ovf output if the operation was signed or zero if the operation was unsigned
OVF <= s_ovf when SN='1' else
	   '0';


RD_inmul		<= s_RD_stall;         
flag_structHzd 	<=s_stall_flag;         

RD_MUX2: MUX21_GENERIC
generic map(NBIT=>log2(num_reg))
port map(A=>s_ALU_RD, B=>s_mul_RD_out, SEL=>s_RD_sel2, Y=>s_final_RD);   --a->0, b->1, ...


-- the ME values are not used to compute anything so they are just passed through
me<=MUX3out;
WAout<=s_final_RD;



end Structural;
