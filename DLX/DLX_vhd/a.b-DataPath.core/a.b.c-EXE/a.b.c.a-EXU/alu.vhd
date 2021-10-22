library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;
use WORK.DLX_constants.all;
use WORK.DLX_functions.all;

entity ALU is
  generic (N : integer := 8);
  port 	 ( DATA1, DATA2: IN std_logic_vector(N-1 downto 0);			-- operands
  		   FUNC: 	IN std_logic_vector(FUN_BITS-1 downto 0);		-- operation to be executed
  		   SN: 		IN std_logic;         							-- indicator of signed(1)/unsigned(0) operation
           OVF:		OUT std_logic;									-- overflow signal
           OUTALU: 	OUT std_logic_vector(N-1 downto 0));			-- result of the operation
end ALU;

architecture BEHAVIOR of ALU is

	component shifter is
	generic(NBITS: integer := 32);
	port(R1: IN std_logic_vector(NBITS-1 downto 0);				--operand 1 to be shifted
		 R2: IN std_logic_vector(NBITS-1 downto 0);				--operand 2 that indicate the amount to shift
		 LnR: IN std_logic;										--signal indicating a shift left(1) or a shift right(0)
		 AnL: IN std_logic;										--signal indicating an arithmetic shift(1) or a logic shift(0)
		 RnS: IN std_logic;										--signal indicating a rotate_right(1) or a shift(0)
		 Rout: OUT std_logic_vector(NBITS-1 downto 0)			--result of the shift
	);
	end component;

    component p4_adder is
	generic (NBIT :		integer := 32);
	port (	
		A    :	in	std_logic_vector(NBIT-1 downto 0);			-- operand_1
		B    :	in	std_logic_vector(NBIT-1 downto 0);			-- operand_2
		Cin  :	in	std_logic;									-- carry in. Cin=1->sub, Cin=0->add
		S    :	out	std_logic_vector(NBIT-1 downto 0);			-- result of the p4 adder
		Cout :	out	std_logic;									-- carry out of the operation
		ovf  : 	out std_logic);									-- overflow signal
    end component;

	component logicals is
	generic (nbit :	integer := 32);
	port (func : in  std_logic_vector(fun_bits-1 downto 0);
		  SN   : in  std_logic;
          in1  : in  std_logic_vector(nbit-1 downto 0);
          in2  : in  std_logic_vector(nbit-1 downto 0);
          o    : out std_logic_vector(nbit-1 downto 0));
	end component;
	
	component nor_generic is
	generic(NBITS: integer :=8);
	port(input: 	IN std_logic_vector(NBITS-1 downto 0);		-- multibit input
		 result: 	OUT std_logic								-- single output of the or between all the input bits
		 );
	end component;

	component comparator is
	port(Z: 		IN std_logic;								-- indicates if the two operands are equal. (Z=1->A-B=0, Z=0->A-B/=0)
		 cout: 		IN std_logic;								-- carry out generated from the subtraction 
		 eq: 		OUT std_logic;								-- indicates a=b
		 neq: 		OUT std_logic;								-- indicates a/=b
		 gt: 		OUT std_logic;								-- indicates a>b
		 lt: 		OUT std_logic;								-- indicates a<b
		 ge: 		OUT std_logic;								-- indicates a>=b
		 le: 		OUT std_logic								-- indicates a<=b
		);
	end component;
	
	
	

	-- connection signals
	signal shifter_out: 			std_logic_vector(N-1 downto 0);
	signal s_LnR, s_AnL, s_RnS: 	std_logic;
	signal p4_sum, comp_in: 		std_logic_vector(N-1 downto 0);
	signal p4_cin, p4_cout, p4_ovf: std_logic;
	signal is_zero, comp_out: 		std_logic;
	signal s_eq, s_neq, s_gt, s_lt , s_ge, s_le: std_logic;
	signal logic_out:				std_logic_vector(N-1 downto 0);
	signal logic_func:				std_logic_vector(FUN_BITS-1 downto 0);
  
begin

	alu_shifter: SHIFTER
	generic map(NBITS=>N)
	port map(R1=>DATA1, R2=>DATA2, LnR=>s_LnR, AnL=>s_AnL, RnS=>s_RnS, Rout=>shifter_out);

    alu_adder: p4_adder
    generic map (NBIT=>N)
    port map (A=>DATA1, B=>DATA2, Cin=>p4_cin, S=>p4_sum, Cout=>p4_cout, OVF=>p4_ovf);
    
    alu_logicals: logicals
    generic map (nbit=>N)
	port map(func=>logic_func, SN=>SN, in1=>DATA1, in2=>DATA2, o=>logic_out);
    
    nor_gen:nor_generic
    generic map(NBITS=>N)
    port map(input=>p4_sum, result=>is_zero);

	comp: comparator
	port map (Z=>is_zero, cout=>p4_cout, eq=>s_eq, neq=>s_neq, gt=>s_gt, lt=>s_lt, ge=>s_ge, le=>s_le);


P_ALU: process (FUNC, SN, DATA1, DATA2, p4_sum, p4_ovf, shifter_out, s_eq, s_neq, s_gt, s_lt, s_ge, s_le)

  
  begin

	
    case FUNC is
	when ADDS 	=> 	p4_cin<='0';			-- add 
				  	ovf<= p4_ovf;			--collect overflow
				  	OUTALU <= p4_sum; 		--collect output
				  	                     
	when SUBS 	=>	p4_cin<='1';			--subtract
				  	ovf<= p4_ovf;			--collect overflow
				  	OUTALU <= p4_sum;       --collect output
				  	                             
				  	
	when BITAND	=> 	logic_func<=func;
					OUTALU <= logic_out;
	-- it includes NAND. The difference is on the SN. SN=0 then AND if SN=1 then NAND. The SN signal is passed in the porting 			  	
				  	                  
	when BITOR 	=> 	logic_func<=func;
					OUTALU <= logic_out;
	-- it includes NAND. The difference is on the SN. SN=0 then AND if SN=1 then NAND. The SN signal is passed in the porting 	
					
	when BITXOR => 	logic_func<=func;
					OUTALU <= logic_out;
	-- it includes NAND. The difference is on the SN. SN=0 then AND if SN=1 then NAND. The SN signal is passed in the porting 	
	
	
	
	--comparisons
	when EQ		=>	p4_cin<='1';			-- sub 
					OUTALU(N-1 downto 1) <= (others=>'0');
					OUTALU(0) <= s_eq;


	when NE		=> 	p4_cin<='1';			-- sub 
					OUTALU(N-1 downto 1) <= (others=>'0');
					OUTALU(0) <= s_neq;
						   
			   
	when GT		=> 	p4_cin<='1';		-- sub
					OUTALU(N-1 downto 1) <= (others=>'0');
					OUTALU(0) <= s_gt;
					if(((DATA1(N-1) XOR DATA2(N-1)) AND SN) = '1') then
						 OUTALU(0) <= not s_gt;
					end if;				
					

	when LT		=>	p4_cin<='1';		-- sub
					OUTALU(N-1 downto 1) <= (others=>'0');
					OUTALU(0) <= s_lt;
					if(((DATA1(N-1) XOR DATA2(N-1)) AND SN) = '1') then
						 OUTALU(0) <= not s_lt;
					end if;	
			 
			 
	when GE		=> 	p4_cin<='1';		-- sub
					OUTALU(N-1 downto 1) <= (others=>'0');
					OUTALU(0) <= s_ge;
					if((s_eq='0') AND (((DATA1(N-1) XOR DATA2(N-1)) AND SN)) = '1') then
						 OUTALU(0) <= not s_ge;
					end if;	


	when LE		=> 	p4_cin<='1';		-- sub
					OUTALU(N-1 downto 1) <= (others=>'0');
					OUTALU(0) <= s_le;
					if((s_eq='0') AND (((DATA1(N-1) XOR DATA2(N-1)) AND SN)) = '1') then
						OUTALU(0) <= not s_le;
					end if;	
			 
			 
	--shifts
	--** shift 32 doesn't do anything ***. We could add a check on R2 so when it is >= to 32 we output (others=>'0')
    
	when LSL 	=>	s_LnR <='1';
					s_AnL <='0';
					s_RnS <='0';
					OUTALU<=shifter_out;
                    
    when LSR 	=> 	s_LnR <='0';
					s_AnL <='0';
					s_RnS <='0';
					OUTALU<=shifter_out;
       
       
    when ASR 	=> 	s_LnR <='0';
					s_AnL <='1';
					s_RnS <='0';
					OUTALU<=shifter_out;
					
	when RTR	=>	s_LnR <='0';
					s_AnL <='0';		--doesnt matter
					s_RnS <='1';
					OUTALU<=shifter_out;



	when others => OUTALU<=(others=>'0');
    end case; 
  end process P_ALU;

end BEHAVIOR;
