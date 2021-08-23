---------------------------------------------------------------------------------------------
--
-- Legal notice:    All rights strictly reserved. Reproduction or issue to third parties in
--                  any form whatever is not permitted without written authority from the
--                  proprietors.
--
---------------------------------------------------------------------------------------------
--
-- File name:       airgun_target.vhd
--
-- Classification:
-- FHL:             Unclassified
-- SekrL:           Unclassified
--
-- Coding rules:    IN IN117887 1.0
--
-- Descripton:      Main file of the airgun target project. 
--
-- Known errors:    None
--
-- To do:           N/A
--
---------------------------------------------------------------------------------------------
--
-- Revision history:
--
-- $Log: $
--
---------------------------------------------------------------------------------------------


library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.airgun_package.all;

entity airgun_target is
   generic (
      -- AD-converter sample frequency [Hz]
      SAMPLE_FREQ           : integer := 192000
   );
   port (
      clk                   : in std_logic;
      reset_n               : in std_logic;
      ce                    : in std_logic;                        -- Clock enable

      mv135                 : in    std_logic_vector(9 downto 0);  -- Main Video 135 amplitude from ADC.
      mv225                 : in    std_logic_vector(9 downto 0);  -- Main Video 225 amplitude from ADC.
      mv315                 : in    std_logic_vector(9 downto 0);  -- Main Video 315 amplitude from ADC.
      mv45                  : in    std_logic_vector(9 downto 0);  -- Main Video 45 amplitude from ADC.

      txd                   : out std_logic;
      rxd                   : in std_logic
   );
end entity airgun_target;

architecture struct of airgun_target is

signal ll_time           : unsigned(23 downto 0);
signal lr_time           : unsigned(23 downto 0);
signal ul_time           : unsigned(23 downto 0);
signal ur_time           : unsigned(23 downto 0);

signal send_msg          : all_msg_type;

signal send_req          : std_logic_vector(NUM_OF_MSG-1 downto 0);
signal send_ack          : std_logic_vector(NUM_OF_MSG-1 downto 0);

signal shot_send_req     : std_logic;
signal shot_send_ack     : std_logic;

signal ver_send_req      : std_logic;
signal ver_send_ack      : std_logic;

signal tx_load           : std_logic;
signal tx_busy           : std_logic;
signal tx_data           : std_logic_vector(7 downto 0);

signal rx_data           : std_logic_vector(7 downto 0);
signal rx_available      : std_logic;
signal rx_read           : std_logic;

-- rx_ce = clock enable for rxunit, driven by baudrate generated clock it disables
-- the rxunit for all clock signals except for those that corresponds to the correct
-- baudrate. 
signal rx_ce             : std_logic;                   

-- tx_ce = clock enable for txunit, driven by baudrate generated clock it disables
-- the txunit for all clock signals except for those that corresponds to the correct
-- baudrate. This should be pusled every fourth time the rx_ce is pulsed to give the
-- correct relationship between receive and transmit units.
signal tx_ce             : std_logic;                   

begin

shot_measure_1 : entity work.shot_measure 
   generic map (
      SAMPLE_FREQ    => SAMPLE_FREQ
   )
   port map (
      clk            => clk,
      reset_n        => reset_n,
      
      ce             => ce,

      mv135          => mv135,
      mv225          => mv225,
      mv315          => mv315,
      mv45           => mv45 ,
                      
      ll_time        => ll_time,
      lr_time        => lr_time,
      ul_time        => ul_time,
      ur_time        => ur_time,

      send_req       => shot_send_req,
      send_ack       => shot_send_ack
   );

transmit_sequenser_1 : entity work.transmit_sequenser(rtl) port map (
   clk            => clk,
   reset_n        => reset_n,

   send_req       => send_req,
   send_ack       => send_ack,
   send_msg       => send_msg,

   tx_load        => tx_load,
   tx_busy        => tx_busy,
   tx_data        => tx_data
);

counter_1 : entity work.counter(behaviour) generic map (
   count       => BR_CLK              -- Acc to: baudrate = fosc / ( BR_CLK * 4 )
)
port map (
   clk            => clk,
   reset          => not reset_n,
   -- chip enable, should always be one, since this divides the main clock
   ce             => '1',                
   o              => rx_ce
);

counter_2 : entity work.counter(behaviour) generic map (
   count       => 4                   -- Transmitter should have a fourth of the processrate
)
port map (
   clk            => clk,
   reset          => not reset_n,
   -- chip enable, for tx this should only be enabled every rx pulse
   ce             => rx_ce,
   o              => tx_ce
);

txunit_1 : entity work.TxUnit port map (
   clk            => clk,
   reset          => not reset_n,
   Enable         => tx_ce,
   LoadA          => tx_load,
   TxD            => txd,
   Busy           => tx_busy,
   DataI          => tx_data
);

rxunit_1 : entity work.rxunit port map (
   clk            => clk,
   reset          => not reset_n,
   Enable         => rx_ce,
   ReadA          => rx_read,
	rxd            => rxd,
   RxAv           => rx_available,
   DataO          => rx_data
);

serial_cmd_1 : entity work.serial_cmd port map (
   clk            => clk,
   reset_n        => reset_n,

   rx_data        => rx_data,
   rx_available   => rx_available,
   rx_read        => rx_read,

   cmd_parameter  => open,

   ver_send_req   => ver_send_req,
	ver_send_ack   => ver_send_ack
);

---------------------------------------------------------------------------------------------
-- Concurrent statements
---------------------------------------------------------------------------------------------

---------------------------------------------------------------------------------------------
-- Message definition
--
-- All message conform to the following format:
--
-- Byte#    Description
-- 0        Message identifier, same as index in message list
-- 1        Message length, includeing byte 0 and 1
-- 2-n      Message data defined by each message
--
-- Shot message:
-- Byte#    Data        Description
-- 0        0           Identifier of shot message
-- 1        14          Shot message length is 14
-- 2        ll(7-0)     LSB of Lower left time
-- 3        ll(15-8)    LSB of Lower left time
-- 4        ll(23-16)   LSB of Lower left time
-- 5        lr(7-0)     LSB of Lower right time
-- 6        lr(15-8)    LSB of Lower right time
-- 7        lr(23-16)   LSB of Lower right time
-- 8        ul(7-0)     LSB of Upper left time
-- 9        ul(15-8)    LSB of Upper left time
-- 10       ul(23-16)   LSB of Upper left time
-- 11       ur(7-0)     LSB of Upper right time
-- 12       ur(15-8)    LSB of Upper right time
-- 13       ur(23-16)   LSB of Upper right time
--
---------------------------------------------------------------------------------------------

-- Identifier of shot mesage
send_msg(SHOT_MSG_INDEX)(0) <= std_logic_vector(to_unsigned(SHOT_MSG_INDEX, 8));
-- Length of shot message
send_msg(SHOT_MSG_INDEX)(1) <= std_logic_vector(to_unsigned(SHOT_MSG_LEN, 8));
-- Shot Message data
send_msg(SHOT_MSG_INDEX)(2) <= std_logic_vector(ll_time(7 downto 0));
send_msg(SHOT_MSG_INDEX)(3) <= std_logic_vector(ll_time(15 downto 8));
send_msg(SHOT_MSG_INDEX)(4) <= std_logic_vector(ll_time(23 downto 16));
send_msg(SHOT_MSG_INDEX)(5) <= std_logic_vector(lr_time(7 downto 0));
send_msg(SHOT_MSG_INDEX)(6) <= std_logic_vector(lr_time(15 downto 8));
send_msg(SHOT_MSG_INDEX)(7) <= std_logic_vector(lr_time(23 downto 16));
send_msg(SHOT_MSG_INDEX)(8) <= std_logic_vector(ul_time(7 downto 0));
send_msg(SHOT_MSG_INDEX)(9) <= std_logic_vector(ul_time(15 downto 8));
send_msg(SHOT_MSG_INDEX)(10) <= std_logic_vector(ul_time(23 downto 16));
send_msg(SHOT_MSG_INDEX)(11) <= std_logic_vector(ur_time(7 downto 0));
send_msg(SHOT_MSG_INDEX)(12) <= std_logic_vector(ur_time(15 downto 8));
send_msg(SHOT_MSG_INDEX)(13) <= std_logic_vector(ur_time(23 downto 16));

-- Identifier of version mesage
send_msg(VER_MSG_INDEX)(0) <= std_logic_vector(to_unsigned(VER_MSG_INDEX, 8));
-- Length of version message
send_msg(VER_MSG_INDEX)(1) <= std_logic_vector(to_unsigned(VER_MSG_LEN, 8));
-- Version Message data
send_msg(VER_MSG_INDEX)(2) <= std_logic_vector(to_unsigned(VER_MSG(2), 8));
send_msg(VER_MSG_INDEX)(3) <= std_logic_vector(to_unsigned(VER_MSG(3), 8));
send_msg(VER_MSG_INDEX)(4) <= std_logic_vector(to_unsigned(VER_MSG(4), 8));
send_msg(VER_MSG_INDEX)(5) <= std_logic_vector(to_unsigned(VER_MSG(5), 8));
send_msg(VER_MSG_INDEX)(6) <= std_logic_vector(to_unsigned(VER_MSG(6), 8));
send_msg(VER_MSG_INDEX)(7) <= std_logic_vector(to_unsigned(VER_MSG(7), 8));
send_msg(VER_MSG_INDEX)(8) <= std_logic_vector(to_unsigned(VER_MSG(8), 8));
send_msg(VER_MSG_INDEX)(9) <= std_logic_vector(to_unsigned(VER_MSG(9), 8));
send_msg(VER_MSG_INDEX)(10) <= std_logic_vector(to_unsigned(VER_MSG(10), 8));


-- Assign send request and acknowledge signals from each message sender
send_req(SHOT_MSG_INDEX) <= shot_send_req;
shot_send_ack <= send_ack(SHOT_MSG_INDEX);

send_req(VER_MSG_INDEX) <= ver_send_req;
ver_send_ack <= send_ack(VER_MSG_INDEX);

end architecture struct;
      


