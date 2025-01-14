library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.constants.all;

entity tb is

end entity tb;


architecture tb_arch of tb is

  component LFSR16 is
    port (
      CLK, RESET, LD, EN : in  std_logic;
      DIN                : in  std_logic_vector(15 downto 0);
      PRN                : out std_logic_vector(15 downto 0);
      ZERO_D             : out std_logic);
  end component LFSR16;

component completeAdderSynchronous is
    generic (
        N: integer := numBit;
        RADIX : INTEGER := radixN);

    port (
        A_tle    : in  std_logic_vector(N-1 downto 0);          -- Input operand
        B_tle    : in  std_logic_vector(N-1 downto 0);          -- Input operand
        Cin_tle : in  std_logic;                                -- CarryIn (from the external world)
        Cout_tle : out std_logic;                               -- CarryOut (to the external world)
        Sum_tle  : out std_logic_vector(N-1 downto 0);          -- Result

        Clk  : in  std_logic;
        rst  : in  std_logic);
end component completeAdderSynchronous;

  constant Period              : time      := 1 ns;  -- Clock period (1 GHz)
  signal clk_s                   : std_logic := '0';
  signal rst_s, LD, EN, ZERO_D : std_logic;
  signal DIN, PRN              : std_logic_vector(15 downto 0);

  signal A_s, B_s      : std_logic_vector(numBit-1 downto 0) := (others => '0');
  signal Cin_s, Cout_S : std_logic;                           
  signal Sum_s         : std_logic_vector(numBit-1 downto 0);

begin  -- architecture tb_arch

  Adder : completeAdderSynchronous generic map (
    N     => numBit,
    RADIX => radixN)
    port map (
      A_tle    => A_s,
      B_tle    => B_s,
      Cin_tle  => Cin_s,
      Cout_tle => Cout_s,
      Sum_tle  => Sum_s,
      clk => clk_s,
      rst => rst_s);

  -- Instanciate the Unit Under Test (UUTs)
  UUT : LFSR16 port map (CLK => clk_s, RESET => rst_s, LD => LD, EN => EN,
                         DIN => DIN, PRN => PRN, ZERO_D => ZERO_D);

  clk_s   <= not clk_s  after Period/2;
  rst_s <= '1', '0' after 2*Period;

  -----------------------------------------------------------------------------
  -- Comment/Uncomment for LFSR input
  -----------------------------------------------------------------------------
  -- LSFR_stim: process(clk_s)
  -- begin
  --   if rising_edge(clk_s) then
    
  --     Cin_s <= '0';      -- Test ADDER functionalities
  --   --Cin_s  <= '1';                        -- Test SUBTRACTOR functionalities
  --     A_s(0) <= PRN(0);
  --     A_s(5) <= PRN(2);
  --     A_s(3) <= PRN(4);
  --     A_s(1) <= PRN(6);
  --     A_s(4) <= PRN(8);
  --     A_s(2) <= PRN(10);
  --     A_s(6) <= PRN(12);
  --     A_s(7) <= PRN(14);

  --     B_s(0) <= PRN(15);
  --     B_s(5) <= PRN(13);
  --     B_s(3) <= PRN(11);
  --     B_s(1) <= PRN(9);
  --     B_s(4) <= PRN(7);
  --     B_s(2) <= PRN(5);
  --     B_s(6) <= PRN(3);
  --     B_s(7) <= PRN(1);
  -- end if;
  -- end process LSFR_stim;
  

  -----------------------------------------------------------------------------
  -- Comment/Uncomment for special input patterns
  -----------------------------------------------------------------------------
  specialStimuli : process
  begin
    Cin_s <= '0';
    A_s   <= X"0000FFFF";
    B_s   <= X"000000FF";
    wait for 5 ns;
    A_s   <= X"FFFFFFFF";
    B_s   <= X"FFFFFFFF";
    wait for 5 ns;
    A_s   <= X"FFFF0000";
    B_s   <= X"0001FFFF";
    wait for 5 ns;
    A_s   <= X"FFFFFFFF";
    B_s   <= X"00000001";
    wait;
  end process specialStimuli;




  STIMULUS1 : process
  begin
    DIN <= "0000000000000001";
    EN  <= '1';
    LD  <= '1';
    wait for 2 * PERIOD;
    LD  <= '0';
    wait for (65600 * PERIOD);
  end process STIMULUS1;
  
end architecture tb_arch;

