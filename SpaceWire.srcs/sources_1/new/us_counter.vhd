----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 05/08/2022 06:37:50 PM
-- Design Name: 
-- Module Name: us_counter - Behavioral
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


entity us_counter is
    generic(
         freq: natural := 100_000 -- in kHz
    );
    port(
         clk : in std_logic
        ;rst : in std_logic
        ;tick_6_4us : out std_logic
        ;tick_12_8us : out std_logic
    );
end us_counter;


architecture Behavioral of us_counter is 


constant clk_period : real := 1_000_000.0/real(freq); -- in nsec
constant us6_4time : integer := integer(6_400.0/clk_period);
constant us12_8time : integer := integer(12_800.0/clk_period);

signal us6_4_cnt : integer range 0 to us6_4time := us6_4time;
signal us12_8_cnt : integer range 0 to us12_8time := us12_8time;

begin

process(clk)
begin
    if rising_edge(clk) then
        if rst = '1' then
            us6_4_cnt   <= us6_4time;
            us12_8_cnt  <= us12_8time;
            tick_6_4us  <= '0';
            tick_12_8us <= '0';
        else
            us6_4_cnt  <= us6_4_cnt - 1;
            us12_8_cnt <= us12_8_cnt - 1;
            tick_6_4us  <= '0';
            tick_12_8us <= '0';
            
            if us6_4_cnt = 1 then
                tick_6_4us <= '1';
            end if;
            
            if us12_8_cnt = 1 then
                tick_12_8us <= '1';
            end if;
            
        end if;
    end if;
end process;


end Behavioral;
