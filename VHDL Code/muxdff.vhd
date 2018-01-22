LIBRARY ieee;
USE ieee.std_logic_1164.all;

ENTITY muxdff IS
	PORT (D0, D1, Sel, Clock : In std_logic;
			Q	:out std_logic);
END muxdff;

ARCHITECTURE Behavior OF muxdff IS
Begin
	Process
	Begin
		Wait Until Clock'EVENT AND Clock='1';
		IF Sel='0' Then
			Q<=D0;
		ELSE
			Q<=D1;
		END IF;
	END Process;
END Behavior;