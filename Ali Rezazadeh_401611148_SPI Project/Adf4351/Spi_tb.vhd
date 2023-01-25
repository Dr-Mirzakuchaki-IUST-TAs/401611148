LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE IEEE.NUMERIC_STD.ALL;
 
ENTITY Spi_tb IS
END Spi_tb;
 
ARCHITECTURE behavior OF Spi_tb IS 
 
    -- Component Declaration for the Unit Under Test (UUT)
 
   --Inputs
   signal Clk_sys : std_logic := '0';
   signal Start   : std_logic := '0';
   signal SCK 		: std_logic := '0';
	signal Rst 		: std_logic := '0';

 	--Outputs
   signal LE : std_logic:='1';
   signal CE : std_logic:='0';
   signal MOSI : std_logic;
	--inner

   -- Clock period definitions
   constant Clk_sys_period : time := 50 ns;
BEGIN
 
	-- Instantiate the Unit Under Test (UUT)
   uut:entity work.Spi_module PORT MAP (
          Clk_sys => Clk_sys,
          Start => Start,
          SCK => SCK,
          LE => LE,
          CE => CE,
          MOSI => MOSI,
			 Rst => Rst
        );

		Start <='0', '1' after 1100 ns, '0' after 1200 ns,'1' after 2000 ns, '0' after 2100 ns;
		Rst <='0', '1' after 1800 ns, '0' after 1900 ns;

   -- Clock process definitions
   Clk_sys_process :process
   begin
		Clk_sys <= '0';
		wait for Clk_sys_period/2;
		Clk_sys <= '1';
		wait for Clk_sys_period/2;
   end process;

END;
