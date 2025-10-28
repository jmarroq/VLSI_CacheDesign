-- Entity: tx_8bit -- 8-bit transmission gate/output enable
-- Architecture : structural

library STD;
library IEEE;
use IEEE.std_logic_1164.all;

entity tx_8bit is
    port (
        sel   : in std_logic;  -- Enable signal
        selnot: in std_logic;  -- Inverse of enable signal (optional, but follows original)
        input : in std_logic_vector(7 downto 0); -- 8-bit data input
        output: out std_logic_vector(7 downto 0) -- 8-bit data output
    );
end tx_8bit;

architecture structural of tx_8bit is
begin
    txprocess: process (sel, selnot, input)
    begin
        -- If the enable conditions are met
        if (sel = '1' and selnot = '0') then
            output <= input; -- Pass the 8-bit input to the 8-bit output
        else
            -- Set all 8 bits of the output to high-impedance ('Z')
            output <= (others => 'Z'); 
        end if;
    end process txprocess;
end structural;
  
