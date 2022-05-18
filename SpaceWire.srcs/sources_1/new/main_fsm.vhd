----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 05/02/2022 01:49:53 PM
-- Design Name: 
-- Module Name: main_fsm - Behavioral
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

entity main_fsm is
    generic(
         freq: natural := 100_000 -- in kHz
    );
    port(
         clk : in std_logic
        ;rst : in std_logic
        ;din : in std_logic
        ;sin : in std_logic
        ;enabled : in std_logic
        ;LinkStart : in std_logic
        ;AutoStart : in std_logic
        
    ;fct_req  : in std_logic
    ;data_req : in std_logic
    ;tc_req   : in std_logic

    ;fct_ack  : out std_logic
    ;data_ack : out std_logic
    ;tc_ack   : out std_logic    
        
        ;dot    : out std_logic
        ;sot    : out std_logic
    );
end main_fsm;

architecture Behavioral of main_fsm is


type fsm_type is (ErrorReset, ErrorWait, Ready, Started, Connecting, Run);
signal fsm_cs,fsm_cs_r : fsm_type := ErrorReset;

signal simcnt : integer := 0;


signal GOT_NULL, GOT_FCT : std_logic := '0';

signal Disabled : std_logic;


signal ReceiveCredit : integer range 0 to 127 := 0;
signal TransmitCredit : integer range 0 to 127 := 0;


--===============================================
component us_counter is
    generic(
         freq: natural := 100_000 -- in kHz
    );
    port(
         clk : in std_logic
        ;rst : in std_logic
        ;tick_6_4us : out std_logic
        ;tick_12_8us : out std_logic
    );
end component;

signal tick_6_4us : std_logic := '0';
signal tick_12_8us : std_logic := '0';
signal rst_us_counter : std_logic := '0';
--===================================================

component RxClk is
    Port (  din : in STD_LOGIC
           ;sin : in STD_LOGIC
           ;RxClk : out std_logic
           );
end component;

signal RxClk_sig : std_logic := '0';


--======================================================
component Decoder is port(
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
    ;ESCError     : out std_logic
    
    ;RxNchar        : out std_logic_vector(7 downto 0)
    ;RxTimeCode     : out std_logic_vector(7 downto 0)
        
    ;ThereIsRxActivity : out std_logic
    );
end component;

    signal GotNull      : std_logic := '0';
    signal GotFCT       : std_logic := '0';
    signal GotEEP       : std_logic := '0';
    signal GotEOP       : std_logic := '0';
    signal GOT_TIMECODE : std_logic := '0';
    signal GOT_DATA     : std_logic := '0';
    signal parityError  : std_logic := '0';
    signal ESCError     : std_logic := '0';
    signal CreditError  : std_logic := '0';
    
    signal RxNchar        : std_logic_vector(7 downto 0);
    signal RxTimeCode     : std_logic_vector(7 downto 0);

    signal ThereIsRxActivity : std_logic := '0';

    signal GotFCTSync : std_logic;
    signal GotNullSync : std_logic;
    signal parityErrorSync : std_logic;
    signal ESCErrorSync : std_logic;

    signal GotNullSyncAlready : std_logic;
    signal NULL_SENTAlready : std_logic;
    
    
    signal GotFCTSyncAlready : std_logic;
    signal FCT_SENTAlready : std_logic;

    ----------
    signal ThereIsRxActivity_p1,ThereIsRxActivity_p2 : std_logic:='0';
--=====================================================

component Encoder is port(
     clk : in std_logic
    ;rst : in std_logic
    ;dot : out std_logic
    ;sot : out std_logic
    
    ;FCT_enabled : in std_logic
    ;SendNULLs : in std_logic
    
    ;fct_req  : in std_logic
    ;data_req : in std_logic
    ;tc_req   : in std_logic

    ;fct_ack  : out std_logic
    ;data_ack : out std_logic
    ;tc_ack   : out std_logic    
    
    ;NULL_SENT : out std_logic
    ;FCT_SENT  : out std_logic
    
    );
end component;

--    signal fct_req  : std_logic := '0';
--    signal data_req : std_logic := '0';
--    signal tc_req   : std_logic := '0';
    signal NULL_SENT: std_logic := '0';
    signal FCT_SENT: std_logic := '0';

    signal FCT_enabled : std_logic;
    signal SendNULLs : std_logic;
--    signal fct_ack  : std_logic;
--    signal data_ack : std_logic;
--    signal tc_ack   : std_logic;

--===========================

component syncher port(
     clka : in std_logic 
    ;strba : in std_logic
    ;clkb : in std_logic 
    ;strbout : out std_logic 
    );
end component;

--========================


component RxCache IS
  PORT (
    rst : IN STD_LOGIC;
    wr_clk : IN STD_LOGIC;
    rd_clk : IN STD_LOGIC;
    din : IN STD_LOGIC_VECTOR(17 DOWNTO 0);
    wr_en : IN STD_LOGIC;
    rd_en : IN STD_LOGIC;
    dout : OUT STD_LOGIC_VECTOR(17 DOWNTO 0);
    full : OUT STD_LOGIC;
    empty : OUT STD_LOGIC
  );
END component;

    signal RxCacheDin   : std_logic_vector(17 downto 0);
    signal RxCacheWrEn  : std_logic;
    signal RxCacheRdEn  : std_logic;
    signal RxCacheDout  : std_logic_vector(17 downto 0);
    signal RxCacheFull  : std_logic;
    signal RxCacheEmpty : std_logic;

--============================


constant disconnect_TIME : integer := 12_800; --nsec
constant period : integer := 10; --nsec


signal disconnect_cnt : integer := 0;
signal DisconnectOccured : std_logic := '0';

signal GotNChar : std_logic;
signal GotBC : std_logic; 

begin

NcharSyncher: syncher port map( clka => RxClk_sig   ,strba   => GOT_DATA,
                                clkb => clk         ,strbout => GotNChar);

BCSyncher: syncher port map(    clka => RxClk_sig   ,strba   => GOT_TIMECODE,
                                clkb => clk         ,strbout => GotBC);

GotFCTSyncher: syncher port map( clka => RxClk_sig  ,strba   => GotFCT,
                                 clkb => clk        ,strbout => GotFCTSync);

GotNullSyncher: syncher port map( clka => RxClk_sig ,strba   => GotNull,
                                  clkb => clk       ,strbout => GotNullSync);

ParityErrorSyncher: syncher port map( clka => RxClk_sig ,strba   => parityError,
                                      clkb => clk       ,strbout => parityErrorSync);

ESCErrorSyncher: syncher port map( clka => RxClk_sig ,strba   => ESCError,
                                   clkb => clk       ,strbout => ESCErrorSync);


Disabled <= not enabled;

FSMcounterModule : us_counter
    generic map(
        freq => 100_000
    )
    port map(
         clk => clk
        ,rst => rst_us_counter
        ,tick_6_4us => tick_6_4us
        ,tick_12_8us => tick_12_8us
        );

RxClkmodule : RxClk port map(
        din => din
       ,sin => sin
       ,RxClk => RxClk_sig
       );


-- TODO these signals must be synchronized
SPWDecoderModule : Decoder port map(
         MainClk      => '0'
        ,RxClk        => RxClk_sig
        ,rst          => rst
        ,din          => din
        ,GotNull      => GotNull 
        ,GotFCT       => GotFCT
        ,GotEEP       => GotEEP      
        ,GotEOP       => GotEOP      
        ,GOT_TIMECODE => GOT_TIMECODE
        ,GOT_DATA     => GOT_DATA    
        ,parityError  => parityError
        ,ESCError     => ESCError

        ,RxNchar      => RxNchar
        ,RxTimeCode   => RxTimeCode

        ,ThereIsRxActivity => ThereIsRxActivity
        );

RxCacheInst: RxCache PORT map(
     rst     => rst
    ,wr_clk  => RxClk_sig
    ,rd_clk  => clk
    ,din     => RxCacheDin
    ,wr_en   => RxCacheWrEn
    ,rd_en   => RxCacheRdEn
    ,dout    => RxCacheDout
    ,full    => RxCacheFull
    ,empty   => RxCacheEmpty
    );


process(RxClk_sig)
begin
    if rising_edge(RxClk_sig) then
        RxCacheWrEn <= '0';
        if GOT_DATA = '1' then
            RxCacheDin <= "00000000" & "00" & RxNchar; --17 downto 0
            RxCacheWrEn <= '1';
        end if;
        
        if GOT_TIMECODE = '1' then
            RxCacheDin <= "00000000" & "01" & RxTimeCode; --17 downto 0
            RxCacheWrEn <= '1';
        end if;
        
        if GotEEP = '1' then
            RxCacheDin <= "00000000" & "10" & "11110000"; --17 downto 0
            RxCacheWrEn <= '1';
        end if;
        
        if GotEOP = '1' then
            RxCacheDin <= "00000000" & "11" & "00001111"; --17 downto 0
            RxCacheWrEn <= '1';
        end if;
    end if;
end process;

ReceiveCreditProcess: process(clk)
begin
    if rising_edge(clk) then
        if GotFCTSync = '1' then
            if fsm_cs = Connecting or fsm_cs = Run then
                ReceiveCredit <= ReceiveCredit + 8;
            end if;
        end if;
        
        if GotNChar = '1' then
            if fsm_cs = Run then
                ReceiveCredit <= ReceiveCredit - 1; -- TODO test this part
            end if;
        end if;
        
        if ReceiveCredit > 56 then
            CreditError <= '1'; else
            CreditError <= '0'; end if;
            
        if fsm_cs = ErrorReset then
            ReceiveCredit <= 0;
        end if; 

    end if;
end process;    
            
--
--
--
--


SPWEncoderModule : Encoder port map(
     clk        => clk
    ,rst        => rst
    ,dot        => dot
    ,sot        => sot
    
    ,FCT_enabled => FCT_enabled
    ,SendNULLs => SendNULLs

    ,fct_req    => fct_req 
    ,data_req   => data_req
    ,tc_req     => tc_req

    ,fct_ack    => fct_ack
    ,data_ack   => data_ack
    ,tc_ack     => tc_ack

    ,NULL_SENT  => NULL_SENT
    ,FCT_SENT  => FCT_SENT

    );


process(clk)
begin
-- TODO: add control signals here
if rising_edge(clk) then
    if rst = '1' or enabled = '0' then
        rst_us_counter <= '1';
    else

        rst_us_counter <= '0';

        if fsm_cs /= fsm_cs_r then
            rst_us_counter <= '1';
        end if; 
    end if;
end if;
end process;


main_fsm_process: process(clk)
begin
    if rising_edge(clk) then
        if rst = '1' then
            fsm_cs <= ErrorReset;
        else
            fsm_cs_r <= fsm_cs;
            FCT_enabled <= '0';
            SendNULLs <= '0'; -- kind of enable TX
            
            case fsm_cs is
                
                when ErrorReset =>
                    -- normal transaction
                    if tick_6_4us = '1' and enabled = '1' then
                        fsm_cs <= ErrorWait;
                    end if;
                     
                    GotNullSyncAlready <='0'; -- we need this only in started state
                    NULL_SENTAlready <='0';  -- we need this only in started AutoStart 

                    GotFCTSyncAlready <='0'; -- we need this only in started state
                    FCT_SENTAlready <='0';  -- we need this only in started AutoStart 

                    
                when ErrorWait =>
                    -- normal transaction
                    if tick_12_8us = '1' and enabled = '1' then
                        fsm_cs <= Ready;
                    end if;
                    
                    -- Error AutoStart
                    if DisconnectOccured = '1'  then fsm_cs <= ErrorReset; end if;
                    if ParityError = '1'        then fsm_cs <= ErrorReset; end if;
                    if ESCError = '1'           then fsm_cs <= ErrorReset; end if;
                    if GotFCT = '1'             then fsm_cs <= ErrorReset; end if;
                    if GotNChar = '1'           then fsm_cs <= ErrorReset; end if;
                    if GotBC = '1'              then fsm_cs <= ErrorReset; end if;
                    
                    
                when Ready =>
                    --normal transaction
                    if enabled = '1' then
                        if LinkStart = '1' or (Autostart = '1' and GOT_NULL = '1') then
                            fsm_cs <= Started;
                        end if;
                    end if;

                    -- ErrorRecovery
                    if DisconnectOccured = '1'  then fsm_cs <= ErrorReset; end if;
                    if ParityError = '1'        then fsm_cs <= ErrorReset; end if;
                    if ESCError = '1'           then fsm_cs <= ErrorReset; end if;
                    if GotFCT = '1'             then fsm_cs <= ErrorReset; end if;
                    if GotNChar = '1'           then fsm_cs <= ErrorReset; end if;
                    if GotBC = '1'              then fsm_cs <= ErrorReset; end if;
                    if tick_12_8us = '1'        then fsm_cs <= ErrorReset; end if;
                    if Disabled = '1'           then fsm_cs <= ErrorReset; end if;
                    
                when Started =>
                    SendNULLs <= '1';
                    if Enabled='1' AND GotNullSyncAlready = '1' AND NULL_SENTAlready = '1' then
                        fsm_cs <= Connecting;
                    end if;

                    
                    if GotNullSync = '1' and GotNullSyncAlready = '0' then
                        GotNullSyncAlready <='1';
                    end if;
                                       
                    if NULL_SENT = '1' and NULL_SENTAlready = '0' then
                        NULL_SENTAlready <='1';
                    end if;
                    
                    -- ErrorRecovery
                    if DisconnectOccured = '1'  then fsm_cs <= ErrorReset; end if;
                    if ParityError = '1'        then fsm_cs <= ErrorReset; end if;
                    if ESCError = '1'           then fsm_cs <= ErrorReset; end if;
                    if GotFCT = '1'             then fsm_cs <= ErrorReset; end if;
                    if GotNChar = '1'           then fsm_cs <= ErrorReset; end if;
                    if GotBC = '1'              then fsm_cs <= ErrorReset; end if;
                    if tick_12_8us = '1'        then fsm_cs <= ErrorReset; end if;
                    if Disabled = '1'           then fsm_cs <= ErrorReset; end if;
                
                when Connecting =>
                    if Enabled = '1' AND GotFCTSyncAlready = '1' AND FCT_SENTAlready = '1' then
                       fsm_cs <= Run;
                    end if;

                    if GotFCTSync = '1' and GotFCTSyncAlready = '0' then
                        GotFCTSyncAlready <='1';
                    end if;
                                       
                    if FCT_SENT = '1' and FCT_SENTAlready = '0' then
                        FCT_SENTAlready <='1';
                    end if;
                    
                    SendNULLs <= '1';
                    FCT_enabled <= '1';

                    -- ErrorRecovery
                    if DisconnectOccured = '1'  then fsm_cs <= ErrorReset; end if;
                    if ParityError = '1'        then fsm_cs <= ErrorReset; end if;
                    if ESCError = '1'           then fsm_cs <= ErrorReset; end if;
                    if GotNChar = '1'           then fsm_cs <= ErrorReset; end if;
                    if GotBC = '1'              then fsm_cs <= ErrorReset; end if;
                    if tick_12_8us = '1'        then fsm_cs <= ErrorReset; end if;
                    if Disabled = '1'           then fsm_cs <= ErrorReset; end if;                
                
                when Run =>
                    
                    SendNULLs <= '1';
                    FCT_enabled <= '1';

                    -- ErrorRecovery
                    if DisconnectOccured = '1'  then fsm_cs <= ErrorReset; end if;
                    if ParityError = '1'        then fsm_cs <= ErrorReset; end if;
                    if ESCError = '1'           then fsm_cs <= ErrorReset; end if;
                    if CreditError = '1'        then fsm_cs <= ErrorReset; end if;
                    if Disabled = '1'           then fsm_cs <= ErrorReset; end if;                     
                
                when others =>
                    fsm_cs <= ErrorReset;
            end case;
        end if;
        
    end if;
end process;





DisconnectDetectionProcess: process(clk)
begin
    if rising_edge(clk) then
        ThereIsRxActivity_p2 <= ThereIsRxActivity_p1;
        ThereIsRxActivity_p1 <= ThereIsRxActivity;
        
        if ThereIsRxActivity_p2 = '1' then
            disconnect_cnt <= disconnect_TIME/period;
        else
            disconnect_cnt <= disconnect_cnt - 1;
        end if;
        
        DisconnectOccured <= '0';
        if disconnect_cnt = 0 then
            DisconnectOccured <= '1';
        end if;
    end if;
end process;

--=================================================================
--=================================================================
--=================================================================



--process(clk)
--procedure pseudoaction(action: in string; val: in integer) is begin
--    if simcnt = val then
--        case action is
--            when "NULL" =>
--                GOT_NULL <='1';
--            when "FCT" => 
--                GOT_FCT <='1';
--            when others =>
--                NULL;
--        end case;
--    end if;
--end procedure;


--begin
--    if rising_edge(clk) then
--        GOT_NULL <='0';
--        GOT_FCT <='0';
--        simcnt <= simcnt + 1;
        
--        pseudoaction("NULL",10);
--        pseudoaction("NULL",197);
        

        
--    end if;
--end process;







end Behavioral;
