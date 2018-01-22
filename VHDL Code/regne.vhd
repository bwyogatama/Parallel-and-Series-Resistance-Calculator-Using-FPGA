LIBRARY ieee;
USE ieee.std_logic_1164.all;

ENTITY regne IS
	GENERIC (N:INTEGER);
	PORT (R	:IN STD_LOGIC_VECTOR(N-1 DOWNTO 0);
		Resetn	:IN std_logic;
		E,Clock	:in std_logic;
		Q		:out std_logic_vector(N-1 downto 0));
end regne;

ARCHITECTURE Behavior OF regne IS
Begin
	Process (Resetn,Clock)
	Begin	
		If Resetn='0' Then
			Q<=(OTHERS=>'0');
		ELSIF Clock'EVENT AND Clock ='1' Then	
			IF E='1' Then	
				Q<=R;
			END IF;
		END IF;
	END PROCESS;
END Behavior;
			