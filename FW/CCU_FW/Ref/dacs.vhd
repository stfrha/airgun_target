-- ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
--
-- VHDL SOURCE FILE dacs.vhd
--
-- DAC interface
--
-- $Id: dacs.vhd,v 1.1 2005/02/15 14:09:42 lra Exp $
-- $Log: dacs.vhd,v $
-- Revision 1.1  2005/02/15 14:09:42  lra
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
-- Entity declaration
-- ------------------------------------------------------------------------------------------
entity dacs is
port
(
    clk          : in std_logic; -- CPU clock signal

    rst          : in std_logic; -- Async reset signal for the clk domain.
                                 -- Release of reset must be externally
                                 -- synchronized to clk.

    clk8x        : in std_logic; -- DAC clock signal

    rst8x        : in std_logic; -- Async reset signal for the clk8x domain.
                                 -- Release of reset must be externally
                                 -- synchronized to clk8x.

    P0Dir        : in std_logic_vector(7 downto 0);
    P1Dir        : in std_logic_vector(7 downto 0);
    P2Dir        : in std_logic_vector(7 downto 0);
    P3Dir        : in std_logic_vector(7 downto 0);

    SfrAddr      : in std_logic_vector(6 downto 0);
    SfrDataOut   : in std_logic_vector(7 downto 0);
    SfrLoad      : in std_logic;

    DAC_SfrData : out std_logic_vector(7 downto 0);

    DCU          : in std_logic;

    CCU_DA1      : out std_logic;
    CCU_DA2      : out std_logic;
    CCU_DA3      : out std_logic;
    CCU_DA4      : out std_logic
);

end entity dacs;

-- ------------------------------------------------------------------------------------------
-- Architecture definition
-- ------------------------------------------------------------------------------------------
architecture rtl of dacs is

-- ------------------------------------------------------------------------------------------
-- Constant declarations
-- ------------------------------------------------------------------------------------------
type DACin_bank_reg_addr_type is array(0 to 3) of std_logic_vector(7 downto 0);
constant DACin_1_reg_addr : DACin_bank_reg_addr_type := (x"ac", x"ad", x"ae", x"af");

-- ------------------------------------------------------------------------------------------
-- Type definitions
-- ------------------------------------------------------------------------------------------
type DACin_bank_type  is array(0 to 3) of std_logic_vector(7 downto 0);
type sigma_bank_type  is array(0 to 3) of unsigned(9 downto 0);
type DACout_bank_type is array(0 to 3) of std_logic;

type DACin_type  is array(0 to 1) of DACin_bank_type;
type sigma_type  is array(0 to 1) of sigma_bank_type;
type DACout_type is array(0 to 1) of DACout_bank_type;

-- ------------------------------------------------------------------------------------------
-- Signal declarations
-- ------------------------------------------------------------------------------------------
signal DACin_1_reg : DACin_bank_type;
signal DACin       : DACin_type;
signal sigma       : sigma_type;
signal DACout      : DACout_type;
signal DA          : DACout_bank_type;

-- ------------------------------------------------------------------------------------------
-- Begin architecture
-- ------------------------------------------------------------------------------------------
begin

-- ------------------------------------------------------------------------------------------
-- Internal signal assignments
-- ------------------------------------------------------------------------------------------
DACin <= ((P0Dir, P1Dir, P2Dir, P3Dir), DACin_1_reg);

DA    <= DACout(1) when DCU='1' else DACout(0);

-- ------------------------------------------------------------------------------------------
-- Secondary (DCU mode) DAC registers write process 
-- ------------------------------------------------------------------------------------------
wr_proc : process(rst, clk) is
variable addr : std_logic_vector(7 downto 0);
begin
  	
    if rst='1' then

        DACin_1_reg <= (others=>(others=>'1'));

    elsif rising_edge(clk) then

        addr := '1' & SfrAddr;

        if SfrLoad = '1' then

            for i in 0 to 3 loop
                if addr = DACin_1_reg_addr(i) then
                    DACin_1_reg(i) <= SfrDataOut;
                end if;
            end loop;

        end if;

    end if;

end process wr_proc;
  	
-- ------------------------------------------------------------------------------------------
-- Secondary (DCU mode) DAC registers read mux
-- ------------------------------------------------------------------------------------------
mux : process(SfrAddr, DACin_1_reg) is
variable addr : std_logic_vector(7 downto 0);
begin
    
    addr := '1' & SfrAddr;
    
    DAC_SfrData <= (others =>'0');

    for i in 0 to 3 loop
        if addr = DACin_1_reg_addr(i) then
            DAC_SfrData <= DACin_1_reg(i);
        end if;
    end loop;

end process mux;

-- ------------------------------------------------------------------------------------------
-- Delta-Sigma DAC process
-- NOTE: The DAC inputs switch completely asynchronous to clk8x. This is unlikely to be a  
-- problem in practice, since there are analog filters on the DAC outputs. 
-- ------------------------------------------------------------------------------------------
dac_proc : process(rst8x, clk8x) is
variable t : unsigned(9 downto 0);
begin
    
    if rst8x = '1' then

        DACout <= (others => (others => '0'));

        sigma <= (others => (others => "0100000000"));

    elsif rising_edge(clk8x) then

        for i in 0 to 1 loop

            for j in 0 to 3 loop

                DACout(i)(j) <= sigma(i)(j)(9);

                -- NOTE: The following is to avoid a simulator stupidity

                t(9) := sigma(i)(j)(9);
                t(8) := sigma(i)(j)(9);

                t(7 downto 0) := unsigned( DACin(i)(j) );

                sigma(i)(j) <= sigma(i)(j) + t;

            end loop;

        end loop;

    end if;

end process dac_proc;

-- ------------------------------------------------------------------------------------------
-- Output signal assignments  
-- ------------------------------------------------------------------------------------------
CCU_DA1 <= DA(0);
CCU_DA2 <= DA(1);
CCU_DA3 <= DA(2);
CCU_DA4 <= DA(3);

end architecture rtl;
