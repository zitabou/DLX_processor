library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use ieee.numeric_std.all;
use WORK.DLX_constants.all;
use WORK.DLX_functions.all;

entity forwarding_unit is
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
end forwarding_unit;

architecture Structural of forwarding_unit is

begin

		-- we are dealing with imm so no FW is needed
    SEL1<=  "00" WHEN ( S1='0') ELSE  
		-- if RA is correct there is no need of fw 
            "01" WHEN ( ( (unsigned(RSA) /= (unsigned(MEM_RD)) AND (unsigned(RSA) /= unsigned(WB_RD)) ) OR (unsigned(RSA) = 0) ) AND S1='1' ) ELSE    
		-- if the correct address is written by the next stage(mem), it is not a L/S and the source is not r0 then take it
            "10" WHEN ( ( unsigned(RSA) = unsigned(MEM_RD) ) AND LD_EN = '0' AND unsigned(RSA) /=0 ) ELSE 
		-- else the correct value is in WB so if is to be written in the RF and the source is not r0 then take it
            "11" WHEN ( ( unsigned(RSA) = unsigned(WB_RD) ) AND WB_EN = '1' AND unsigned(RSA) /=0);
            
            
		-- we are dealing with imm so no FW is needed
    SEL2<=  "01" WHEN ( S2='1') ELSE
		-- if RB is correct there is no need of fw		
            "00" WHEN ( ( (unsigned(RSB) /= (unsigned(MEM_RD)) AND (unsigned(RSB) /= unsigned(WB_RD)) ) OR (unsigned(RSB) = 0) ) AND S2='0' ) ELSE
		-- if the correct address is written by the next stage(mem), it is not a L/S and the source is not the r0 then take it
            "10" WHEN ( ( unsigned(RSB)  = unsigned(MEM_RD) ) AND LD_EN = '0' AND unsigned(RSB) /=0 ) ELSE
		-- else the correct value is in WB so if is to be written in the RF and the source is not r0 then take it
            "11" WHEN ( ( unsigned(RSB)  = unsigned(WB_RD) ) AND WB_EN = '1' AND unsigned(RSB) /=0);        
    
		-- considering that the ME is the value of the second operand(RB) in case of a store instruction the forwarding is applied to RB.
		-- we cannot use the same MUX as for RB because when we store S2=1
		-- if the correct address is written by the next stage(mem), it is not a L/S and the source is not the r0 then take it
    SEL3<=  "10" WHEN ( ( unsigned(RSB)  = unsigned(MEM_RD) ) AND LD_EN = '0' AND unsigned(RSB) /=0 ) ELSE 
		-- else the correct value is in WB so if is to be written in the RF and the source is not r0 then take it
            "11" WHEN ( ( unsigned(RSB)  = unsigned(WB_RD) )  AND WB_EN = '1' AND unsigned(RSB) /=0)  ELSE       
            "01" ;
            


end Structural;
