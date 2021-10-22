library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;
use WORK.DLX_constants.all;
use WORK.DLX_functions.all;

entity comparator is
	port(Z: 		IN std_logic;								-- indicates if the two operands are equal. (Z=1->A-B=0, Z=0->A-B/=0)
		 cout: 		IN std_logic;								-- carry out generated from the subtraction 
		 eq: 		OUT std_logic;								-- indicates a=b
		 neq: 		OUT std_logic;								-- indicates a/=b
		 gt: 		OUT std_logic;								-- indicates a>b
		 lt: 		OUT std_logic;								-- indicates a<b
		 ge: 		OUT std_logic;								-- indicates a>=b
		 le: 		OUT std_logic								-- indicates a<=b
	 );
end comparator;



architecture Structural of comparator is

begin

	eq <=  Z;
	neq<=  NOT Z; 					
	Gt <= (NOT Z) AND cout; 	
	lt <=  NOT cout;
	ge <=  cout; 					
	le <= (NOT cout) OR Z;		
	


end Structural;
