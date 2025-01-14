library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.myTypes.all;

entity cu_test is
end cu_test;

architecture TEST of cu_test is

    component cu_up
       port (
              -- FIRST PIPE STAGE OUTPUTS
              EN1    : out std_logic;               -- enables the register file and the pipeline registers
              RF1    : out std_logic;               -- enables the read port 1 of the register file
              RF2    : out std_logic;               -- enables the read port 2 of the register file
              WF1    : out std_logic;               -- enables the write port of the register file
              -- SECOND PIPE STAGE OUTPUTS
              EN2    : out std_logic;               -- enables the pipe registers
              S1     : out std_logic;               -- input selection of the first multiplexer
              S2     : out std_logic;               -- input selection of the second multiplexer
              ALU1   : out std_logic;               -- alu control bit
              ALU2   : out std_logic;               -- alu control bit
              -- THIRD PIPE STAGE OUTPUTS
              EN3    : out std_logic;               -- enables the memory and the pipeline registers
              RM     : out std_logic;               -- enables the read-out of the memory
              WM     : out std_logic;               -- enables the write-in of the memory
              S3     : out std_logic;               -- input selection of the multiplexer
              -- INPUTS
              OPCODE : in  std_logic_vector(OP_CODE_SIZE - 1 downto 0);
              FUNC   : in  std_logic_vector(FUNC_SIZE - 1 downto 0);              
              Clk : in std_logic;
              Rst : in std_logic);                  -- Active Low
    end component;

    signal Clock: std_logic := '0';
    signal Reset: std_logic := '1';

    signal cu_opcode_i: std_logic_vector(OP_CODE_SIZE - 1 downto 0) := (others => '0');
    signal cu_func_i: std_logic_vector(FUNC_SIZE - 1 downto 0) := (others => '0');

    type stateType is (XXX, ADDx, SUBx, ANDx, ORx, NOPx, ADDI1, SUBI1, ANDI1, ORI1, ADDI2, SUBI2, ANDI2, ORI2, MOV, SREG1, SREG2, SMEM2, LMEM1, LMEM2);
    signal currentInstruction : stateType := XXX;

    signal EN1_i, RF1_i, RF2_i, WF1_i, EN2_i, S1_i, S2_i, ALU1_i, ALU2_i, EN3_i, RM_i, WM_i, S3_i: std_logic := '0';

begin

        -- instance of DLX
       dut: cu_up
       port map (
                 -- OUTPUTS
                 EN1    => EN1_i,
                 RF1    => RF1_i,
                 RF2    => RF2_i,
                 WF1    => WF1_i,
                 EN2    => EN2_i,
                 S1     => S1_i,
                 S2     => S2_i,
                 ALU1   => ALU1_i,
                 ALU2   => ALU2_i,
                 EN3    => EN3_i,
                 RM     => RM_i,
                 WM     => WM_i,
                 S3     => S3_i,
                 -- INPUTS
                 OPCODE => cu_opcode_i,
                 FUNC   => cu_func_i,            
                 Clk    => Clock,
                 Rst    => Reset
               );

        Clock <= not Clock after 1 ns;
	Reset <= '0', '1' after 6 ns;


        CONTROL: process
        begin

        wait for 6.5 ns;
        -------------------------------------------------------------------------------
        -- RTYPE instructions 
        -------------------------------------------------------------------------------
        cu_func_i <= RTYPE; 
        
        -- ADD RS1,RS2,RD -> Rtype
        currentInstruction <= ADDx;
        cu_opcode_i <= RTYPE_ADD_addr;
        wait for 6 ns;

        -- SUB R1, R2, R3
        currentInstruction <= SUBx;
        cu_opcode_i <= RTYPE_SUB_addr;
        wait for 6 ns;

        -- AND R1, R2, R3
        currentInstruction <= ANDx;
        cu_opcode_i <= RTYPE_AND_addr;
        wait for 6 ns;

        -- OR R1, R2, R3
        currentInstruction <= ORx;
        cu_opcode_i <= RTYPE_OR_addr;
        wait for 6 ns;

        -- OR R1, R2, R3
        currentInstruction <= NOPx;
        cu_opcode_i <= NOP_addr;
        wait for 6 ns;

        -----------------------------------------------------------------------
        -- ITYPE instructions 
        -----------------------------------------------------------------------

        cu_func_i <= ITYPE;
        
        -- ADDI1 R1, R2, INP1
        currentInstruction <= ADDI1;
        cu_opcode_i <= ITYPE_ADDI1_addr;
        wait for 6 ns;

        -- SUBI1 R1, R2, INP1
        currentInstruction <= SUBI1;
        cu_opcode_i <= ITYPE_SUBI1_addr;
        wait for 6 ns;

        -- ANDI1 R1, R2, INP1
        currentInstruction <= ANDI1;
        cu_opcode_i <= ITYPE_ANDI1_addr;
        wait for 6 ns;

        -- ORI1 R1, R2, INP1
        currentInstruction <= ORI1;
        cu_opcode_i <= ITYPE_ORI1_addr;
        wait for 6 ns;

        -- ADDI2 R1, R2, INP2
        currentInstruction <= ADDI2;
        cu_opcode_i <= ITYPE_ADDI2_addr;
        wait for 6 ns;

        -- SUBI2 R1, R2, INP2
        currentInstruction <= SUBI1;
        cu_opcode_i <= ITYPE_SUBI2_addr;
        wait for 6 ns;

        -- ANDI2 R1, R2, INP2
        currentInstruction <= ANDI2;
        cu_opcode_i <= ITYPE_ANDI2_addr;
        wait for 6 ns;

        -- ORI2 R1, R2, INP2
        currentInstruction <= ORI2;
        cu_opcode_i <= ITYPE_ORI2_addr;
        wait for 6 ns;

        -- MOV R1, R2
        currentInstruction <= MOV;
        cu_opcode_i <= ITYPE_MOV_addr;
        wait for 6 ns;

        -- SREG1 R2, INP1
        currentInstruction <= SREG1;
        cu_opcode_i <= ITYPE_SREG1_addr;
        wait for 6 ns;

        -- SREG2 R2, INP2
        currentInstruction <= SREG2;
        cu_opcode_i <= ITYPE_SREG2_addr;
        wait for 6 ns;

        -- SMEM2 R1, R2, INP2
        currentInstruction <= SMEM2;
        cu_opcode_i <= ITYPE_SMEM2_addr;
        wait for 6 ns;

        -- LMEM1 R1, R2, INP1
        currentInstruction <= LMEM1;
        cu_opcode_i <= ITYPE_LMEM1_addr;
        wait for 6 ns;

        -- LMEM2 R1, R2, INP2
        currentInstruction <= LMEM2;
        cu_opcode_i <= ITYPE_LMEM2_addr;
        wait for 6 ns;

        wait;
        end process;

end TEST;
