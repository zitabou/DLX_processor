--     comments glossary
--
--.   ' --() ' -> is a flow comment
--.   ' --   '  -> is a comment that explains the purpose of the line
--.   ' --*  '   -> comment is too big and can be found to the related tag at the end of the file
--.

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use ieee.math_real.all;

entity CARRY_GENERATOR is
		generic (
			NBIT :		integer := 32;
			NBIT_PER_BLOCK: integer := 4);
		port (
			A :	in	std_logic_vector(NBIT-1 downto 0);
			B :	in	std_logic_vector(NBIT-1 downto 0);
			Cin :	in	std_logic;
			Co :	out	std_logic_vector((NBIT/NBIT_PER_BLOCK)-1 downto 0) );
end CARRY_GENERATOR;



architecture structural of CARRY_GENERATOR is
-- the components are commented in their description

------------
--COMPONENTS
------------

component pg_net
	port (	a :	in	std_logic;
		b :	in	std_logic;
		p :	out	std_logic;
		g :	out	std_logic );
end component;

component G_BLOCK
	port (	p2 :	in	std_logic;
		g2 :	in	std_logic;
		g1 :	in	std_logic;
		G  :	out	std_logic );
end component;

component PG_BLOCK
	port (	p2 :	in	std_logic;
		g2 :	in	std_logic;
		p1 :	in	std_logic;
		g1 :	in	std_logic;
		PG_P :	out	std_logic;
		PG_G :	out	std_logic );
end component;


-----------
--SIGNALS
-----------




type SignalVector is array (NBIT-1 downto 0) of std_logic_vector (NBIT-1 downto 0);
signal p_vector: SignalVector;  --* comment_1 (see end of file)
signal g_vector: SignalVector;  --* comment_1 (see end of file)	










begin

----------------
--INITIALIZATION
----------------


-- given the inputs oth the carry_generator we make the pass through the pg network to obtain i p,g couples which will be
-- stored in the forst row of p_vector ang g_vector respectivelly 
PG_net_block: for i in NBIT-1 downto 1 generate
	pg_network: pg_net
	port map( a=>a(i), b=>b(i), p=>p_vector(0)(i), g=>g_vector(0)(i) );
end generate;
--() Now we have level 0 of the carry generator structure. It is the pg_network composed of the p's and g's for each bit. We have the bits. What is left is to put cin into the equation.

--() Now we need to make Cin part of g(0). So we left the first bit ourside of the PG_net_block generate
g_vector(0)(0) <= ( (a(0) and b(0)) or (p_vector(0)(0) and cin) );  	--concurrent assignment to include p1*cin into g1
p_vector(0)(0) <= a(0) or b(0);  					--concurrent assignment of p1. No carry involved

--() Now we have everything we need to start the tree.
--() The pg_network and the gates necessary to consider the subtraction (b XOR cin, adding through an or the carry on g1)






-----------------
--TREE GENERATION
-----------------
--In the tree there are some blocks that no matter what they must be generated. We'll call these blocks 'std_blocks'. Once they are generated, based on the number of carries we want to generate, we will generate some additional blocks for both PGs and Gs.




--() Let's start generating each level taking into account the characteristics of each level


define_rows: for level in 1 to integer( log2 ( real (NBIT) ) ) generate --the number of rows, depth,  is equal to log_2(number of bits). 'level' identifies the level we are in.

--() Generate PGs of the level
	gen_Blocks: for vec_pos in Nbit-1 downto 0 generate  --for all positions down to the last position used for a PG block. The meaning of each position is assesed with ifs
		pg_limit: if (vec_pos >= 2**level) generate
			std_PG_blocks: if ( vec_pos mod (2**level) = 2**level -1 ) generate --* comment_2 (see at the end of file)
				std_PG: PG_BLOCK
				port map(p2=>p_vector(level-1)(vec_pos),
					g2=>g_vector(level-1)(vec_pos),
					p1=>p_vector(level-1)(vec_pos-2**(level-1)),
					g1=>g_vector(level-1)(vec_pos-2**(level-1)),
					PG_P=>p_vector(level)(vec_pos),
					PG_G=>g_vector(level)(vec_pos));  --the output is the connection below each block. That output may be used or not but it is available.
--() after each std_block if necessary add the additional blocks
				additional_PG: if ( integer( (2**(level-1)) / NBIT_PER_BLOCK ) -1 > 0 ) generate --* comment_3
					gen_add_PG: for k in 1 to ( (integer( (2**(level-1)) / NBIT_PER_BLOCK)-1) ) generate
					add_PG: PG_BLOCK
					port map(p2=>p_vector(level-1)(vec_pos- k*NBIT_PER_BLOCK),
				 		g2=>g_vector(level-1)(vec_pos- k*NBIT_PER_BLOCK),
				 		p1=>p_vector(level-1)(vec_pos-2**(level-1)), --NBIT_PER_BLOCK compensates for vec_pos	
				 		g1=>g_vector(level-1)(vec_pos-2**(level-1)),
				 		PG_P=>p_vector(level)(vec_pos- k*NBIT_PER_BLOCK),
						PG_G=>g_vector(level)(vec_pos- k*NBIT_PER_BLOCK));
					end generate gen_add_PG; -- for
				end generate additional_PG; -- if
			end generate std_PG_blocks; --if

		--propagate signal
			prop: if (vec_pos mod (2**level) /= 2**level -1) generate --used to implement an elsif generate
				lvl_limit: if ( level > (integer (log2 (real (NBIT_PER_BLOCK)))) ) generate  --* comment_4 (see at the end of file)
					BPB_multiplicity: if( vec_pos mod (2**(integer (log2 (real (NBIT_PER_BLOCK))))) =   2**(integer (log2 (real (NBIT_PER_BLOCK))))-1 ) generate
						sel_pos: if( vec_pos mod (2**level) < 2**(level-1) ) generate		
							p_vector(level)(vec_pos) <= p_vector(level-1)(vec_pos);
							g_vector(level)(vec_pos) <= g_vector(level-1)(vec_pos);
						end generate sel_pos; --if
					end generate BPB_multiplicity; --BPB->bits_per_block --if
				end generate lvl_limit;-- if
			end generate prop;-- if
		end generate pg_limit; --if	


		g_limit: if (vec_pos < 2**level) generate --done to implement an elsif generate
		--() Generate Gs of the level
		-- vec_pos during G generation is not changed		
			std_G_blocks: if (vec_pos = 2**level - 1) generate --the position in which the std_G should be
			--() generate std_G_block				
				std_G : G_BLOCK	--Generate G1. g1 already has cin in it. Done during initialization
				port map( p2=>p_vector(level-1)(vec_pos),
					  g2=>g_vector(level-1)(vec_pos),
					  g1=>g_vector(level-1)(vec_pos-2**(level-1)),
					  G=>g_vector(level)(vec_pos) );
				collect_out:if (level >= integer(log2 (real (NBIT_PER_BLOCK))) ) generate			
					Co(integer((vec_pos)/NBIT_PER_BLOCK)) <= g_vector(level)(vec_pos);
				end generate collect_out;-- if
				--() generate additional G blocks
				check_for_add_G: if ( integer( (2**(level-1)) / NBIT_PER_BLOCK ) -1 > 0 ) generate  --* comment_3
					additional_G: for k in 1 to ( integer( (2**(level-1)) / NBIT_PER_BLOCK)-1 ) generate
						add_G : G_BLOCK	--Generate G1. g1 already has cin in it. Done during initialization
						port map( p2=>p_vector(level-1)(vec_pos-k*NBIT_PER_BLOCK),
							g2=>g_vector(level-1)(vec_pos-k*NBIT_PER_BLOCK),
					  		g1=>g_vector(level-1)(vec_pos-2**(level-1)),   --NBIT_PER_BLOCK compensates for vec_pos	
							G=>g_vector(level)(vec_pos-k*NBIT_PER_BLOCK) );
						Co(integer(((vec_pos-k*NBIT_PER_BLOCK))/NBIT_PER_BLOCK)) <= g_vector(level)(vec_pos-k*NBIT_PER_BLOCK);
					end generate additional_G; --for
				end generate check_for_add_G; --if
			end generate std_G_blocks; --if
		end generate g_limit; --if
	end generate gen_Blocks; --for
--() Now we have all the PG blocks of the level. std+additional. If there are any blocks left these are G blocks

end generate define_rows;

end structural;

--at the beginning of the file there is an explanation for the different type of comments


--comment_1--
--
--the matrix represents the data in the tree, the connections values in the figure 2.3 of the pdf. The row_0(level 0) contains the values of the pg_network. So it contains the p and g values. This is done through two matrices that share the indexes. These values will be used by the blocks of the next row(level 1) as inputs and produce results in the row_1(level 1) and so on. Not all elements of a row will be used. In fact each stage will have a number of blocks equal to NBIT/2**level



--comment_2--
--
-- With mod we restaraint the index inside a range defined by the level. ex: level=1-> the step is two positions, level->2 the step is 4 positions. the '=' is used to be sure that we are in a position multiple of 2**level. In those positions the blocks must be generated no matter what.
-- [ 2**(level-1) ] is the step.


--comment_3--
--
--the condition that has to be met so that the additional blocks must be generated is that, given the step of the previous level [2**(level-1)], we must have a space of NBIT_PER_BLOCK positions. If NBIT_PER_BLOCK positions fits in that space then the result will be >0. We considered the -1 because the std_G_block is already generated and we use it as a starting point. So in the end 
--[integer( (2**(level-1)) / NBIT_PER_BLOCK ) -1] = the number of blocks to be added




--comment_4--
--
 -- We use the same condition as in the std_PG_blocks(comment_2) but for the level we use the level where the step is equal to the NBIT_PER_BLOCK. This is done because at each multiple of NBIT_PER_BLOCK position we must have an std_PG, an additional_PG or a propagation of the signal.
--So we checked for the std_PG then if it is an std_PG at vec_pos we check if we should add any PGs. Once this is done we propagate the remaining positions. The checks done are 1)Is the current level higher than the level from which we must consider propagation 2)Is the position op possible propagation a multiple of NBIT_PER_BLOCK 3)Is the vec_pos a ¨free¨ position. 



--comment_5--
--
--PGs are done and 2**level was the last position checked, not necessarily used, for the PGs. The first G block of the level will start from the next position and at least one will be generated. So (vec_pos = 2**level - 1) makes so that the generate will happe only for that position. Then we will eventually generate more.




