library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

-------------------------------------------------------------------------------
-- Top-Level Entity (TLE)
-------------------------------------------------------------------------------

entity ACC is
  generic (
    N : integer := 8);
  port (
    A          : in  std_logic_vector(N-1 downto 0);
    B          : in  std_logic_vector(N-1 downto 0);
    CLK        : in  std_logic;
    RST_n      : in  std_logic;
    ACCUMULATE : in  std_logic;
    Y          : out std_logic_vector(N-1 downto 0));
end entity ACC;


-------------------------------------------------------------------------------
-- Structural Architecture Definition
-------------------------------------------------------------------------------

architecture struct of ACC is

  -----------------------------------------------------------------------------
  -- Generic Mux Component
  -----------------------------------------------------------------------------

  component MUX21_GENERIC is

    generic (N : integer := 8);
    port (
      A   : in  std_logic_vector(N-1 downto 0);
      B   : in  std_logic_vector(N-1 downto 0);
      SEL : in  std_logic;
      Y   : out std_logic_vector(N-1 downto 0));

  end component;

  -----------------------------------------------------------------------------
  -- Generic FF Component
  -----------------------------------------------------------------------------

  component FD_GENERIC is

    generic (N : integer := 8);
    port (
      D     : in  std_logic_vector(N-1 downto 0);
      CK    : in  std_logic;
      RESET : in  std_logic;
      Q     : out std_logic_vector(N-1 downto 0));

  end component;

  -----------------------------------------------------------------------------
  -- Generic Ripple Carry Adder Component
  -----------------------------------------------------------------------------

  component RCA_GENERIC is

    generic (N : integer := 8);
    port (
      A  : in  std_logic_vector(N-1 downto 0);
      B  : in  std_logic_vector(N-1 downto 0);
      Ci : in  std_logic;
      S  : out std_logic_vector(N-1 downto 0);
      Co : out std_logic);

  end component;


  -----------------------------------------------------------------------------
  -- Signal Declaration
  -----------------------------------------------------------------------------

  signal feed_back     : std_logic_vector(N-1 downto 0);
  signal MuxOutAdderIn : std_logic_vector(N-1 downto 0);
  signal out_add       : std_logic_vector(N-1 downto 0);
  signal rst           : std_logic;

begin  -- architecture struct

  rst <= not(RST_n);

  MUX_GEN_1 : MUX21_GENERIC
    generic map (
      N => N)
    port map (
      A   => B,
      B   => feed_back,
      SEL => ACCUMULATE,
      Y   => MuxOutAdderIn);

  FD_GEN_1 : FD_GENERIC
    generic map (
      N => N)
    port map (
      D     => out_add,
      CK    => clk,
      RESET => rst,      -- The register component has a Active High
                                -- reset, out TLE has a Active Low Reset
      Q     => feed_back);

  RCA_GEN_1 : RCA_GENERIC
    generic map (
      N => N)
    port map (
      A  => A,
      B  => MuxOutAdderIn,
      Ci => '0',
      S  => out_add);

  Y <= feed_back;

end architecture struct;



-------------------------------------------------------------------------------
-- Behavioral Architecture Definition
-------------------------------------------------------------------------------

architecture beh of ACC is

  signal feed_back     : std_logic_vector(N-1 downto 0);
  signal MuxOutAdderIn : std_logic_vector(N-1 downto 0);
  signal out_add       : std_logic_vector(N-1 downto 0);

begin  -- architecture beh

  -- purpose: This process describes the behavior of the MUX
  -- type   : combinational
  -- inputs : B, ACCUMULATE, feed_back
  -- outputs: MuxOutAdderIn
  Mux_Proc: process (B, ACCUMULATE, feed_back) is
  begin  -- process Mux_Proc
    if ACCUMULATE = '1' then
      MuxOutAdderIn <= feed_back;
    else
      MuxOutAdderIn <= B;
    end if;
  end process Mux_Proc;

  -- purpose: This porcess describes the behavior of the Adder
  -- type   : combinational
  -- inputs : A, MuxOutAdderIn
  -- outputs: out_add
  Adder_Proc: process (A, MuxOutAdderIn) is
  begin  -- process Adder_Proc
    out_add <= std_logic_vector(unsigned(A) + unsigned(MuxOutAdderIn));
  end process Adder_Proc;

   -- purpose: This process describes the behavior of the Register
   -- type   : sequential
   -- inputs : CLK, RST, out_add
   -- outputs: feed_back
  Register_Proc: process (CLK, RST_n) is
   begin  -- process Register_Proc
     if rising_edge(CLK) then
       if RST_n = '0' then
         feed_back <= (others => '0');
       else
         feed_back <= out_add;
       end if;
     end if;
   end process Register_Proc;

   Y <= feed_back;

end architecture beh;



configuration CFG_ACC_STRUCT of ACC is
  for struct
    for FD_GEN_1 : FD_GENERIC
      use configuration WORK.CFG_FD_SYNCARCH;
    end for;

    for MUX_GEN_1 : MUX21_GENERIC
      use configuration WORK.CFG_MUX21_GEN_STRUCTURAL;
    end for;

    for RCA_GEN_1 : RCA_GENERIC
      use configuration WORK.CFG_RCA_STRUCTURAL;
    end for;
  end for;
end CFG_ACC_STRUCT;

configuration CFG_ACC_BEH of ACC is

  for beh
  end for;
  
end CFG_ACC_BEH;
