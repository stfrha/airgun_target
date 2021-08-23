-- ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
--
-- VHDL SOURCE FILE memclkgen.vhd
--
-- Generates a 25% duty cycle memory clock at 20 MHz.
--
-- $Id: memclkgen.vhd,v 1.1 2005/02/11 14:11:33 lra Exp $
-- $Log: memclkgen.vhd,v $
-- Revision 1.1  2005/02/11 14:11:33  lra
-- New project directory structure created
--
-- Revision 1.4  2005/02/11 14:00:26  lra
-- Cleaned up signal names
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
-- Version  Date        Who                     What
-- 1        99-10-28    MXXN/Mikael Andersson   Created
-- 2        03-03-10    LRA/ Lars Albihn        Changed to RST8X as reset, added sWCLK as
--                                              a dedicated clock signal.
-- 3        03-03-13    LRA                     Changed to CVS style history log.
-- 4        03-03-19    LRA                     Improved comments.
--  
-- ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

-- ------------------------------------------------------------------------------------------
-- Library declarations
-- ------------------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library unisim;
use unisim.VCOMPONENTS.all;

-- ------------------------------------------------------------------------------------------
-- Entity declaration
-- ------------------------------------------------------------------------------------------
entity memclkgen is
port(

    clk8x    : in std_logic;  -- Clock signal

    rst8x    : in std_logic;  -- Async reset signal.
                              -- Release of reset must be externally
                              -- synchronized to clk8x.
    wclk_net : out std_logic
);
end entity memclkgen;

-- ------------------------------------------------------------------------------------------
-- Architecture definition
-- ------------------------------------------------------------------------------------------
architecture rtl of memclkgen is

-- ------------------------------------------------------------------------------------------
-- Signal declarations
-- ------------------------------------------------------------------------------------------
signal sCOUNTER : unsigned(1 downto 0);
signal sWCLK    : std_logic;

-- ------------------------------------------------------------------------------------------
-- Begin architecture
-- ------------------------------------------------------------------------------------------
begin
    
-- ------------------------------------------------------------------------------------------
-- Simple binary divide by 4 counter
-- ------------------------------------------------------------------------------------------
counter_process : process(rst8x, clk8x)
begin

  if rst8x = '1' then

    sWCLK    <= '0';
    sCOUNTER <= (others=>'0');

  elsif rising_edge(clk8x) then

    if sCOUNTER=3 then
      sWCLK <= '1';
    else
      sWCLK <= '0';
    end if;

    sCOUNTER <= sCOUNTER + 1;

  end if;

end process counter_process;

-- ------------------------------------------------------------------------------------------
-- Instantiate the global clock buffer
-- ------------------------------------------------------------------------------------------
bufg0 : BUFG port map (I=>sWCLK, O=>wclk_net);

end architecture rtl;
