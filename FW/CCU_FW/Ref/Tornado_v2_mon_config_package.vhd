-- ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
--
-- VHDL SOURCE FILE Tornado_v2_mon_config_package.vhd
--
-- Package for declaring constants specific to the Tornado_v2_mon configuration.
--
-- $Id: Tornado_v2_mon_config_package.vhd,v 1.1 2005/02/11 14:11:33 lra Exp $
-- $Log: Tornado_v2_mon_config_package.vhd,v $
-- Revision 1.1  2005/02/11 14:11:33  lra
-- New project directory structure created
--
-- Revision 1.1  2004/04/26 13:06:31  lra
-- Import to CVS
--
--
--
-- ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
-- ------------------------------------------------------------------------------------------
-- Library declarations
-- ------------------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

-- ------------------------------------------------------------------------------------------
-- Package declaration
-- ------------------------------------------------------------------------------------------
package config_package is

constant cADP            : boolean := false; -- This is not an ADP configuration

constant cVIRTEX2        : boolean := true;  -- FPGA is Virtex-2
constant cRAMB_SIZE      : natural := 16383; -- Size of RAMB primitives

constant cROM0_WRITEABLE : boolean := true;  -- To allow use of ROM monitor program.

constant cAgtR_INVERT    : std_logic := '0'; -- No inversion of ADC comparator inputs.

constant cSAMPLING_MAXCOUNT : natural := 8;  -- ADHS sampling delay.
	                                         -- Set so that samples are guaranteed to be taken
	                                         -- before CAL_ON negative edge.

constant cADHS_EN_COUNT  : natural := 3;     -- Controls where in the ADHS_CLK cycle data from the
                                             -- ADC is sampled. 

constant cADHS_WRITEABLE : boolean := true;  --	ADHS ADC:s are writeable

end package;
