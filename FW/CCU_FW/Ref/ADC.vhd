-- ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
--
-- VHDL SOURCE FILE adc.vhd
--
-- Free-running 8-bit Successive Approximation ADC
-- For details, see Xilinx application note XAPP 155
-- External components: One R/C filter and one comparator.
-- Uses a Delta-Sigma DAC to produce a reference voltage
-- for the inverting comparator input.
--
-- From XAPP 155: 
-- This is an Analog to Digital Converter that uses an external
-- analog comparator, which compares the input voltage to a
-- voltage generated by the built-in DAC.  The DAC voltage starts at midrange,
-- and continues to narrow down the result by successive division by 2
-- until the DAC LSB is reached. This requires MSB+1 (the width of
-- the DAC input) samples.  The width of the result is 1 bit less than the
-- width of the DAC.  The precision of the result is within 1/2 LSB.
--
-- $Id: ADC.vhd,v 1.1 2005/02/11 14:11:33 lra Exp $
-- $Log: ADC.vhd,v $
-- Revision 1.1  2005/02/11 14:11:33  lra
-- New project directory structure created
--
-- Revision 1.7  2005/02/11 13:53:47  lra
-- Removed dependency on config_package,
-- AgtR must now be inverted externally to this block, if necessary.
-- Changed some constants into generics.
-- Some minor cleanup
--
-- Revision 1.6  2004/03/01 18:34:39  lra
-- Removed input signal AgtR_n. Polarity of the input from the comparator is now selected
-- through a constant in config_package.
--
-- Revision 1.5  2003/08/20 17:19:59  lra
-- Changed the cFstmConst delay constant from 7 to 18, to improve ADC accuracy
--
-- Revision 1.4  2003/04/17 15:18:19  lra
-- Moved SfrAddr decoding outside of this block. Removed signal sADCout, no longer needed.
-- ADC is now very similar to Xilinx original design.
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
-- 1        99-10-28    MXXN/ Mikael Andersson  Created for the EWCS Project. Port from Verilog.
-- 2        02-05-23    JEGA/ Jeppe Gade        Adaption to Tornado project
-- 3        02-07-12    LRA/  Lars Albihn       Added external address selection pin
-- 4        02-11-15    LRA                     Added AD_RDY output etc. stolen from EWCS
-- 5        02-11-22    LRA                     Added AgtR_n input to handle signal
--                                              inversion in EWCS
-- 6        02-11-26    LRA                     Added inversion of AD_RDY in order to
--                                              use edge-triggered interrupt
-- 7        03-03-11    LRA                     Changed output data selector
--                                              to not use tristate buffers.
--                                              Some code cleanup.
-- 8        03-03-13    LRA                     Code cleanup, changed to CVS style history log.
--                                              Simplified the samplepulse_stretcher process.
--                                              Moved the DAC2 function into this file, since it
--                                              is essentially just one line of code.
-- 9        03-03-14    LRA                     Added DACin output, to simplify simulation.
--                                              Removed AD_RDY_n signal etc., since we can just
--                                              as well use the falling edge of Sample to trig
--                                              the CPU interrupt.
--                                              Removed dependence on "serial port package".
-- 10       03-03-19    LRA                     Improved comments.
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
entity ADC is
generic(
    
    -- NOTE: See XAPP 155 and comments in Fstm_proc below for
    --       details about these constants.
    
    FSTMMSB    : positive;                            -- MSB in sFSTM_COUNTER
    cFstmConst : positive                             -- Low Pass Filter settle time constant
);
port(     
      clk        : in std_logic;                      -- Clock signal

      reset      : in std_logic;                      -- Async reset signal.
                                                      -- Release of reset must be externally
                                                      -- synchronized to clk.

      DACin      : out std_logic_vector(8 downto 0);  -- Input to the internal DAC, use for
                                                      -- simulation only.

      DACout     : out std_logic;                     -- Drives external filter to generate
                                                      -- reference voltage for the ext.
                                                      -- comparator.
    
      AgtR       : in std_logic;                      -- Input from external comparator

      ADCout     : out std_logic_vector(7 downto 0);  -- ADC output

      ADCsampled : out std_logic;                     -- Clock enable for the ADCout reg.
                                                      -- Indicates that ADCout will change on
                                                      -- the next positive clk edge (if the
                                                      -- analog input has changed).

      Sample     : out std_logic                      -- Signal is true when ADC is sampling
                                                      -- upper bit of each word.
                                                      -- Can drive an external Sample and
                                                      -- hold circuit.
);                                 

end entity ADC;

-- ------------------------------------------------------------------------------------------
-- Architecture definition
-- ------------------------------------------------------------------------------------------
architecture rtl of ADC is

-- ------------------------------------------------------------------------------------------
-- constant declarations
-- ------------------------------------------------------------------------------------------
constant MSB : positive := ADCout'left + 1;  -- MSB in DAC input.

-- ------------------------------------------------------------------------------------------
-- Signal declarations
-- ------------------------------------------------------------------------------------------

-- ADC registered signals
signal sDAC_SAMPLE_COUNTER: unsigned(MSB downto 0);     -- DAC sample counter
signal sDACsampled: std_logic;                          -- Pipelining DAC Sampled status
signal sDecFSTM_COUNTER: std_logic;                     -- Pipeline DecFSTM_COUNTER
signal sFSTM_COUNTER: unsigned(FSTMMSB downto 0);       -- Low Pass Filter settle time counter
signal sSHIFT: std_logic;                               -- Pipeline SHIFT signal
signal sADCsampled: std_logic;                          -- Pipeline ADCsampled status
signal sMASK_SHIFTER: std_logic_vector(MSB downto 0);   -- Mask shifter
signal sREF_SHIFTER: std_logic_vector(MSB downto 0);    -- Reference shifter. Drives the DAC input.

-- ADC intermediary combinatorial signals
signal sFstmCntrEq0: std_logic;
signal sCONCATENATED_LSB_MASKSHIFTER:std_logic_vector(MSB downto 0);
signal sCONCATENATED_AgtR:std_logic_vector(MSB downto 0);

-- Signals not in original ADC design
signal sigma: unsigned(MSB+2 downto 0);                 -- DAC sigma register

-- ------------------------------------------------------------------------------------------
-- Begin architecture
-- ------------------------------------------------------------------------------------------
begin
    
-- ---------------------------------------------------------------------------------------
-- DAC sample counter. Same width as DACin. Counts up continuously.
-- One cycle of this counter is the minimum time it takes for the
-- DAC output to resolve to DACin.
-- ---------------------------------------------------------------------------------------
DAC_sample_counter : process(reset, clk)
begin
  if reset='1' then
    sDAC_SAMPLE_COUNTER <= (others => '0');
  elsif rising_edge(clk) then
    sDAC_SAMPLE_COUNTER <= sDAC_SAMPLE_COUNTER + 1;
  end if;
end process DAC_sample_counter;

-- ---------------------------------------------------------------------------------------
-- Pipeline sDACsampled status for speed
-- ---------------------------------------------------------------------------------------
DACsampled_status : process(reset, clk)
begin
  if reset = '1' then
    sDACsampled <= '0';
  elsif rising_edge(clk) then
    if sDAC_SAMPLE_COUNTER = 0 then
      sDACsampled <= '1';
    else
      sDACsampled <= '0';
    end if;
  end if;
end process DACsampled_status;

-- ---------------------------------------------------------------------------------------
-- Pipeline sDecFSTM_COUNTER signal so it is in phase with shift signal
-- ---------------------------------------------------------------------------------------
decFstmCntr : process(reset, clk)
begin
  if reset = '1' then
    sDecFSTM_COUNTER <= '0';
  elsif rising_edge(clk) then
    sDecFSTM_COUNTER <= sDACsampled;
  end if;
end process decFstmCntr;

-- ---------------------------------------------------------------------------------------
-- Filter settle time multiplier. The counter counts down to 0 from cFstmConst.
-- When this counter reaches 0, the output of the comparator is sampled so the
-- DAc output reference voltage must be stable at that time.
-- cFstmConst may be set to the lowest value that ensures a stable reference voltage, 
-- based on the low pass filter parameters.
-- ---------------------------------------------------------------------------------------
Fstm_proc : process(reset, clk)
begin
  if reset = '1' then
    sFSTM_COUNTER <= To_unsigned(1, sFSTM_COUNTER'length);
  elsif rising_edge(clk) then
    if sSHIFT = '1' then 
      sFSTM_COUNTER <= To_unsigned(cFstmConst, sFSTM_COUNTER'length);
    elsif sDecFSTM_COUNTER = '1' then
      sFSTM_COUNTER <= sFSTM_COUNTER-1;
    end if;
  end if;
end process Fstm_proc;

-- ---------------------------------------------------------------------------------------
-- Pipeline sSHIFT signal for speed
-- ---------------------------------------------------------------------------------------

sFstmCntrEq0 <= '1' when sFSTM_COUNTER = 0 else '0';

shift_pipeline : process(reset, clk)
begin
  if reset = '1' then
    sSHIFT <= '0';
  elsif rising_edge(clk) then
    sSHIFT <= (sDACsampled and sFstmCntrEq0);
  end if;
end process shift_pipeline;

-- ---------------------------------------------------------------------------------------
-- Pipeline sADCsampled status for speed
-- ---------------------------------------------------------------------------------------
ADCsampled_pipeline : process(reset,clk)
begin
  if reset='1' then
    sADCsampled <= '0';
  elsif rising_edge(clk) then
    sADCsampled <= (sDACsampled and sFstmCntrEq0 and sMASK_SHIFTER(0));
  end if;
end process ADCsampled_pipeline;

-- ---------------------------------------------------------------------------------------
-- Mask shifter. Same width as DACin. A single bit rotates endlessly.
-- This bit specifies the next bit that will be sampled.
-- ---------------------------------------------------------------------------------------
Mask_shift : process(reset, clk)
begin
  if reset='1' then
    sMASK_SHIFTER <= (others => '0');
  elsif rising_edge(clk) then
    if sSHIFT = '1' then
      if sMASK_SHIFTER(1)='1' or unsigned(sMASK_SHIFTER) = 0 then

        -- NOTE: The following guarantees 1 and only 1 bit set.
        sMASK_SHIFTER <= std_logic_vector(To_unsigned(1, sMASK_SHIFTER'length));

      else

        -- Rotate right
        sMASK_SHIFTER <= sMASK_SHIFTER(0) & sMASK_SHIFTER(sMASK_SHIFTER'left downto 1);

      end if;
    end if;
  end if;
end process Mask_shift;

-- ---------------------------------------------------------------------------------------
-- Reference shifter. This shifter feeds the DAC input. Starts with only upper bit set.
-- Shifts right, forcing next bit set, but conditionally clearing previous bit based on AgtR.
-- ---------------------------------------------------------------------------------------

sCONCATENATED_LSB_MASKSHIFTER <= (others => sMASK_SHIFTER(0));
sCONCATENATED_AgtR <= (others => AgtR);

Reference_shifter: process(reset, clk)
begin
  if reset='1' then
    sREF_SHIFTER <= (others=>'0');
  elsif rising_edge(clk) then
    if sSHIFT = '1' then
      sREF_SHIFTER <= ((sMASK_SHIFTER(0) & sMASK_SHIFTER(sMASK_SHIFTER'left downto 1)) or
                      (sREF_SHIFTER and (not(sCONCATENATED_LSB_MASKSHIFTER)))) and
                      (not(sMASK_SHIFTER and (not(sCONCATENATED_AgtR))));
    end if;
  end if;
end process Reference_shifter;

-- ---------------------------------------------------------------------------------------
-- Internal ADC output register. Snaps upper bits of sREF_SHIFTER when sample is justified.
-- ---------------------------------------------------------------------------------------
ADCout_register: process(reset, clk)
begin
  if reset='1' then
    ADCout<= (others=>'0');
  elsif rising_edge(clk) then
    if sADCsampled = '1' then
      ADCout <= sREF_SHIFTER(sMASK_SHIFTER'left downto 1);
    end if;
  end if;
end process ADCout_register;

-- ---------------------------------------------------------------------------------------
-- Sample Latch
-- ---------------------------------------------------------------------------------------
Sample_latch: process(reset, clk)
begin
  if reset='1' then
    Sample <= '0';
  elsif rising_edge(clk) then
    if sSHIFT = '1' then
      if sMASK_SHIFTER(0) = '1' then
        Sample <= '1';
      else
        Sample <= '0';
      end if;
    end if;
  end if;
end process Sample_latch;

-- ---------------------------------------------------------------------------------------
-- Sigma-Delta DAC process. See Xilinx application note XAPP 154 for details.
-- ---------------------------------------------------------------------------------------
dac_proc : process(reset, clk)        
begin
  if reset = '1' then

      DACout <= '0';

      sigma <= (others => '0');
      sigma(sigma'left-1) <= '1';

  elsif rising_edge(clk) then

      DACout <= sigma(sigma'left);

      sigma <= sigma + (sigma(sigma'left) & sigma(sigma'left) & unsigned(sREF_SHIFTER));

  end if;

end process dac_proc;

-- ---------------------------------------------------------------------------------------
-- Output signal assignments
-- ---------------------------------------------------------------------------------------

DACin <= sREF_SHIFTER; -- Use for simulation only

ADCsampled <= sADCsampled; 

end architecture rtl;
