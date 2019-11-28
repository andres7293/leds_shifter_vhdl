----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    17:39:18 09/11/2019 
-- Design Name: 
-- Module Name:    leds_shifter - Behavioral 
-- Project Name: 
-- Target Devices: 
-- Tool versions: 
-- Description: 
--
-- Dependencies: 
--
-- Revision: 
-- Revision 0.01 - File Created
-- Additional Comments: 
--
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity leds_shifter is
	port (
		Clk: in std_logic;
		Reset: in std_logic;
		Leds: out std_logic_vector(2 downto 0)
	); 
end leds_shifter;

architecture Behavioral of leds_shifter is
	--ShiftRegister Leds
	signal QLed: std_logic_vector(2 downto 0);
	signal DLed: std_logic_vector(2 downto 0);
	--Timer
	signal QTimer: std_logic_vector(31 downto 0);
	signal DTimer: std_logic_vector(31 downto 0);
	--FSM Register
	signal QFSM: std_logic_vector(3 downto 0);
	signal DFSM: std_logic_vector(3 downto 0);
	--Multiplexers
	signal Mux1: std_logic_vector(1 downto 0);
	signal Mux2: std_logic_vector(1 downto 0);

begin
	--Update flip flops
	process (Clk)
		begin
			if (Clk'event and (Clk = '1')) then
				QLed <= DLed;
				QTimer <= DTimer;
				QFSM <= DFSM;
			end if;
	end process;

	--ShiftRegister Leds
	DLed <= std_logic_vector(to_signed(1, 3)) when (Mux1 = "00") else --Set register to zero
		QLed when (Mux1 = "01") else --keep register state
		QLed(1 downto 0) & '0' when(Mux1 = "10") else --rotate left
      '0' & QLed(2 downto 1) when(Mux1 = "11") else -- rotate right
      QLed;

	--QTimer
    DTimer <= std_logic_vector(to_signed(8000000, 32)) when (Mux2 = "00") else
              std_logic_vector(to_signed(to_integer(signed(QTimer)) - 1, 32)) when (Mux2 = "01") else
              QTimer when (Mux2 = "10") else
              QTimer;
              
    --Next state logic
    DFSM <= "0000" when (Reset = '0') else
            "0001" when (QFSM = "0000" and Reset = '1') else
            "0010" when (QFSM = "0001") else
            "0010" when (QTimer /= std_logic_vector(to_unsigned(0, 32)) and QFSM = "0010") else
            "0011" when (QTimer = std_logic_vector(to_unsigned(0, 32)) and QFSM = "0010") else
            "0001" when (QLed(2) = '0' and QFSM = "0011") else
            "0100" when (QLed(2) = '1' and QFSM = "0011") else
				"0101" when (QFSM = "0100") else
				"0110" when (QFSM = "0101") else
				"0110" when (QTimer /= std_logic_vector(to_unsigned(0, 32)) and QFSM = "0110") else
				"0111" when (QTimer = std_logic_vector(to_unsigned(0, 32)) and QFSM = "0110") else
				"0101" when (QLed(0) = '0' and QFSM = "0111") else
				"1000" when (QLed(0) = '1' and QFSM = "0111") else
				"0001" when (QFSM = "1000") else
            "0000";

	--Mux logic
	Mux1 <= "00" when (QFSM = "0000") else
			  "10" when (QFSM = "0001") else
			  "11" when (QFSM = "0101") else
           "01" when (QFSM = "0010" or QFSM = "0011" or QFSM = "0100" or QFSM = "0110" or QFSM = "0111" or QFSM = "1000") else
           "00";
	
	Mux2 <= "00" when (QFSM = "0000" or QFSM = "0001" or QFSM = "0011" or QFSM = "0100" or QFSM = "0101" or QFSM = "0111" or QFSM = "1000") else
            "01" when (QFSM = "0010" or QFSM  = "0110") else
            "00";
	
	--output logic
	Leds <= QLed;	
end Behavioral;
