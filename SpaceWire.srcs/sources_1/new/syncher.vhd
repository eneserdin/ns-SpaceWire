----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 05/14/2022 10:58:44 PM
-- Design Name: 
-- Module Name: syncher - Behavioral
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
use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity syncher is port(
     clka : in std_logic 
    ;strba : in std_logic
    ;clkb : in std_logic 
    ;strbout : out std_logic 
    );
end syncher;

architecture Behavioral of syncher is

--signal strbin_r: std_logic ;
--signal strbin_2r: std_logic ;
--signal strbout_p: std_logic ;

--signal incoming_cs : integer range 0 to 3 := 0;
--signal outgoing_cs : integer range 0 to 3 := 0;
--signal req_ack : std_logic;
--signal req_ack_r : std_logic;
--signal ack_r : std_logic;
--signal ack : std_logic;
signal strbout_l : std_logic;


signal incoming_cntr : std_logic_vector(3 downto 0) := "0000";

signal outgoing_cntr : std_logic_vector(3 downto 0) := "0000";
signal outgoing_cntr_r : std_logic_vector(3 downto 0) := "0000";

signal incoming_cntr_p : std_logic_vector(3 downto 0) := "0000";
signal incoming_cntr_r : std_logic_vector(3 downto 0) := "0000";


begin

-- incoming strb signal
process(clka)
begin
    if rising_edge(clka) then
        if strba = '1' then
            case incoming_cntr is
                when "0000" => incoming_cntr <= "0001";
                when "0001" => incoming_cntr <= "0011";
                when "0011" => incoming_cntr <= "0010";
                when "0010" => incoming_cntr <= "0110";
                when "0110" => incoming_cntr <= "0100";
                when "0100" => incoming_cntr <= "0101";
                when "0101" => incoming_cntr <= "0111";
                when "0111" => incoming_cntr <= "1111";
                when "1111" => incoming_cntr <= "1101";
                when "1101" => incoming_cntr <= "1100";
                when "1100" => incoming_cntr <= "1110";
                when "1110" => incoming_cntr <= "1010";
                when "1010" => incoming_cntr <= "1011";
                when "1011" => incoming_cntr <= "1001";
                when "1001" => incoming_cntr <= "1000";
                when "1000" => incoming_cntr <= "0000";
                when others => incoming_cntr <= "0000";
            end case;
        end if;
    end if;
end process;


-- outgoing one

process(clkb)
begin
    if rising_edge(clkb) then
        incoming_cntr_p <= incoming_cntr;
        incoming_cntr_r <= incoming_cntr_p;
        
        if strbout_l = '1' then
            case outgoing_cntr is
                when "0000" => outgoing_cntr <= "0001";
                when "0001" => outgoing_cntr <= "0011";
                when "0011" => outgoing_cntr <= "0010";
                when "0010" => outgoing_cntr <= "0110";
                when "0110" => outgoing_cntr <= "0100";
                when "0100" => outgoing_cntr <= "0101";
                when "0101" => outgoing_cntr <= "0111";
                when "0111" => outgoing_cntr <= "1111";
                when "1111" => outgoing_cntr <= "1101";
                when "1101" => outgoing_cntr <= "1100";
                when "1100" => outgoing_cntr <= "1110";
                when "1110" => outgoing_cntr <= "1010";
                when "1010" => outgoing_cntr <= "1011";
                when "1011" => outgoing_cntr <= "1001";
                when "1001" => outgoing_cntr <= "1000";
                when "1000" => outgoing_cntr <= "0000";
                when others => outgoing_cntr <= "0000";
            end case;
        end if;
        
        outgoing_cntr_r <= outgoing_cntr;
        
        strbout_l <= '0';
        if (outgoing_cntr /= incoming_cntr_r) and strbout_l = '0' then
            strbout_l <= '1';
        end if;
        
        strbout <= strbout_l;
        
    end if;
end process;


end Behavioral;
