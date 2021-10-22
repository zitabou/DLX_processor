library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use WORK.DLX_constants.all;
use WORK.DLX_functions.all;


entity hardwired_CU is
port(
    clk:        IN std_logic;
    rst:        IN std_logic;
    
    opcode:     IN std_logic_vector(OP_CODE_SIZE-1 downto 0);		-- bits that identify the type of instruction (register, immediate, floaating-point)
    func:       IN std_logic_vector(FUNC_SIZE-1 downto 0);			-- bits that identify the operation to be executed in case of R-type instructions
    
    --stage1(DEC)
    RF1:        OUT std_logic;  -- enable read from port_1 of RF        MSB of CW
    RF2:        OUT std_logic;  -- enable read from port_2 of RF
    EN1:        OUT std_logic;  -- enable RF
    --stage2(EXE)
    S1:         OUT std_logic;	-- mux_1 selection signal (between IMM(0) and operand_1(1))
    S2:         OUT std_logic;	-- mux_2 selection signal (between IMM(1) and operand_2(0))
    ALU3:       OUT std_logic;	-- alu operation selection bit 3
    ALU2:       OUT std_logic;	-- alu operation selection bit 2
    ALU1:       OUT std_logic;	-- alu operation selection bit 1
    ALU0:       OUT std_logic;	-- alu operation selection bit 0
    SN:       	OUT std_logic;	-- bit that indicates that the alu functions must be executed with signed operands, if zero then for unsigned ones
    --stage3(MEM)
    LnS:        OUT std_logic;	-- Load notStore from main memory
    Wrd:		OUT std_logic;	-- load/store 	word
    BHU1:       OUT std_logic;	-- load 		signed/unsigned 
    BHU0:       OUT std_logic;  -- load/store 	byte/halfword
    EN3:		OUT std_logic;	-- enables memory 
    --stage4(WB)
    S3:         OUT std_logic;	-- write back mux selection signal
    WF1:        OUT std_logic;  -- enable write for RF

    --others
    Ld:         OUT std_logic   -- THIS IS EXTRA and indicates that the instr in ALU is a load. Used for the hazard detection.

); 

   
end hardwired_CU;

architecture Behavioral of hardwired_CU is

-- To consider the semantic of the CW bits we must first make some choices.
--1) RF1 is the address of the register that will be used in RA and RF2 is the address of the register that will be used in RB
--2) the order of the bit is the one shown in the lab4.pdf. This means that MSB=RF1, MSB-1=RF2, ..., LSB+1=S3, LSB=WF1
--3) the selection signals of the multiplexers are 0 for the first(upmost) input and 1 of the second(downmost) input. ex mux(in1,A) for 0->in1 for 1->A
--4) the ALU operations are: '+'->0000, '-'->0001, 'and'->0010, 'or'->0011, 'xor'->0100. the add/sub is always done 'mux1 -/+ mux2'


subtype uMEM_addr is integer range 0 to uCODE_LUT_SIZE-1;
type micro_mem is array(uMEM_addr) of std_logic_vector(CW_size-1 downto 0);  
constant LUT: micro_mem :=(  

                                  
"11110000000000011",  --R_type             ADD RS1,RS2,RD | SUB RS1,RS2,RD | AND RS1,RS2,RD | OR RS1,RS2,RD | XOR RS1,RS2,RD | MUL RS1,RS2,RD | SLL RS1,RS2,RD | SRL RS1,RS2,RD | SRA RS1,RS2,RD. It will be defined by the function. The function will define the ALU signals
                         "00000001000000000",  --FP_type
                         "00000001000000000",  --J
                         "10101001010000011",  --JAL 		**** R31 <= PC + 4
                         "00000001000000000",  --BEQZ
                         "00000001000000000",  --BNEZ       
                         "00000001000000000",  --BFPT
                         "00000001000000000",  --BFPF
                         "10111000010000011",  --ADDI      ADDI RS1,RD,IMM
                         "10111000000000011",  --ADDUI	   ADDUI RS1,RD,IMM
                         "10111000110000011",  --SUBI      SUBI RS1,RD,IMM
                         "10111000100000011",  --SUBUI	   SUBUI RS1,RD,IMM
                         "10111001000000011",  --ANDI      ANDI RS1,RD,IMM    
                         "10111001100000011",  --ORI       ORI RS1,RD,IMM
                         "10111010000000011",  --XORI      XORI RS1,RD,IMM
                         "00000001000000000",  --LHI         **********
                         "00000001000000000",  --RFE
                         "00000001000000000",  --TRAP
                         "00000001000000000",  --JR
                         "10101001010000011",  --JALR		**** R31 <= PC + 4
                         "10011010110000011",  --SLLI      SLLI RS1,RD,IMM 
                         "00001010000000000",  --NOP       it is a IMM xor IMM
                         "10011011010000011",  --SRLI      SRLI RS1,RD,IMM
                         "10011011110000011",  --SRAI      SRAI RS1,RD,IMM
                         "10111100010000011",  --SEQI	   SEQI RS1,RD,IMM
                         "10111100110000011",  --SNEI      SNEI RS1,RD,IMM
                         "10111110110000011",  --SLTI	   SLTI RS1,RD,IMM
                         "10111110010000011",  --SGTI      SGTI RS1,RD,IMM
                         "10111101010000011",  --SLEI      SLEI RS1,RD,IMM
                         "10111101110000011",  --SGEI      SGEI RS1,RD,IMM
                         "00000001000000000",  --
                         "00000001000000000",  --
                         "10111000011010101",  --LB        LB RS1,RD,IMM
                         "10111000011011101",  --LH	   	   LH RS1,RD,IMM
                         "00000001000000000",  --
                         "10111000011100101",  --LW        LW RS1,RD,IMM
                         "10111000011000101",  --LBU       LBU RS1,RD,IMM
                         "10111000011001101",  --LHU       LHU RS1,RD,IMM
                         "00000001001000100",  --LF
                         "00000001001000100",  --LD        
                         "11111000010000100",  --SB		   SB RS,RD,IMM
                         "11111000010001100",  --SH	       SH RS,RD,IMM
                         "00000001000000000",  --	
                         "11111000010100100",  --SW        SW RS1,RD,IMM
                         "00000001000000000",  --
                         "00000001000000000",  --
                         "00000001000000000",  --SF
                         "00000001000000000",  --SD
                         "10111001010000011",  --NANDI      NANDI RS1,RD,IMM    
                         "10111001110000011",  --NORI       NORI RS1,RD,IMM
                         "10111010010000011",  --XNORI      XNORI RS1,RD,IMM
                         "00000001000000000",  --
                         "00000001000000000",  --
                         "10111111110000011",  --MUL		MUL ADDI RS1,RD,IMM  (signed)
                         "10111111010000011",  --ROR		ROR RS1,RD,IMM
                         "00000001000000000",  --
                         "00000001000000000",  --ITLB
                         "00000001000000000",  --
                         "10111110100000011",  --SLTUI	   SLTUI RS1,RD,IMM
                         "10111110000000011",  --SGTUI	   SGTUI RS1,RD,IMM
                         "10111100100000011",  --SLEUI	   SLEUI RS1,RD,IMM
                         "10111101100000011"   --SGEUI	   SGEUI RS1,RD,IMM
                         );                        
                        
                         
-- In the LUT above we have all possible combinations of the opcode. To note that the opcode=0 is true for all R-Type operations and opcode=1 for all FP operations.
-- In R-Type cases we must do an additional step to calculate the ALU signal of the CW and it is done separately in cw_proc.
-- In I-Type cases we get the correct CW from the table and function=0 for all of them.

    
-- the CW is all the control signals for an instruction. In each stage we have a different instruction so only part of the CW will be used in a stage.
-- We use 4 cw, one for each stage, and from it we get only the necessary control signals. This movement of the instr. CW through the cwx signals represents the pipeline movement
    signal cw1: std_logic_vector(CW_SIZE-1 downto 0);				-- this is the cw that will be used in the stage 1(DEC). Basically it is the instruction that is in stage 1
    signal cw2: std_logic_vector(CW_SIZE-1 downto 0);   			-- this is the cw that will be used in the stage 2(EXE). Basically it is the instruction that is in stage 2
    signal s_cw2: std_logic_vector(CW_SIZE-1 downto 0);   			-- this is the cw that will be used in the stage 2(EXE). Basically it is the instruction that is in stage 2
    signal cw21,cw22, cw23: std_logic_vector(CW_SIZE-1 downto 0);   -- this cw is used for the internal pipeline of 4 stages
    signal s_cw3: std_logic_vector(CW_SIZE-1 downto 0);   			-- this is the cw that will be used in the stage 3(MEM). Basically it is the instruction that is in stage 3
    signal cw3: std_logic_vector(CW_SIZE-1 downto 0);   			-- this is the cw that will be used in the stage 3(MEM). Basically it is the instruction that is in stage 3
    signal cw4: std_logic_vector(CW_SIZE-1 downto 0);   			-- this is the cw that will be used in the stage 3(WB). Basically it is the instruction that is in stage 4
 	signal exe_type, exe_type2, exe_type21, exe_type22, exe_type23: std_logic; -- this is used to correctly manage the mul pipeline. this will be the selector of the instr. to be passed to the mem stage. The same approach can be used for any additional pipelined exe
 
-- the way these four signals will be used is to:
--1) get the cw as soon as the op code changes(the instruction has been fetched)
--2) then at each cc this cw will be moved to cw1->cw2->cw3->cw4 in sequence indicating the movement along the pipeline
--3) at the same time this happens for all the stages.

begin


-- //// PROCESSES \\\\ 

-- we will need two processes.
--One is needed to control the part of the CW to be used for each stage and when. Implementing the pipeline shift
--The other one is used to define the cw. This is needed because we have R-types. R-type instructions have one op code for all of them so the cw is the same with the ALU selection signals to be determined by the FUNC. For I-type we use the cw as is.
--  So the idea is to use this second process to define the correct ALU bits to be used for the specific R-Type instruction.
--
-- Once an instruction is fetched it is decoded and the opcode+functions are extracted and we have the conrtol word that defines what operation each stage must do to complete this instr.
-- The first stage uses part of the cw and when it is done, with the first stage, a new instr is fetched.
-- When a new instr is being decoded we again obtain the cw which contains the signals for all the stages. And again for the first stage we use only part of it.
-- this cw must not be lost until the related instr completes its execution. So we must keep track of all 4 cw.
--   Our appoach to do what explained above is to
--   1) have 4 cw registers, one for each stage, that contain the entire cw of the instruction currently at that stage 
--   2) after each stage is completed, every rising clk edge, the values of the individual cw will "shift" by assigning for ex cw1->cw2, cw2->cw3, cw3->cw4.
--   3) when the "shifting" is done then each stage will read only part of the cw associated to that stage
--   4) As soon as the INSTR is fetched we extract the cw that will become cw1 at the next clock edge.
 
pipelineProc: Process(clk,rst)  -- asynch reset
begin
    if(rst = '0') then          --active low    
        cw2<=(others=>'0');	--empty stage
        cw3<=(others=>'0');	--empty stage
        cw4<=(others=>'0');	--empty stage
        cw21<=(others=>'0');	--empty stage
        cw22<=(others=>'0');	--empty stage
        cw23<=(others=>'0');	--empty stage
        
        exe_type2 <='0';
        exe_type21<='0';
        exe_type22<='0';
        exe_type23<='0';
        
        
        
    elsif (rising_edge(clk)) then
    
        --shifting of the instructions in the pipeline
        cw2<=cw1;                --the previously on the first stage instr will be moved to the second stage
        exe_type2<=exe_type;
        
        cw21<=cw2;
        exe_type21<=exe_type2;
        cw22<=cw21;
        exe_type22<=exe_type21;
        cw23<=cw22;
        exe_type23<=exe_type22;
        
        cw3<=s_cw3;                --the previously on the second stage instr will be moved to the third stage
        cw4<=cw3;                --the previously on the third stage instr will be moved to the fourth stage
    end if;

end Process pipelineProc;
	
	exe_type<='1' when ((unsigned(opcode) = 53) OR (unsigned(func) = 31)) else
    		  '0';
	--mux
	s_cw2 <= cw2 when (exe_type23='0') else
			"00000001000000000";	
	
	
	--mux
	s_cw3 <= s_cw2 when (exe_type23 ='0') else
			 cw23;
	
	

-- concirrent assignement of the output signals considering for each stage the correct cw
    --stage1
    RF1   <=    cw1(16);	-- access register 1
    RF2   <=    cw1(15);	-- access register 2
    EN1   <=    cw1(14);    -- enable the pipeline register towards the next stage
    --stage2   
    S1    <=    cw2(13);	-- selection signal between IMM and RA
    S2    <=    cw2(12);	-- selection signal between RB and IMM
    ALU3  <=    cw2(11);	-- MSB of ALU selection signal
    ALU2  <=    cw2(10);	-- MSB-1 of ALU selection signal
    ALU1  <=    cw2(9);		-- LSB+1 of ALU selection signal
    ALU0  <=    cw2(8);		-- LSB of ALU selection signal
    SN  <=      cw2(7);		-- identifies an instruction as signed
    --stage3
    LnS   <=    cw3(6);		-- Load notStore
    Wrd   <=    cw3(5);  	-- Word
    BHU1  <=    cw3(4);  	-- signed notUnsigned  BHU->Byte_HalfWord_Unsigned
    BHU0  <=    cw3(3);  	-- Halfword notByte
    EN3   <=    cw3(2);  	-- enable the pipeline register towards the next stage
    --stage4
    S3    <=    cw4(1);		-- selection signal between memout and aluout to writeback
    WF1   <=    cw4(0);		-- enable write to the Register file


    LD<=cw2(6);			-- the load signal is given in the MEM stage but for the hazard detection we need to know if we have a load instr. in EXE so we get the load info from the second cw that usually is not yet given

-- the ALU process is in charge of defining the ALU operation of the R-Type instr. When a different opcode is read or a new function is read we start the procedure of defining the ALU signals 
cw_proc:Process(opcode, func)
begin

    --get the cw from the LUT. It may be complete or not, ALU missing for R-types.
    cw1 <= LUT(to_integer(unsigned(opcode)));
    
    --if it is an R-type then use the function to determine the ALU signals bits 9 and 6 of the cw
    if(unsigned(opcode) = 0) then   --if it is an R-Type instr
        case (to_integer(unsigned(func))) is    
        	when 1  => cw1(11 downto 7)<= BITNAND & '1';	--nand
            when 2  => cw1(11 downto 7)<= BITNOR  & '1';	--nor
            when 3  => cw1(11 downto 7)<= BITXNOR & '1';	--xnor  
            when 4  => cw1(11 downto 7)<= LSL 	& '1'; 	--lsl
            when 6  => cw1(11 downto 7)<= LSR 	& '1'; 	--lsr
            when 7  => cw1(11 downto 7)<= ASR 	& '1'; 	--asr
            when 8  => cw1(11 downto 7)<= RTR	& '1';  --ror
            when 31 => cw1(11 downto 7)<= MUL	& '1'; 	--mul    
            when 32 => cw1(11 downto 7)<= ADDS	& '1'; 	--add
            when 33 => cw1(11 downto 7)<= ADDU	& '0'; 	--addu
            when 34 => cw1(11 downto 7)<= SUBS	& '1'; 	--sub
            when 35 => cw1(11 downto 7)<= SUBU	& '0'; 	--subu
            when 36 => cw1(11 downto 7)<= BITAND& '0';	--and
            when 37 => cw1(11 downto 7)<= BITOR	& '0';	--or
            when 38 => cw1(11 downto 7)<= BITXOR& '0';	--xor
            when 40 => cw1(11 downto 7)<= EQ	& '1'; 	--seq
 	    	when 41 => cw1(11 downto 7)<= NE	& '1'; 	--sne
 	    	when 44 => cw1(11 downto 7)<= LE	& '1'; 	--sle
 	    	when 45 => cw1(11 downto 7)<= GE	& '1'; 	--sge
 	    	when 43 => cw1(11 downto 7)<= GT	& '1'; 	--sgt
            when 42 => cw1(11 downto 7)<= LT	& '1'; 	--slt
            when 58 => cw1(11 downto 7)<= LTU	& '0';	--sltu
            when 59 => cw1(11 downto 7)<= GTU	& '0';	--sgtu
            when 60 => cw1(11 downto 7)<= LEU	& '0';	--sleu
            when 61 => cw1(11 downto 7)<= GEU	& '0';	--sgeu
            
            
            when others => cw1(11 downto 7)<="00000";     -- includes nop     
        end case;
    end if;




end process cw_proc;



















end Behavioral;
