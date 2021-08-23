-------------------------------------------------------------------------------------------
--
-- Legal notice:    All rights strictly reserved. Reproduction or issue to third parties in
--                  any form whatever is nor permitted without written authority from the
--                  proprietors.
--
-------------------------------------------------------------------------------------------
--
-- File name:         $Id: $
--
-- Classification:
-- FHL:               Unclassified
-- SekrL:             Unclassified
--
-- Coding rules:      IN IN117887 1.0
--
-- Description:       TBD
--
-- Known errors:      None.
-- 
-- To do:             Nothing.
--
-------------------------------------------------------------------------------------------
-- Revision history
-- 
-- $Log: $
--
-------------------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity airgun_target_vp is
   port(
      clk           : in    std_logic;    -- DH1 40MHz clock from DSP.                    
      reset_n       : in    std_logic;    -- Reset, from VMX.  

      clk_0         : out   std_logic;    -- 40MHz Clock to ADC. 
      clk_1         : out   std_logic;    -- 40MHz Clock to ADC.

      ---------------------------------------------------------------------------
      -- Used signals
      ---------------------------------------------------------------------------
      led_n         : out   std_logic_vector(1 downto 0);  -- LED Control.

      mv135         : in    std_logic_vector(9 downto 0);  -- Main Video 135 amplitude from ADC.
      mv225         : in    std_logic_vector(9 downto 0);  -- Main Video 225 amplitude from ADC.
      mv315         : in    std_logic_vector(9 downto 0);  -- Main Video 315 amplitude from ADC.
      mv45          : in    std_logic_vector(9 downto 0);  -- Main Video 45 amplitude from ADC.

      rxd           : in std_logic;
      txd           : out std_logic;
      
      ---------------------------------------------------------------------------
      -- Signals to quip stable state of components
      ---------------------------------------------------------------------------
      -- IO control
      binen_n       : out    std_logic_vector(1 downto 0);  -- bit 0: Y-bus direction control. Input en. Default. 
                                                          -- bit 1: FED data bus dir ctrl. Input en. Default.  
      bouten_n      : out    std_logic_vector(1 downto 0);  -- bit 0: Y-bus direction control. Output enable.
                                                          -- bit 1: FED data bus dir control. Output en.
      -- dsp bus
      dbe_n         : out   std_logic_vector(3 downto 0);  -- DSP SRAM Byte enable. 
      dhold_n       : out   std_logic;  -- DSP Hold. Tells the DSP to tristate DSP bus   
      dint_n        : out   std_logic_vector(2 downto 0);  -- DSP External interrupt.
      doe_n         : out   std_logic;    -- DSP SRAM & FLASH output enable.
      dpage_n       : inout std_logic_vector(3 downto 2);  -- DSP bus page strobes.
      drdy_n        : inout std_logic;    -- DSP bus ready.
      --lut interface
      wa0           : out   std_logic_vector(17 downto 0);  -- LUT memory 0 address.
      wa1           : out   std_logic_vector(17 downto 0);  -- LUT memory 1 address.
      wbe0_n        : out   std_logic_vector(1 downto 0);  -- LUT memory 0 byte control.
      wbe1_n        : out   std_logic_vector(1 downto 0);  -- LUT memory 1 byte control.                
      wce_n         : out   std_logic_vector(1 downto 0);  -- LUT memory chip select.   
      woe_n         : out   std_logic;    -- LUT memory output enable.     
      wwe_n         : out   std_logic;    -- LUT memory write enable.      
      -- Video and DAC setup
      p_ctrl        : out   std_logic_vector(3 downto 0);  -- Peak video switch control        
      tha           : out   std_logic_vector(2 downto 0);  -- DAC Threshold address bus.   
      thd           : out   std_logic_vector(7 downto 0);  -- DAC Threshold data bus.
      thwr_n        : out   std_logic;    -- DAC Threshold bus WR.     
      vid_bite      : out   std_logic_vector(3 downto 0)   -- Video BIT switch enable, channel 0-3.


      ---------------------------------------------------------------------------
      -- Posibly interesting later
      ---------------------------------------------------------------------------
--      gt            : in    std_logic_vector(5 downto 0);  -- From video comparators. Read Register.
--      xsig012055    : out   std_logic;    -- Connected to testpoint J22.       
--      xsig012056    : out   std_logic;    -- Connected to testpoint J21.
--      xsig012057    : out   std_logic;    -- Connected to testpoint J20.
--      xsig012058    : out   std_logic     -- Connected to testpoint J19.
       

   );
end entity airgun_target_vp;

architecture rtl of airgun_target_vp is

---------------------------------------------------------------------------
-- Constant declarations
---------------------------------------------------------------------------
   -- ADC clock generation
   constant ADC_FS : integer := 768000;            -- [samples per second]
   constant CLK_F : integer := 40000000;           -- [Hz]
   constant ADC_HALF_PERIOD : integer := CLK_F / ADC_FS / 2;
   
---------------------------------------------------------------------------
-- Signal declarations
---------------------------------------------------------------------------
   -- ADC clock generation
   signal adc_clk_counter : unsigned(6 downto 0);
   signal adc_clk : std_logic;
   signal adc_clk_transit : std_logic;
   signal adc_clk_en : std_logic;

   
begin

---------------------------------------------------------------------------
-- Airgun target instansiation
---------------------------------------------------------------------------
airgun_target_0 : entity work.airgun_target
   generic map (
      SAMPLE_FREQ    => ADC_FS
   )
   port map (
      clk            => clk,
      reset_n        => reset_n,
      
      ce             => adc_clk_en,

      mv135          => mv135,
      mv225          => mv225,
      mv315          => mv315,
      mv45           => mv45,
      
      rxd            => rxd,
      txd            => txd
   );


---------------------------------------------------------------------------
-- ADC clock generation process
---------------------------------------------------------------------------
   adc_clk_p : process (clk)
   begin
      if rising_edge(clk) then
         adc_clk_transit <= '0';
         adc_clk_en <= '0';
         
         if adc_clk_counter < ADC_HALF_PERIOD - 1 then
            adc_clk_counter <= adc_clk_counter + 1;
         else
            if adc_clk = '0' then
               adc_clk_en <= '1';
            end if;
            adc_clk_transit <= '1';
            adc_clk_counter <= (others => '0');
         end if;

         if adc_clk_transit = '1' then
            adc_clk <= not adc_clk ;
         end if;
         
         if reset_n = '0' then
            adc_clk_counter <= (others => '0');
            adc_clk <= '0';
            adc_clk_transit <= '0';
         end if;
      end if;
   end process adc_clk_p;


---------------------------------------------------------------------------
-- ADC clock signals
---------------------------------------------------------------------------
   clk_0 <= adc_clk;  -- 40MHz to ADC's
   clk_1 <= adc_clk;  -- 40MHz to ADC's

---------------------------------------------------------------------------
-- Defaults to keep components in steady state
---------------------------------------------------------------------------
   dbe_n <= (others => '1');
   dhold_n <= '1';
   dint_n <= (others => '1');
   doe_n <= '1';
   dpage_n <= (others => 'Z');
   drdy_n <= 'Z';
   wa0 <= (others => '0');
   wa1 <= (others => '0');
   wbe0_n <= (others => '1');
   wbe1_n <= (others => '1');
   wce_n <= (others => '1');
   woe_n <= '1';
   wwe_n <= '1';
   vid_bite <= (others => '0');  -- Video BIT Switch control, disable BIT Video.
   binen_n <= "00";  -- Enables buffer direction input
   bouten_n <= "11"; -- Disables buffer direction output
   p_ctrl <= (others => '0'); -- Is this correct? FUNT had this unassigned
   tha <= (others => '0');
   thd <= (others => '0');
   thwr_n <= '1';

   
end architecture rtl;
