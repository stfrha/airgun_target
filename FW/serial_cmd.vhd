---------------------------------------------------------------------------------------------
--
-- Legal notice:    All rights strictly reserved. Reproduction or issue to third parties in
--                  any form whatever is not permitted without written authority from the
--                  proprietors.
--
---------------------------------------------------------------------------------------------
--
-- File name:       serial_cmd.vhd
--
-- Classification:
-- FHL:             Unclassified
-- SekrL:           Unclassified
--
-- Coding rules:    IN IN117887 1.0
--
-- Descripton:      This file handles received commands on the serial bus. 
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

entity serial_cmd is
   port (
      clk                   : in std_logic;
      reset_n               : in std_logic;

      rx_data               : in std_logic_vector(7 downto 0);
		rx_available          : in std_logic;
      rx_read               : out std_logic;

      cmd_parameter         : out std_logic_vector(3 downto 0);

      ver_send_req          : out std_logic;
      ver_send_ack          : in std_logic
   );
end entity serial_cmd;

architecture rtl of serial_cmd is

type state_type is (idle, fetch_data, new_cmd, process_cmd, wait_ack);   

signal state                 : state_type;
signal cmd                   : std_logic_vector(7 downto 0);
signal rx_available_r        : std_logic;
signal rx_available_r_d      : std_logic;

begin
   
process (clk)
begin
   if (rising_edge(clk)) then

      rx_available_r <= rx_available;
      rx_available_r_d <= rx_available_r;

      case state is
      when idle =>

         if (rx_available_r = '1') and (rx_available_r_d = '0') then
            state <= fetch_data;
            cmd <= rx_data;
         end if;

      when fetch_data =>

         state <= new_cmd;
         rx_read <= '1';

      when new_cmd =>

         state <= process_cmd;
         rx_read <= '0';

      when process_cmd =>

         cmd_parameter <= cmd(3 downto 0);

         if (cmd(7 downto 4) = "0001") then
            state <= wait_ack;
            ver_send_req <= '1';
			else
			   state <= idle;
         end if;            

      when wait_ack =>

         if (ver_send_ack = '1') then
            state <= idle;
            ver_send_req <= '0';
         end if;

      end case;

      -- Synchronous reset

      if (reset_n = '0') then
         state <= idle;
         rx_available_r <= '0';
         rx_available_r_d <= '0';
         ver_send_req <= '0';
         cmd_parameter <= (others => '0');
         rx_read <= '0';
         cmd <= (others => '0');
      end if;
   end if;
end process;

end architecture rtl;
