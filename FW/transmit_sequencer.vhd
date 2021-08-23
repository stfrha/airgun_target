---------------------------------------------------------------------------------------------
--
-- Legal notice:    All rights strictly reserved. Reproduction or issue to third parties in
--                  any form whatever is not permitted without written authority from the
--                  proprietors.
--
---------------------------------------------------------------------------------------------
--
-- File name:       transmitt_sequencer.vhd
--
-- Classification:
-- FHL:             Unclassified
-- SekrL:           Unclassified
--
-- Coding rules:    IN IN117887 1.0
--
-- Descripton:      This file receives messages to be sent from different sources.
--                  It manages the sources to avoid congestion and sequensially
--                  sends transfers the messages, one byte at a time, to the UART
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

entity transmit_sequenser is
   port (
      clk                   : in std_logic;
      reset_n               : in std_logic;

      -- One message request strobe for each sender
      send_req              : in std_logic_vector(NUM_OF_MSG-1 downto 0);  
      -- One message acknowledge strobe for each sender
      send_ack              : out std_logic_vector(NUM_OF_MSG-1 downto 0); 
      -- Message data port
      send_msg              : in all_msg_type;                                 
      
      tx_load               : out std_logic;
      tx_busy               : in std_logic;
      tx_data               : out std_logic_vector(7 downto 0)
   );
end entity transmit_sequenser;

architecture rtl of transmit_sequenser is
type state_type is (idle, transmit_byte, wait_trans_ack);

signal state             : state_type;
signal curr_msg          : unsigned(7 downto 0);
signal byte_counter      : unsigned(7 downto 0);
signal tx_busy_r         : std_logic;
   
begin

process (clk)
   variable dum : unsigned(7 downto 0);
begin
   if (rising_edge(clk)) then

      tx_busy_r <= tx_busy;

      case state is
      when idle =>
         for i in 0 to NUM_OF_MSG-1 loop
            if (send_req(i) = '1') then
               state <= transmit_byte;
               curr_msg <= to_unsigned(i, 8);
               -- Only acknowledge to current source
               send_ack <= std_logic_vector(to_unsigned(1, NUM_OF_MSG) sll i);
               byte_counter <= to_unsigned(0, 8);
            end if;
         end loop;
      when transmit_byte =>
         send_ack <= (others => '0');                  -- Clear acknowledge to all sources
         -- Fetch next message byte
         tx_data <= send_msg(to_integer(curr_msg))(to_integer(byte_counter)); 
         -- Inform txunit of the new byte to be send
         tx_load <= '1';                              
         if (tx_busy_r = '1') then                    -- Has the txunit reacted to new data?
            state <= wait_trans_ack;
         end if;
      when wait_trans_ack =>
         tx_load <= '0';
         if (tx_busy_r = '0') then                    -- txunit is ready forO more data

            -- Was this the last byte of the message?...
            if (byte_counter = to_unsigned(MSG_LENGTHS(to_integer(curr_msg)), 8) - 1) then
               state <= idle;                         -- ...Yes, wait for new message request
            else
               byte_counter <= byte_counter + 1;      -- ...No, send another byte
               state <= transmit_byte;
            end if;
         end if;
      end case;

      -- Synchronous reset

      if (reset_n = '0') then
         state <= idle;
         send_ack <= (others => '0');
         tx_load <= '0';
         tx_data <= (others => '0');
         tx_busy_r <= '0';
      end if;
   end if;
end process;

end architecture rtl;
     
      
      
      

