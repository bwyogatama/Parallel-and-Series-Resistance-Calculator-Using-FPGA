library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
 
entity converter is
    generic(N: positive := 9);
    port(
        clock: in std_logic;
        bit_in: in std_logic_vector(N-1 downto 0);
        bcd0, bcd1, bcd2: out std_logic_vector(3 downto 0)
    );
end converter ;
 
architecture behaviour of converter is
    type states is (Mulai, shift, Selesai);
    --mendefinisikan tipe baru yaitu states yang terdiri dari 3 states (mulai,shift,selesai)
    signal state, state_next: states;
 
    signal biner, bit_next: std_logic_vector(N-1 downto 0);
    signal Bc_dec, Bc_dec_reg, Bc_dec_next: std_logic_vector(11 downto 0); 
    signal Bc_dec_out_reg, Bc_dec_out_reg_next: std_logic_vector(11 downto 0);
    signal shift_count, shift_count_next: natural range 0 to N;
    --mendefinisikan signal yang akan digunakan
begin
 
    process(clock)
    begin
       
        if falling_edge(clock) then
    --ketika clock berganti ke '0'
            biner <= bit_next;
            Bc_dec <= Bc_dec_next;
            state <= state_next;
            Bc_dec_out_reg <= Bc_dec_out_reg_next;
            shift_count <= shift_count_next;
        end if;
    end process;
 
    convert:
    process(state, biner, bit_in, Bc_dec, Bc_dec_reg, shift_count)
    begin
        state_next <= state;
        Bc_dec_next <= Bc_dec;
        bit_next <= biner;
        shift_count_next <= shift_count;
     
        case state is
            when Mulai =>
                state_next <= shift;
                bit_next <= bit_in;
                Bc_dec_next <= (others => '0');
                shift_count_next <= 0;
            when shift =>
                if shift_count = N then
                    state_next <= Selesai;
              -- jika sudah digeser sebanyak N kali maka akan masuk ke state terakhir
                else
                    bit_next <= biner(N-2 downto 0) & 'L';
                    Bc_dec_next <= Bc_dec_reg(10 downto 0) & biner(N-1);
                    shift_count_next <= shift_count + 1;
              --proses penggeseran
                end if;
            when Selesai =>
                state_next <= Mulai;
        end case;
    end process;
 
    Bc_dec_reg(11 downto 8) <= Bc_dec(11 downto 8) + 3 when Bc_dec(11 downto 8) > 4 else
                             Bc_dec(11 downto 8);
    Bc_dec_reg(7 downto 4) <= Bc_dec(7 downto 4) + 3 when Bc_dec(7 downto 4) > 4 else
                            Bc_dec(7 downto 4);
    Bc_dec_reg(3 downto 0) <= Bc_dec(3 downto 0) + 3 when Bc_dec(3 downto 0) > 4 else
                            Bc_dec(3 downto 0);
    -- cara mengubah dari biner ke bcd adalah dengan ,menggeser kemudian dibandingkan, apabila >4 maka ditambah 3
 
    Bc_dec_out_reg_next <= Bc_dec when state = Selesai else
                         Bc_dec_out_reg;
 
    bcd2 <= Bc_dec_out_reg(11 downto 8);
    bcd1 <= Bc_dec_out_reg(7 downto 4);
    bcd0 <= Bc_dec_out_reg(3 downto 0);
 
end behaviour;
