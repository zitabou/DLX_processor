library ieee; 
use ieee.std_logic_1164.all; 
use ieee.std_logic_unsigned.all;
use WORK.DLX_constants.all;

-- Entity declaration
entity logicals is
	generic (nbit :	integer := 32);
	port (func : in  std_logic_vector(fun_bits-1 downto 0);
		  SN   : in  std_logic;
          in1  : in  std_logic_vector(nbit-1 downto 0);
          in2  : in  std_logic_vector(nbit-1 downto 0);
          o    : out std_logic_vector(nbit-1 downto 0));
end logicals;

-- Behavioral description
architecture behavioral of logicals is

    component nand31 is
        port (in1: in  std_logic;
              in2: in  std_logic;
              in3: in  std_logic;
              o  : out std_logic);
    end component nand31;
    
    component nand41 is
        port (in1: in  std_logic;
              in2: in  std_logic;
              in3: in  std_logic;
              in4: in  std_logic;
              o  : out std_logic);
    end component nand41;
    
    signal in1_n: std_logic_vector(nbit-1 downto 0);
    signal in2_n: std_logic_vector(nbit-1 downto 0);
    
    signal s0: std_logic_vector(nbit-1 downto 0);
    signal s1: std_logic_vector(nbit-1 downto 0);
    signal s2: std_logic_vector(nbit-1 downto 0);
    signal s3: std_logic_vector(nbit-1 downto 0);
    
    signal l0: std_logic_vector(nbit-1 downto 0);
    signal l1: std_logic_vector(nbit-1 downto 0);
    signal l2: std_logic_vector(nbit-1 downto 0);
    signal l3: std_logic_vector(nbit-1 downto 0);

begin

    level1: for i in nbit-1 downto 0 generate  
                g1_a: nand31 port map (s0(i), in1_n(i), in2_n(i), l0(i));
                g1_b: nand31 port map (s1(i), in1_n(i), in2(i)  , l1(i));
                g1_c: nand31 port map (s2(i), in1(i)  , in2_n(i), l2(i));
                g1_d: nand31 port map (s3(i), in1(i)  , in2(i)  , l3(i));
            end generate level1;
           
    level2: for i in nbit-1 downto 0 generate
                g2_a: nand41 port map (l0(i), l1(i), l2(i), l3(i), o(i));
            end generate level2;

    process (func, SN, in1, in2)
    begin
    
        if (func = BITAND AND SN='0') then 
            s0 <= (others => '0');
	        s1 <= (others => '0');
	        s2 <= (others => '0');
	        s3 <= (others => '1');
	    elsif (func = BITOR AND SN='0') then 
            s0 <= (others => '0');
	        s1 <= (others => '1');
	        s2 <= (others => '1');
	        s3 <= (others => '1');
	    elsif (func = BITXOR AND SN='0') then 
            s0 <= (others => '0');
	        s1 <= (others => '1');
	        s2 <= (others => '1');
	        s3 <= (others => '0');
	    elsif (func = BITNAND AND SN='1') then 
            s0 <= (others => '1');
	        s1 <= (others => '1');
	        s2 <= (others => '1');
	        s3 <= (others => '0');
	    elsif (func = BITNOR AND SN='1') then 
            s0 <= (others => '1');
	        s1 <= (others => '0');
	        s2 <= (others => '0');
	        s3 <= (others => '0');
	    elsif (func = BITXNOR AND SN='1') then 
            s0 <= (others => '1');
	        s1 <= (others => '0');
	        s2 <= (others => '0');
	        s3 <= (others => '1'); 
        else
        	s0 <= (others => '0');
	        s1 <= (others => '0');
	        s2 <= (others => '0');
	        s3 <= (others => '1'); 
        end if;

    end process;
    
    in1_n <= not in1;
    in2_n <= not in2;

end behavioral;


