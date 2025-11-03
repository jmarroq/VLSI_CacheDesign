-- Testbench for the 2to4decoder entity
library IEEE;
use IEEE.std_logic_1164.all;

entity tb_decoder2to4 is
-- The testbench entity is typically empty
end tb_decoder2to4;

architecture behavior of tb_decoder2to4 is

    -- Declare the component (Unit Under Test - UUT)
    component decoder2to4
    port ( EN  : in  std_logic;
   	A  : in  std_logic_vector(1 downto 0);
    	Y  : out std_logic_vector(3 downto 0)
         );
    end component;

    -- Signal Declarations for connecting to the UUT ports
    -- Input signals (Initialize to '0')
    signal tb_EN  : std_logic := '0';
    signal tb_A : std_logic := '00';

    -- Output signals
    signal tb_Y : std_logic := '0000';



begin

    -- Instantiate the Unit Under Test (UUT)
    uut: decoder2to4
    port map ( EN  => tb_EN,
               A => tb_A,
               Y => tb_Y,
               );

    -- Stimulus process: Generates all input combinations
    stim_proc: process
    begin
        -- --------------------------------------------------------
        -- Phase 1: Test with the decoder DISABLED (E='0')
        -- All output lines (Y0-Y3) should be '0' regardless of A1A0
        -- --------------------------------------------------------
        tb_EN <= '0';
        
        -- E='0', A1A0="00". Expected Y="0000"
        tb_A <= '00';
        wait for 20 ns;

        -- E='0', A1A0="01". Expected Y="0000"
        tb_A <= '01';
        wait for 20 ns;

        -- E='0', A1A0="10". Expected Y="0000"
        tb_A <= '10';
        wait for 20 ns;
        
        -- E='0', A1A0="11". Expected Y="0000"
        tb_A <= '11';
        wait for 20 ns;
        
        -- --------------------------------------------------------
        -- Phase 2: Test with the decoder ENABLED (E='1')
        -- The appropriate Y line should be asserted ('1')
       tb_EN <= '1';
        
        -- E='1', A1A0="00". Expected Y="1000"
        tb_A <= '00';
        wait for 20 ns;

        -- E='1', A1A0="01". Expected Y="0100"
        tb_A <= '01';
        wait for 20 ns;

        -- E='1', A1A0="10". Expected Y="0010"
        tb_A <= '10';
        wait for 20 ns;
        
        -- E='1', A1A0="11". Expected Y="0001"
        tb_A <= '11';
        wait for 20 ns;
        wait;
    end process;

end behavior;
