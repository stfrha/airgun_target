-- ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
--
-- VHDL SOURCE FILE inoutmux.vhd
--
-- Multiplexers etc. for CCU/ADP input/output functionality
--
-- $Id: inoutmux.vhd,v 1.4 2005/11/15 15:01:37 lra Exp $
-- $Log: inoutmux.vhd,v $
-- Revision 1.4  2005/11/15 15:01:37  lra
-- Added condition in NOTCH_FILTER_n assignment so that the filter is
-- switched out when DCU mode is selected.
-- Some other minor cleanup.
--
-- Revision 1.3  2005/04/28 12:21:13  lra
-- Changed SPARE_OUT1 signal to NOTCH_FILTER_N
--
-- Revision 1.2  2005/02/15 14:10:24  lra
-- Added DCU output signal
--
-- Revision 1.1  2005/02/11 14:11:33  lra
-- New project directory structure created
--
-- Revision 1.14  2005/02/11 14:00:07  lra
-- Cleaned up signal names
--
-- Revision 1.13  2004/08/20 15:51:40  lra
-- Added FLASH4_n input
--
-- Revision 1.12  2004/04/26 14:29:20  lra
-- Added RxREG_RDY input
--
-- Revision 1.11  2004/03/25 12:52:36  lra
-- Output chksum_clear_n renamed to crc_clear_n
--
-- Revision 1.10  2004/03/18 16:58:18  lra
-- Moved some output bits from P0 to ADHS_CNTRL_REG.
-- Rearranged the bits in P0.
--
-- Revision 1.9  2004/03/01 18:32:05  lra
-- Removed port signals CCU_OE_n and ADP_OE_n.
-- CCU/ADP mode is now selected through the cADC constant
-- in config_package.
-- In ADP mode, some output port bits are now inverted in order
-- to  automatically obtain the correct default state.
--
-- Revision 1.8  2003/10/31 19:53:10  lra
-- Added FLASH_WP_n input signal
--
-- Revision 1.7  2003/10/28 18:12:53  lra
-- Changed LO_LOCKED to LO_LOCKED_n to reflect actual behavior of the lock signal from the
-- DCU
--
-- Revision 1.6  2003/08/29 14:10:58  lra
-- Moved som more logic into this block. Rearranged the code for better readability.
-- Moved the (so far unused) inputs SPARE_IN1 and SPARE_IN2 from P0 to P1.
-- Moved the chksum_clear_n bit from P1 to P0.
-- Added the crc_err input.
-- FIXED BUG: Cal_On was not correctly gated with UPLINK_FAIL.
--
-- Revision 1.5  2003/08/25 11:09:29  lra
-- Added chksum_clear_n output
--
-- Revision 1.4  2003/04/17 15:10:43  lra
-- Changed SPARE_OUT2 signal into VIDEO_DISABLE.
--
-- Revision 1.3  2003/04/04 17:09:30  lra
-- Major cleanup and simplification of code. Please see old-style history log in file header
-- for details. Use CVS log messages for revision history from now on.
--
-- ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
--
-- Pre-CVS-log history. Do not use for future revisions.
--
-- Version  Date        Who                     What
-- 1        03-02-07    LRA/Lars Albihn         First Version
-- 2        03-02-09    LRA                     Updated with more signals
-- 3        03-03-11    LRA                     Moved some more logic into this
--                                              block for clarity.
-- 4        03-03-13    LRA                     Changed to CVS style history log.
--  
-- ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

-- ------------------------------------------------------------------------------------------
-- Library declarations
-- ------------------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;

use work.config_package.all;

-- ------------------------------------------------------------------------------------------
-- Entity declaration
-- ------------------------------------------------------------------------------------------
entity inoutmux is
port
(
    -- ------------------------------------------------------------------------------------
    -- CPU ports
    -- ------------------------------------------------------------------------------------
    P0Out             : in std_logic_vector(7 downto 0);
    P1Out             : in std_logic_vector(7 downto 0);
    P3Out             : in std_logic_vector(7 downto 0);

    P0In              : out std_logic_vector(7 downto 0);
    P1In              : out std_logic_vector(7 downto 0);
    P2In              : out std_logic_vector(7 downto 0);
    P3In              : out std_logic_vector(7 downto 0);

    SMod              : in std_logic;     -- Controls Cal_On in ADP mode 

    -- ------------------------------------------------------------------------------------
    -- ColdLink signals
    -- ------------------------------------------------------------------------------------
    DOUT              : in std_logic_vector(7 downto 0);  -- Receiver extender bits out
    DIN               : out std_logic_vector(7 downto 0); -- Transmitter extender bits in

    UPLINK_FAIL       : in std_logic;                     -- Status signal from receiver

    -- ------------------------------------------------------------------------------------
    -- FPGA-internal control signals
    -- ------------------------------------------------------------------------------------
    HSSP_RxACK_n      : out std_logic;    -- Clears HSSP receiver
    UART_RxACK_n      : out std_logic;    -- Clears UART receiver
	crc_clear_n       : out std_logic;    -- Clears CRC register
    timer_reset       : out std_logic;    -- Resets the MSG_TIMEOUT timer

    HSSP_TxBUSY       : in std_logic;     -- HSSP transmitter busy signal

    UART_TxBUSY       : in std_logic;     -- UART transmitter busy signal
    UART_RxREADY      : in std_logic;     -- UART receiver ready signal
                                          -- (for polled reception, e.g. in ROM monitor
                                          -- program)

    crc_err           : in std_logic;     -- Indicates CRC error
    FLASH_WP_n        : in std_logic;     -- FLASH write protection status

    Cal_On            : out std_logic;    -- ADHS sampling strobe

    DCU               : out std_logic;    -- DCU mode flag

    -- ------------------------------------------------------------------------------------
    -- FPGA-external inputs/outputs
    -- ------------------------------------------------------------------------------------
    EXTWD_KILLER      : out std_logic;    -- Watchdog retrig signal

    ADHS1_END_CAL     : in std_logic;     -- ADHS1 end of calibration
    ADHS2_END_CAL     : in std_logic;     -- ADHS2 end of calibration

    FLASH_P           : out std_logic_vector(5 downto 0);  -- FLASH page select signals

    FLASH4_n          : in std_logic;     -- Indicates on-board FLASH organization
                                          -- '0' = 4 x  4 Mbit FLASH
                                          -- '1' = 1 x 16 Mbit FLASH

    -- ------------------------------------------------------------------------------------
    -- CCU-external inputs/outputs
    -- ------------------------------------------------------------------------------------
    RFU0              : inout std_logic;    -- Output in CCU, input in ADP
    RFU1              : inout std_logic;    -- Output in CCU, input in ADP
    RFU2              : inout std_logic;    -- Output in CCU, input in ADP

    DCU0              : inout std_logic;    -- Output in CCU, input in ADP
    DCU1              : inout std_logic;    -- Output in CCU, input in ADP
    DCU2              : inout std_logic;    -- Output in CCU, input in ADP

    VIDEO_DISABLE_N   : inout std_logic;    -- Output in CCU, input in ADP
    NOTCH_FILTER_N    : inout std_logic;    -- Output in CCU, input in ADP
    VIDEO_DISABLE     : inout std_logic;    -- Output in CCU, input in ADP
    SPARE_OUT3        : inout std_logic;    -- Output in CCU, input in ADP

    LO_LOCKED_n       : inout std_logic;    -- Input in CCU, output in ADP
    PWR_GOOD          : inout std_logic;    -- Input in CCU, output in ADP
    SPARE_IN1         : inout std_logic;    -- Input in CCU, output in ADP
    SPARE_IN2         : inout std_logic     -- Input in CCU, output in ADP
);

end entity inoutmux;

-- ------------------------------------------------------------------------------------------
-- Architecture definition
-- ------------------------------------------------------------------------------------------
architecture rtl of inoutmux is

-- ------------------------------------------------------------------------------------------
-- constant declarations
-- ------------------------------------------------------------------------------------------
constant UPLINK_EXTBITS_DEFAULT : std_logic_vector(7 downto 0) := "01100111";
constant OUTPUT_BITS_DEFAULT    : std_logic_vector(7 downto 0) := "00000011";

-- ------------------------------------------------------------------------------------------
-- Signal declarations
-- ------------------------------------------------------------------------------------------
signal UPLINK_EXTBITS   : std_logic_vector(7 downto 0); -- CCU UPLINK extender bits
signal DOWNLINK_EXTBITS : std_logic_vector(7 downto 0); -- CCU DOWNLINK extender bits

signal CCU_RDY_n : std_logic;     -- CCU DOWNLINK extender bit
signal STM       : std_logic;     -- CCU DOWNLINK extender bit

-- ------------------------------------------------------------------------------------------
-- Begin architecture
-- ------------------------------------------------------------------------------------------
begin
    
-- ------------------------------------------------------------------------------------------
-- Set CCU UPLINK extender bits to default if receiver not locked
-- ------------------------------------------------------------------------------------------
UPLINK_EXTBITS <= UPLINK_EXTBITS_DEFAULT when UPLINK_FAIL='1'
                  else DOUT;

-- ------------------------------------------------------------------------------------------
-- CCU mode external output signal assignments
-- ------------------------------------------------------------------------------------------
RFU0 <= UPLINK_EXTBITS(0) when not cADP else 'Z';
RFU1 <= UPLINK_EXTBITS(1) when not cADP else 'Z';
RFU2 <= UPLINK_EXTBITS(2) when not cADP else 'Z';

DCU0 <= UPLINK_EXTBITS(4) when not cADP else 'Z';
DCU1 <= UPLINK_EXTBITS(5) when not cADP else 'Z';
DCU2 <= UPLINK_EXTBITS(6) when not cADP else 'Z';

-- ------------------------------------------------------------------------------------------
-- Cal_on control multiplexer
-- ------------------------------------------------------------------------------------------
Cal_On <= SMod when cADP else UPLINK_EXTBITS(3);

-- ------------------------------------------------------------------------------------------
-- DCU mode flag
-- ------------------------------------------------------------------------------------------
DCU <= '1' when not cADP and UPLINK_EXTBITS(1 downto 0)="00" else '0';

-- ------------------------------------------------------------------------------------------
-- CCU DOWNLINK extender bits mapping
-- ------------------------------------------------------------------------------------------
DOWNLINK_EXTBITS(0) <= CCU_RDY_n;
DOWNLINK_EXTBITS(1) <= LO_LOCKED_n;
DOWNLINK_EXTBITS(2) <= UPLINK_FAIL;
DOWNLINK_EXTBITS(3) <= STM;
DOWNLINK_EXTBITS(4) <= '0';
DOWNLINK_EXTBITS(5) <= PWR_GOOD;
DOWNLINK_EXTBITS(6) <= '0';
DOWNLINK_EXTBITS(7) <= '0';

-- ------------------------------------------------------------------------------------------
-- Port P0 output mapping
--
-- These port pins are used for general bit-based output functions, common to CCU and ADP.
-- ------------------------------------------------------------------------------------------  
HSSP_RxACK_n    <= P0Out(0);
UART_RxACK_n    <= P0Out(1);
crc_clear_n     <= P0Out(2);
timer_reset     <= P0Out(3);
EXTWD_KILLER    <= P0Out(4);

-- P0Out(5) is spare
-- P0Out(6) is spare
-- P0Out(7) is spare

-- ------------------------------------------------------------------------------------------
-- Port P0 input mapping
--
-- These port pins are used for general bit-based input functions, common to CCU and ADP.
-- ------------------------------------------------------------------------------------------
P0In(0)         <= HSSP_TxBUSY;
P0In(1)         <= UART_TxBUSY;
P0In(2)         <= crc_err;
P0In(3)         <= FLASH_WP_n;
P0In(4)         <= UPLINK_FAIL;
P0In(5)         <= ADHS1_END_CAL;
P0In(6)         <= ADHS2_END_CAL;
P0In(7)         <= UART_RxREADY;

-- ------------------------------------------------------------------------------------------
-- Port P1 output mapping
--
-- These port pins are used for bit- or byte-based output functions,
-- which may differ between CCU and ADP.
-- ------------------------------------------------------------------------------------------

-- CCU mode

VIDEO_DISABLE_N <= P1Out(0)       when not cADP else 'Z';
VIDEO_DISABLE   <= not(P1Out(0))  when not cADP else 'Z';

NOTCH_FILTER_N  <= ( P1Out(1) or ( not(UPLINK_EXTBITS(1)) and not(UPLINK_EXTBITS(0)) ) )
                   when not cADP else 'Z';

-- P1Out(2) is spare

SPARE_OUT3      <= P1Out(3)       when not cADP else 'Z';
CCU_RDY_n       <= P1Out(4);
STM             <= not(P1Out(5));

-- P1Out(6) is spare
-- P1Out(7) is spare

-- ADP mode

LO_LOCKED_n     <= (P1Out(0) xnor OUTPUT_BITS_DEFAULT(0)) when cADP else 'Z';
PWR_GOOD        <= (P1Out(1) xnor OUTPUT_BITS_DEFAULT(1)) when cADP else 'Z';
SPARE_IN1       <= (P1Out(2) xnor OUTPUT_BITS_DEFAULT(2)) when cADP else 'Z';
SPARE_IN2       <= (P1Out(3) xnor OUTPUT_BITS_DEFAULT(3)) when cADP else 'Z';

-- P1Out(4) is spare
-- P1Out(5) is spare
-- P1Out(6) is spare
-- P1Out(7) is spare

-- ------------------------------------------------------------------------------------------
-- Port P1 input mapping
--
-- These port pins are used for bit- or byte-based input functions,
-- which may differ between CCU and ADP.
-- ------------------------------------------------------------------------------------------

--         ADP mode                               CCU mode
--         --------                               --------

P1In(0) <= VIDEO_DISABLE_N when cADP        else SPARE_IN1;
P1In(1) <= NOTCH_FILTER_N  when cADP        else SPARE_IN2;
P1In(2) <= VIDEO_DISABLE;                                     -- spare in CCU
P1In(3) <= SPARE_OUT3;                                        -- spare in CCU
P1In(4) <=                        '0';                        -- spare in CCU/ADP 
P1In(5) <=                        '0';                        -- spare in CCU/ADP 
P1In(6) <=                        '0';                        -- spare in CCU/ADP 
P1In(7) <=                        '0';                        -- spare in CCU/ADP 

-- ------------------------------------------------------------------------------------------
-- Port P2 output mapping
--
-- This port is reserved for PDATA page adressing, and can not be used for other purposes.
-- ------------------------------------------------------------------------------------------

-- ------------------------------------------------------------------------------------------
-- Port P2 input mapping
--
-- These port pins are used for bit- or byte-based input functions,
-- which may differ between CCU and ADP.
-- ------------------------------------------------------------------------------------------

--         ADP mode                               CCU mode
--         --------                               --------

P2In(0) <= RFU0;                                              -- spare in CCU 
P2In(1) <= RFU1;                                              -- spare in CCU 
P2In(2) <= RFU2;                                              -- spare in CCU 
P2In(3) <=                        '0';                        -- spare in CCU/ADP 
P2In(4) <= DCU0;                                              -- spare in CCU 
P2In(5) <= DCU1;                                              -- spare in CCU 
P2In(6) <= DCU2;                                              -- spare in CCU 
P2In(7) <=                        '0';                        -- spare in CCU/ADP 

-- ------------------------------------------------------------------------------------------
-- Port P3 output mapping
--
-- These port pins are used for bit-based or byte-based output functions,
-- which may differ between CCU and ADP.
-- ------------------------------------------------------------------------------------------

-- CCU mode

FLASH_P         <= P3Out(5 downto 0);

-- P3Out(6) is reserved
-- P3Out(7) is reserved

-- ADP mode

DIN             <= (P3Out xnor UPLINK_EXTBITS_DEFAULT) when cADP else DOWNLINK_EXTBITS;

-- ------------------------------------------------------------------------------------------
-- Port P3 input mapping
--
-- These port pins are used for bit- or byte-based input functions,
-- which may differ between CCU and ADP.
-- ------------------------------------------------------------------------------------------

--         ADP mode                               CCU mode
--         --------                               --------

P3In(0) <= DOUT(0) when CADP                 else FLASH4_n;
P3In(1) <= DOUT(1);                                              -- spare in CCU
P3In(2) <= DOUT(2);                                              -- spare in CCU
P3In(3) <= DOUT(3);                                              -- spare in CCU
P3In(4) <= DOUT(4);                                              -- spare in CCU
P3In(5) <= DOUT(5);                                              -- spare in CCU
P3In(6) <= DOUT(6);                                              -- spare in CCU
P3In(7) <= DOUT(7);                                              -- spare in CCU

end architecture rtl;
