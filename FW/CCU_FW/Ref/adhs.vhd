-- ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
--
-- VHDL SOURCE FILE adhs.vhd
--
-- ADHS interface
--
-- $Id: adhs.vhd,v 1.1 2005/02/11 14:11:33 lra Exp $
-- $Log: adhs.vhd,v $
-- Revision 1.1  2005/02/11 14:11:33  lra
-- New project directory structure created
--
-- Revision 1.7  2005/02/11 13:57:02  lra
-- Cleaned up signal names
--
-- Revision 1.6  2004/03/18 16:56:50  lra
-- Changed ADHS_CNTRL_ADDR from 0xc0 to 0xf8.
-- Moved some output bits from P0 to ADHS_CNTRL_REG.
--
-- Revision 1.5  2004/03/12 10:23:09  lra
-- Removed DOR inputs, which have never been used.
-- Added support for the THS1403 ADC, including writeable registers.
--
-- Revision 1.4  2003/04/17 15:11:43  lra
-- Renamed SfrAddr to Addr_in and SfrData to Data_out for consistency with ver_id block.
-- Changed output mux to case statement for efficient implementation.
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
-- 1        02-11-18    LRA/Lars Albihn         Version common to MAX1205 and AD9220
-- 2        02-11-26    LRA                     Removed inversion of ready output, in
--                                              order to use active high interrupt input
-- 3        03-03-11    LRA                     Changed output data selector to not use
--                                              tristate buffers
-- 4        03-03-13    LRA                     Changed to CVS style history log.
-- 5        03-03-14    LRA                     Removed dependence on "serial_port_package".
-- 6        03-03-19    LRA                     Improved comments.
--  
-- ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

-- ------------------------------------------------------------------------------------------
-- Library declarations
-- ------------------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.config_package.all;

-- ------------------------------------------------------------------------------------------
-- Entity declaration
-- ------------------------------------------------------------------------------------------
entity ADHS is
port
(
    clk          : in std_logic; -- Clock signal

    rst          : in std_logic; -- Async reset signal.
                                 -- Release of reset must be externally
                                 -- synchronized to clk.

    ADHS1_CLK    : out std_logic;
    ADHS2_CLK    : out std_logic;

    ADHS1_A      : out std_logic_vector(1 downto 0);
    ADHS2_A      : out std_logic_vector(1 downto 0);

    ADHS1_CS_n   : out std_logic;
    ADHS2_CS_n   : out std_logic;

    ADHS1_OE_n   : out std_logic;
    ADHS2_OE_n   : out std_logic;

    ADHS1_WR_n   : out std_logic;
    ADHS2_WR_n   : out std_logic;

    ADHS1_D      : inout std_logic_vector(13 downto 0); -- (bits 13-12 not used by AD9220,
                                                        -- must have PULLDOWN)

    ADHS2_D      : inout std_logic_vector(13 downto 0); -- (bits 13-12 not used by AD9220,
                                                        -- must have PULLDOWN)

    ADHS1_DAV    : in std_logic;                        -- DAV , Data AValailable
                                                        -- (only used by MAX1205,
                                                        -- must have PULLUP)

    ADHS2_DAV    : in std_logic;                        -- DAV , Data AValailable
                                                        -- (only used by MAX1205,
                                                        -- must have PULLUP)

    ADHS1_ST_CAL : out std_logic;                       -- Starts ADHS1 calibration
    ADHS2_ST_CAL : out std_logic;                       -- Starts ADHS2 calibration

    Cal_On       : in std_logic;                        -- Data from AD converters are
                                                        -- sampled on Cal_On falling edge
      
    ADHS_READY   : out std_logic;

    SfrAddr      : in std_logic_vector(6 downto 0);
    SfrDataOut   : in std_logic_vector(7 downto 0);
    SfrLoad      : in std_logic;

    ADHS_SfrData : out std_logic_vector(7 downto 0)
);

end entity ADHS;

-- ------------------------------------------------------------------------------------------
-- Architecture definition
-- ------------------------------------------------------------------------------------------
architecture rtl of ADHS is

-- ------------------------------------------------------------------------------------------
-- constant declarations
-- ------------------------------------------------------------------------------------------

constant ADHS1_H_ADDR : std_logic_vector(7 downto 0) := x"f4";
constant ADHS1_L_ADDR : std_logic_vector(7 downto 0) := x"f5";
constant ADHS2_H_ADDR : std_logic_vector(7 downto 0) := x"f6";
constant ADHS2_L_ADDR : std_logic_vector(7 downto 0) := x"f7";

constant ADHS_CNTRL_ADDR : std_logic_vector(7 downto 0) := x"f8";

-- ------------------------------------------------------------------------------------------
-- Signal declarations
-- ------------------------------------------------------------------------------------------
signal ADHS_CLK_divider : unsigned(3 downto 0);

signal D1_EN : std_logic;
signal D2_EN : std_logic;

signal SCAL_ON    : std_logic;
signal SCAL_ON_M1 : std_logic;

type sampling_state_type is(IDLE, RUNNING, DONE);
signal SAMPLING_STATE1 : sampling_state_type;
signal SAMPLING_STATE2 : sampling_state_type;

signal SAMPLING_COUNTER1 : unsigned(1 downto 0);
signal SAMPLING_COUNTER2 : unsigned(1 downto 0);

signal ADHS1_D_REG : std_logic_vector(ADHS1_D'left downto 0);
signal ADHS2_D_REG : std_logic_vector(ADHS2_D'left downto 0);

signal ADHS1_H_WR_REG : std_logic_vector(5 downto 0);
signal ADHS1_L_WR_REG : std_logic_vector(7 downto 0);
signal ADHS2_H_WR_REG : std_logic_vector(5 downto 0);
signal ADHS2_L_WR_REG : std_logic_vector(7 downto 0);

signal ADHS_CNTRL_REG : std_logic_vector(7 downto 0);

alias ADHS_CLK      : std_logic is ADHS_CLK_divider(ADHS_CLK_divider'left);

alias ADHS_A        : std_logic_vector(1 downto 0) is ADHS_CNTRL_REG(1 downto 0);
alias ADHS_CS_n     : std_logic is ADHS_CNTRL_REG(2);	
alias ADHS_OE_n     : std_logic is ADHS_CNTRL_REG(3);
alias ADHS_WR_n     : std_logic is ADHS_CNTRL_REG(4);
alias ADHS_D_OE_n   : std_logic is ADHS_CNTRL_REG(5);
alias clear         : std_logic is ADHS_CNTRL_REG(6); -- Resets ADHS state machine
alias ADHS_ST_CAL_n : std_logic is ADHS_CNTRL_REG(7); -- Starts ADHS calibration

-- ------------------------------------------------------------------------------------------
-- Begin architecture
-- ------------------------------------------------------------------------------------------
begin

-- ------------------------------------------------------------------------------------------
-- ADHS sampling process
-- ------------------------------------------------------------------------------------------
ADHS_proc : process(rst, clk)
begin
  
  if rst='1' then

    ADHS_CLK_divider <= (others=>'0');

    D1_EN <= '0';
    D2_EN <= '0';

    SCAL_ON     <= '0';
    SCAL_ON_M1  <= '0';

    SAMPLING_STATE1 <= IDLE;
    SAMPLING_STATE2 <= IDLE;

    SAMPLING_COUNTER1 <= (others=>'0');
    SAMPLING_COUNTER2 <= (others=>'0');

    ADHS1_D_REG <= (others=>'0');
    ADHS2_D_REG <= (others=>'0');

    ADHS_READY <= '0';

  elsif rising_edge(clk) then

    -- -------------------------------------------------------------
    -- Divider for ADHS_CLK output
    -- Assumes clk frequency is 20 MHz
    -- Count sequence is ...0, 1, 2, 3, 4, 11, 12, 13, 14, 15, 0...
    -- Output (MSB) frequency is then 2 MHz at 50% duty cycle
    -- -------------------------------------------------------------      
    if ADHS_CLK_divider = 4 then
      ADHS_CLK_divider <= To_unsigned(11, 4);
    else
      ADHS_CLK_divider <= ADHS_CLK_divider + 1;
    end if;

    -- -------------------------------------------------------------
    -- Data enable signals.
    -- Indicates that new data is available and stable on the
    -- ADHS_D inputs.
    -- For MAX1205, DAV is only high in every second clock cycle, so
    -- sampling rate is 1 Ms/s.
    -- For the other ADC:s, DAV inputs are assumed held constant high
    -- by PULLUPS, so sampling rate is 2 Ms/s.
    -- -------------------------------------------------------------

    if ADHS_CLK_divider = cADHS_EN_COUNT and ADHS1_DAV = '1' then
      D1_EN <= '1';
    else
      D1_EN <= '0';
    end if;

    if ADHS_CLK_divider = cADHS_EN_COUNT and ADHS2_DAV = '1' then
      D2_EN <= '1';
    else
      D2_EN <= '0';
    end if;

    -- -------------------------------------------------------------
    -- Synchronize Cal_On to clk
    -- -------------------------------------------------------------
    SCAL_ON    <= Cal_On;
    SCAL_ON_M1 <= SCAL_ON;

    -- -------------------------------------------------------------
    -- Sampling state machines
    -- -------------------------------------------------------------
    if clear = '1' then

      -- Synchronous reset

      SAMPLING_STATE1 <= IDLE;
      SAMPLING_STATE2 <= IDLE;

      SAMPLING_COUNTER1 <= (others=>'0');
      SAMPLING_COUNTER2 <= (others=>'0');

      ADHS_READY <= '0';

    else

      -- -----------------------------------------------------------
      -- ADHS1 sampling state machine
      -- -----------------------------------------------------------
      case SAMPLING_STATE1 is

        when IDLE =>

          if SCAL_ON = '0' and SCAL_ON_M1 = '1' then
            SAMPLING_STATE1 <= RUNNING;
          end if;

        when RUNNING =>

          if D1_EN = '1' then

            if SAMPLING_COUNTER1 = cSAMPLING_MAXCOUNT then

              SAMPLING_STATE1 <= DONE;

              ADHS1_D_REG <= ADHS1_D;     -- Store data

            else
              SAMPLING_COUNTER1 <= SAMPLING_COUNTER1 + 1; 
            end if;

          end if;

        when DONE =>
          null;

      end case;

      -- -----------------------------------------------------------
      -- ADHS2 sampling state machine
      -- -----------------------------------------------------------
      case SAMPLING_STATE2 is

        when IDLE =>

          if SCAL_ON = '0' and SCAL_ON_M1 = '1' then
            SAMPLING_STATE2 <= RUNNING;
          end if;

        when RUNNING =>

          if D2_EN = '1' then

            if SAMPLING_COUNTER2 = cSAMPLING_MAXCOUNT then

              SAMPLING_STATE2 <= DONE;

              ADHS2_D_REG <= ADHS2_D;     -- Store data

            else
              SAMPLING_COUNTER2 <= SAMPLING_COUNTER2 + 1; 
            end if;

          end if;

        when DONE =>
          null;

      end case;

      -- -----------------------------------------------------------
      -- ADHS_READY generation
      -- -----------------------------------------------------------
      if SAMPLING_STATE1 = DONE and SAMPLING_STATE2 = DONE then
        ADHS_READY <= '1';
      else
        ADHS_READY <= '0';
      end if;

    end if;

  end if;
end process ADHS_proc;

-- ------------------------------------------------------------------------------------------
-- ADHS control/data register write process
-- ------------------------------------------------------------------------------------------
WR_proc : process(rst, clk)
variable addr : std_logic_vector(7 downto 0);
begin
  	
  if rst='1' then

    ADHS1_H_WR_REG <= (others=>'0');
    ADHS1_L_WR_REG <= (others=>'0');
    ADHS2_H_WR_REG <= (others=>'0');
    ADHS2_L_WR_REG <= (others=>'0');

    ADHS_CNTRL_REG <= (others=>'1');

  elsif rising_edge(clk) then

    addr := '1' & SfrAddr;

    if SfrLoad = '1' then

      if addr = ADHS1_H_ADDR then
        ADHS1_H_WR_REG <= SfrDataOut(5 downto 0);
      end if;

      if addr = ADHS1_L_ADDR then
        ADHS1_L_WR_REG <= SfrDataOut;  
      end if;

      if addr = ADHS2_H_ADDR then
        ADHS2_H_WR_REG <= SfrDataOut(5 downto 0);  
      end if;

      if addr = ADHS2_L_ADDR then
        ADHS2_L_WR_REG <= SfrDataOut;  
      end if;

      if addr = ADHS_CNTRL_ADDR then
        ADHS_CNTRL_REG <= SfrDataOut;  
      end if;

    end if;

  end if;

end process WR_proc;
  	
-- ------------------------------------------------------------------------------------------
-- Output data multiplexer  
-- ------------------------------------------------------------------------------------------
mux : process(SfrAddr, ADHS_CNTRL_REG, ADHS1_D_REG, ADHS2_D_REG) is
variable addr : std_logic_vector(7 downto 0);
begin
    
  addr := '1' & SfrAddr;
    
  case addr is

    when ADHS1_H_ADDR => ADHS_SfrData <= "00" & ADHS1_D_REG(13 downto 8);
    when ADHS1_L_ADDR => ADHS_SfrData <= ADHS1_D_REG(7 downto 0);
    when ADHS2_H_ADDR => ADHS_SfrData <= "00" & ADHS2_D_REG(13 downto 8);
    when ADHS2_L_ADDR => ADHS_SfrData <= ADHS2_D_REG(7 downto 0);

    when ADHS_CNTRL_ADDR => ADHS_SfrData <= ADHS_CNTRL_REG;

    when others => ADHS_SfrData <= (others =>'0');

  end case;

end process mux;

-- ------------------------------------------------------------------------------------------
-- Output signal assignments  
-- ------------------------------------------------------------------------------------------
ADHS1_CLK <= ADHS_CLK;
ADHS2_CLK <= ADHS_CLK;

ADHS1_A <= ADHS_A;
ADHS2_A <= ADHS_A;

ADHS1_CS_n <= ADHS_CS_n;
ADHS2_CS_n <= ADHS_CS_n;
	
ADHS1_OE_n <= ADHS_OE_n;
ADHS2_OE_n <= ADHS_OE_n;
	
ADHS1_WR_n <= ADHS_WR_n;
ADHS2_WR_n <= ADHS_WR_n;

ADHS1_D <= (ADHS1_H_WR_REG & ADHS1_L_WR_REG) when cADHS_WRITEABLE and ADHS_OE_n = '1' and ADHS_D_OE_n = '0'
           else (others => 'Z');
	
ADHS2_D <= (ADHS2_H_WR_REG & ADHS2_L_WR_REG) when cADHS_WRITEABLE and ADHS_OE_n = '1' and ADHS_D_OE_n = '0'
           else (others => 'Z');
	
ADHS1_ST_CAL <= not ADHS_ST_CAL_n;
ADHS2_ST_CAL <= not ADHS_ST_CAL_n;

end architecture rtl;
