LIBRARY ieee;
USE ieee.std_logic_1164.all;

ENTITY shiftlne IS
	GENERIC (N:INTEGER );
	PORT (	R	:IN STD_logic_vector(N-1 DOWNTO 0);
			L,E,w:in std_logic;
			Clock :in std_logic;
			Q	:buffer std_logic_Vector(N-1 downto 0));
	END shiftlne;
	
	ARCHITECTURE Behavior OF shiftlne IS
	BEGIN
		PROCESS
		BEGIN	
			WAIT UNTIL Clock'EVENT AND Clock='1';
			IF L='1' THEN
				Q<=R;
			ELSIF E='1' THEN
				Q(0)<=w;
				Genbits: FOR i IN 1 to N-1 LOOP
					Q(i)<=Q(i-1);
				END LOOP;
			END IF;
		END PROCESS;
	END Behavior;