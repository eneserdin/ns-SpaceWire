----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 05/08/2022 07:00:42 PM
-- Design Name: 
-- Module Name: us_cntr_tb - Behavioral
-- Project Name: 
-- Target Devices: 
-- Tool Versions: 
-- Description: 
-- 
-- Dependencies: 
-- 
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
-- 
----------------------------------------------------------------------------------


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity us_cntr_tb is
end us_cntr_tb;

architecture Behavioral of us_cntr_tb is

signal clk : std_logic := '1';
signal rst : std_logic := '1';
signal tick_6_4us : std_logic := '0';
signal tick_12_8us : std_logic := '0';



begin

uut : entity work.us_counter
    generic map(
        freq => 100_000
    )
    port map(
         clk => clk
        ,rst => rst
        ,tick_6_4us => tick_6_4us
        ,tick_12_8us => tick_12_8us
        );


clk <= not clk after 5 ns;
rst <= '1','0' after 100 ns;

end Behavioral;
