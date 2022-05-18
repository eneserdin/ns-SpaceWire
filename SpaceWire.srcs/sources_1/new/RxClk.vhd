----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 04/15/2022 05:16:24 PM
-- Design Name: 
-- Module Name: RxClk - Behavioral
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

entity RxClk is
    Port ( din : in STD_LOGIC
           ;sin : in STD_LOGIC
           ;RxClk : out std_logic
           );
end RxClk;

architecture Behavioral of RxClk is

signal RxClk_i : std_logic := '0';

begin

RxClk_i <= din xor sin; -- this can be a LUT and clock can be a regional clock buffer
RxClk <= RxClk_i; -- we need to put clock buffer here.




end Behavioral;
