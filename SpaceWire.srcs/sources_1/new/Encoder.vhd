----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 04/20/2022 01:39:42 PM
-- Design Name: 
-- Module Name: Encoder - Behavioral
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

entity Encoder is port(
     clk : in std_logic
    ;rst : in std_logic
    ;dot : out std_logic
    ;sot : out std_logic
    
    ;FCT_enabled : in std_logic
    ;SendNULLs : in std_logic
    
    ;datain : in std_logic_vector(7 downto 0)
    ;TCin   : in std_logic_vector(7 downto 0)
    
    ;fct_req  : in std_logic
    ;data_req : in std_logic
    ;tc_req   : in std_logic
    
    ;fct_ack  : out std_logic
    ;data_ack : out std_logic
    ;tc_ack   : out std_logic
    
    ;NULL_SENT : out std_logic
    ;FCT_SENT  : out std_logic

    );
end Encoder;

architecture Behavioral of Encoder is

constant MAIN_FREQ : integer := 100_000; --in KHz

constant MBps10 : integer := 10_000; --in KHz

constant CLK_Period : real := 1.0/MAIN_FREQ; -- in nsec
constant MY10Period : real := (1.0/MBps10)/2.0;

constant CNT10_const : integer := integer(MY10Period/CLK_Period);

signal TxClk : std_logic := '0';
signal TxClk_r : std_logic := '0';
signal CNT10 : integer range 0 to 2047 := 0;
signal clk_en : std_logic := '0';

signal bufferToSend : std_logic_vector(13 downto 0) := (others => '0');
signal bit_cnt : integer range 0 to 15 := 0;
signal bit_cnt_r : integer range 0 to 15 := 0;
signal bit_cnt_2r : integer range 0 to 15 := 0;

signal dout : std_logic := '0';
signal sout : std_logic := '0';
signal sync_enable : std_logic := '0';

signal fct_req_r : std_logic := '0';
signal data_req_r : std_logic := '0';
signal tc_req_r : std_logic := '0';

signal loader_parity : std_logic := '0';



constant NULL_LOADED    : std_logic_vector := "001";
constant FCT_LOADED     : std_logic_vector := "011";
constant TC_LOADED      : std_logic_vector := "101";
constant DATA_LOADED    : std_logic_vector := "010";

signal LOADED_WAS : std_logic_vector(2 downto 0) := (others => '0');

begin

process(clk,rst) begin
if rising_edge(clk) then
    dot <= dout;
    sot <= sout;
    if rst ='1' then
        TxClk <= '0';
        clk_en <= '0';
        CNT10 <= 0;
    else
        clk_en <= '0';
        if CNT10 = 0 then
            CNT10 <= CNT10_const-1;
            TxClk <= not TxClk;
            clk_en <= '1';
        else
            CNT10 <= CNT10 - 1;
        end if;
    end if;
end if;
end process;


process(clk,rst)
---------
impure function loader_parity_func(a : in std_logic_vector(7 downto 0)) return std_logic is
    variable localpar : std_logic := '0';
    begin
    for ii in 0 to 7 loop
        localpar := localpar xor a(ii);
    end loop;
    return localpar;
end function;
---------
procedure LOAD_NULL_procedure is begin
    bit_cnt <= 7;
    bufferToSend <= "000000"& (loader_parity xor '0') & "1110100"; -- this is null -- parity can be updated here.
    loader_parity <= '0';
    LOADED_WAS <= NULL_LOADED;
end procedure;

procedure LOAD_FCT_procedure is begin
    bit_cnt <= 3;
    bufferToSend <= "0000000000"& (loader_parity xor '0')  &"100"; -- this is fct
    loader_parity <= '0';
    LOADED_WAS  <= FCT_LOADED;
    fct_ack     <= '1'; 
end procedure;

procedure LOAD_DATA_procedure is begin
    bit_cnt <= 9;
    bufferToSend <= "0000" & (loader_parity xor '1')  & '0' & datain(0)& datain(1)& datain(2)& datain(3)& datain(4)& datain(5)& datain(6)& datain(7); -- this is data
    loader_parity <= loader_parity_func(datain);  
    LOADED_WAS <= DATA_LOADED;
    data_ack    <= '1';    
end procedure;

procedure LOAD_TC_procedure is begin
    bit_cnt <= 13;
    bufferToSend <= (loader_parity xor '0') & "11110" & TCin(0)& TCin(1)& TCin(2)& TCin(3)& TCin(4)& TCin(5)& TCin(6)& TCin(7); -- this is timecode
    loader_parity <= loader_parity_func(TCin);  
    LOADED_WAS  <= TC_LOADED;
    tc_ack      <= '1';
end procedure;

begin
    if rising_edge(clk) then
        if rst = '1' then
            bit_cnt <= 0;
            sync_enable <= '0';
            TxClk_r <= '0';
        else
            TxClk_r <= TxClk;
            if TxClk = '1' and TxClk_r = '0' and SendNULLs = '1' then
                sync_enable <= '1';
            end if;
            

            fct_ack  <= '0';
            data_ack <= '0';
            tc_ack   <= '0';
 
            NULL_SENT <= '0';
            FCT_SENT <= '0';

               
            if clk_en = '1' and sync_enable = '1' and SendNULLs = '1' then
                bit_cnt_r <= bit_cnt;
                bit_cnt_2r <= bit_cnt_r;
                dout <= bufferToSend(bit_cnt);
                bit_cnt <= bit_cnt - 1;
                
                
                if bit_cnt = 0 then -- send null default
                    fct_req_r <= fct_req;
                    data_req_r <= data_req;
                    tc_req_r <= tc_req;
                    
                    if fct_req = '1' and FCT_enabled = '1' then
                        LOAD_FCT_procedure;
                    elsif data_req = '1' then
                        LOAD_DATA_procedure;
                    elsif tc_req = '1' then
                        LOAD_TC_procedure;
                    else
                        LOAD_NULL_procedure;
                    end if;
                    
                    
                    if LOADED_WAS = NULL_LOADED then
                        NULL_SENT <= '1';
                    end if;

                    if LOADED_WAS = FCT_LOADED then
                        FCT_SENT <= '1';
                    end if;
                    
                end if;
            end if;
        end if;
    end if;
end process;

sout <= dout xor TxClk_r;


end Behavioral;
