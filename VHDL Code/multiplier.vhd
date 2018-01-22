LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.std_logic_unsigned.all;
USE work.components.all;

ENTITY multiplier IS
GENERIC (N:INTEGER:=8 ; NN: INTEGER:=16);
PORT(Clock:IN STD_LOGIC;
	reset: IN STD_LOGIC;
	LR1,LR2,s: IN STD_LOGIC;
	R1: IN STD_LOGIC_VECTOR(N-1 DOWNTO 0);
	R2 : IN STD_LOGIC_VECTOR(N-1 DOWNTO 0);
	P: Buffer STD_LOGIC_VECTOR(NN-1 Downto 0);
	Done : OUT STD_LOGIC);
END multiplier;

Architecture Behavior OF multiplier IS
Type State_type IS (M1,M2,M3);
Signal y: State_type;
SIGNAL selektor,j,EA,EB,EP,Kosong: STD_LOGIC;
SIGNAL B,N_0 : STD_LOGIC_VECTOR(N-1 DOWNTO 0);
SIGNAL A,Ainput,Hasil,Sum: STD_LOGIC_VECTOR (NN-1 DOWNTO 0);
BEGIN
Transisi_FSM: PROCESS (reset,Clock)
--FSM transition
BEGIN
	IF reset='0' Then
		y<=M1;
	-- ketika reset kembali ke state pertama
	ELSIF (Clock'EVENT AND Clock = '1') Then
		Case y IS
			When M1 => 
				IF s='0' THEN y<=M1; ELSE y<=M2; END IF;
			When M2 =>
				IF j='0' THEN y<=M2; ELSE y<=M3; END IF;
			WHEN M3 =>
				IF s='1' THEN y<= M3; ELSE y<=M1; END IF;
		END CASE;
	END IF;
END PROCESS;

Keluaran_FSM: PROCESS(y,s,B(0))
--FSM output
BEGIN
	EP<='0'; EA<='0'; EB<= '0'; Done <='0'; selektor<= '0';
	--inisialisasi
	Case y IS
		WHEN M1=>
		EP<='1';
	--register aktif
		WHEN M2=>
		EA<='1'; EB<='1';selektor<='1';
	--shift register aktif, selektor untuk multiplexer aktif
		IF B(0)='1' THEN EP<='1'; ELSE EP<='0'; END IF;
		WHEN M3=>
		Done<='1';
	--sinyal yang menandakan perkalian selesai
	END CASE;
END PROCESS;

Kosong<='0';
N_0<=(OTHERS=>'0');
--N-0 selalu bernilai 0
Ainput<=N_0&R1;
-- agar input pertama menjadi 16 bit
Multiplexer: FOR i IN 0 TO NN-1 GENERATE
	Muxi: mux2to1 PORT MAP (Kosong,Sum(i),selektor,Hasil(i));
	END GENERATE;
--menentukan apakah akan dijumlahkan dengan '0' atau dengan inputnya
	RegP: regne GENERIC MAP (N=>NN)
	PORT MAP (Hasil,reset,EP,Clock,P);
ShiftA:shiftlne GENERIC MAP (N=>NN)
PORT MAP (Ainput,LR1,EA,Kosong,Clock,A);
--Ainput digeser
ShiftB: shiftrne GENERIC MAP ( N => N )
PORT MAP ( R2, LR2, EB, Kosong, Clock, B ) ;
--R2 digeser menjadi B
j<='1' WHEN B=N_0 ELSE '0';
Sum<=A+P;
-- menjumlahkan A dengan nilai sebelumnya

END Behavior;
	
	