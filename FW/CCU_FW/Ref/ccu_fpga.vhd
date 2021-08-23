-- ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
--
-- VHDL SOURCE FILE ccu_fpga.vhd
--
-- CCU board FPGA. Top entity.
--
-- $Id: ccu_fpga.vhd,v 1.5 2005/04/28 12:21:13 lra Exp $
-- $Log: ccu_fpga.vhd,v $
-- Revision 1.5  2005/04/28 12:21:13  lra
-- Changed SPARE_OUT1 signal to NOTCH_FILTER_N
--
-- Revision 1.4  2005/04/19 11:41:46  lra
-- Minor modification due to change in UART bit rate generic definition.
-- Some minor cleanup.
--
-- Revision 1.3  2005/04/15 11:31:55  lra
-- Modifications due to changes in UART and HSSP block interfaces
--
-- Revision 1.2  2005/02/15 14:14:28  lra
-- Removed sfr_decode block.
-- Added DCU mode DAC registers, replaced all the DAC blocks
-- with a single dacs block.
--
-- Revision 1.1  2005/02/11 14:09:38  lra
-- Import to CVS, new design file. Replaces top level schematic.
--
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

library unisim;
use unisim.VCOMPONENTS.all;

use work.config_package.all;

-- ------------------------------------------------------------------------------------------
-- Entity declaration
-- ------------------------------------------------------------------------------------------
entity ccu_fpga is
    port(

        CLK4X1          : in std_logic;

        ADHS1_CLK       : out std_logic;
        ADHS1_A         : out std_logic_vector(1 downto 0);
        ADHS1_CS_n      : out std_logic;
        ADHS1_OE_n      : out std_logic;
        ADHS1_WR_n      : out std_logic;
        ADHS1_D         : inout std_logic_vector(13 downto 0);
        ADHS1_DAV       : in std_logic;
        ADHS1_ST_CAL    : out std_logic;
        ADHS1_END_CAL   : in std_logic;

        ADHS2_CLK       : out std_logic;
        ADHS2_A         : out std_logic_vector(1 downto 0);
        ADHS2_CS_n      : out std_logic;
        ADHS2_OE_n      : out std_logic;
        ADHS2_WR_n      : out std_logic;
        ADHS2_D         : inout std_logic_vector(13 downto 0);
        ADHS2_DAV       : in std_logic;
        ADHS2_ST_CAL    : out std_logic;
        ADHS2_END_CAL   : in std_logic;

        AD1_SD          : out std_logic;
        AD2_SD          : out std_logic;
        AD1_COMP        : in std_logic;
        AD2_COMP        : in std_logic;

        CCU_DA1         : out std_logic;
        CCU_DA2         : out std_logic;
        CCU_DA3         : out std_logic;
        CCU_DA4         : out std_logic;

        FLASH_A         : out std_logic_vector(20 downto 0);
        FLASH_CE_n      : out std_logic;
        FLASH4_CE_n     : out std_logic_vector(3 downto 0);
        FLASH_OE_n      : out std_logic;
        FLASH_WE_n      : out std_logic;
        FLASH_D         : inout std_logic_vector(7 downto 0);
        FLASH_WP_n      : out std_logic;
        FLASH_CE1_n     : out std_logic;
        FLASH_RP_n      : out std_logic;
        FLASH_BYTE_n    : out std_logic;
        FLASH4_n        : in std_logic;

        SEROUT          : out std_logic;
        SERIN           : in std_logic;

        RxD             : in std_logic;
        TxD             : out std_logic;

        RFU0            : inout std_logic;
        RFU1            : inout std_logic;
        RFU2            : inout std_logic;
        DCU0            : inout std_logic;
        DCU1            : inout std_logic;
        DCU2            : inout std_logic;
        VIDEO_DISABLE_N : inout std_logic;
        NOTCH_FILTER_N  : inout std_logic;
        VIDEO_DISABLE   : inout std_logic;
        SPARE_OUT3      : inout std_logic;
        LO_LOCKED_n     : inout std_logic;
        PWR_GOOD        : inout std_logic;
        SPARE_IN1       : inout std_logic;
        SPARE_IN2       : inout std_logic;

        EXTWD_KILLER    : out std_logic;

        TPA_D14         : out std_logic;
        TPA_D15         : out std_logic

    );
end entity ccu_fpga;

-- ------------------------------------------------------------------------------------------
-- Architecture definition
-- ------------------------------------------------------------------------------------------
architecture struct of ccu_fpga is

-- ------------------------------------------------------------------------------------------
-- Component declarations
-- ------------------------------------------------------------------------------------------
component ip
port(
    rst         : in std_logic;
    clk         : in std_logic;
    MemAddr     : out std_logic_vector(15 downto 0);
    DataToMem   : out std_logic_vector(7 downto 0);
    DataFromMem : in std_logic_vector(7 downto 0);
    Psen        : out std_logic;
    WriteStrobe : out std_logic;
    ReadStrobe  : out std_logic;
    DataDir     : out std_logic;
    SfrAddr     : out std_logic_vector(6 downto 0);
    SfrDataOut  : out std_logic_vector(7 downto 0);
    SfrDataIn   : in std_logic_vector(7 downto 0);
    SfrLoad     : out std_logic;
    P0Out       : out std_logic_vector(7 downto 0);
    P1Out       : out std_logic_vector(7 downto 0);
    P2Out       : out std_logic_vector(7 downto 0);
    P3Out       : out std_logic_vector(7 downto 0);
    P0In        : in std_logic_vector(7 downto 0);
    P1In        : in std_logic_vector(7 downto 0);
    P2In        : in std_logic_vector(7 downto 0);
    P3In        : in std_logic_vector(7 downto 0);
    P0Dir       : out std_logic_vector(7 downto 0);
    P1Dir       : out std_logic_vector(7 downto 0);
    P2Dir       : out std_logic_vector(7 downto 0);
    P3Dir       : out std_logic_vector(7 downto 0);
    Interrupt0  : in std_logic;
    Interrupt1  : in std_logic;
    Interrupt2  : in std_logic;
    Interrupt3  : in std_logic;
    Interrupt4  : in std_logic;
    Interrupt5  : in std_logic;
    ClrIrq2     : out std_logic;
    ClrIrq3     : out std_logic;
    SMod        : out std_logic;
    BusMonCtrl  : out std_logic_vector(3 downto 0);
    Load_IR     : out std_logic;
    PowerDown   : out std_logic
);
end component ip;

-- ------------------------------------------------------------------------------------------
-- Constant declarations
-- ------------------------------------------------------------------------------------------
constant P : positive := 174;          -- To get 115200 bits/s
                                       -- UART bit rate

constant FSTMMSB    : positive := 4;   -- MSB in ADC sFSTM_COUNTER
constant cFstmConst : positive := 18;  -- ADC Low Pass Filter settle time constant

constant UART_ADDR  : std_logic_vector(7 downto 0) := x"99"; -- Original 805x SBUF sfr location
constant HSSP_ADDR  : std_logic_vector(7 downto 0) := x"f1";
constant ADC1_ADDR  : std_logic_vector(7 downto 0) := x"f2";
constant ADC2_ADDR  : std_logic_vector(7 downto 0) := x"f3";

-- ------------------------------------------------------------------------------------------
-- Signal declarations
-- ------------------------------------------------------------------------------------------
signal roc_net         : std_logic;
signal clk8x           : std_logic;
signal clk16x          : std_logic;
signal locked8x        : std_logic;
signal locked16x       : std_logic;
signal rst8x           : std_logic;
signal rst16x          : std_logic;
signal wclk_net        : std_logic;

signal MemAddr         : std_logic_vector(15 downto 0);
signal DataToMem       : std_logic_vector(7 downto 0);
signal DataFromMem     : std_logic_vector(7 downto 0);
signal Psen            : std_logic;
signal WriteStrobe     : std_logic;
signal ReadStrobe      : std_logic;
signal DataDir         : std_logic;
signal SfrAddr         : std_logic_vector(6 downto 0);
signal SfrDataOut      : std_logic_vector(7 downto 0);
signal SfrDataIn       : std_logic_vector(7 downto 0);
signal SfrLoad         : std_logic;
signal P0Out           : std_logic_vector(7 downto 0);
signal P1Out           : std_logic_vector(7 downto 0);
signal P3Out           : std_logic_vector(7 downto 0);
signal P0In            : std_logic_vector(7 downto 0);
signal P1In            : std_logic_vector(7 downto 0);
signal P2In            : std_logic_vector(7 downto 0);
signal P3In            : std_logic_vector(7 downto 0);
signal P0Dir           : std_logic_vector(7 downto 0);
signal P1Dir           : std_logic_vector(7 downto 0);
signal P2Dir           : std_logic_vector(7 downto 0);
signal P3Dir           : std_logic_vector(7 downto 0);
signal SMod            : std_logic;

signal crc_clear_n     : std_logic;
signal crc_err         : std_logic;

signal iFLASH_WP_n     : std_logic;

signal UART_SfrLoad    : std_logic;
signal UART_TxBUSY     : std_logic;
signal UART_RxDATA     : std_logic_vector(7 downto 0);
signal UART_RxREADY    : std_logic;
signal UART_RxACK_n    : std_logic;

signal HSSP_SfrLoad    : std_logic;
signal HSSP_TxBUSY     : std_logic;
signal HSSP_RxDATA     : std_logic_vector(7 downto 0);
signal HSSP_RxREADY    : std_logic;
signal HSSP_RxACK_n    : std_logic;
signal DIN             : std_logic_vector(7 downto 0);
signal DOUT            : std_logic_vector(7 downto 0);
signal UPLINK_FAIL     : std_logic;

signal Cal_On          : std_logic;
signal ADHS_SfrData    : std_logic_vector(7 downto 0);
signal ADHS_READY      : std_logic;

signal AgtR1           : std_logic;
signal AgtR2           : std_logic;
signal ADC1out         : std_logic_vector(7 downto 0);
signal ADC2out         : std_logic_vector(7 downto 0);
signal ADC_READY_n     : std_logic;

signal DAC_SfrData     : std_logic_vector(7 downto 0);
signal DCU             : std_logic;

signal timer_reset     : std_logic;
signal message_timeout : std_logic;

signal FLASH_P         : std_logic_vector(5 downto 0);

signal UART_SfrData    : std_logic_vector(7 downto 0);
signal HSSP_SfrData    : std_logic_vector(7 downto 0);
signal ADC1_SfrData    : std_logic_vector(7 downto 0);
signal ADC2_SfrData    : std_logic_vector(7 downto 0);

-- ------------------------------------------------------------------------------------------
-- Begin architecture
-- ------------------------------------------------------------------------------------------
begin
    
-- ------------------------------------------------------------------------------------------
-- Instantiate ROC (reset-on-configuration) component.
-- NOTE: This component is useful for pre-route simulation, but it is also essential for
-- ensuring that start-up states for FFs are not lost during synthesis.
-- ------------------------------------------------------------------------------------------
ROC1 : ROC
port map(
    O => roc_net
);

-- ------------------------------------------------------------------------------------------
-- Instantiate DLL4X block
-- ------------------------------------------------------------------------------------------
DLL4X1 : entity work.DLL4X
port map(
    CLK4X1    => CLK4X1,
    clk8x     => clk8x,
    clk16x    => clk16x,
    locked8x  => locked8x,
    locked16x => locked16x
);

-- ------------------------------------------------------------------------------------------
-- Instantiate reset_gen block
-- ------------------------------------------------------------------------------------------
reset_gen1 : entity work.reset_gen
port map(
    roc_net   => roc_net,
    clk8x     => clk8x,
    clk16x    => clk16x,
    locked8x  => locked8x,
    locked16x => locked16x,
    rst8x     => rst8x,
    rst16x    => rst16x
);

-- ------------------------------------------------------------------------------------------
-- Instantiate memclkgen block
-- ------------------------------------------------------------------------------------------
memclkgen1 : entity work.memclkgen
port map(
    rst8x    => rst8x,
    clk8x    => clk8x,
    wclk_net => wclk_net
);

-- ------------------------------------------------------------------------------------------
-- Instantiate Flip805x-PR CPU ip module
-- ------------------------------------------------------------------------------------------
ip1 : ip
port map(
    rst         => roc_net,
    clk         => wclk_net,
    MemAddr     => MemAddr,
    DataToMem   => DataToMem,
    DataFromMem => DataFromMem,
    Psen        => Psen,
    WriteStrobe => WriteStrobe,
    ReadStrobe  => ReadStrobe,
    DataDir     => DataDir,
    SfrAddr     => SfrAddr,
    SfrDataOut  => SfrDataOut,
    SfrDataIn   => SfrDataIn,
    SfrLoad     => SfrLoad,
    P0Out       => P0Out,
    P1Out       => P1Out,
    P2Out       => open,  -- NOTE: Used for PDATA adressing. Do not connect.
    P3Out       => P3Out,
    P0In        => P0In,
    P1In        => P1In,
    P2In        => P2In,
    P3In        => P3In,
    P0Dir       => P0Dir,
    P1Dir       => P1Dir,
    P2Dir       => P2Dir,
    P3Dir       => P3Dir,
    Interrupt0  => ADC_READY_n,
    Interrupt1  => '1',
    Interrupt2  => HSSP_RxREADY,
    Interrupt3  => ADHS_READY,
    Interrupt4  => UART_RxREADY,
    Interrupt5  => message_timeout,
    ClrIrq2     => open,
    ClrIrq3     => open,
    SMod        => SMod,
    BusMonCtrl  => open,
    Load_IR     => open,
    PowerDown   => open
);

-- ------------------------------------------------------------------------------------------
-- Instantiate memory block
-- ------------------------------------------------------------------------------------------
memory1 : entity work.memory
port map(
    rst         => roc_net,
    clk         => wclk_net,
    MemAddr     => MemAddr,
    DataToMem   => DataToMem,
    DataFromMem => DataFromMem,
    Psen        => Psen,
    WriteStrobe => WriteStrobe,
    ReadStrobe  => ReadStrobe,
    DataDir     => DataDir,
    FLASH_P     => FLASH_P,
    FLASH_A     => FLASH_A,
    FLASH_CE_n  => FLASH_CE_n,
    FLASH4_CE_n => FLASH4_CE_n,
    FLASH_OE_n  => FLASH_OE_n,
    FLASH_D     => FLASH_D
);

-- ------------------------------------------------------------------------------------------
-- Instantiate crc block
-- ------------------------------------------------------------------------------------------
crc1 : entity work.crc
port map(
    rst         => roc_net,
    clk         => wclk_net,
    crc_clear_n => crc_clear_n,
    DataToMem   => DataToMem,
    WriteStrobe => WriteStrobe,
    ReadStrobe  => ReadStrobe,
    DataDir     => DataDir,
    FLASH_D     => FLASH_D,
    crc_err     => crc_err
);

-- ------------------------------------------------------------------------------------------
-- Instantiate flash_protect block
-- ------------------------------------------------------------------------------------------
flash_protect1 : entity work.flash_protect
port map(
    rst         => roc_net,
    clk         => wclk_net,
    SfrAddr     => SfrAddr,
    SfrDataOut  => SfrDataOut,
    SfrLoad     => SfrLoad,
    MemAddr     => MemAddr,
    WriteStrobe => WriteStrobe,
    FLASH_WE_n  => FLASH_WE_n,
    FLASH_WP_n  => iFLASH_WP_n
);

-- ------------------------------------------------------------------------------------------
-- Instantiate UART block
-- ------------------------------------------------------------------------------------------
UART1 : entity work.UART
generic map(
    P => P
)
port map(
    CLK       => wclk_net,
    RESET     => roc_net,
    SRESET    => '0',
    TxDATA    => SfrDataOut,
    TxLOAD    => UART_SfrLoad,
    TxBUSY    => UART_TxBUSY,
    TxD       => TxD,
    RxD       => RxD,
    RxDATA    => UART_RxDATA,
    RxREG_RDY => UART_RxREADY,
    RxACK_n   => UART_RxACK_n
);

-- ------------------------------------------------------------------------------------------
-- Instantiate HSSP block
-- ------------------------------------------------------------------------------------------
HSSP1 : entity work.HSSP
generic map(
    CLK_Tx_DIV_EXPONENT => 1 -- CLK_Tx runs at 2x bitrate
)
port map(
    CLK_Tx               => wclk_net,
    RST_Tx               => roc_net,
    SRST_Tx              => '0',
    CLK_16X              => clk16x,
    RST_16X_1            => rst16x,
    RST_16X_2            => roc_net,
    SRST_16X             => '0',
    CLK_CPU              => wclk_net,
    RST_CPU              => roc_net,
    SRST_CPU             => '0',
    DATA_BUS             => SfrDataOut,
    WRITE_ENABLE         => HSSP_SfrLoad,
    BUSY                 => HSSP_TxBUSY,
    DIN                  => DIN,
    SEROUT               => SEROUT,
    CLKEN_1X_TRANSMITTER => open,
    TxDATA_EN            => open,
    SERIN                => SERIN,
    DOUT                 => DOUT,
    CLKEN_1X_RECEIVER    => open,
    RxDATA_EN            => open,
    CPU_DATA_BUS         => HSSP_RxDATA,
    READY                => HSSP_RxREADY,
    CLEAR_n              => HSSP_RxACK_n,
    RxFAIL               => UPLINK_FAIL,
    SCAN_TP              => open,
    MAYBE_TP             => open,
    OK_TP                => open,
    HESITATE_TP          => open,
    EYE_TP               => TPA_D15
);

-- ------------------------------------------------------------------------------------------
-- Instantiate ADHS block
-- ------------------------------------------------------------------------------------------
ADHS1 : entity work.ADHS
port map(
    rst          => roc_net,
    clk          => wclk_net,
    SfrAddr      => SfrAddr,
    SfrDataOut   => SfrDataOut,
    ADHS_SfrData => ADHS_SfrData,
    SfrLoad      => SfrLoad,
    Cal_On       => Cal_On,
    ADHS_READY   => ADHS_READY,
    ADHS1_CLK    => ADHS1_CLK,
    ADHS1_A      => ADHS1_A,
    ADHS1_CS_n   => ADHS1_CS_n,
    ADHS1_OE_n   => ADHS1_OE_n,
    ADHS1_WR_n   => ADHS1_WR_n,
    ADHS1_D      => ADHS1_D,
    ADHS1_DAV    => ADHS1_DAV,
    ADHS1_ST_CAL => ADHS1_ST_CAL,
    ADHS2_CLK    => ADHS2_CLK,
    ADHS2_A      => ADHS2_A,
    ADHS2_CS_n   => ADHS2_CS_n,
    ADHS2_OE_n   => ADHS2_OE_n,
    ADHS2_WR_n   => ADHS2_WR_n,
    ADHS2_D      => ADHS2_D,
    ADHS2_DAV    => ADHS2_DAV,
    ADHS2_ST_CAL => ADHS2_ST_CAL
);

-- ------------------------------------------------------------------------------------------
-- Instantiate ADC blocks
-- ------------------------------------------------------------------------------------------
ADC1 : entity work.ADC
generic map(
    FSTMMSB    => FSTMMSB,
    cFstmConst => cFstmConst
)
port map(
    reset      => rst8x,
    clk        => clk8x,
    DACout     => AD1_SD,
    AgtR       => AgtR1,
    ADCout     => ADC1out,
    Sample     => ADC_READY_n,
    ADCsampled => open,
    DACIn      => open
);

ADC2 : entity work.ADC
generic map(
    FSTMMSB    => FSTMMSB,
    cFstmConst => cFstmConst
)
port map(
    reset      => rst8x,
    clk        => clk8x,
    DACout     => AD2_SD,
    AgtR       => AgtR2,
    ADCout     => ADC2out,
    Sample     => open,
    ADCsampled => open,
    DACIn      => open
);

-- ------------------------------------------------------------------------------------------
-- Instantiate dacs block
-- ------------------------------------------------------------------------------------------
dacs1 : entity work.dacs
port map(

    rst         => roc_net,
    clk         => wclk_net,

    rst8x       => rst8x,
    clk8x       => clk8x,

    P0Dir       => P0Dir,
    P1Dir       => P1Dir,
    P2Dir       => P2Dir,
    P3Dir       => P3Dir,

    SfrAddr     => SfrAddr,
    SfrDataOut  => SfrDataOut,
    SfrLoad     => SfrLoad,

    DAC_SfrData => DAC_SfrData,

    DCU         => DCU,

    CCU_DA1     => CCU_DA1,
    CCU_DA2     => CCU_DA2,
    CCU_DA3     => CCU_DA3,
    CCU_DA4     => CCU_DA4
);

-- ------------------------------------------------------------------------------------------
-- Instantiate cmd_timer block
-- ------------------------------------------------------------------------------------------
cmd_timer1 : entity work.cmd_timer
port map(
    rst             => roc_net,
    clk             => wclk_net,
    timer_reset     => timer_reset,
    message_timeout => message_timeout
);

-- ------------------------------------------------------------------------------------------
-- Instantiate inoutmux block
-- ------------------------------------------------------------------------------------------
inoutmux1 : entity work.inoutmux
port map(

    -- --------------------------------------------------------------------------------------
    -- CPU ports
    -- --------------------------------------------------------------------------------------
    P0Out           => P0Out,
    P1Out           => P1Out,
    P3Out           => P3Out,

    P0In            => P0In,
    P1In            => P1In,
    P2In            => P2In,
    P3In            => P3In,

    SMod            => SMod,

    -- --------------------------------------------------------------------------------------
    -- ColdLink signals
    -- --------------------------------------------------------------------------------------
    DOUT            => DOUT,
    DIN             => DIN,
    UPLINK_FAIL     => UPLINK_FAIL,

    -- --------------------------------------------------------------------------------------
    -- FPGA-internal control signals
    -- --------------------------------------------------------------------------------------
    HSSP_RxACK_n    => HSSP_RxACK_n,
    UART_RxACK_n    => UART_RxACK_n,
    crc_clear_n     => crc_clear_n,
    timer_reset     => timer_reset,
    HSSP_TxBUSY     => HSSP_TxBUSY,
    UART_TxBUSY     => UART_TxBUSY,
    UART_RxREADY    => UART_RxREADY,
    crc_err         => crc_err,
    FLASH_WP_n      => iFLASH_WP_n,
    Cal_On          => Cal_On,
    DCU             => DCU,

    -- --------------------------------------------------------------------------------------
    -- FPGA-external inputs/outputs
    -- --------------------------------------------------------------------------------------
    EXTWD_KILLER    => EXTWD_KILLER,
    ADHS1_END_CAL   => ADHS1_END_CAL,
    ADHS2_END_CAL   => ADHS2_END_CAL,
    FLASH_P         => FLASH_P,
    FLASH4_n        => FLASH4_n,

    -- --------------------------------------------------------------------------------------
    -- CCU-external inputs/outputs
    -- --------------------------------------------------------------------------------------
    RFU0            => RFU0,
    RFU1            => RFU1,
    RFU2            => RFU2,
    DCU0            => DCU0,
    DCU1            => DCU1,
    DCU2            => DCU2,
    VIDEO_DISABLE_N => VIDEO_DISABLE_N,
    NOTCH_FILTER_N  => NOTCH_FILTER_N,
    VIDEO_DISABLE   => VIDEO_DISABLE,
    SPARE_OUT3      => SPARE_OUT3,
    LO_LOCKED_n     => LO_LOCKED_n,
    PWR_GOOD        => PWR_GOOD,
    SPARE_IN1       => SPARE_IN1,
    SPARE_IN2       => SPARE_IN2

);

-- ------------------------------------------------------------------------------------------
-- Instantiate BUF component
-- NOTE: This is just a trick to avoid wclk_net being renamed in synthesis.
-- ------------------------------------------------------------------------------------------
BUF1 : BUF
port map(
    O => TPA_D14,
    I => wclk_net
);

-- ------------------------------------------------------------------------------------------
-- Internal signal assignments
-- ------------------------------------------------------------------------------------------

-- Conditional inversion of ADC comparator outputs

AgtR1 <= AD1_COMP xor cAgtR_INVERT;
AgtR2 <= AD2_COMP xor cAgtR_INVERT;

-- SFR write strobes

UART_SfrLoad <= '1' when (SfrLoad = '1' and SfrAddr = UART_ADDR(6 downto 0)) else '0';
HSSP_SfrLoad <= '1' when (SfrLoad = '1' and SfrAddr = HSSP_ADDR(6 downto 0)) else '0';

-- SFR read data mux

UART_SfrData <= UART_RxDATA  when SfrAddr = UART_ADDR(6 downto 0) else (others=>'0');
HSSP_SfrData <= HSSP_RxDATA  when SfrAddr = HSSP_ADDR(6 downto 0) else (others=>'0');
ADC1_SfrData <= ADC1out      when SfrAddr = ADC1_ADDR(6 downto 0) else (others=>'0');
ADC2_SfrData <= ADC2out      when SfrAddr = ADC2_ADDR(6 downto 0) else (others=>'0');
 
SfrDataIn <= UART_SfrData or HSSP_SfrData or ADC1_SfrData or ADC2_SfrData or
             ADHS_SfrData or DAC_SfrData;

-- ------------------------------------------------------------------------------------------
-- Output signal assignments
-- ------------------------------------------------------------------------------------------
FLASH_WP_n   <= iFLASH_WP_n;

FLASH_CE1_n  <= '0';
FLASH_RP_n   <= '1';
FLASH_BYTE_n <= '0';

end architecture struct;
