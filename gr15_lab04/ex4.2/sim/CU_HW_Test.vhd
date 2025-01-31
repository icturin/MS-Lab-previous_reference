library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.myTypes.all;

entity cu_test is
end cu_test;

architecture TEST of cu_test is

    component CU_HW
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

    signal cu_opcode_i: std_logic_vector(OP_CODE_SIZE - 1 downto 0) := RTYPE;
    signal cu_func_i: std_logic_vector(FUNC_SIZE - 1 downto 0) := RTYPE_ADD;

    -- Signal used to easily determine, while reading the waveforms, what part of the testbench is being executed
    type instructionType is (ADDx, SUBx, ANDx, ORx, NOPx, ADDI1, SUBI1, ANDI1, ORI1, ADDI2, SUBI2, ANDI2, ORI2, MOV, SREG1, SREG2, SMEM2, LMEM1, LMEM2);
    signal currentInstruction : instructionType;

    signal EN1_i, RF1_i, RF2_i, WF1_i, EN2_i, S1_i, S2_i, ALU1_i, ALU2_i, EN3_i, RM_i, WM_i, S3_i: std_logic := '0';

begin
        -- Instance of the Control Unit
        dut: CU_HW port map (
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


        -- In this process we iterate on all the possible isntructions
        -- We provide to the Control Unit the OPCODE and FUNC corresponding 
        -- to the instruction indicated in the  "currentInstruction" signal.
        -- Every new clock cycle a new instruction is given at the inputs 
        -- of the Control Unit (pipelined).
        -- Thus, after 3 clock cycles 3 different instruction will have been executed.
        CONTROL: process
        begin
                wait for 5 ns;

                -- ADD RS1,RS2,RD -> Rtype
                currentInstruction <= ADDx;
                cu_opcode_i <= RTYPE;
                cu_func_i <= RTYPE_ADD;
                wait for 2 ns;

                -- SUB R1, R2, R3
                currentInstruction <= SUBx;
                cu_opcode_i <= RTYPE;
                cu_func_i <= RTYPE_SUB;
                wait for 2 ns;

                -- AND R1, R2, R3
                currentInstruction <= ANDx;
                cu_opcode_i <= RTYPE;
                cu_func_i <= RTYPE_AND;
                wait for 2 ns;

                -- OR R1, R2, R3
                currentInstruction <= ORx;
                cu_opcode_i <= RTYPE;
                cu_func_i <= RTYPE_OR;
                wait for 2 ns;

                -- NOP R1, R2, R3
                currentInstruction <= NOPx;
                cu_opcode_i <= RTYPE;
                cu_func_i <= NOP;
                wait for 2 ns;

                -- ADDI1 R1, R2, INP1
                currentInstruction <= ADDI1;
                cu_opcode_i <= ITYPE_ADDI1;
                wait for 2 ns;

                -- SUBI1 R1, R2, INP1
                currentInstruction <= SUBI1;
                cu_opcode_i <= ITYPE_SUBI1;
                wait for 2 ns;

                -- ANDI1 R1, R2, INP1
                currentInstruction <= ANDI1;
                cu_opcode_i <= ITYPE_ANDI1;
                wait for 2 ns;

                -- ORI1 R1, R2, INP1
                currentInstruction <= ORI1;
                cu_opcode_i <= ITYPE_ORI1;
                wait for 2 ns;

                -- ADDI2 R1, R2, INP2
                currentInstruction <= ADDI2;
                cu_opcode_i <= ITYPE_ADDI2;
                wait for 2 ns;

                -- SUBI2 R1, R2, INP2
                currentInstruction <= SUBI2;
                cu_opcode_i <= ITYPE_SUBI2;
                wait for 2 ns;

                -- ANDI2 R1, R2, INP2
                currentInstruction <= ANDI2;
                cu_opcode_i <= ITYPE_ANDI2;
                wait for 2 ns;

                -- ORI2 R1, R2, INP2
                currentInstruction <= ORI2;
                cu_opcode_i <= ITYPE_ORI2;
                wait for 2 ns;

                -- MOV R1, R2
                currentInstruction <= MOV;
                cu_opcode_i <= ITYPE_MOV;
                wait for 2 ns;

                -- SREG1 R2, INP1
                currentInstruction <= SREG1;
                cu_opcode_i <= ITYPE_SREG1;
                wait for 2 ns;

                -- SREG2 R2, INP2
                currentInstruction <= SREG2;
                cu_opcode_i <= ITYPE_SREG2;
                wait for 2 ns;

                -- SMEM2 R1, R2, INP2
                currentInstruction <= SMEM2;
                cu_opcode_i <= ITYPE_SMEM2;
                wait for 2 ns;

                -- LMEM1 R1, R2, INP1
                currentInstruction <= LMEM1;
                cu_opcode_i <= ITYPE_LMEM1;
                wait for 2 ns;

                -- LMEM2 R1, R2, INP2
                currentInstruction <= LMEM2;
                cu_opcode_i <= ITYPE_LMEM2;
                wait for 2 ns;

                wait;
        end process;

end TEST;
