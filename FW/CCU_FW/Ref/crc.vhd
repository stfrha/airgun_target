-- ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
--
-- VHDL SOURCE FILE crc.vhd
--
-- Function to support fast ROM and FLASH CRC-32 calculations.
-- 
-- Compatible with the CRC calculation performed by the IAR Systems linker.
--
-- $Id: crc.vhd,v 1.1 2005/02/11 14:11:33 lra Exp $
-- $Log: crc.vhd,v $
-- Revision 1.1  2005/02/11 14:11:33  lra
-- New project directory structure created
--
-- Revision 1.2  2005/02/11 13:57:57  lra
-- Cleaned up signal names
--
-- Revision 1.1  2004/03/25 12:50:27  lra
-- Import to CVS, new design file
--
--
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
entity crc is
port
(
  clk         : in std_logic;  -- Clock signal

  rst         : in std_logic;  -- Async. reset signal.
                               -- Release of reset must be externally
                               -- synchronized to clk.

  ReadStrobe  : in std_logic;  -- CPU read strobe
  WriteStrobe : in std_logic;  -- CPU write strobe

  DataDir     : in std_logic;  -- CPU data direction signal
        
  FLASH_D     : in std_logic_vector(7 downto 0);  -- Data bus from flash
  DataToMem   : in std_logic_vector(7 downto 0);  -- Data bus from CPU

  crc_clear_n : in std_logic;  -- CRC register init signal

  crc_err     : out std_logic  -- Indicates CRC error, only valid after completed calculation

);
end entity crc;

-- ------------------------------------------------------------------------------------------
-- Architecture definition
-- ------------------------------------------------------------------------------------------
architecture rtl of crc is

-- ------------------------------------------------------------------------------------------
-- Constant declarations
-- ------------------------------------------------------------------------------------------
constant ZERO          : std_logic_vector(31 downto 0) := (others=>'0');

-- ------------------------------------------------------------------------------------------
-- Signal declarations
-- ------------------------------------------------------------------------------------------
signal XDATA_access    : std_logic;
signal XDATA_access_m1 : std_logic;
signal d               : std_logic_vector(7 downto 0);  -- Temporary data register
signal r               : std_logic_vector(31 downto 0); -- CRC register

-- ------------------------------------------------------------------------------------------
-- Begin architecture
-- ------------------------------------------------------------------------------------------
begin
    
XDATA_access <= '1' when ReadStrobe='0' or WriteStrobe='0' else '0'; -- Indicates access
	                                                                 -- to XDATA in progress
    
-- ------------------------------------------------------------------------------------------
-- Synchronous process
-- ------------------------------------------------------------------------------------------
crc_p : process(rst, clk)
begin
    
  if rst = '1' then

    XDATA_access_m1 <= '0';
    d               <= (others=>'0');
    r               <= (others=>'0');

  elsif rising_edge(clk) then

    XDATA_access_m1 <= XDATA_access;

    -- NOTE: If DataDir = 0, then DataToMem is actually driven onto the FLASH_D external pins.
	-- We do not take advantage of this, in order to avoid e.g. a shorted FLASH_D pin causing
	-- a ROM CRC error.

	if DataDir = '0' then
      d <= DataToMem;
	else
      d <= FLASH_D;
	end if;

    if crc_clear_n = '0' then

      r <= (others=>'0');

    elsif XDATA_access='0' and XDATA_access_m1='1' then -- Detect end of XDATA access cycle

      -- Update CRC register

      ---------------------------------------------------------------------------------------
      -- NOTE: This is a byte-based calculation, using the "standard" CRC-32 polynomial
      --
      -- G(x) = x^32 + x^26 + x^23 + x^22 + x^16 + x^12 + x^11 + x^10 + x^8 + x^7 + x^5
      --        + x^4 + x^2 + x^1 + 1
      --
      -- Finding the bit equations below from G(x) is an exercise in GF(2) linear algebra,
      -- which will not be described here.
      --
      -- Also note that there are several ways to define the CRC calculation. Here, the most
      -- basic form is used - feeding all of the data (including the 32-bit CRC value at the end)
      -- into the register should produce an all-zero condition.
      ---------------------------------------------------------------------------------------

      r(0)  <=  d(0) xor r(24) xor r(30);
      r(1)  <=  d(1) xor r(24) xor r(25) xor r(30) xor r(31);
      r(2)  <=  d(2) xor r(24) xor r(25) xor r(26) xor r(30) xor r(31);
      r(3)  <=  d(3) xor r(25) xor r(26) xor r(27) xor r(31);
      r(4)  <=  d(4) xor r(24) xor r(26) xor r(27) xor r(28) xor r(30);
      r(5)  <=  d(5) xor r(24) xor r(25) xor r(27) xor r(28) xor r(29) xor r(30) xor r(31);
      r(6)  <=  d(6) xor r(25) xor r(26) xor r(28) xor r(29) xor r(30) xor r(31);
      r(7)  <=  d(7) xor r(24) xor r(26) xor r(27) xor r(29) xor r(31);
      r(8)  <=  r(0) xor r(24) xor r(25) xor r(27) xor r(28);
      r(9)  <=  r(1) xor r(25) xor r(26) xor r(28) xor r(29);
      r(10) <=  r(2) xor r(24) xor r(26) xor r(27) xor r(29);
      r(11) <=  r(3) xor r(24) xor r(25) xor r(27) xor r(28);
      r(12) <=  r(4) xor r(24) xor r(25) xor r(26) xor r(28) xor r(29) xor r(30);
      r(13) <=  r(5) xor r(25) xor r(26) xor r(27) xor r(29) xor r(30) xor r(31);
      r(14) <=  r(6) xor r(26) xor r(27) xor r(28) xor r(30) xor r(31);
      r(15) <=  r(7) xor r(27) xor r(28) xor r(29) xor r(31);
      r(16) <=  r(8) xor r(24) xor r(28) xor r(29);
      r(17) <=  r(9) xor r(25) xor r(29) xor r(30);
      r(18) <= r(10) xor r(26) xor r(30) xor r(31);
      r(19) <= r(11) xor r(27) xor r(31);
      r(20) <= r(12) xor r(28);
      r(21) <= r(13) xor r(29);
      r(22) <= r(14) xor r(24);
      r(23) <= r(15) xor r(24) xor r(25) xor r(30);
      r(24) <= r(16) xor r(25) xor r(26) xor r(31);
      r(25) <= r(17) xor r(26) xor r(27);
      r(26) <= r(18) xor r(24) xor r(27) xor r(28) xor r(30);
      r(27) <= r(19) xor r(25) xor r(28) xor r(29) xor r(31);
      r(28) <= r(20) xor r(26) xor r(29) xor r(30);
      r(29) <= r(21) xor r(27) xor r(30) xor r(31);
      r(30) <= r(22) xor r(28) xor r(31);
      r(31) <= r(23) xor r(29);

    end if;

  end if;

end process crc_p;
    
-- ------------------------------------------------------------------------------------------
-- Output signal assignments
-- ------------------------------------------------------------------------------------------
crc_err <= '1' when r /= ZERO else '0';

end architecture rtl;
