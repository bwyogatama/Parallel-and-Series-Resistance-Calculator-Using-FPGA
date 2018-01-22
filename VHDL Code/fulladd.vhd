LIBRARY ieee;
USE ieee.std_logic_1164.all;

Entity fulladd IS
	PORT(A	:in std_logic;
		B	:in std_logic;
		CI	:in std_logic;
		O	:out std_logic;
		CO	:out std_logic);
end fulladd;

ARCHITECTURE behave OF fulladd is
begin
	O<=A XOR B XOR CI;
	CO<= (A AND B) OR (CI AND A) OR (CI AND B);
end behave;