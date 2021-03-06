library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

ENTITY part2 IS
	PORT (
		CLOCK_50 : IN STD_LOGIC; -- 50 MHz Clock
		CLOCK2_50 : IN STD_LOGIC; -- 50 MHz Clock
		CLOCK3_50 : IN STD_LOGIC; -- 50 MHz Clock
		CLOCK4_50 : IN STD_LOGIC; -- 50 MHz Clock
		SW : IN STD_LOGIC_VECTOR(9 downto 0); -- switches
		KEY : IN STD_LOGIC_VECTOR(3 downto 0); -- push buttons
		LEDR : OUT STD_LOGIC_VECTOR(9 downto 0); -- red LEDs
		HEX0 : OUT STD_LOGIC_VECTOR(0 to 6); -- hex displays 0 through 5
		HEX1 : OUT STD_LOGIC_VECTOR(0 to 6);
		HEX2 : OUT STD_LOGIC_VECTOR(0 to 6);
		HEX3 : OUT STD_LOGIC_VECTOR(0 to 6);
		HEX4 : OUT STD_LOGIC_VECTOR(0 to 6);
		HEX5 : OUT STD_LOGIC_VECTOR(0 to 6)
		);
END ENTITY part2;

architecture behavior of part2 is
	signal input1: signed(7 downto 0);
	signal input2: signed(7 downto 0);
	signal result: signed(15 downto 0);
	signal in_reg1, in_reg2: signed(7 downto 0);
	signal res_reg: signed(15 downto 0);
	signal state, next_state: std_logic_vector(3 downto 0);
	--signal div0: boolean := false;
	
	function nibbleToSevenSegment(h: std_logic_vector(3 downto 0)) return std_logic_vector is
		variable ret: std_logic_vector(6 downto 0);
	begin
		--identify segments that are on
		case h is
			when X"0" => ret := "1111110";
			when X"1" => ret := "0110000";
			when X"2" => ret := "1101101"; 
			when x"3" => ret := "1111001"; 
			when X"4" => ret := "0110011"; 
			when X"5" => ret := "1011011";
			when X"6" => ret := "1011111";
			when X"7" => ret := "1110000";
			when X"8" => ret := "1111111";
			when X"9" => ret := "1111011"; 
			when X"a" => ret := "1110111"; --
			when X"b" => ret := "0011111";
			when X"c" => ret := "1001110"; 
			when X"d" => ret := "0111101";
			when X"e" => ret := "1001111";
			when X"f" => ret := "1000111"; --
			
			when others => ret := "0000000";
		end case;
		--led's are active low, complement return
		ret := not ret;
		return ret;
	end function;
	
begin
	HEX4 <= "1111111";
	
	process(CLOCK_50, KEY(3))
	begin
		if KEY(3) = '0' then
			state <= "0000";
			res_reg <= (others => '0'); 
			in_reg1 <= (others => '0');
			in_reg2 <= (others => '0');
		elsif rising_edge(clock_50) then
			state <= next_state;
			in_reg1 <= input1;
			in_reg2 <= input2;
			res_reg <= result;
		end if;
	end process;
	
	process(KEY)
	begin	 
		if KEY(3) = '0' then
			next_state(1 downto 0) <= "00";
			input1 <= (others => '0');
			input2 <= (others => '0');
		elsif falling_edge(KEY(0)) then   
			input1 <= in_reg1;
			input2 <= in_reg2;
			next_state(1 downto 0) <= state(1 downto 0);
			if state = "0000" then
				input1 <= signed(SW(7 downto 0));
				next_state(0) <= '1';
			elsif state = "0001" then
				input2 <= signed(SW(7 downto 0));
				next_state(1) <= '1';  
			end if;
			
		end if;
	end process;	 
	
	process(KEY)
	begin
		if KEY(3) = '0' then
			next_state(3 downto 2) <= "00";
			result <= (others => '0');
		elsif falling_edge(KEY(1)) then	 
			next_state(3) <= '0';
			case state(1) is -- = '1' then	
				when '1' =>
					next_state(2) <= '1';
					case SW(9 downto 8) is
						when "00" => result <= resize(in_reg1, 16) + resize(in_reg2, 16);
						when "01" => result <= resize(in_reg1, 16) - resize(in_reg2, 16);
						when "10" => result <= in_reg1 * in_reg2;
						when "11" => if in_reg2 /= "00000000" then
								result(15 downto 8) <= in_reg1 / in_reg2;
								result(7 downto 0) <= in_reg1 rem in_reg2;
							else 
								result <= (others => 'X');	
								next_state(3) <= '1';
							end if;
						
						when others => result <= (others => 'X');
				end case;  
				when others => 
					result <= res_reg;
				    next_state(3 downto 2) <= state(3 downto 2);
			end case;	  
		end if;
	end process;
	
	
	
	process(CLOCK_50)
	begin  
		if rising_edge(CLOCK_50) then
			if state(3) = '1' then
				HEX0 <= "1111111";
				HEX1 <= "1111111";
				HEX2 <= "1111111";
				HEX3 <= "1111111";
				HEX5 <= nibbleToSevenSegment(X"E");
			elsif state(2) = '1' and state(3) = '0' then
				HEX0 <= nibbleToSevenSegment(std_logic_vector(res_reg( 3 downto  0)));
				HEX1 <= nibbleToSevenSegment(std_logic_vector(res_reg( 7 downto  4)));
				HEX2 <= nibbleToSevenSegment(std_logic_vector(res_reg(11 downto  8)));
				HEX3 <= nibbleToSevenSegment(std_logic_vector(res_reg(15 downto 12)));
				HEX5 <= "1111111";
			elsif state = "0001" then
				HEX0 <= nibbleToSevenSegment(std_logic_vector(in_reg1( 3 downto  0)));
				HEX1 <= nibbleToSevenSegment(std_logic_vector(in_reg1( 7 downto  4)));
				HEX2 <= "1111111";
				HEX3 <= "1111111";
				HEX5 <= "1111111";
			elsif state(2 downto 1) = "01" then
				HEX0 <= nibbleToSevenSegment(std_logic_vector(in_reg2( 3 downto  0)));
				HEX1 <= nibbleToSevenSegment(std_logic_vector(in_reg2( 7 downto  4)));
				HEX2 <= "1111111";
				HEX3 <= "1111111";
				HEX5 <= "1111111";
			else
				HEX0 <= "1111111";
				HEX1 <= "1111111";
				HEX2 <= "1111111";
				HEX3 <= "1111111";
				HEX5 <= "1111111";
			end if;	
		end if;
	end process;
end architecture;





