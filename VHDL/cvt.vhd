-- Entity: cvt
-- Architecture: structural
-- Author: hmathew1
--
library STD;
library IEEE;
use IEEE.std_logic_1164.all;

entity cvt is
  port (
	input1   : in std_logic_vector(1 downto 0); -- input Tag[1:0]
	input2   : in std_logic_vector(1 downto 0); -- input cache Tag[1:0]
	valid   : in std_logic; -- valid bit
	output   : out std_logic); -- hit / miss
end cvt;

architecture structural of cvt is

component xnor2
	port (
  	input1 : in  std_logic;
  	input2 : in  std_logic;
  	output : out std_logic
	);
  end component;

component and3
	port (
    	input1   : in  std_logic;
    	input2   : in  std_logic;
    	input3   : in  std_logic;
    	output   : out std_logic);
	end component;

signal out1, out2: std_logic;
for xnor2_1: xnor2 use entity work.xnor2(structural);
for xnor2_2: xnor2 use entity work.xnor2(structural);
for and3_1: and3 use entity work.and3(structural);

begin
	xnor2_1: xnor2 port map (input1(0), input2(0), out1);
	xnor2_2: xnor2 port map (input1(1), input2(1), out2);
	and3_1: and3 port map (out1, out2, valid, output);

end structural;


