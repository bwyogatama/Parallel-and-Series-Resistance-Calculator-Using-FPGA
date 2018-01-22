LIBRARY ieee;
USE ieee.std_logic_1164.all;

ENTITY downcnt IS
	GENERIC (modulus:INTEGER);
	PORT(Clock,L,E :IN STD_LOGIC;
			Q	:OUT INTEGER RANGE 0 to modulus-1);
END downcnt;

ARCHITECTURE Behavior OF downcnt IS
	SIGNAL count: INTEGER RANGE 0 to modulus-1;
BEGIN
	PROCESS
	BEGIN
		WAIT UNTIL (Clock'EVENT AND Clock='1');
		IF L='1' THEN
			Count<=modulus-1;
		ELSE
			IF E='1' THEN
				Count<=Count-1;
			END IF;
		END IF;
	END PROCESS;
	Q<=Count;
END Behavior;