library IEEE;
use IEEE.std_logic_1164.all;

entity sr_latch is
    port (
        S    : in std_logic;  -- Set input
        R    : in std_logic;  -- Reset input
        Q    : out std_logic; -- Q output
        Q_n  : out std_logic  -- Q' output (complementary)
    );
end sr_latch;

architecture behavioral of sr_latch is
    -- Internal signals for Q and Q'
    signal Q_int, Q_n_int : std_logic;
begin
    -- NOR Gate logic for SR Latch
    process(S, R)
    begin
        if (S = '1' and R = '0') then
            Q_int <= '1';  -- Set state (Q = 1)
            Q_n_int <= '0'; -- Complementary state (Q' = 0)
        elsif (S = '0' and R = '1') then
            Q_int <= '0';  -- Reset state (Q = 0)
            Q_n_int <= '1'; -- Complementary state (Q' = 1)
        -- Hold state (both inputs 0): maintain previous state
        else
            Q_int <= Q_int;
            Q_n_int <= Q_n_int;
        end if;
    end process;

    -- Output the values of Q and Q'
    Q <= Q_int;
    Q_n <= Q_n_int;

end behavioral;
