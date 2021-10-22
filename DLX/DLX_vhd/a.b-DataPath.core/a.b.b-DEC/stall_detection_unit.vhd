library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use ieee.numeric_std.all;
use WORK.DLX_constants.all;
use WORK.DLX_functions.all;

entity stall_detection_unit is
    generic(
	op_code_size: integer:= 6;
	func_size: integer:= 11;
	PC_reg_size: integer:= 32;
	reg_file_size: integer:= 32);
    port(
	  -- from dec logic
      opcode:     	IN std_logic_vector(op_code_size-1 downto 0);				-- opcode is passed throught the hazard detection logic(in case it needs to pass a nop)
	  RSA:        	IN std_logic_vector(Log2(reg_file_size)-1 downto 0);
      RSB:        	IN std_logic_vector(Log2(reg_file_size)-1 downto 0);
	  RD:        	IN std_logic_vector(Log2(reg_file_size)-1 downto 0);		-- destination address of instr.
	  FUNC:       	IN std_logic_vector(func_size-1 downto 0);					-- for the same reason as the opcode the func passes through the HDU

	  -- for hazard detection
	  EXE_RD:     	IN std_logic_vector(Log2(reg_file_size)-1 downto 0);		-- dest address of the instr. currently in exe stage
	  NPC_in:		IN std_logic_vector(PC_reg_size-1 downto 0);				-- NPC read from the IF/DEC pipeline register (used to refetch the instr.)
	  Ld:         	IN std_logic;												-- indicates the presence of a load instr in EXE stage
      --mul management
	  RD_inmul:			IN std_logic_vector(log2(num_reg)-1 downto 0);
	  flag_structHzd:	IN std_logic;
	  flag_ismul:		IN std_logic;
		  
      opcode_out: 	OUT std_logic_vector(op_code_size-1 downto 0);				-- definitive opcode towards CU (=IN_opcode or =NOP_opcode)
      RD_out:       OUT std_logic_vector(Log2(reg_file_size)-1 downto 0);
	  FUNC_out:   	OUT std_logic_vector(func_size-1 downto 0);					-- definitive func towards CU (=IN_func or =NOP_func)
          
      NPC_out:    	OUT std_logic_vector(PC_reg_size-1 downto 0);  				-- hazard_PC that may be the same as before in case of refetch
      PC_sel:     	OUT std_logic);												-- selection signal to select between fetch_PC and hazard_PC
        
end stall_detection_unit;

architecture Behavioral of stall_detection_unit is

begin
logic: Process(opcode, RSA, RSB, RD, FUNC, EXE_RD, NPC_in, LD, RD_inmul, flag_structHzd, flag_ismul)
begin

    opcode_out <= opcode;
	RD_out	   <= RD;
    func_out   <= func;
    PC_sel     <= '0';
	NPC_out    <= NPC_in;
	
         
      -- if the instr. in DEC is not a NOP instr and in EXE there is a load instr then put a stall between them if the destination of the load instr. is the same a source of the instr in dec. Also true for two consecutive load instr.
      if( (unsigned(opcode) /= unsigned(NOP) )) then
      	
        if( Ld = '1') then
            if( (unsigned(RSA) = unsigned(EXE_RD)) OR (unsigned(RSB) = unsigned(EXE_RD)) ) then
                
                opcode_out <=NOP;
	   			RD_out	      <= (others=>'0');
                NPC_out    <=std_logic_vector(unsigned(NPC_in)-4);
                PC_sel     <='1';           
            end if;
		
			
		-- if the instruction is a jump, put a stall	 
      	elsif ( (to_integer(unsigned(opcode)) = unsigned(I_BEQZ))    OR	 	--beqz
				(to_integer(unsigned(opcode)) = unsigned(I_BNEZ))    OR   	--bnez
				(to_integer(unsigned(opcode)) = unsigned(I_JR))   OR  		--jr
				(to_integer(unsigned(opcode)) = unsigned(I_JALR)) ) then		--jalr
				
					if( (unsigned(RSA) = unsigned(EXE_RD)) AND (unsigned(RSA) /= 0 ) ) then
						opcode_out <=NOP;
						NPC_out    <=std_logic_vector(unsigned(NPC_in)-4);
						PC_sel     <='1';
					end if;
        	--data hazard
			--consider conflict and structural hazard in mem stage
			-- if the mul has a dest and the next instr has the same dest then we will have to wait for the mul to keep the order. (it shouldn't happen often)
		elsif( ((unsigned(RSA)  = unsigned(EXE_RD)) OR (unsigned(RSB) = unsigned(EXE_RD))) AND (flag_ismul='1') ) then
				opcode_out <= NOP;
	   			RD_out	   <= (others=>'0');
                NPC_out    <= std_logic_vector(unsigned(NPC_in)-4);
                PC_sel     <= '1';     

		elsif( (((unsigned(RSA) = unsigned(RD_inmul)) OR (unsigned(RSB) = unsigned(RD_inmul)) ) AND (unsigned(RD_inmul) /=0) )) then 
				opcode_out <= NOP;
	   			RD_out	   <= (others=>'0');
                NPC_out    <= std_logic_vector(unsigned(NPC_in)-4);
                PC_sel     <= '1';    
                                
		elsif(((unsigned(RD) = unsigned(EXE_RD)) OR (unsigned(RD)  = unsigned(RD_inmul))) AND ((unsigned(RD_inmul) /=0) OR (flag_ismul='1'))  ) then              
                opcode_out <= NOP;
	   			RD_out	   <= (others=>'0');
                NPC_out    <= std_logic_vector(unsigned(NPC_in)-4);
                PC_sel     <= '1';                                     
				
		elsif(flag_structHzd='1') then 
				opcode_out <= NOP;
	   			RD_out	   <= (others=>'0');
                NPC_out    <= std_logic_vector(unsigned(NPC_in)-4);
                PC_sel     <= '1';           
				
    	end if;
   	end if;
    
end process logic;

end Behavioral;
