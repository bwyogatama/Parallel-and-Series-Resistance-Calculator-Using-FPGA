LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.std_logic_unsigned.all;
USE work.components.all;

ENTITY divider IS
	GENERIC(N:INTEGER:=16);
	PORT (Clock: IN STD_LOGIC;
			reset:IN STD_LOGIC;
			s,LP,Esum : IN STD_LOGIC;
			R1xR2 : IN STD_LOGIC_VECTOR (N-1 Downto 0);
			sumR1R2 : IN STD_LOGIC_VECTOR (N-1 DOWNTO 0);
			Rhasil,Rsisa : Buffer STD_LOGIC_VECTOR(N-1 DOWNTO 0);
			Done : OUT STD_LOGIC);
END divider;


ARCHITECTURE Behavior OF divider IS
	TYPE State_type IS (D1,D2,D3);
	Signal y: State_type;
	Signal Kosong,Cout,j : STD_LOGIC;
	SIGNAL EA, selektor, LR, ER, ER0, LC, EC, R0 : STD_LOGIC ;
	SIGNAL A,B,Remainder,sum2 :STD_LOGIC_VECTOR(N-1 DOWNTO 0);
	Signal Sum :STD_LOGIC_VECTOR(N DOWNTO 0);
	SIGNAL COUNT : INTEGER RANGE 0 TO N-1;

BEGIN
Transisi_FSM : PROCESS (reset,Clock)
--FSM transition
begin
IF reset = '0' THEN y<=D1;
ELSIF ( Clock'EVENT AND CLOCK = '1') THEN 
	Case y is 
		when D1 =>
			IF s='0' then y<=D1; ELSE y<=D2; END IF;
		when D2 =>
			IF j='0' then y<=D2; ELSE y<=D3; END IF;
		when D3 =>
			IF s='1' then y<= D3; ELSE y<= D1; END IF;
		END Case;
	END IF;
END PROCESS;

Keluaran_FSM: PROCESS (s,y,Cout,j)
--FSM output
BEGIN
	LR <= '0'; ER <= '0'; ER0 <= '0';
	LC <= '0'; EC <= '0'; EA <= '0'; Done <= '0';
	selektor <= '0';
	--inisisalisasi
	Case y IS	
	WHEN D1 =>
		LC <='1'; ER<='1' ;
		IF s='0' THEn 
			LR<='1' ; EA<= '0'; ER0<= '0';
	--Nilai input shift register dimasukkan
		ELSE
			LR<='0'; EA <='1'; ER0<= '1';
	--shiftA diaktifkan
		END IF;
	WHEN D2 =>
	selektor<= '1'; ER <= '1'; ER0<= '1'; EA<= '1';
	--proses pembagian dengan shift compare substract
	IF Cout = '1' THEN LR <= '1'; ELSE LR <='0'; END IF;
	IF j='0' THEN EC <='1';ELSE EC<='0';END IF;
	WHEN D3 =>
	Done <='1';
	--proses pembagian selesai
	END Case;
END PROCESS;

Kosong<='0';
RegB:regne GENERIC MAP (N=>N)
PORT MAP (sumR1R2,reset,Esum,Clock,B);
--untuk menyimpan pembagi
Counter:downcnt GENERIC MAP (modulus=>N)
PORT MAP (Clock,EC,LC,Count);
ShiftR:shiftlne GENERIC MAP (N=>N)
PORT MAP (Remainder,LR,ER,R0,Clock,Rsisa);
Flip_R0: muxdff PORT MAP (Kosong, A(N-1),ER0, Clock,R0);
ShiftA: shiftlne GENERIC MAP (N=>N)
PORT MAP (R1xR2, LP, EA,Cout,Clock,A);
Rhasil<=A;

j<='1' WHEN Count=0 ELSE '0';
Sum <= Rsisa&R0 + (NOT B+1);
--proses pengurangan
Cout<= Sum(N);
subtract:for X in 0 to N-1 generate
	sum2(x)<=sum(x);
end generate;
--merubah dari sum yang 9 bit menjadi sum2 yang 8 bit
Remainder <= (Others => '0') WHEN selektor = '0' ELSE sum2;
--mengassign nilai remainder
END Behavior;


