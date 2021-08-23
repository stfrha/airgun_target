-- ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
--
-- VHDL SOURCE FILE reset_gen.vhd
--
-- Reset Signal Generator
--
-- $Id: reset_gen.vhd,v 1.1 2005/02/11 14:11:33 lra Exp $
-- $Log: reset_gen.vhd,v $
-- Revision 1.1  2005/02/11 14:11:33  lra
-- New project directory structure created
--
-- Revision 1.4  2005/02/11 14:04:05  lra
-- Cleaned up signal names.
--
-- Revision 1.3  2003/04/04 17:09:30  lra
-- Major cleanup and simplification of code. Please see old-style history log in file header for details.
-- Use CVS log messages for revision history from now on.
--
--
-- ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
--
-- Pre-CVS-log history. Do not use for future revisions.
--
-- Version  Date        Who                 What
-- 1        02-07-12    LRA/ Lars Albihn    Merged some blocks into one. Removed push-button
--                                          reset support.
-- 2        03-03-10    LRA                 Changed so that reset logic uses delayed LOCK
--                                          signals from DLLs.
-- 3        03-03-12    LRA                 Added pipeline stages to make life easier for the
--                                          placer.
-- 4        03-03-13    LRA                 Changed to CVS style history log.
-- 5        03-04-03    LRA                 Removed reset generation for WCLK domain.
--                                          FFs running on WCLK can simply be reset by ROC_NET,
--                                          since this reset signal is released long before
--                                          WCLK starts operating.
--  
-- ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

-- ------------------------------------------------------------------------------------------
-- Library declarations
-- ------------------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;

-- ------------------------------------------------------------------------------------------
-- Entity declaration
-- ------------------------------------------------------------------------------------------
entity reset_gen is
port
(
    roc_net   : in std_logic;

    clk8x     : in std_logic;
    clk16x    : in std_logic;

    locked8x  : in std_logic;
    locked16x : in std_logic;

    rst8x     : out std_logic;
    rst16x    : out std_logic
);
end entity reset_gen;

-- ------------------------------------------------------------------------------------------
-- Architecture definition
-- ------------------------------------------------------------------------------------------
architecture rtl of reset_gen is

-- ------------------------------------------------------------------------------------------
-- Signal declarations
-- ------------------------------------------------------------------------------------------
signal locked8x_m1  : std_logic;
signal rst8x_p1     : std_logic;

signal locked16x_m1 : std_logic;
signal rst16x_p1    : std_logic;

-- ------------------------------------------------------------------------------------------
-- Begin architecture
-- ------------------------------------------------------------------------------------------
begin

-- ------------------------------------------------------------------------------------------
-- Reset generation for everything that runs on the 80 MHz clock
-- ------------------------------------------------------------------------------------------
rst8x_proc : process(roc_net, clk8x)
begin
    if roc_net='1' then

        locked8x_m1 <= '0';
        rst8x_p1    <= '1';
        rst8x       <= '1';

    elsif rising_edge(clk8x) then

        locked8x_m1 <= locked8x;
        rst8x_p1    <= not locked8x_m1;
        rst8x       <= rst8x_p1;

    end if;

end process rst8x_proc;

-- ------------------------------------------------------------------------------------------
-- Reset generation for everything that runs on the 160 MHz clock
-- ------------------------------------------------------------------------------------------
rst16x_proc : process(roc_net, clk16x)
begin
    if roc_net='1' then

        locked16x_m1 <= '0';
        rst16x_p1    <= '1';
        rst16x       <= '1';

    elsif rising_edge(clk16x) then

        locked16x_m1 <= locked16x;
        rst16x_p1    <= not locked16x_m1;
        rst16x       <= rst16x_p1;

    end if;

end process rst16x_proc;

end architecture rtl;
