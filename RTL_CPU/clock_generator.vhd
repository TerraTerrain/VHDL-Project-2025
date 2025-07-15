entity clock_generator is
generic( init_value : bit := '1';
        init_delay : time := 1 ns;
        T_high, T_low : time := 1 ns;
        T_active : time := 100 ns );
port( clk : buffer bit:=init_value );

end clock_generator;

architecture Behavioral of clock_generator is

begin
clk <= not init_value, init_value after init_delay
        when now = 0 ns else
        '1' after T_low
        when clk = '0' and now > 0 ns and now < T_active else
        '0' after T_high
        when clk = '1' and now > 0 ns and now < T_active else
clk;


end Behavioral;
