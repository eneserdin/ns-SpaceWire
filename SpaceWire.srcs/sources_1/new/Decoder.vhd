----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 04/16/2022 12:14:26 AM
-- Design Name: 
-- Module Name: Decoder - Behavioral
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

entity Decoder is port(
    
     MainClk      : in std_logic

    ;RxClk        : in std_logic
    ;rst          : in std_logic
    ;din          : in std_logic
    ;GotNull      : out std_logic
    ;GotFCT       : out std_logic
    ;GotEEP       : out std_logic
    ;GotEOP       : out std_logic
    ;GOT_TIMECODE : out std_logic
    ;GOT_DATA     : out std_logic
    ;parityError  : out std_logic
    ;ESCError    : out std_logic
    
    ;RxNchar        : out std_logic_vector(7 downto 0)
    ;RxTimeCode     : out std_logic_vector(7 downto 0)
    
    ;ThereIsRxActivity : out std_logic

    );
end Decoder;

architecture Behavioral of Decoder is

signal sample_data,sample_data_r,sample_data_2r : std_logic_vector(1 downto 0);
signal temp_sample : std_logic_vector(sample_data'range); 

signal NullArray : std_logic_vector(7 downto 0);


type token_state_type is (  st_waiting_for_Null,st_idle, st_saw_control_char,
                            st_saw_data_char,st_saw_data_chara,st_saw_data_charb,st_saw_data_charc,
                            st_saw_timecode, st_saw_timecodea, st_saw_timecodeb, st_saw_timecodec, st_saw_timecoded,
                            st_FCT_or_TC,st_saw_NULL);
    signal token_cs : token_state_type := st_waiting_for_Null;

signal parity_var : std_logic;


signal timecode : std_logic_vector(7 downto 0) := (others => '0');
signal datachar : std_logic_vector(7 downto 0) := (others => '0');

signal grayc : std_logic_vector(2 downto 0) := "000";
signal RxToggle : std_logic;
signal RxToggle_r : std_logic;

signal FirstNull : std_logic := '0';

begin

RxNchar      <= datachar;
RxTimeCode   <= timecode;


process(RxClk)
begin
    if rising_edge(RxClk) then
        temp_sample(1) <= din;
    end if;
    
    if falling_edge(RxClk) then
        temp_sample(0) <= din;
    end if;
    
    if rising_edge(RxClk) then
        sample_data <= temp_sample;
        
        NullArray <= NullArray(5 downto 0) & sample_data;
        sample_data_r <= sample_data;
    end if;
end process;


process(RxClk)
begin
    if rising_edge(RxClk) then
        FirstNull <= '0';


        sample_data_2r <= sample_data_r;
        if NullArray = "01110100" then
            FirstNull <= '1';
        end if;
    end if;
end process;
        
-- Now we need to do the parity part

process(RxClk)
procedure CHECK_PARITY_PROCEDURE is begin
    if parity_var = '0' then -- parity is zero upto now
        if    sample_data_2r(0) = '1' and sample_data_2r(1) = '0' then -- ok
        elsif sample_data_2r(0) = '0' and sample_data_2r(1) = '1' then -- ok
        else
            parityError <= '1';
        end if;
    end if;

    
    if parity_var = '1' then -- parity is one upto now
        if    sample_data_2r(0) = '1' and sample_data_2r(1) = '1' then -- ok
        elsif sample_data_2r(0) = '0' and sample_data_2r(1) = '0' then -- ok
        else
            parityError <= '1';
        end if;
    end if;
end procedure;
begin
    if rising_edge(RxClk) then
        parityError <= '0';
        GotNull <= '0';
        GotFCT <= '0';
        GotEEP <= '0';
        GotEOP <= '0';
        GOT_TIMECODE <= '0';
        GOT_DATA <= '0';
        ESCError <= '0';

        case token_cs is
            when st_waiting_for_Null =>
                parity_var <= '0';

                if FirstNull = '1' then
                    token_cs <= st_idle;
                end if;
            
            when st_idle =>
            
                CHECK_PARITY_PROCEDURE;                
                
                if sample_data_2r = "01" or sample_data_2r = "11" then -- control token is coming
                    token_cs <= st_saw_control_char;
                end if;
                
                if sample_data_2r = "00" or sample_data_2r = "10" then -- data character is coming
                    token_cs <= st_saw_data_char;
                end if;
            
            when st_saw_control_char =>                
                parity_var <= sample_data_2r(1) xor sample_data_2r(0);
            
                if sample_data_2r = "00" then -- FCT
                    GotFCT  <= '1';
                    token_cs <= st_idle;
                
                elsif sample_data_2r = "01" then -- EOP
                    GotEOP  <= '1';
                    token_cs <= st_idle;
                
                elsif sample_data_2r = "10" then -- EEP
                    GotEEP  <= '1';
                    token_cs <= st_idle;
                
                elsif sample_data_2r = "11" then -- ESC
                    -- GOT ESC, if next is 01 then it is FCT => NULL
                    --          else if next is 10 then it is a timecode
                    token_cs <= st_FCT_or_TC;
                end if;    
                
            when st_FCT_or_TC =>
                parity_var <= parity_var xor sample_data_2r(1) xor sample_data_2r(0);
                
                if sample_data_2r = "01" then -- this is going to be an FCT hence NULL
                    --NULL
                    CHECK_PARITY_PROCEDURE;
                    token_cs <= st_saw_NULL;

                elsif sample_data_2r = "10" then -- this is going to be an Timecode
                    --Timecode
                    token_cs <= st_saw_timecode;
                else -- it is not good
                    token_cs <= st_waiting_for_Null;
                    ESCError <= '1';
                end if;
            
            when st_saw_data_char =>
                parity_var <= sample_data_2r(1) xor sample_data_2r(0);
                datachar(1 downto 0) <= sample_data_2r(0) & sample_data_2r(1);
                token_cs <= st_saw_data_chara;
                
            when st_saw_data_chara =>
                parity_var <= parity_var xor sample_data_2r(1) xor sample_data_2r(0);
                datachar(3 downto 2) <= sample_data_2r(0) & sample_data_2r(1);
                token_cs <= st_saw_data_charb;

            when st_saw_data_charb =>
                parity_var <= parity_var xor sample_data_2r(1) xor sample_data_2r(0);
                datachar(5 downto 4) <= sample_data_2r(0) & sample_data_2r(1);
                token_cs <= st_saw_data_charc;
                
            when st_saw_data_charc =>
                parity_var <= parity_var xor sample_data_2r(1) xor sample_data_2r(0);
                datachar(7 downto 6) <= sample_data_2r(0) & sample_data_2r(1);
                token_cs <= st_idle;
                GOT_DATA <= '1';

                
            when st_saw_NULL =>
                parity_var <= sample_data_2r(1) xor sample_data_2r(0);
                if sample_data_2r = "00" then -- it is null
                    token_cs <= st_idle;
                    GotNull <= '1';
                else -- not good
                    token_cs <= st_waiting_for_Null;
                end if;
                
            when st_saw_timecode =>
                parity_var <= sample_data_2r(1) xor sample_data_2r(0);
                token_cs <= st_saw_timecodea;
                timecode(1 downto 0) <= sample_data_2r(0) & sample_data_2r(1);
                
            when st_saw_timecodea =>
                parity_var <= parity_var xor sample_data_2r(1) xor sample_data_2r(0);
                token_cs <= st_saw_timecodeb;
                timecode(3 downto 2) <= sample_data_2r(0) & sample_data_2r(1);
                
            when st_saw_timecodeb =>
                parity_var <= parity_var xor sample_data_2r(1) xor sample_data_2r(0);
                token_cs <= st_saw_timecodec;
                timecode(5 downto 4) <= sample_data_2r(0) & sample_data_2r(1);
                
            when st_saw_timecodec =>
                parity_var <= parity_var xor sample_data_2r(1) xor sample_data_2r(0);
                token_cs <= st_idle;
                timecode(7 downto 6) <= sample_data_2r(0) & sample_data_2r(1);
                GOT_TIMECODE <= '1';

            when others =>
                token_cs <= st_waiting_for_Null;
            
        end case;
    end if;
end process;


process(RxClk)
begin
    if rising_edge(RxClk) then
        case grayc is 
            when "000" => grayc <= "001";
            when "001" => grayc <= "011";
            when "011" => grayc <= "010";
            when "010" => grayc <= "110";
            when "110" => grayc <= "111";
            when "111" => grayc <= "101";
            when "101" => grayc <= "100";
            when "100" => grayc <= "000";
            when others => grayc <= "000";
        end case;
    end if;
end process;

-- we can use toggle counter instead of that one as well.
process(RxClk)
begin
    if rising_edge(RxClk) then
        RxToggle <= grayc(2);
        RxToggle_r <= RxToggle;
    end if;
end process;

ThereIsRxActivity <= RxToggle xor RxToggle_r;


end Behavioral;
