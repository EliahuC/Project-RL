----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 05.03.2023 15:17:26
-- Design Name: 
-- Module Name: project_reti_logiche - Behavioral
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

entity project_reti_logiche is

port (

    --segnali ingresso
    i_clk : in std_logic;
    i_rst : in std_logic;
    i_start : in std_logic;
    i_w : in std_logic;
    
    --uscite
    o_z0 : out std_logic_vector(7 downto 0);
    o_z1 : out std_logic_vector(7 downto 0);
    o_z2 : out std_logic_vector(7 downto 0);
    o_z3 : out std_logic_vector(7 downto 0);
    
    --done
    o_done : out std_logic;
    
    --input/output memoria
    o_mem_addr : out std_logic_vector(15 downto 0);
    i_mem_data : in std_logic_vector(7 downto 0);
    
    --write enable 
    o_mem_we : out std_logic :='0';
    
    --data enable 
    o_mem_en : out std_logic := '0'
    
    );

end project_reti_logiche;



architecture Behavioral of project_reti_logiche is
   
   --parametri di supporto
   signal uscita : std_logic_vector(1 downto 0);
   signal last_z0 : std_logic_vector(7 downto 0);
   signal last_z1 : std_logic_vector(7 downto 0);
   signal last_z2 : std_logic_vector(7 downto 0);
   signal last_z3 : std_logic_vector(7 downto 0);
   signal indirizz: std_logic_vector (15 downto 0);
  
   --stati FSM
   type S is (IDLE, READ_TWO, READ_OTHER,SET_MEM, ASK_MEM, WAIT_MEM, READ_MEM, SET_EXITS);
   signal curr_state : S ;
   
  begin 
--FSM
 fsm : process( i_clk,i_rst)
       begin
     --reset
     if(i_rst='1') then
         curr_state<= IDLE;
         o_z0<=(others=>'0');
         o_z1<=(others=>'0');
         o_z2<=(others=>'0');
         o_z3<=(others=>'0');
         last_z0<=(others=>'0');
         last_z1<=(others=>'0');
         last_z2<=(others=>'0');
         last_z3<=(others=>'0'); 
         uscita<=(others=>'0');
         indirizz<=(others=>'0');
         o_mem_addr<=(others=>'0');
         o_done<='0';
         o_mem_en<='0';

     
     elsif (rising_edge(i_clk)) then
        
        case curr_state is
          when IDLE =>
          --setting variabili
               o_z0<="00000000";
               o_z1<="00000000";
               o_z2<="00000000";
               o_z3<="00000000"; 
               o_done<='0';
               o_mem_addr<=(others=>'0');
               indirizz<=(others=>'0');
               uscita<=(others=>'0');
               o_mem_en<='0';
               --inizio lettura
              if (i_start= '1') then 
                curr_state<=READ_TWO;
                uscita(1)<=i_w;
              end if ;
           
          when READ_TWO=>
                 uscita(0)<=i_w;  
                 curr_state<=READ_OTHER ;
       
           --leggo bit indirizzo mem 
          when READ_OTHER=> 
              if (i_start='1') then
                   indirizz(15 downto 1)<=indirizz(14 downto 0);
                   indirizz(0)<=i_w;  
              elsif (i_start='0') then 
                curr_state<=SET_MEM;
                o_mem_addr<=(others=>'0');
              end if;
       
        --carico valore indirizzo mem in o_mem    
        when SET_MEM=>
           o_mem_addr<= indirizz;
           curr_state<= ASK_MEM;
        
        --passo indirizzo a memoria    
        when ASK_MEM=>
            o_mem_en<='1';
            curr_state<=WAIT_MEM;
        
        --ciclo di clock di attesa
        when WAIT_MEM=>
               curr_state<=READ_MEM;
               o_mem_en<='0';
               
       --leggo dato da memoria e lo carico su uscita giusta
        when READ_MEM=> 
            if(uscita ="00") then last_z0<=i_mem_data;
            elsif(uscita = "01") then last_z1<=i_mem_data;
            elsif (uscita= "10") then last_z2<=i_mem_data;
            else last_z3<=i_mem_data; 
            end if;  
            curr_state<=SET_EXITS;
       
        --setting uscite e print
        when SET_EXITS=>
             o_z0<=last_z0;
             o_z1<=last_z1;
             o_z2<=last_z2;
             o_z3<=last_z3;
             o_done<='1';
             curr_state<=IDLE;

        end case; 
        end if;   
 end process;
      
end Behavioral;

