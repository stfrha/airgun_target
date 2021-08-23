-- ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
--
-- VHDL SOURCE FILE cmd_timer.vhd
--
-- MSG_TIMEOUT timer
--
-- $Id: cmd_timer.vhd,v 1.1 2005/02/11 14:11:33 lra Exp $
-- $Log: cmd_timer.vhd,v $
-- Revision 1.1  2005/02/11 14:11:33  lra
-- New project directory structure created
--
-- Revision 1.3  2005/02/11 13:57:30  lra
-- Cleaned up signal names
--
-- Revision 1.2  2003/04/04 17:09:30  lra
-- Major cleanup and simplification of code. Please see old-style history log in file header for details.
-- Use CVS log messages for revision history from now on.
--
--
-- ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
--
-- Pre-CVS-log history. Do not use for future revisions.
--
-- Version  Date        Who                     What
-- 1        02-11-12    LRA/Lars Albihn         Created
-- 2        03-03-13    LRA                     Changed to CVS style history log.
-- 3        03-03-19    LRA                     Improved comments.
--  
-- ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

-- ------------------------------------------------------------------------------------------
-- Library declarations
-- ------------------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

-- ------------------------------------------------------------------------------------------
-- Entity declaration
-- ------------------------------------------------------------------------------------------
entity cmd_timer is
port
(
    clk             : in std_logic;  -- Clock signal

    rst             : in std_logic;  -- Async. reset signal.
                                     -- Release of reset must be externally
                                     -- synchronized to clk.
    timer_reset     : in std_logic;
    message_timeout : out std_logic 
);

end entity cmd_timer;

-- ------------------------------------------------------------------------------------------
-- Architecture definition
-- ------------------------------------------------------------------------------------------
architecture rtl of cmd_timer is

-- ------------------------------------------------------------------------------------------
-- Signal declarations
-- ------------------------------------------------------------------------------------------
signal cnt_reg : unsigned(17 downto 0); -- MSB is asserted after ~6 ms which is 
                                        -- the maximum time allowed for the
                                        -- CCU to receive a message

-- ------------------------------------------------------------------------------------------
-- Begin architecture
-- ------------------------------------------------------------------------------------------
begin
    
-- ------------------------------------------------------------------------------------------
-- Synchronous process
-- ------------------------------------------------------------------------------------------
timer:process(rst, clk)
begin
  if rst='1' then

     cnt_reg<=(others=>'0');

  elsif rising_edge(clk) then

    if timer_reset = '1' then
      cnt_reg<=(others=>'0');
    elsif cnt_reg(cnt_reg'left) = '0' then
      cnt_reg <= cnt_reg + 1;
    end if;

  end if;

end process timer;              

-- ------------------------------------------------------------------------------------------
-- Output signal assignments  
-- ------------------------------------------------------------------------------------------
message_timeout <= cnt_reg(cnt_reg'left);         

end architecture rtl;
