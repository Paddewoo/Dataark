----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 11/20/2023 12:19:21 PM
-- Design Name: 
-- Module Name: avbrottshanterare - Behavioral
-- Project Name: 
-- Target Devices: 
-- Tool Versions: 
-- Description: 
-- 
-- Dependencies: 
-- 
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
-- 
----------------------------------------------------------------------------------


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

library work;
use work.CPU_pkg.all;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity avbrottshanterare is
    Port ( 
           ret_addr : in STD_LOGIC_VECTOR (5 downto 0);
           int_done : in STD_LOGIC;
           clk : in STD_LOGIC;                              -- kommer utifrån
           rst : in STD_LOGIC;                              -- kommer utifrån
           int0 : in STD_LOGIC;
           int_addr : out STD_LOGIC_VECTOR(5 downto 0);
           int_mux : out STD_LOGIC;
           save_wreg : out STD_LOGIC;
           restore_wreg : out STD_LOGIC );
end avbrottshanterare;

architecture Behavioral of avbrottshanterare is

    type state_type is (Idle1, Save, Idle2, Restore);
    signal current_state, next_state : state_type;

    component avbrott_work_wreg is
        port(
            clk   : in  std_logic;
            ena   : in  std_logic;
            n_rst : in  std_logic;
            D 	  : in  std_logic_vector(5 downto 0);
            Q     : out std_logic_vector(5 downto 0)
        );
    end component;
    
    signal s_int_addr : std_logic_vector(5 downto 0);
    signal s_ret_addr : std_logic_vector(5 downto 0);
    signal s_save_ret_addr : std_logic := '0';
    

begin

    with current_state select s_save_ret_addr <=
        '1' when Save,
        '0' when others;
    s_ret_addr <= ret_addr;


    R0: entity work.avbrott_work_reg
    port map(
        clk  => clk,
        ena => s_save_ret_addr,
        n_rst => rst,
        D => ret_addr, 
        Q => s_int_addr
    );


    process(clk)
    begin
    if rising_edge(clk) then
        if(rst = '0') then 
              current_state <= Idle1;
        else
              current_state <= next_state;
       end if;
    end if;
    end process;
      
    process(current_state, int0, int_done)
    begin
       next_state <= current_state;     -- Idle1
       case current_state is  
       when Idle1 =>
        if(int0 = '1')then
            next_state <= Save;
           end if;
        when Save =>
            next_state <= Idle2;
        when Idle2 =>
            if int_done = '1' then
                next_state <= Restore;
                end if;
            when Restore =>
                next_state <= Idle1;
            end case;
      end process;
      
      process(current_state,int0, int_done)
      begin
        case current_state is
            when Idle1 => 
                int_addr <= "------"; 
                save_wreg <= '0';
                restore_wreg <= '0';
                int_mux <= '0';
            when Save => 
              int_addr <= INTERRUPT_ADDRESS;
                --int_addr <= "001111";
                save_wreg <= '1';
                restore_wreg <= '0';
                int_mux <= '1';
            when Idle2 =>
                int_addr <= "------";
                save_wreg <= '0';
                restore_wreg <= '0';
                int_mux <= '0';
            when Restore =>
                int_addr <= s_int_addr; -- ret adress "100111"
                save_wreg <= '0';
                restore_wreg <= '1';
                int_mux <= '1';
        end case;
    end process;
        
--end Behavioral;
  end architecture;  
    
