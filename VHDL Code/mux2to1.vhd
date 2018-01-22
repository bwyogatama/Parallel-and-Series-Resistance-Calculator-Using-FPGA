LIBRARY ieee ;
USE ieee.std_logic_1164.all ;
ENTITY mux2to1 IS
PORT ( w0, w1, s : IN STD_LOGIC ;
		f : OUT STD_LOGIC ) ;
END mux2to1 ;
ARCHITECTURE Behavior OF mux2to1 IS
BEGIN
PROCESS (w0,w1,s)
BEGIN
	CASE s IS
		WHEN '0' =>
			f<=w0 ;
		WHEN OTHERS=>
			f<=w1 ;
	END CASE ;
END PROCESS ;
END Behavior ;