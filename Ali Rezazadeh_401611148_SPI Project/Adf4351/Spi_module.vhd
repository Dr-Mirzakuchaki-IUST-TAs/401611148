 -- Required Libraries
library IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.NUMERIC_STD.ALL;

entity Spi_module is
	port( -- inputs --
			Clk_sys	:in	std_logic;  -- Master Clock
			Start		:in	std_logic;  -- Additional bit to start the process (not actual pin on device)
			Rst		:in	std_logic;  -- a  synchronous Reset Pin (not actual pin on device)
			-- outputs --
			SCK		:out	std_logic;  -- Slave Clock
			LE			:out	std_logic;  -- LE pin of the Slave (Read Report for more information)
			CE			:out	std_logic;  -- Chip Enable of the Slave
			MOSI		:out	std_logic); -- Data port of the Slave in Data Sheet
end Spi_module;

architecture test of Spi_module is
 -- In/Out signals --
 signal	Start_s	:	std_logic := '0';
 signal	Rst_s		: 	std_logic := '0';
 signal	LE_s		:	std_logic := '1';
 signal	CE_s		:	std_logic := '0';
 signal	MOSI_s	:	std_logic := '0';
 signal	SCK_s		:	std_logic := 'Z';
 signal	Data_s	:	std_logic_vector (31 downto 0) := (others => '0');
 -- Data --
 constant Data		:	std_logic_vector (31 downto 0) := "01101001000101111001011010010011"; -- 32-bit Data we are going to send
 -- Control signals --
 signal	Cnt		:	unsigned (4 downto 0) := "11111"; -- Counter of bits we are going to send
 -- States --
 type		Mode	is	(Idle, Send, delay_ins, delay_ce); -- new type to use for states of program
 signal	State		:	Mode := Idle; -- state of program at the current time
 
begin
 -- signals to ports --
	CE		<= CE_s;
	LE		<= LE_s;
	MOSI	<= MOSI_s;
	SCK	<= SCK_s;
	Rst_s <= Rst;
 -- Main Process --
	Process (Clk_sys) Begin

		if (Clk_sys ='1' and Clk_sys'event) then	-- Rising edge of Clock --

			if (Rst_s ='1') then -- check if reset is enable
			state		<= Idle;
			CE_s		<= '0';
			LE_s		<= '1';
			else
				Data_s	<= Data;
				Start_s	<= Start;
					Case State is  -- Taking actions based on State value
						when Idle 		=>
							MOSI_s	<= '0';
							Cnt		<= "11111";
							Ce_s		<= '0';
							SCK_s		<= 'Z';
							LE_s		<= '1';
							if (Start_s = '1') then -- checks if process should start or not
								State <= delay_ins;
								CE_s	<= '1';
								LE_s	<= '0';
							else							-- if the previous condition is not true
								State	<= Idle;			--- remain in the Idle Mode
								CE_s	<= '0';
								LE_s	<= '1';
							end if;
						
						when delay_ins =>
							State		<= Send;
							CE_s		<= '1';
							MOSI_s	<= Data_s (to_integer(Cnt)); -- puts data on MOSI
							Cnt		<= Cnt - 1;
							LE_s		<= '0';
						
						when Send		=>
							MOSI_s	<= Data_s (to_integer(Cnt));
							CE_s		<= '1';
							LE_s		<= '0';
							if (cnt /= 0) then -- checks if all bits have been sent
								State <= Send;
								Cnt	<= Cnt -1;
							else
								State <= delay_ce;
								Cnt	<= "11111";
							end if;
						
						when delay_ce  =>    -- sending is complete and go back to 
							State		<= Idle; --- the Idle State
							CE_s		<= '1';
							LE_s		<= '0';
							Cnt		<= "11111";
					End Case;
			  End if;
			End if;
			if (CE_s = '1' and state /= Idle)then -- When should give clock to slave
				SCK_s <= not(CLK_sys); -- Best phase for slave clock
			else
				SCK_s <= 'Z';
			end if;

		End Process;			
	end test;
