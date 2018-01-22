LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.std_logic_unsigned.all;
Use work.components.all;
Entity control_state is
	GENERIC(N:INTEGER:=8;NN:INTEGER:=16);
	Port( 	Clock	:in std_logic;
			Input 	:in std_logic_vector(N-1 downto 0);
			k1,k2	:in std_logic; --SW[9] dan SW[8]
			kseri	:in std_logic; --KEY3
			kparalel:in std_logic; --KEY2
			ksisa	:in std_logic; --KEY1
			HEX0	:out std_logic_vector(1 to 7); --7segment untuk satuan
			HEX1	:out std_logic_vector(1 TO 7); --7segment untuk puluhan
			HEX2	:out std_logic_vector(1 to 7)); --7segment untuk ratusan
end control_state;

ARCHITECTURE Behavior of control_state IS
	TYPE State_type IS (S1,S2,S3,S4,S5);
	--mendefinisikan tipe state dari S1 sampe S5
	Signal y:state_type:=S1;
	Signal Reset	:std_logic;
	Signal Done1,Done2:STD_LOGIC;
	Signal R1, R2 : STD_LOGIC_VECTOR (N-1 downto 0);
	Signal temp:	STD_LOGIC_VECTOR (N downto 0);
	Signal ER1: STD_LOGIC := '0'; --mengatur aktif tidaknya register R1
	Signal ER2: STD_LOGIC := '0'; --mengatur aktif tidaknya register R2
	Signal Lm1:STD_LOGIC := '0';
	Signal Lm2:STD_LOGIC := '0';
	Signal Ld:STD_LOGIC := '0';
	Signal Ed:STD_LOGIC:='0';
	Signal Sm:STD_LOGIC := '0';
	Signal Sd:STD_LOGIC := '0';
	Signal Rseri: STD_LOGIC_VECTOR (NN-1 downto 0); --hasil R1+R2
	Signal Rparalel,P,Rsisa:std_logic_vector(NN-1 downto 0); --hasil perhitungan resistansi paralel
	Signal CI : std_logic :='0';
	Signal bcd0,bcd1,bcd2 : STD_LOGIC_VECTOR (3 downto 0); --hasil perhitungan yang sudah dikonversi ke bentuk bcd
Component multiplier
			GENERIC (N:INTEGER ; NN: INTEGER);
PORT(Clock:IN STD_LOGIC;
	reset: IN STD_LOGIC;
	LR1,LR2,s: IN STD_LOGIC;
	R1: IN STD_LOGIC_VECTOR(N-1 DOWNTO 0);
	R2 : IN STD_LOGIC_VECTOR(N-1 DOWNTO 0);
	P: Buffer STD_LOGIC_VECTOR(NN-1 Downto 0);
	Done : OUT STD_LOGIC);
END component multiplier;

Component divider
	GENERIC(N:INTEGER);
	PORT (Clock: IN STD_LOGIC;
			reset:IN STD_LOGIC;
			s,LP,Esum : IN STD_LOGIC;
			R1xR2 : IN STD_LOGIC_VECTOR (N-1 Downto 0);
			sumR1R2 : IN STD_LOGIC_VECTOR (N-1 DOWNTO 0);
			Rhasil,Rsisa : Buffer STD_LOGIC_VECTOR(N-1 DOWNTO 0);
			Done : OUT STD_LOGIC);
END component divider;
component adder
	generic (N: integer);
  port (
    R1:  in  std_logic_vector(N-1 downto 0);
    R2:  in  std_logic_vector(N-1 downto 0);
    CI: in  std_logic;
    sumR1R2:  out std_logic_vector((2*N-1) downto 0);
    CO: buffer std_logic);
end component adder;

component converter
	generic(N: Positive );
    port(
        clock: in std_logic;
        bit_in: in std_logic_vector(N-1 downto 0);
        bcd0, bcd1, bcd2: out std_logic_vector(3 downto 0)
    );
end component converter ;

BEGIN
	reset<=k1 or k2;
	--sistem akan direset apabila SW9 dan SW8 bernilai 0
FSM_transition: PROCESS(k1,k2,clock)
	BEGIN
	IF reset='0' then y<=S1;
	ELSIF (clock'EVENT and clock='1') then
		case y is
		When S1=>
			IF k1='0' then y<=S1; ELSE y<=S2;END IF;
		-- S1 akan berpindah state apabila SW9 bernilai 1
		WHEN S2=>
			IF k2='0' then y<=S2; ELSE y<=S3;END IF;
		-- S2 akan berpindah state apabila SW8 bernilai 1
		WHEN S3=>
			IF Done1='0' then y<=S3; ELSE y<=S4; END IF;
		-- S3 akan berpindah state apabila perkalian telah selesai (Done1=1)
		WHEN S4=>
			IF DONE2='0' then y<=S4; ELSE y<=S5;END IF;
		-- S4 akan berpindah state apabila pembagian telah selesai (Done2=1)
		WHEN S5=>
			IF reset='1' then y<=s5; ELSE y<=S1; END IF;
		-- S5 hanya akan kembali ke S1 jika reset bernilai 0
		end case;
	end if;
end PROCESS;

FSM_output: PROCESS 
BEGIN
	wait until clock'event and clock ='1';
	--menunggu hingga clock bernilai 1 (rising edge)
	Case y IS
	When S1=>
		ER1<='1'; ER2<='0';Sm<='0';Sd<='0';
		--inisialisasi signal pada S1
		pindahan1:for l in 0 to (N-1) loop
				temp(l)<=input(l);
				end loop;
				temp(N)<='0';
		--agar nilai input R1 dapat ditampilkan pada 7segment
	WHEN S2=>
		ER2<='1'; ER1<='0';
		--inisialisasi signal pada S2
		pindahan2:for l in 0 to (N-1) loop
				temp(l)<=input(l);
				end loop;
				temp(N)<='0';
		--agar nilai input R2 dapat ditampilkan pada 7segment
	WHEN S3=>
		ER2<='0'; ER1<='0';
		--inisialisasi signal pada S3
		if reset='1' and Lm1='0' and sm='0' then
		Lm1<='1';
		Lm2<='1';
		sm <='0';
		elsif reset ='1'and Lm1='1' then
		Lm1<='0';
		Lm2<='0';
		Sm<='1';
		end if;
		--control signal untuk multiplier (mengatur nilai Load dan S pada multiplier)
	WHEN S4=>
		if reset ='1'and Ld='0' and Sd='0' then
		Ld<='1';
		Ed<='1';
		sd<='0';
		elsif reset ='1'and Ld='1' then
		Ld<='0';
		Ed<='0';
		Sd<='1';
		end if;
		--control signal untuk divider (mengatur nilai Load, Enable, dan S pada divider)
	When S5=>
			if kseri='0' then
				seri: for x in 0 to N loop
				temp(x)<=Rseri(x);
				end loop;
				--agar nilai Rseri dapat ditampilkan pada 7segment
			elsif kparalel='0' then
				paralel: for x in 0 to N loop
				temp(x)<=Rparalel(x);
				end loop;
				--agar nilai Rparalel dapat ditampilkan pada 7segment
			elsif ksisa='0' then
				sisa: for x in 0 to N loop
				temp(x)<=Rsisa(x);
				end loop;
				--agar nilai Rsisa dapat ditampilkan pada 7segment
			end if;
	end case;
END PROCESS;
RegisterR1: regne GENERIC MAP (N=>N)
PORT MAP (input, reset, ER1, Clock, R1);
--memanggil register untuk menyimpan R1
RegisterR2: regne GENERIC MAP (N=>N)
PORT MAP (input, reset, ER2, Clock, R2);
--memanggil register untuk menyimpan R2
Add : adder GENERIC MAP(N=>8)
PORT MAP (
    R1 =>  R1,
    R2 =>  R2,
    CI => CI,
    sumR1R2 => Rseri );
    --memanggil adder
Multiply: Multiplier generic map (N=>N, NN=>NN)
PORT MAP (
	Clock => clock,
	reset => reset,
	LR1 => Lm1,
	LR2 => Lm2,
	s => sm,
	R1=> R1,
	R2 => R2,
	P => P,
	Done => Done1 );
	--memanggil multiplier
Divide: Divider generic map (N=>NN)
PORT MAP (
	Clock => clock,
	reset => reset,
	s => sd,
	LP => LD,
	Esum => ED,
	R1xR2 => P,
	sumR1R2 => Rseri,
	Rhasil => Rparalel,
	Rsisa => Rsisa,
	Done => Done2 );
	--memanggil divider
Convert: Converter generic map (N=>(N+1))
PORT MAP(
        clock => clock,     
        bit_in => temp,
        bcd0 => bcd0, 
        bcd1 => bcd1,
        bcd2 =>  bcd2
    );
    --memanggil converter dari binary to bcd
Display1: BCDto7SEG
PORT MAP (bcd0,HEX0);
--menampilkan satuan pada HEX0
Display2: BCDto7SEG
PORT MAP (bcd1,HEX1);
--menampilkan puluhan pada HEX1
Display3: BCDto7SEG
PORT MAP (bcd2,HEX2);
--menampilkan ratusan pada HEX2

END behavior;
	


			

	



			