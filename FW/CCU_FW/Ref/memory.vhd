-- ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
--
-- VHDL SOURCE FILE memory.vhd
--
-- Memory (ROM, RAM and FLASH) interface
--
-- $Id: memory.vhd,v 1.1 2005/02/11 14:11:33 lra Exp $
-- $Log: memory.vhd,v $
-- Revision 1.1  2005/02/11 14:11:33  lra
-- New project directory structure created
--
-- Revision 1.8  2005/02/11 14:03:38  lra
-- Cleaned up signal names.
-- Removed INIT arrays on block RAMs and the corresponding
-- code for pre-synthesis simulation, since they are now obsolete
-- (see unisim library).
--
-- Revision 1.7  2004/08/20 15:48:17  lra
-- Renamed FLASH_CE0_n to FLASH_CE_n.
-- Added FLASH_P inputs and FLASH4_CE_n outputs.
-- Changed FLASH_A from 15 to 21 bits.
--
-- Revision 1.6  2004/03/01 11:20:38  lra
-- Changed back to original memory model for the Virtex platform.
--
-- Revision 1.5  2004/02/26 14:47:07  lra
-- Added memory options for Virtex-2 FPGA.
--
-- Revision 1.4  2003/04/04 17:09:30  lra
-- Major cleanup and simplification of code. Please see old-style history log in file header for details.
-- Use CVS log messages for revision history from now on.
--
--
-- ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
--
-- Pre-CVS-log history. Do not use for future revisions.
--
-- Version  Date        Who                     What
-- 1        yy-mm-dd    LRA/Lars Albihn         Created
-- 2        02-11-26    LRA                     Simplified address decoding of MAIN2,
--                                              added read of TRAP opcode if trying to execute from FLASH
-- 3        03-02-28    LRA                     Changed to 8K ROM + 4K XRAM to improve timing.
--                                              Moved FLASH data bus direction control to this file.
-- 4        03-03-03    LRA                     Added logic to generate FLASH_OE_n signal.
-- 5        03-03-07    LRA                     Changed FLASH_OE_n generation to run on falling edge of WCLK.
-- 6        03-03-11    LRA                     Moved FLASH address bus mapping to this file.
-- 7        03-03-13    LRA                     Changed to CVS style history log.
-- 8        03-03-19    LRA                     Improved comments.
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

use work.config_package.all;

-- ------------------------------------------------------------------------------------------
-- Entity declaration
-- ------------------------------------------------------------------------------------------
entity memory is
port(

    clk         : in std_logic;  -- Clock signal

    rst         : in std_logic;  -- Async reset signal.
                                 -- Release of reset must be externally
                                 -- synchronized to clk.

    FLASH_P     : in std_logic_vector(5 downto 0); -- FLASH page select bits

    MemAddr     : in std_logic_vector(15 downto 0);

    Psen        : in std_logic;
    ReadStrobe  : in std_logic;
    WriteStrobe : in std_logic;

    DataDir     : in std_logic;
    
    DataToMem   : in std_logic_vector(7 downto 0);
    DataFromMem : out std_logic_vector(7 downto 0);

    FLASH_A     : out std_logic_vector(20 downto 0);        
    FLASH_CE_n  : out std_logic;                        -- For 1 x 16 Mbit FLASH        
    FLASH4_CE_n : out std_logic_vector(3 downto 0);     -- For 4 x  4 Mbit FLASH        
    FLASH_OE_n  : out std_logic;        
    FLASH_D     : inout std_logic_vector(7 downto 0)
);
end entity memory;

-- ------------------------------------------------------------------------------------------
-- Architecture definition
-- ------------------------------------------------------------------------------------------
architecture struct of memory is

-- ------------------------------------------------------------------------------------------
-- Signal declarations
-- ------------------------------------------------------------------------------------------
signal clk_n      : std_logic;

signal ROM0_DO    : std_logic_vector(7 downto 0);
signal ROM0_DO_G  : std_logic_vector(7 downto 0);

signal ROM0X_DO   : std_logic_vector(7 downto 0);
signal ROM0X_DO_G : std_logic_vector(7 downto 0);
signal ROM0X_WE   : std_logic;

signal ROM1_DO    : std_logic_vector(7 downto 0);
signal ROM1_DO_G  : std_logic_vector(7 downto 0);

signal XRAM_DO    : std_logic_vector(7 downto 0);
signal XRAM_DO_G  : std_logic_vector(7 downto 0);
signal XRAM_WE    : std_logic;

signal FLASH_DO_G : std_logic_vector(7 downto 0); 

-- ------------------------------------------------------------------------------------------
-- Begin architecture
-- ------------------------------------------------------------------------------------------
begin
    
-- ------------------------------------------------------------------------------------------
-- Generate ROM and RAM using RAMB primitives.
-- ------------------------------------------------------------------------------------------
-- ------------------------------------------------------------------------------------------
-- Virtex: 2*4k ROM and 4k RAM.
-- ------------------------------------------------------------------------------------------
VIRTEX_GENERATE : if not cVIRTEX2 generate

-- ------------------------------------------------------------------------------------------
-- Generate a 4k x 8 ROM block (ROM0)
-- ------------------------------------------------------------------------------------------
ROM0_ARRAY : for i in 7 downto 0 generate
begin

  RAMB_1 : RAMB4_S1
   port map(

     DO   => ROM0_DO(i downto i),

     ADDR => MemAddr(11 downto 0),
     DI   => (others=>'0'),
     EN   => '1',
     CLK  => clk_n, -- NOTE: ROM clocked on clk falling edge
     WE   => '0',
     RST  => '0'
   );

end generate ROM0_ARRAY;

-- ------------------------------------------------------------------------------------------
-- Generate a 4k x 8 ROM block (ROM1)
-- ------------------------------------------------------------------------------------------
ROM1_ARRAY : for i in 7 downto 0 generate
begin

  RAMB_1 : RAMB4_S1
   port map(

     DO   => ROM1_DO(i downto i),

     ADDR => MemAddr(11 downto 0),
     DI   => (others=>'0'),
     EN   => '1',
     CLK  => clk_n, -- NOTE: ROM clocked on clk falling edge
     WE   => '0',
     RST  => '0'
   );

end generate ROM1_ARRAY;

-- ------------------------------------------------------------------------------------------
-- Generate a 4k x 8 RAM block (XRAM)
-- ------------------------------------------------------------------------------------------
XRAM_ARRAY : for i in 7 downto 0 generate
begin

  RAMB_1 : RAMB4_S1
   port map(

     DO   => XRAM_DO(i downto i),

     ADDR => MemAddr(11 downto 0),
     DI   => DataToMem(i downto i),
     EN   => '1',
     CLK  => clk,      -- NOTE: Reads from XDATA are multi-cycle operations,
                       -- so XRAM can be clocked by clk rising edge to relax timing.
     WE   => XRAM_WE,
     RST  => '0'

   );

end generate XRAM_ARRAY;

end generate VIRTEX_GENERATE;

-- ------------------------------------------------------------------------------------------
-- Virtex-2: 2*16k ROM and 16k RAM.
-- ------------------------------------------------------------------------------------------
VIRTEX2_GENERATE : if cVIRTEX2 generate

-- ------------------------------------------------------------------------------------------
-- Generate a 16k x 8 ROM block (ROM0).
-- This block is also mapped to XDATA space for use by the ROM-monitor program.
-- ------------------------------------------------------------------------------------------
ROM0_ARRAY : for i in 7 downto 0 generate
begin

  RAMB_1 : RAMB16_S1_S1
   port map(

	 -- Port A is used as a read-only port (CODE access) 

     DOA   => ROM0_DO(i downto i),

     ADDRA => MemAddr(13 downto 0),
     DIA   => (others=>'0'),
     ENA   => '1',
     CLKA  => clk_n, -- NOTE: ROM clocked on clk falling edge
     WEA   => '0',
     SSRA  => '0',

	 -- Port B is used as a read/write port (XDATA access) 

     DOB   => ROM0X_DO(i downto i),

     ADDRB => MemAddr(13 downto 0),
     DIB   => DataToMem(i downto i),
     ENB   => '1',
     CLKB  => clk,      -- NOTE: Reads from XDATA are multi-cycle operations,
                        -- so ROM0 port B can be clocked by clk rising edge to relax timing.
     WEB   => ROM0X_WE,
     SSRB  => '0'
   );

end generate ROM0_ARRAY;

-- ------------------------------------------------------------------------------------------
-- Generate a 16k x 8 ROM block (ROM1)
-- ------------------------------------------------------------------------------------------
ROM1_ARRAY : for i in 7 downto 0 generate
begin

  RAMB_1 : RAMB16_S1
   port map(

     DO   => ROM1_DO(i downto i),

     ADDR => MemAddr(13 downto 0),
     DI   => (others=>'0'),
     EN   => '1',
     CLK  => clk_n, -- NOTE: ROM clocked on clk falling edge
     WE   => '0',
     SSR  => '0'
   );

end generate ROM1_ARRAY;

-- ------------------------------------------------------------------------------------------
-- Generate a 16k x 8 RAM block (XRAM)
-- ------------------------------------------------------------------------------------------
XRAM_ARRAY : for i in 7 downto 0 generate
begin

  RAMB_1 : RAMB16_S1
   port map(

     DO   => XRAM_DO(i downto i),

     ADDR => MemAddr(13 downto 0),
     DI   => DataToMem(i downto i),
     EN   => '1',
     CLK  => clk,      -- NOTE: Reads from XDATA are multi-cycle operations,
                       -- so XRAM can be clocked by clk rising edge to relax timing.
     WE   => XRAM_WE,
     SSR  => '0'

   );

end generate XRAM_ARRAY;

end generate VIRTEX2_GENERATE;

-- ------------------------------------------------------------------------------------------
-- Signal assignments
-- ------------------------------------------------------------------------------------------
clk_n <= not clk;

-- ------------------------------------------------------------------------------------------
-- Address mapping
-- ------------------------------------------------------------------------------------------
MAP_PROCESS : process(Psen, FLASH_P, MemAddr, WriteStrobe,
                      ROM0_DO, ROM1_DO, ROM0X_DO, XRAM_DO, FLASH_D)
begin
  
  if not cVIRTEX2 then

    -- Map ROM0 block to 0000h-0fffh in CODE space, first 4kB.
    -- NOTE: Block also present at 2000h-2fffh, 4000h-4fffh etc.

	if Psen='0' and MemAddr(12)='0' then
      ROM0_DO_G <= ROM0_DO;
	else
      ROM0_DO_G <= (others=>'0');
	end if;

    -- Map ROM1 block to 1000h-1fffh in CODE space, second 4kB.
    -- NOTE: Block also present at 3000h-3fffh, 5000h-5fffh etc. 

	if Psen='0' and MemAddr(12)='1' then
      ROM1_DO_G <= ROM1_DO;
	else
      ROM1_DO_G <= (others=>'0');
	end if;

    -- In Virtex, ROM0 is not mapped to XDATA

    ROM0X_DO_G <= (others=>'0');

    -- Map XRAM block to 0000h-0fffh, in XDATA space, first 4kB.
    -- NOTE: Block also present at 2000h-2fffh, 4000h-4fffh etc, up to 7fffh.

	if Psen='1' and MemAddr(15)='0' and MemAddr(12)='0' then
      XRAM_DO_G <= XRAM_DO;
	else
      XRAM_DO_G <= (others=>'0');
	end if;

	if WriteStrobe='0' and MemAddr(15)='0' and MemAddr(12)='0' then
      XRAM_WE  <= '1';
	else
      XRAM_WE <= '0';
	end if;

  else

    -- Map ROM0 block to 0000h-3fffh in CODE space, first 16kB.
    -- NOTE: Block also present at 8000h-bfffh.

	if Psen='0' and MemAddr(14)='0' then
      ROM0_DO_G <= ROM0_DO;
	else
      ROM0_DO_G <= (others=>'0');
	end if;

    -- Map ROM1 block to 4000h-7fffh in CODE space, second 16kB.
    -- NOTE: Block also present at c000h-ffffh.

	if Psen='0' and MemAddr(14)='1' then
      ROM1_DO_G <= ROM1_DO;
	else
      ROM1_DO_G <= (others=>'0');
	end if;

    -- Map ROM0 block to 0000h-3fffh in XDATA space, first 16kB.

	if Psen='1' and MemAddr(15)='0' and MemAddr(14)='0' then
      ROM0X_DO_G <= ROM0X_DO;
	else
      ROM0X_DO_G <= (others=>'0');
	end if;

	if cROM0_WRITEABLE and WriteStrobe='0' and MemAddr(15)='0' and MemAddr(14)='0' then
      ROM0X_WE  <= '1';
	else
      ROM0X_WE <= '0';
	end if;

    -- Map XRAM block to 4000h-7fffh, in XDATA space, second 16kB.

	if Psen='1' and MemAddr(15)='0' and MemAddr(14)='1' then
      XRAM_DO_G <= XRAM_DO;
	else
      XRAM_DO_G <= (others=>'0');
	end if;

	if WriteStrobe='0' and MemAddr(15)='0' and MemAddr(14)='1' then
      XRAM_WE  <= '1';
	else
      XRAM_WE <= '0';
	end if;

  end if;

  -- Map FLASH chip to 8000h-ffffh in XDATA space.

  if Psen='1' and MemAddr(15)='1' then
    FLASH_DO_G <= FLASH_D;
  else
    FLASH_DO_G <= (others=>'0');
  end if;

  if MemAddr(15)='1' then
    FLASH_CE_n <= '0';
  else
    FLASH_CE_n <= '1';
  end if;

  FLASH4_CE_n <= (others=>'1');

  if MemAddr(15)='1' then
    FLASH4_CE_n(To_integer(unsigned(FLASH_P(5 downto 4)))) <= '0';
  end if;

end process MAP_PROCESS;

-- ------------------------------------------------------------------------------------------
-- Logic to generate a re-timed FLASH output enable signal, to guarantee glitch-free reads.
-- May be necessary since the Flip805x MemAddr and ReadStrobe signals switch simultaneously
-- (on the same clock edge). Read glitches may upset the flash write state machine, particularily
-- in the White (Tornado) flash, which supports the "Toggle Bit" algorithm.
-- NOTE: This logic depends on FLASH_CE_n being a function of a single address bit only,
-- MemAddr(15) in this case.  
-- ------------------------------------------------------------------------------------------
FLASH_OE_n_PROCESS : process(rst, clk)
begin
  if rst = '1' then
    FLASH_OE_n <= '1';
  elsif falling_edge(clk) then
    if ReadStrobe='0' and MemAddr(15)='1' then
      FLASH_OE_n <= '0';
    else
      FLASH_OE_n <= '1'; 
    end if;
  end if;
end process FLASH_OE_n_PROCESS;

-- ------------------------------------------------------------------------------------------
-- Output signal assignments  
-- ------------------------------------------------------------------------------------------

-- Output data combiner
DataFromMem <= ROM0_DO_G or ROM1_DO_G or ROM0X_DO_G or XRAM_DO_G or FLASH_DO_G;

-- FLASH data bus output control
FLASH_D <= DataToMem when DataDir = '0' else (others => 'Z');

-- FLASH address bus mapping
FLASH_A <= FLASH_P & MemAddr(14 downto 0);

end architecture struct;