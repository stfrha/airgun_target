-- ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
--
-- VHDL SOURCE FILE flash_protect.vhd
--
-- State machine for write protection of the CCU flash memory
--
-- $Id: flash_protect.vhd,v 1.1 2005/02/11 14:11:33 lra Exp $
-- $Log: flash_protect.vhd,v $
-- Revision 1.1  2005/02/11 14:11:33  lra
-- New project directory structure created
--
-- Revision 1.2  2005/02/11 13:59:23  lra
-- Minor cleanup
--
-- Revision 1.1  2003/10/31 19:52:29  lra
-- Import to CVS. New design file.
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
entity flash_protect is
port
(
  clk         : in std_logic;  -- Clock signal

  rst         : in std_logic;  -- Async. reset signal.
                               -- Release of reset must be externally
                               -- synchronized to clk.

  SfrAddr     : in std_logic_vector(6 downto 0);
  SfrDataOut  : in std_logic_vector(7 downto 0);
  SfrLoad     : in std_logic;

  MemAddr     : in std_logic_vector(15 downto 0);
  WriteStrobe : in std_logic;

  FLASH_WP_n  : out std_logic;
  FLASH_WE_n  : out std_logic

);

end entity flash_protect;

-- ------------------------------------------------------------------------------------------
-- Architecture definition
-- ------------------------------------------------------------------------------------------
architecture rtl of flash_protect is

-- ------------------------------------------------------------------------------------------
-- Constant declarations
-- ------------------------------------------------------------------------------------------
constant WP_SFR1_ADDR : std_logic_vector(7 downto 0) := x"aa";
constant WP_SFR2_ADDR : std_logic_vector(7 downto 0) := x"d5";

constant WR_0_DATA    : std_logic_vector(7 downto 0) := x"55";
constant WR_1_DATA    : std_logic_vector(7 downto 0) := x"aa";
constant WR_2_DATA    : std_logic_vector(7 downto 0) := x"a5";
constant WR_3_DATA    : std_logic_vector(7 downto 0) := x"5a";

-- ------------------------------------------------------------------------------------------
-- Signal declarations
-- ------------------------------------------------------------------------------------------
type state_type is (PROTECTED,
                    WR_0_0, WR_0_1, WR_0_2, WR_0_3,
                    WR_1_0, WR_1_1, WR_1_2, WR_1_3,
                    WR_2_0, WR_2_1, WR_2_2, WR_2_3,
                    UNPROTECTED);

signal state : state_type;

signal iFLASH_WP_n : std_logic;

-- ------------------------------------------------------------------------------------------
-- Begin architecture
-- ------------------------------------------------------------------------------------------
begin

-- ------------------------------------------------------------------------------------------
-- Synchronous process
-- ------------------------------------------------------------------------------------------
wp_p : process(rst, clk) is
variable addr : std_logic_vector(7 downto 0);
begin
  
  if rst = '1' then

    state <= PROTECTED;

    iFLASH_WP_n <= '0';

  elsif rising_edge(clk) then

    addr := '1' & SfrAddr;

    case state is

      when PROTECTED =>

        if SfrLoad='1' and addr=WP_SFR1_ADDR and SfrDataOut=WR_0_DATA then
          state <= WR_0_0;
        end if;

      when WR_0_0 =>

        if SfrLoad='1' and addr=WP_SFR2_ADDR and SfrDataOut=WR_1_DATA then
          state <= WR_1_0;
        else
          state <= WR_0_1;
        end if;
         
      when WR_0_1 =>

        if SfrLoad='1' and addr=WP_SFR2_ADDR and SfrDataOut=WR_1_DATA then
          state <= WR_1_0;
        else
          state <= WR_0_2;
        end if;
         
      when WR_0_2 =>

        if SfrLoad='1' and addr=WP_SFR2_ADDR and SfrDataOut=WR_1_DATA then
          state <= WR_1_0;
        else
          state <= WR_0_3;
        end if;
         
      when WR_0_3 =>

        if SfrLoad='1' and addr=WP_SFR2_ADDR and SfrDataOut=WR_1_DATA then
          state <= WR_1_0;
        else
          state <= PROTECTED;
        end if;
         
      when WR_1_0 =>

        if SfrLoad='1' and addr=WP_SFR1_ADDR and SfrDataOut=WR_2_DATA then
          state <= WR_2_0;
        else
          state <= WR_1_1;
        end if;
         
      when WR_1_1 =>

        if SfrLoad='1' and addr=WP_SFR1_ADDR and SfrDataOut=WR_2_DATA then
          state <= WR_2_0;
        else
          state <= WR_1_2;
        end if;
         
      when WR_1_2 =>

        if SfrLoad='1' and addr=WP_SFR1_ADDR and SfrDataOut=WR_2_DATA then
          state <= WR_2_0;
        else
          state <= WR_1_3;
        end if;
         
      when WR_1_3 =>

        if SfrLoad='1' and addr=WP_SFR1_ADDR and SfrDataOut=WR_2_DATA then
          state <= WR_2_0;
        else
          state <= PROTECTED;
        end if;
         
      when WR_2_0 =>

        if SfrLoad='1' and addr=WP_SFR2_ADDR and SfrDataOut=WR_3_DATA then
          state <= UNPROTECTED;
        else
          state <= WR_2_1;
        end if;
         
      when WR_2_1 =>

        if SfrLoad='1' and addr=WP_SFR2_ADDR and SfrDataOut=WR_3_DATA then
          state <= UNPROTECTED;
        else
          state <= WR_2_2;
        end if;
         
      when WR_2_2 =>

        if SfrLoad='1' and addr=WP_SFR2_ADDR and SfrDataOut=WR_3_DATA then
          state <= UNPROTECTED;
        else
          state <= WR_2_3;
        end if;
         
      when WR_2_3 =>

        if SfrLoad='1' and addr=WP_SFR2_ADDR and SfrDataOut=WR_3_DATA then
          state <= UNPROTECTED;
        else
          state <= PROTECTED;
        end if;

      when UNPROTECTED =>
          
        if SfrLoad='1' and (addr=WP_SFR1_ADDR or addr=WP_SFR2_ADDR) then
          state <= PROTECTED;
        end if;
         
    end case;

    if state=UNPROTECTED then
      iFLASH_WP_n <= '1';
    else
      iFLASH_WP_n <= '0';
    end if;

  end if;

end process wp_p;

-- ------------------------------------------------------------------------------------------
-- Output signal assignments  
-- ------------------------------------------------------------------------------------------
FLASH_WP_n <= iFLASH_WP_n;

FLASH_WE_n <= '0' when iFLASH_WP_n='1' and WriteStrobe='0' and MemAddr(15)='1' else '1';

end architecture rtl;
