library ieee;
use ieee.std_logic_1164.all;

ENTITY FF IS
	PORT(
		D : IN STD_LOGIC;
		CLK : IN STD_LOGIC;
		Q : OUT STD_LOGIC);
END FF;

ARCHITECTURE BEHAV OF FF IS
	BEGIN
		PROCESS (CLK)
		BEGIN
			 IF RISING_EDGE(CLK) THEN
						Q <= D;
					END IF;
		END PROCESS;
END BEHAV;
