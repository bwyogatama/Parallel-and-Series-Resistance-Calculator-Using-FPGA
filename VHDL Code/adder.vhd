library ieee;
use ieee.std_logic_1164.all;

entity adder is
  generic (
  	N:integer
  );
  port (
    R1:  in  std_logic_vector(N-1 downto 0);
    R2:  in  std_logic_vector(N-1 downto 0);
    CI: in  std_logic;
    sumR1R2:  out std_logic_vector((2*N-1) downto 0);
    CO: buffer std_logic
  );
end entity adder;

architecture behavior of adder is

  component fulladd is
    port (
      A:  in  std_logic;
      B:  in  std_logic;
      CI: in  std_logic;
      O:  out std_logic;
      CO: out std_logic
    );
  end component fulladd;

  signal carry_internal: std_logic_vector(N downto 0);

begin

  adders: for X in 0 to N-1 generate

    myfulladder: fulladd
      port map (
        A  => R1(X),
        B  => R2(X),
        CI => carry_internal(X),
        O=>sumR1R2(X),
        CO => carry_internal(X+1)
      );

  end generate;

  carry_internal(0) <= CI;
  CO <= carry_internal(N);
  sumR1R2(N)<=CO;
  zero: for i in (N+1) to (2*N-1) generate
	sumR1R2(i)<='0';
	end generate;

end behavior;