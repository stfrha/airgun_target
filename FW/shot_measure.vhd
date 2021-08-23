---------------------------------------------------------------------------------------------
--
-- Legal notice:    All rights strictly reserved. Reproduction or issue to third parties in
--                  any form whatever is not permitted without written authority from the
--                  proprietors.
--
---------------------------------------------------------------------------------------------
--
-- File name:       shot_measure.vhd
--
-- Classification:
-- FHL:             Unclassified
-- SekrL:           Unclassified
--
-- Coding rules:    IN IN117887 1.0
--
-- Descripton:      This file measures the time between all pulses of a shot. 
--
-- Known errors:    None
--
-- To do:           N/A
--
---------------------------------------------------------------------------------------------
--
-- Revision history:
--
-- $Log: $
--
---------------------------------------------------------------------------------------------


library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.airgun_package.all;

entity shot_measure is
   generic (
      -- AD-converter sample frequency [Hz]
      SAMPLE_FREQ           : integer := 192000
   );
   port (
      clk                   : in std_logic;
      reset_n               : in std_logic;
      
      ce                    : in std_logic;                        -- Clock enable

      mv135                 : in    std_logic_vector(9 downto 0);  -- Main Video 135 amplitude from ADC.
      mv225                 : in    std_logic_vector(9 downto 0);  -- Main Video 225 amplitude from ADC.
      mv315                 : in    std_logic_vector(9 downto 0);  -- Main Video 315 amplitude from ADC.
      mv45                  : in    std_logic_vector(9 downto 0);  -- Main Video 45 amplitude from ADC.
      
      ll_time               : out unsigned(23 downto 0);
      lr_time               : out unsigned(23 downto 0);
      ul_time               : out unsigned(23 downto 0);
      ur_time               : out unsigned(23 downto 0);
      send_req              : out std_logic;
      send_ack              : in std_logic
   );
end entity shot_measure;

architecture rtl of shot_measure is

---------------------------------------------------------------------------
-- Constant definitions
---------------------------------------------------------------------------
-- SHOT_DET_TIMEOUT is the max waiting time to detect pulses from all mics. 
-- If timeout occurs no shot message is sent
-- 120000 * 25 ns = 3 ms, which corresponds to a distance of one meter
constant SHOT_DET_TIMEOUT : unsigned(23 downto 0) := to_unsigned(120000, 24); 

-- SETTLE_TIME is the time that must pass without activity before a new shot can
-- be accepted.
-- 120000 * 25 ns = 3 ms, which corresponds to a distance of one meter
constant SETTLE_TIMEOUT : unsigned(23 downto 0) := to_unsigned(120000, 24); 

-- Empirically, this level seems to be above the sound of the gun from a distance of 2.5 meter
-- but well below the maximum amplitude (wich saturates the receiver and gives 1024 out)
constant SHOT_THRESHOLD : unsigned (9 downto 0) := to_unsigned(600, 10);

-- We start  with a value from the gut
constant SETTLE_THRESHOLD : unsigned (9 downto 0) := to_unsigned(400, 10);

-- We start  with a value from the gut
constant PEND_SLOPE : signed (10 downto 0) := to_signed(-50, 11);
---------------------------------------------------------------------------
-- Type definitions
---------------------------------------------------------------------------
type times_type is array (3 downto 0) of unsigned(23 downto 0);

-- Audio channel types
type ach_type is array (3 downto 0) of unsigned(9 downto 0);
type delta_amp_type is array (3 downto 0) of signed(10 downto 0);

-- Shot detect FSM type
type state_type is (IDLE, SHOT_DETECTED, SEND_MSG, SETTLE_TIME);
---------------------------------------------------------------------------
-- Signal declarations
---------------------------------------------------------------------------

-- Delta amplitude signals
signal ach_d             : ach_type;
signal ach_d2            : ach_type;
signal ach_d3            : ach_type;
signal delta_amp         : delta_amp_type;  
signal max_delta         : delta_amp_type;

-- State holding signals
signal times             : times_type;
signal pulse_end         : std_logic_vector(3 downto 0);
signal counter           : unsigned(23 downto 0);
signal state             : state_type;

begin

calc_delta_p : process (clk)
begin
   if rising_edge(clk) then
      if ce = '1' then
         ach_d(0) <= unsigned(mv45);
         ach_d(1) <= unsigned(mv315);
         ach_d(2) <= unsigned(mv135);
         ach_d(3) <= unsigned(mv225);

         ach_d2 <= ach_d;
         ach_d3 <= ach_d2;

         for i in 0 to 3 loop
            delta_amp(i) <= signed('0' & ach_d3(i)) - signed(ach_d(i));
         end loop;
      end if;
      if reset_n = '0' then
         delta_amp <= (others => (others => '0'));
         ach_d <= (others => (others => '0'));
         ach_d2 <= (others => (others => '0'));
         ach_d3 <= (others => (others => '0'));
      end if;
   end if;
   
end process calc_delta_p;

max_delta_p : process (clk)
begin
   if rising_edge(clk) then
      if state = SHOT_DETECTED then
         for i in 0 to 3 loop
            if pulse_end(i) = '0' then
               if delta_amp(i) > max_delta(i) then
                  max_delta(i) <= delta_amp(i);
                  times(i) <= counter;
               end if;
            end if;
         end loop;
      else
         max_delta <= (others => (others => '0'));
      end if;
   end if;
end process max_delta_p;

pulse_end_p : process (clk)
begin
   if rising_edge(clk) then
      for i in 0 to 3 loop
         if state = SHOT_DETECTED then
            if (delta_amp(i) < PEND_SLOPE) and (ach_d3(i) > SHOT_THRESHOLD) then
               pulse_end(i) <= '1';
            end if;
         else
            pulse_end <= "0000";
         end if;
      end loop;
   end if;
end process pulse_end_p;


shot_p : process (clk)
begin
   if (rising_edge(clk)) then
      case state is
         when IDLE =>
            for i in 0 to 3 loop
               if ach_d(i) >= SHOT_THRESHOLD then
                  state <= SHOT_DETECTED;
                  counter <= (others => '0');
               end if;
            end loop;
         when SHOT_DETECTED =>
            counter <= counter + 1;
            if counter >= SHOT_DET_TIMEOUT then
               state <= IDLE;
            else
               if pulse_end = "1111" then
                  state <= SEND_MSG;
                  send_req <= '1';
               end if;
            end if;

         when SEND_MSG =>
            if (send_ack = '1') then
               state <= SETTLE_TIME;
               send_req <= '0';
               counter <= (others => '0');
            end if;
         when SETTLE_TIME =>
             counter <= counter + 1;
             if (counter >= SETTLE_TIMEOUT) then
                state <= IDLE;
             else
               for i in 0 to 3 loop
                  if ach_d(i) >= SETTLE_THRESHOLD then
                     counter <= (others => '0');
                  end if;
               end loop;
             end if;
      end case;

      -- Synchronous reset
      if (reset_n = '0') then
         state <= IDLE;
         send_req <= '0';
      end if;
   end if;
end process;         

---------------------------------------------------------------------------------------------
-- Concurrent statements
---------------------------------------------------------------------------------------------

ur_time <= times(0);
ul_time <= times(1);
lr_time <= times(2);
ll_time <= times(3);


end architecture rtl;
      

