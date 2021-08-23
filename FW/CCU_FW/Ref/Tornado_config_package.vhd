-- ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
--
-- VHDL SOURCE FILE Tornado_config_package.vhd
--
-- Package for declaring constants specific to the Tornado configuration.
--
-- $Id: Tornado_config_package.vhd,v 1.1 2005/02/11 14:11:33 lra Exp $
-- $Log: Tornado_config_package.vhd,v $
-- Revision 1.1  2005/02/11 14:11:33  lra
-- New project directory structure created
--
-- Revision 1.4  2004/03/18 16:49:56  lra
-- Removed a "TODO" comment
--
-- Revision 1.3  2004/03/12 10:17:39  lra
-- Added more constants
--
-- Revision 1.2  2004/03/01 18:25:20  lra
-- Added more constants.
--
-- Revision 1.1  2004/03/01 12:21:35  lra
-- Import to CVS. New design file.
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

constant cVIRTEX2        : boolean := false; -- FPGA is not Virtex-2
constant cRAMB_SIZE      : natural := 4095;  -- Size of RAMB primitives

constant cROM0_WRITEABLE : boolean := false; -- Option to make ROM0 block writable
                                             -- is not implemented.

constant cAgtR_INVERT    : std_logic := '0'; -- No inversion of ADC comparator inputs.

constant cSAMPLING_MAXCOUNT : natural := 2;  -- ADHS sampling delay.
	                                         -- Set so that samples are guaranteed to be taken
	                                         -- before CAL_ON negative edge.

constant cADHS_EN_COUNT  : natural := 14;    -- Controls where in the ADHS_CLK cycle data from the
                                             -- ADC is sampled. 

constant cADHS_WRITEABLE : boolean := false; --	ADHS ADC:s are read-only

end package;
