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

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity avbrottshanterare is
    Port ( 
           ret_addr : in STD_LOGIC;
           int_done : in STD_LOGIC;
           clk : in STD_LOGIC;
           rst : in STD_LOGIC;
           int0 : in STD_LOGIC;
           int_addr : out STD_LOGIC_VECTOR(5 downto 0);
           int_mux : out STD_LOGIC;
           save_wreg : out STD_LOGIC;
           restore_wreg : out STD_LOGIC );
end avbrottshanterare;

architecture Behavioral of avbrottshanterare is

type state_type is (Idle, Save, Restore);
signal current_state, next_state : state_type;

begin
process(clk, rst)
begin
if(rst = '1') then 
    current_state <= Idle;
elsif(rising_edge(clk)) then 
    current_state <= next_state;
end if;
end process;
    
process(current_state, int0, int_done)
begin
    case current_state is
        when Idle =>
            if((int0 = '1') and (int_done = '0')) then
                next_state <= Save;
            else
                next_state <= Idle;
          end if;
         when Save =>
            if((int0 = '0') and (int_done = '1')) then
                next_state <= Restore;
            else
                next_state <= Save;
        end if;
        when Restore => 
            if((int0 = '1') and (int_done = '0')) then
                next_state <= Save;
            elsif ((int0 = '1') and (int_done = '1')) then
                next_state <= Restore;
            else 
                next_state <= Idle;
            end if;
          end case;
  end process;
  
  process(current_state)
  begin
    case current_state is
        when Idle => 
            int_addr <= "100111"; -- ret_addr
            save_wreg <= '0';
            restore_wreg <= '0';
            int_mux <= '0';
        when Save => 
            int_addr <= "0001111";
            save_wreg <= '1';
            restore_wreg <= '0';
            int_mux <= '0';
        when Restore =>
            int_addr <= "0001111";
            save_wreg <= '0';
            restore_wreg <= '1';
            int_mux <= '1';
    end case;
end process;
        
--end Behavioral;
  end architecture;  
    
