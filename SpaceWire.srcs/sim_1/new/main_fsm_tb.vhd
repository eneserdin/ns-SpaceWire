----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 05/02/2022 01:57:59 PM
-- Design Name: 
-- Module Name: main_fsm_tb - Behavioral
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

entity main_fsm_tb is
--  Port ( );
end main_fsm_tb;

architecture Behavioral of main_fsm_tb is

signal clk : std_logic := '0';
signal rst : std_logic := '0';

begin

uut: work.main_fsm port map(
     clk => clk
    ,rst => rst
    );

end Behavioral;
