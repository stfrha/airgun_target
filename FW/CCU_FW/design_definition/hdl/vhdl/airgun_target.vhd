-- ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
--
-- VHDL SOURCE FILE ccu_fpga.vhd
--
-- CCU board FPGA. Top entity.
--
-- $Id: $
-- $Log: $
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
entity airgun_target is
    port(

        CLK4X1          : in std_logic;

        ADHS1_CLK       : out std_logic;
        ADHS1_A         : out std_logic_vector(1 downto 0);
        ADHS1_CS_n      : out std_logic;
        ADHS1_OE_n      : out std_logic;
        ADHS1_WR_n      : out std_logic;
        ADHS1_D         : inout std_logic_vector(13 downto 0);

        ADHS2_CLK       : out std_logic;
        ADHS2_A         : out std_logic_vector(1 downto 0);
        ADHS2_CS_n      : out std_logic;
        ADHS2_OE_n      : out std_logic;
        ADHS2_WR_n      : out std_logic;
        ADHS2_D         : inout std_logic_vector(13 downto 0);

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
        FLASH4_n        : in std_logic;

        SEROUT          : out std_logic;
        SERIN           : in std_logic;

        RxD             : in std_logic;				-- Serial port input
        TxD             : out std_logic;			-- Serial port output

        LL_L            : in std_logic;
        LL_H            : in std_logic;
        LR_L            : in std_logic;
        LR_H            : in std_logic;
        UL_L            : in std_logic;
        UL_H            : in std_logic;
        UR_L            : in std_logic;
        UR_H            : in std_logic;

        SPARE0          : inout std_logic;
        SPARE1          : inout std_logic;
        SPARE2          : inout std_logic;
        SPARE3          : inout std_logic;

        EXTWD_KILLER    : out std_logic;		-- Give a pulse with PW > 50ns and period < 1 s

        TPA_D14         : out std_logic;		-- Testpoint, preserves clk name in synthesis
        TPA_D15         : out std_logic			-- Testpoint, 

    );
end entity airgun_target;

-- ------------------------------------------------------------------------------------------
-- Architecture definition
-- ------------------------------------------------------------------------------------------
architecture behav of airgun_target is

-- ------------------------------------------------------------------------------------------
-- Constant declarations
-- ------------------------------------------------------------------------------------------

-- ------------------------------------------------------------------------------------------
-- Signal declarations
-- ------------------------------------------------------------------------------------------
signal roc_net         : std_logic;

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
-- Output signal assignments
-- ------------------------------------------------------------------------------------------

ADHS1_CLK       <= '0';
ADHS1_A         <= "00";
ADHS1_CS_n      <= '1';
ADHS1_OE_n      <= '1';
ADHS1_WR_n      <= '1';
ADHS1_D         <= "zzzzzzzzzzzzzz";	-- Default to Z?
ADHS1_DAV       <= '0';
ADHS1_ST_CAL    <= '0';
ADHS1_END_CAL   <= '0';

ADHS2_CLK       <= '0';
ADHS2_A         <= "00";
ADHS2_CS_n      <= '1';
ADHS2_OE_n      <= '1';
ADHS2_WR_n      <= '1';
ADHS2_D         <= "zzzzzzzzzzzzzz";	-- Default to Z?
ADHS2_DAV       <= '0';
ADHS2_ST_CAL    <= '0';
ADHS2_END_CAL   <= '0';

AD1_SD          <= '0';
AD2_SD          <= '0';
AD1_COMP        <= 'z';
AD2_COMP        <= 'z';

CCU_DA1         <= '0';
CCU_DA2         <= '0';
CCU_DA3         <= '0';
CCU_DA4         <= '0';

FLASH_A         <= (others => '0');
FLASH_CE_n      <= '1';
FLASH4_CE_n     <= '1';
FLASH_OE_n      <= '1';
FLASH_WE_n      <= '1';
FLASH_D         <= "zzzzzzzz";
FLASH4_n        <= 'z';

SEROUT          <= '0';
SERIN           <= 'z';

EXTWD_KILLER    : out std_logic;

TPA_D15			<= '0';

end architecture struct;

