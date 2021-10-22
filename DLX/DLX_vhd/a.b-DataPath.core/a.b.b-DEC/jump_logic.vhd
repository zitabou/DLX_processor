library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use ieee.numeric_std.all;
use WORK.DLX_constants.all;
use WORK.DLX_functions.all;

entity jump_logic is
    generic(WORD_size: integer := data_size;
    		NREG: integer := num_reg;
    		reg_file_size: integer:= 32);
    port(
         opcode:    in  std_logic_vector(OP_CODE_SIZE-1 downto 0);			--used to detect jumps
         RSA:       in  std_logic_vector(Log2(reg_file_size)-1 downto 0);	--used to detect forwarding by comparing with WB_RD and MEM_RD
		 WB_RD:     in  std_logic_vector(Log2(reg_file_size)-1 downto 0);	
		 MEM_RD:    in  std_logic_vector(Log2(reg_file_size)-1 downto 0);	
		 Rega:	    in  std_logic_vector(data_size-1 downto 0);				--output of Register File
		 ALU_out:  	in  std_logic_vector(data_size-1 downto 0);				--ALU_out register signal in MEM stage
		 MEM_out:  	in  std_logic_vector(data_size-1 downto 0);				--output of mux in WB stage
		 Rega_new:  out std_logic_vector(data_size-1 downto 0);				--the correct value of R[rega]
		 mux_s:		out std_logic;											--signal to select the kind of jump (adder/R[rega])
		 flag:		out std_logic											--signal to select(no jump/jump)
		 );
end jump_logic;


architecture Behavioral of jump_logic is

signal s_mux_sel: std_logic;
signal s_flag: std_logic;
signal s_Rega_new: std_logic_vector(data_size-1 downto 0);

begin

	s_Rega_new <= ALU_out when ( unsigned(RSA) = unsigned(MEM_RD)) else
				  MEM_out when ( unsigned(RSA) = unsigned(WB_RD)) else
				  Rega;		-- in case we have no forwarding, the value will not change
	
	--forwarding
	--if( unsigned(RSA) = unsigned(MEM_RD) ) then		-- if we have forwarding in MEM stage 
	--	s_Rega_new <= ALU_out;						-- we update R[rega] value with ALU_out
	--elsif( unsigned(RSA) = unsigned(WB_RD) ) then	-- if we have forwarding in WB stage 
	--	s_Rega_new <= MEM_out;						-- we update R[rega] value with WB_out
	--end if;

dec_proc: process(opcode,RSA,WB_RD,MEM_RD,s_Rega_new,ALU_out,MEM_out)
begin
	

	
	
	--mux signal selection
	s_mux_sel <= '0'; 
	s_flag <= '0'; 
	
	-- here we detect jumps by reading the opcode
	-- in case of having any kind of jump, we set flag signal to 1
	-- in 2 cases of JALR and JR, we set mux_sel to 1, to choose R[rega] instead of adder_output in related mux
	
    if(to_integer(unsigned(opcode)) 	= unsigned(I_J)) then				-- j
		s_flag <= '1';
		
	elsif(to_integer(unsigned(opcode)) 	= unsigned(I_JAL)) then			-- jal
		s_flag <= '1';
		
	elsif(to_integer(unsigned(opcode)) 	= unsigned(I_JALR)) then			-- jalr
		s_mux_sel <= '1';
		s_flag <= '1';
		
	elsif(to_integer(unsigned(opcode)) 	= unsigned(I_JR)) then			-- jr
		s_mux_sel <= '1';	
		s_flag <= '1';
		
	elsif( to_integer(unsigned(opcode)) = unsigned(I_BEQZ))  then  		-- beqz
		if ( to_integer(unsigned(s_Rega_new)) = 0 ) then	-- since it's a conditional jump
			s_flag <= '1';
		end if;
		
	elsif( to_integer(unsigned(opcode)) = unsigned(I_BNEZ) ) then 			-- bnez
		if ( to_integer(unsigned(s_Rega_new)) /= 0 ) then	-- since it's a conditional jump
			s_flag <= '1';
		end if;
		
    end if;
end process dec_proc;

Rega_new <= s_Rega_new;
mux_s <= s_mux_sel;
flag  <= s_flag;

end Behavioral;
