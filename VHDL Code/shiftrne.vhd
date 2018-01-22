LIBRARY ieee;
USE ieee.std_logic_1164.all;

ENTITY shiftrne is
	GENERIC (N:INTEGER);
	PORT (R:IN STD_LOGIC_VECTOR(N-1 DOWNTO 0);
		L,E,w : IN STD_LOGIC;
		Clock : IN STD_LOGIC;
		Q : buffer STD_LOGIC_VECTOR(N-1 DOWNTO 0));
	END shiftrne;
ARCHITECTURE behavior OF shiftrne IS
BEGIN
 PROCESS
 BEGIN
	WAIT UNTIL Clock'EVENT AND Clock='1';
		
			IF L = '1' THEN
				Q<=R;
			ELSIF E='1' THEN
				Genbits: FOR i in 0 to n-2 loop
				Q(i)<=Q(i+1);
				end loop;
				Q(N-1)<=w;
			END IF;
END PROCESS;
ENd behavior;