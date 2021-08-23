-- ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
--
-- VHDL SOURCE FILE DLL4X.vhd
--
-- Multiplies the input (4x) clock signal frequency by 2 and 4.
-- Outputs 8x and 16x clocks.
--
-- $Id: DLL4X.vhd,v 1.1 2005/02/11 14:11:33 lra Exp $
-- $Log: DLL4X.vhd,v $
-- Revision 1.1  2005/02/11 14:11:33  lra
-- New project directory structure created
--
-- Revision 1.4  2005/02/11 13:54:31  lra
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
-- 1        02-06-12    MXXN/ Mikael Andersson  Created for the EWCS Project
-- 2        03-03-10    LRA/ Lars Albihn        Added delayed LOCKED outputs.
--                                              Cleaned up code, changed to
--                                              meaningful signal names.
-- 3        03-03-13    LRA                     Changed to CVS style history log.
--  
-- ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

-- ------------------------------------------------------------------------------------------
-- Library declarations
-- ------------------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;

library unisim;
use unisim.VCOMPONENTS.all;

-- ------------------------------------------------------------------------------------------
-- Entity declaration
-- ------------------------------------------------------------------------------------------
entity DLL4X is
port
(
    CLK4X1    : std_logic;

    clk8x     : out std_logic;
    clk16x    : out std_logic;

    locked8x  : out std_logic;
    locked16x : out std_logic
);

end entity DLL4X;

-- ------------------------------------------------------------------------------------------
-- Architecture definition
-- ------------------------------------------------------------------------------------------
architecture struct of DLL4X is

-- ------------------------------------------------------------------------------------------
-- Signal declarations
-- ------------------------------------------------------------------------------------------
signal sCLK4X       : std_logic;
signal sCLK8X_1     : std_logic;
signal sCLK8X       : std_logic;
signal sLOCKED8X_1  : std_logic;
signal sLOCKED8X    : std_logic;

signal sRST         : std_logic;
signal sCLK16X_1    : std_logic;
signal sCLK16X      : std_logic;
signal sLOCKED16X_1 : std_logic;
signal sLOCKED16X   : std_logic;

-- ------------------------------------------------------------------------------------------
-- Begin architecture
-- ------------------------------------------------------------------------------------------
begin

-- ------------------------------------------------------------------------------------------
-- Instantiate the first (4x->8x) DLL, with support functions
-- ------------------------------------------------------------------------------------------
ibufg0 : IBUFG port map (I=>CLK4X1, O=>sCLK4X);

dll0 : CLKDLL port map (CLKIN  => sCLK4X,
                        CLKFB  => sCLK8x,
                        RST    => '0',
                        CLK0   => open,
                        CLK90  => open,
                        CLK180 => open,
                        CLK270 => open,
                        CLK2X  => sCLK8X_1,
                        CLKDV  => open,
                        LOCKED => sLOCKED8X_1);

bufg0 : BUFG port map (I=>sCLK8X_1, O=>sCLK8x);

srl160 : SRL16 port map (Q=>sLOCKED8X, A0=>'1',A1=>'1', A2=>'1', A3=>'1', D=>sLOCKED8X_1, CLK=>sCLK8X);

-- ------------------------------------------------------------------------------------------
-- Instantiate the second (8x->16x) DLL, with support functions
-- ------------------------------------------------------------------------------------------
sRST <= not(sLOCKED8X);

dll1 : CLKDLL port map (CLKIN  => sCLK8X,
                        CLKFB  => sCLK16X,
                        RST    => sRST,
                        CLK0   => open,
                        CLK90  => open,
                        CLK180 => open,
                        CLK270 => open,
                        CLK2X  => sCLK16X_1,
                        CLKDV  => open,
                        LOCKED => sLOCKED16X_1);

bufg1 : BUFG port map (I=>sCLK16X_1, O=>sCLK16X);

srl161 : SRL16 port map (Q=>sLOCKED16X, A0=>'1',A1=>'1', A2=>'1', A3=>'1', D=>sLOCKED16X_1, CLK=>sCLK16X);

-- ------------------------------------------------------------------------------------------
-- Output signal assignments
-- ------------------------------------------------------------------------------------------
clk8x  <= sCLK8X;
clk16x <= sCLK16X;

locked8x  <= sLOCKED8X;
locked16x <= sLOCKED16X;

end architecture struct;
