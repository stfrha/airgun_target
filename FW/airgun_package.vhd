---------------------------------------------------------------------------------------------
--
-- Legal notice:    All rights strictly reserved. Reproduction or issue to third parties in
--                  any form whatever is not permitted without written authority from the
--                  proprietors.
--
---------------------------------------------------------------------------------------------
--
-- File name:       airgun_package.vhd
--
-- Classification:
-- FHL:             Unclassified
-- SekrL:           Unclassified
--
-- Coding rules:    IN IN117887 1.0
--
-- Descripton:      This file contains constants and types common to the airgun project.
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

package airgun_package is


   constant NUM_OF_MSG     : integer := 2;

   type msg_len_type is array (0 to NUM_OF_MSG-1) of integer;

   constant MSG_MAX_LEN    : integer := 14;
   constant SHOT_MSG_INDEX : integer := 0;
   constant SHOT_MSG_LEN   : integer := 14;
   constant VER_MSG_INDEX  : integer := 1;
   constant VER_MSG_LEN    : integer := 11;

   type ver_msg_type is array (0 to VER_MSG_LEN-1) of integer;

   -- String reads: "FW: 01.01"
   constant VER_MSG        : ver_msg_type := (1, 11, 70, 87, 58, 32, 48, 50, 46, 48, 51);
   constant MSG_LENGTHS    : msg_len_type := (SHOT_MSG_LEN, VER_MSG_LEN);
   
   constant F_OSC          : integer := 40000000;            -- Frequency of main clock
   constant BAUDRATE       : integer := 9600;                -- Required baudrate
   constant BR_CLK         : integer := F_OSC / (4 * BAUDRATE);
   
   type msg_type is array (0 to MSG_MAX_LEN-1) of std_logic_vector(7 downto 0);
   type all_msg_type is array (0 to NUM_OF_MSG-1) of msg_type;

end package airgun_package;


-- How to add a new message:
--
-- In this file:
--
-- 1. Increase one to NUM_OF_MSG above
--
-- 2. If length of the new message is longer then any other messages, update MSG_MAX_LEN
--
-- 3. Add this code (kind of):
--    constant *_MSG_INDEX : integer := *; -- * = one more then last message
--    constant *_MSG_LEN   : integer := *;
--
-- 4. Add *_MSG_LEN to the beginning of MSG_LENGTHS array
-- 
-- In airgun_target.vhd (in concurrent statements) :
--
-- 5. Add message definition for new message
--
-- 6. Add send request and acknowledge signals from new message sender
--


