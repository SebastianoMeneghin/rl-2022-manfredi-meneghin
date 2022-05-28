----------------------------------------------------------------------------------
----------------------------------------------------------------------------------
--------------    Progetto Reti Logiche    ---------------------------------------
--------------         AA 2021-2022        ---------------------------------------
-------------- Codificatore Convoluzionale ---------------------------------------
----------------------------------------------------------------------------------
----------------------------------------------------------------------------------
---------- Manfredi Giovanni   Meneghin Sebastiano -------------------------------
----------      937160              937058         -------------------------------
----------     10708042            10627650        -------------------------------
----------------------------------------------------------------------------------
----------------------------------------------------------------------------------



----------------------------------------------------------------------------------
-- DATAPATH: rappresenta il trasferimento dei dati -------------------------------
-- Il suo comportamento è regolato dalla FSM presente più avanti nel codice ------
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;


entity datapath is
    port ( i_clk   : in std_logic;
           i_rst   : in std_logic;
           i_start : in std_logic;
           i_data  : in std_logic_vector(7 downto 0);
           o_data  : out std_logic_vector(7 downto 0);
           o_end   : out std_logic_vector(7 downto 0);
           r1_load : in std_logic;
           r2_load : in std_logic;
           r3_load : in std_logic;
           r4_load : in std_logic;
           r5_load : in std_logic;
           d0_load : in std_logic;
           d1_load : in std_logic;
           d0_sel  : in std_logic;
           d1_sel  : in std_logic;
           c1_sel  : in std_logic_vector(2 downto 0);
           c2_sel  : in std_logic_vector(1 downto 0);
           c5_sel  : in std_logic;
           aI_sel  : in std_logic;
           aO_sel  : in std_logic;
           aI_load : in std_logic;
           aO_load : in std_logic;
           o_aI    : out std_logic_vector(15 downto 0);
           o_aO    : out std_logic_vector(15 downto 0)
           
         );
end datapath;


architecture Behavioral of datapath is
    signal o_reg1  : std_logic_vector(7 downto 0);
    signal o_reg2  : std_logic_vector(1 downto 0);
    signal o_reg3  : std_logic_vector(7 downto 0);
    signal o_reg4  : std_logic_vector(7 downto 0);
    signal o_reg5  : std_logic_vector(7 downto 0);
    signal o_regD0 : std_logic;
    signal o_regD1 : std_logic;
    signal o_muxC1 : std_logic;
    signal o_muxC5 : std_logic_vector(7 downto 0);
    signal o_muxD0 : std_logic;
    signal o_muxD1 : std_logic;
    signal o_sub   : std_logic_vector(7 downto 0);
    signal o_regAI : std_logic_vector(15 downto 0);
    signal o_regAO : std_logic_vector(15 downto 0);
    signal o_muxAI : std_logic_vector(15 downto 0);
    signal o_muxAO : std_logic_vector(15 downto 0);
    signal o_sumAI : std_logic_vector(15 downto 0);
    signal o_sumAO : std_logic_vector(15 downto 0);
    signal p1k     : std_logic;
    signal p2k     : std_logic;
begin



----------------------------------------------------------------------------------
------ Parte Convolutore, lettura da memoria, scrittura in memoria ---------------
----------------------------------------------------------------------------------

    -- Registro R1 con 8 bit di memoria
    process(i_clk, i_rst)
    begin
        if (i_rst = '1') then
            o_reg1 <= "00000000";
        elsif rising_edge(i_clk) then
            if(r1_load = '1') then
                o_reg1 <= i_data;
            end if;
        end if;
    end process;
    
    
    -- Multiplexer C1 
    with c1_sel select
        o_muxC1 <=  o_reg1(7) when "000",
                    o_reg1(6) when "001",
                    o_reg1(5) when "010",
                    o_reg1(4) when "011",
                    o_reg1(3) when "100",
                    o_reg1(2) when "101",
                    o_reg1(1) when "110",
                    o_reg1(0) when "111",
                    'X' when others;
    
    
    -- Multiplexer per il Registro D0 (convolutore)
    with d0_sel select
        o_muxD0 <=  '0' when '0',
                    o_muxC1 when '1',
                    'X' when others;
    
                    
    -- Registro D0 (convolutore)                
    process(i_clk, i_rst)
    begin
        if(i_rst = '1') then
            o_regD0 <= '0';
        elsif rising_edge(i_clk) then
            if(d0_load = '1') then
                o_regD0 <= o_muxD0;
            end if;
        end if;
    end process;
    
    
    -- Multiplexer per il Registro D1 (convolutore)                
    with d1_sel select
        o_muxD1 <=  '0' when '0',
                    o_regD0 when '1',
                    'X' when others;
    
                    
    -- Registro D1 (convolutore)                
    process(i_clk, i_rst)
    begin
        if(i_rst = '1') then
            o_regD1 <= '0';
        elsif rising_edge(i_clk) then
            if(d1_load = '1') then
                o_regD1 <= o_muxD1;
            end if;
        end if;
    end process;
    
    
    -- Uscite del convolutore
    p1k <= o_muxC1 xor o_regD1;
    p2k <= (o_muxC1 xor o_regD0)xor o_regD1;
    
    
    -- Registro R2                
    process(i_clk, i_rst)
    begin
        if(i_rst = '1') then
            o_reg2 <= "00";
        elsif rising_edge(i_clk) then
            if(r2_load = '1') then
                o_reg2 <= std_logic_vector'(p1k & p2k);
            end if;
        end if;
    end process;
    
    
    -- Registro R3                
    process(i_clk, i_rst)
    begin
        if(i_rst = '1') then
            o_reg3 <= "00000000";
        elsif rising_edge(i_clk) then
            if(r3_load = '1') then
                if(c2_sel = "11")then
                    o_reg3(1 downto 0) <= o_reg2;
                elsif (c2_sel = "10") then
                    o_reg3(3 downto 2) <= o_reg2;
                elsif (c2_sel = "01") then
                    o_reg3(5 downto 4) <= o_reg2;
                elsif (c2_sel = "00") then
                    o_reg3(7 downto 6) <= o_reg2; 
                end if;
            end if;
        end if;
    end process;
    
    
    -- Aggiorno o_data al valore di R3
    o_data <= o_reg3;
 
    
    
----------------------------------------------------------------------------------
------ Contatore e Trigger di Fine Traduzione ------------------------------------
----------------------------------------------------------------------------------
    
    -- Registro R4 (inizializzazione contatore)                
    process(i_clk, i_rst)
    begin
        if(i_rst = '1') then
            o_reg4 <= "00000000";
        elsif rising_edge(i_clk) then
            if(r4_load = '1') then
                o_reg4 <= i_data;
            end if;
        end if;
    end process;
    
    
    -- Multiplexer per il Registro R5                
    with c5_sel select
        o_muxC5 <=  o_reg4 when '0',
                    o_sub  when '1',
                    "XXXXXXXX" when others;
                    
                    
    -- Registro R5 (contatore)                
    process(i_clk, i_rst)
    begin
        if(i_rst = '1') then
            o_reg5 <= "00000000";
        elsif rising_edge(i_clk) then
            if(r5_load = '1') then
                o_reg5 <= o_muxC5;
            end if;
        end if;
    end process;
    
    
    -- Eseguo la sottrazione unitaria del contatore
    o_sub <= o_reg5 - "00000001";
    
    
    -- Alzo il segnale o_end quando il contatore giunge a zero
    o_end <= "00000001"  when (o_reg5 = "00000000") else "00000000";
    
    
    
----------------------------------------------------------------------------------
------ Parte memorizzazione degli Indirizzi tramite Registri ---------------------
----------------------------------------------------------------------------------

    -- Multiplexer per il Registro AI                
    with aI_sel select
        o_muxAI <=  "0000000000000000" when '0',
                    o_sumAI when '1',
                    "XXXXXXXXXXXXXXXX" when others;
             
                             
    -- Registro AI              
    process(i_clk, i_rst)
    begin
        if(i_rst = '1') then
            o_regAI <= "0000000000000000";
        elsif rising_edge(i_clk) then
            if(aI_load = '1') then
                o_regAI <= o_muxAI;
            end if;
        end if;
    end process;
    
    
    -- Eseguo l'addizione unitaria del contatore di AI
    o_sumAI <= o_regAI + "0000000000000001";
    
    
    -- Associo l'uscita del registro che salva AddressIn all'uscita del datapath
    o_aI    <= o_regAI;
    
    
    -- Multiplexer per il Registro AO                
    with aO_sel select
        o_muxAO <=  "0000001111101000" when '0',
                    o_sumAO when '1',
                    "XXXXXXXXXXXXXXXX" when others;
               
                             
    -- Registro AO              
    process(i_clk, i_rst)
    begin
        if(i_rst = '1') then
            o_regAO <= "0000000000000000";
        elsif rising_edge(i_clk) then
            if(aO_load = '1') then
                o_regAO <= o_muxAO;
            end if;
        end if;
    end process;
    
    
    -- Eseguo l'addizione unitaria del contatore di AO
    o_sumAO <= o_regAO + "0000000000000001";
    
    
    -- Associo l'uscita del registro che salva AddressOut all'uscita del datapath
    o_aO    <= o_regAO;
      
end Behavioral;
    
    

----------------------------------------------------------------------------------
-- FSM: Controlla gli stati operativi del componente -----------------------------
----------------------------------------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;


entity project_reti_logiche is
    port (
        i_clk     : in std_logic;
        i_rst     : in std_logic;
        i_start   : in std_logic;
        i_data    : in std_logic_vector(7 downto 0);
        o_address : out std_logic_vector(15 downto 0);
        o_done    : out std_logic;
        o_en      : out std_logic;
        o_we      : out std_logic;
        o_data    : out std_logic_vector (7 downto 0)
    );
end project_reti_logiche;


architecture Behavioral of project_reti_logiche is
    component datapath is
        port ( i_clk   : in std_logic;
               i_rst   : in std_logic;
               i_start : in std_logic;
               i_data  : in std_logic_vector(7 downto 0);
               o_data  : out std_logic_vector (7 downto 0);
               o_end   : out std_logic_vector(7 downto 0);
               r1_load : in std_logic;
               r2_load : in std_logic;
               r3_load : in std_logic;
               r4_load : in std_logic;
               r5_load : in std_logic;
               d0_load : in std_logic;
               d1_load : in std_logic;
               d0_sel  : in std_logic;
               d1_sel  : in std_logic;
               c1_sel  : in std_logic_vector(2 downto 0);
               c2_sel  : in std_logic_vector(1 downto 0);
               c5_sel  : in std_logic;
               aI_sel  : in std_logic;
               aO_sel  : in std_logic;
               aI_load : in std_logic;
               aO_load : in std_logic;
               o_aI    : out std_logic_vector(15 downto 0);
               o_aO    : out std_logic_vector(15 downto 0)
             );
    end component;
    
    
    -- Segnali con cui controllare il datapath
    signal o_end   : std_logic_vector(7 downto 0);
    signal r1_load : std_logic;
    signal r2_load : std_logic;
    signal r3_load : std_logic;
    signal r4_load : std_logic;
    signal r5_load : std_logic;
    signal d0_load : std_logic;
    signal d1_load : std_logic;
    signal d0_sel  : std_logic;
    signal d1_sel  : std_logic;
    signal c1_sel  : std_logic_vector(2 downto 0);
    signal c2_sel  : std_logic_vector(1 downto 0);
    signal c5_sel  : std_logic;
    signal addIn   : std_logic_vector(15 downto 0);
    signal addOut  : std_logic_vector(15 downto 0);
    signal aI_sel  : std_logic;
    signal aO_sel  : std_logic;
    signal aI_load : std_logic;
    signal aO_load : std_logic;
    
    -- Informazioni per creare la macchina a stati
    type S is (S0, S1,S2,S3,S4,S5,S6,S7,S8,S9,S10,S11,S12,S13,S14,S15,S16,S17,S18,S19,S20,S21,S22,S23,S24,S25,S26,S27,S28);
    signal cur_state, next_state : S;
    
    
    begin
        DATAPATH0: datapath port map(
            i_clk   => i_clk,
            i_rst   => i_rst,
            i_start => i_start,
            i_data  => i_data,
            o_data  => o_data,
            o_end   => o_end,
            r1_load => r1_load,
            r2_load => r2_load,
            r3_load => r3_load,
            r4_load => r4_load,
            r5_load => r5_load,
            d0_load => d0_load,
            d1_load => d1_load,
            d0_sel  => d0_sel,
            d1_sel  => d1_sel,
            c1_sel  => c1_sel,
            c2_sel  => c2_sel,
            c5_sel  => c5_sel,
            aI_load => aI_load,
            aO_load => aO_load,
            aI_sel  => aI_sel,
            aO_sel  => aO_sel,
            o_aI    => addIn,
            o_aO    => addOut
        );
        
        
        
---------------------------------------------------------------------------------
------ Registri dello Stato -----------------------------------------------------
---------------------------------------------------------------------------------

    process(i_clk, i_rst)
    begin
        if (i_rst = '1') then
            cur_state <= S0;
        elsif rising_edge(i_clk) then
            cur_state <= next_state;
        end if;
    end process;
    
    
    
---------------------------------------------------------------------------------
------ Funzione di Stato Prossimo -----------------------------------------------
---------------------------------------------------------------------------------

    process(cur_state, i_start, o_end, i_clk)
    begin
        next_state <= cur_state;
        case cur_state is
        
            when S0  =>
                if i_start = '1' then
                    next_state <= S1;
                end if;
            
            
            when S1  =>
                next_state <= S2;
            
            
            when S2  =>
                next_state <= S3;
            
            
            when S3  =>
                next_state <= S4;
            
            
            when S4  =>
                if o_end = "00000000" then
                    next_state <= S5;
                elsif o_end = "00000001" then
                    next_state <= S27;
                end if;
            
                
            when S5  =>
                next_state <= S6;
            
                
            when S6  =>
                next_state <= S7;
            
                
            when S7  =>
                next_state <= S8;
                
                
            when S8  =>
                next_state <= S9;
                
                
            when S9 =>
                next_state <= S10;
                
                
            when S10 =>
                next_state <= S11;
                
                
            when S11 =>
                next_state <= S12;
                
                
            when S12 =>
                next_state <= S13;
                
                
            when S13 =>
                next_state <= S14;
                
                
            when S14 =>
                next_state <= S15;
                
                
            when S15 =>
                next_state <= S16;
                
                
            when S16 =>
                next_state <= S17;
                
                
            when S17 =>
                next_state <= S18;
                
                
            when S18 =>
                next_state <= S19;
            
            
            when S19 =>
                if o_end = "00000000" then
                    next_state <= S20;
                elsif o_end = "00000001" then
                    next_state <= S27;
                end if;
            
                
            when S20 =>
                next_state <= S21;
            
                
            when S21 =>
                next_state <= S22;
            
                
            when S22 =>
                next_state <= S23;
            
                
            when S23 =>
                next_state <= S24;
            
                
            when S24 =>
                next_state <= S25;
            
                
            when S25 =>
                next_state <= S26;
            
                
            when S26 =>
                next_state <= S13;
            
                
            when S27 =>
                if i_start = '0' then
                    next_state <= S28;
                end if;
            
            
            when S28 =>
                next_state <= S0;
                
        end case;
    end process;
    
    
    
---------------------------------------------------------------------------------
------ Funzione di Uscita -------------------------------------------------------
---------------------------------------------------------------------------------

    process(cur_state)
    begin
        -- Inizializzazione a valori di default
        r1_load   <= '0';
        r2_load   <= '0';
        r3_load   <= '0';
        r4_load   <= '0';
        r5_load   <= '0';
        d0_load   <= '0';
        d1_load   <= '0';
        c1_sel    <= "000";
        c2_sel    <= "00";
        c5_sel    <= '0';
        d0_sel    <= '0';
        d1_sel    <= '0';
        o_address <= "0000000000000000";
        o_done    <= '0';
        o_en      <= '0';
        o_we      <= '0';
        aI_sel    <= '0';
        aO_sel    <= '0';
        aI_load   <= '0';
        aO_load   <= '0';
        
        

        case cur_state is
            when S0 =>
            
            
            when S1  => 
                o_address <= "0000000000000000";
                o_en      <= '1';
                o_we      <= '0';
                r1_load   <= '0';
                r3_load   <= '0';
                r4_load   <= '0';
                r5_load   <= '0';
                d0_load   <= '1';
                d1_load   <= '1';
                c1_sel    <= "000";
                c2_sel    <= "00";
                c5_sel    <= '0';
                d0_sel    <= '0';
                d1_sel    <= '0';
                aI_load   <= '1';
                aO_load   <= '1';
                aI_sel    <= '0';
                aO_sel    <= '0';
            
                
            when S2  =>
                o_en      <= '0';
                d0_load   <= '0';
                d1_load   <= '0';
                r4_load   <= '1';
                aI_load   <= '0';
                aO_load   <= '0';
                aI_sel    <= '1';
                aO_sel    <= '1';
                c5_sel    <= '0';
            
                
            when S3  =>
                r4_load   <= '1';
                r5_load   <= '1'; 
                aI_sel    <= '1'; 
                aO_sel    <= '1';
                c5_sel    <= '0';
                
                
            when S4  =>
                r5_load   <= '0';
                aI_sel    <= '1'; 
                aO_sel    <= '1';
                c5_sel    <= '0';
            
                
            when S5  =>
                o_address <= addIn + "000000000000001";
                o_en      <= '1';
                c5_sel    <= '1';
                aI_sel    <= '1'; 
                aO_sel    <= '1';
            
                
            when S6  =>            
                o_en      <= '0';
                r1_load   <= '1';
                d0_sel    <= '1';
                d1_sel    <= '1';
                c5_sel    <= '1';
                aI_sel    <= '1'; 
                aO_sel    <= '1';
                aI_load   <= '1';
            
                
            when S7  =>
                r1_load   <= '0';
                r2_load   <= '1'; 
                d0_load   <= '1';
                d1_load   <= '0';
                c1_sel    <= "000";
                c5_sel    <= '1';
                aI_sel    <= '1'; 
                aO_sel    <= '1';
                d0_sel    <= '1';
                d1_sel    <= '1';
                aI_load   <= '0';
            
                
            when S8  =>
                r3_load   <= '1';
                c1_sel    <= "001";
                c2_sel    <= "00";
                c5_sel    <= '1';
                aI_sel    <= '1'; 
                aO_sel    <= '1';
                d0_sel    <= '1';
                d1_sel    <= '1';
                d0_load   <= '1';
                d1_load   <= '1';
                r2_load   <= '1'; 
            
                
            when S9 =>
                c1_sel    <= "010";
                c2_sel    <= "01";
                c5_sel    <= '1';
                aI_sel    <= '1'; 
                aO_sel    <= '1';
                d0_sel    <= '1';
                d1_sel    <= '1';
                d0_load   <= '1';
                d1_load   <= '1';
                r2_load   <= '1';
                r3_load   <= '1';
            
                
            when S10 =>
                c1_sel    <= "011";
                c2_sel    <= "10";
                c5_sel    <= '1';
                aI_sel    <= '1'; 
                aO_sel    <= '1';
                d0_sel    <= '1';
                d1_sel    <= '1';
                d0_load   <= '1';
                d1_load   <= '1';
                r2_load   <= '1';
                r3_load   <= '1';
            
                
            when S11 =>
                r2_load   <= '0';
                d0_load   <= '0';
                d1_load   <= '0';
                c2_sel    <= "11";
                c5_sel    <= '1';
                aI_sel    <= '1'; 
                aO_sel    <= '1';
                d0_sel    <= '1';
                d1_sel    <= '1';
                r3_load   <= '1';
  
  
            when S12 =>
                r3_load   <= '0';
                c5_sel    <= '1';
                aI_sel    <= '1'; 
                aO_sel    <= '1';
                d0_sel    <= '1';
                d1_sel    <= '1';
  
            
            when S13 =>
                o_address <= addOut;
                o_en      <= '1';
                o_we      <= '1';
                c5_sel    <= '1';
                aI_sel    <= '1'; 
                aO_sel    <= '1';
                d0_sel    <= '1';
                d1_sel    <= '1';
  
                
            when S14 =>
                o_en      <= '0';
                o_we      <= '0';
                r2_load   <= '1';
                r3_load   <= '0';
                d0_load   <= '1';
                d1_load   <= '1';
                aO_load   <= '1';
                c1_sel    <= "100";
                c2_sel    <= "00";
                c5_sel    <= '1';
                aI_sel    <= '1'; 
                aO_sel    <= '1';
                d0_sel    <= '1';
                d1_sel    <= '1';

  
                
            when S15 =>
                c1_sel    <= "101";
                c2_sel    <= "00";
                c5_sel    <= '1';
                aI_sel    <= '1'; 
                aO_sel    <= '1';
                d0_sel    <= '1';
                d1_sel    <= '1';
                d0_load   <= '1';
                d1_load   <= '1';
                r2_load   <= '1';
                r3_load   <= '1';
                aO_load   <= '0';
  
                
            when S16 =>
                c1_sel    <= "110";
                c2_sel    <= "01";
                c5_sel    <= '1';
                aI_sel    <= '1'; 
                aO_sel    <= '1';
                d0_sel    <= '1';
                d1_sel    <= '1';
                d0_load   <= '1';
                d1_load   <= '1';
                r2_load   <= '1';
                r3_load   <= '1';
  
            
            when S17 =>
                c1_sel    <= "111";
                c2_sel    <= "10";
                r5_load   <= '0';
                c5_sel    <= '1';
                aI_sel    <= '1'; 
                aO_sel    <= '1';
                d0_sel    <= '1';
                d1_sel    <= '1';
                d0_load   <= '1';
                d1_load   <= '1';
                r2_load   <= '1';
                r3_load   <= '1';
  
                
            when S18 =>
                c2_sel    <= "11";
                r2_load   <= '0';
                r3_load   <= '1';
                r5_load   <= '1';
                d0_load   <= '0';
                d1_load   <= '0';
                c5_sel    <= '1';
                aI_sel    <= '1'; 
                aO_sel    <= '1';
                d0_sel    <= '1';
                d1_sel    <= '1';
  
                
            when S19 =>
                o_address <= addOut;
                o_en      <= '1';
                o_we      <= '1';
                r3_load   <= '0';
                r5_load   <= '0';
                d0_load   <= '0';
                d1_load   <= '0';
                c5_sel    <= '1';
                aI_sel    <= '1'; 
                aO_sel    <= '1';
                d0_sel    <= '1';
                d1_sel    <= '1';
  
                
            when S20 =>
                o_address <= addIn + "000000000000001";
                o_we      <= '0';
                o_en      <= '1';
                c5_sel    <= '1';
                aI_sel    <= '1'; 
                aO_sel    <= '1';
                d0_sel    <= '1';
                d1_sel    <= '1';
                aO_load   <= '1';  
  
            
            when S21 =>
                o_en      <= '0';
                r1_load   <= '1';
                c5_sel    <= '1';
                aI_sel    <= '1'; 
                aO_sel    <= '1';
                d0_sel    <= '1';
                d1_sel    <= '1';
                aI_load   <= '1';
                aO_load   <= '0'; 
  
            
            when S22 =>
                r1_load   <= '0';
                r2_load   <= '1';
                r3_load   <= '0';
                d0_load   <= '1';
                d1_load   <= '1';
                c1_sel    <= "000";
                c2_sel    <= "00";
                c5_sel    <= '1';
                aI_sel    <= '1'; 
                aO_sel    <= '1';
                d0_sel    <= '1';
                d1_sel    <= '1';
                aI_load   <= '0';
  
            
            when S23 =>
                c1_sel    <= "001";
                c2_sel    <= "00";
                c5_sel    <= '1';
                aI_sel    <= '1'; 
                aO_sel    <= '1';
                d0_sel    <= '1';
                d1_sel    <= '1';
                r2_load   <= '1';
                r3_load   <= '1';
                d0_load   <= '1';
                d1_load   <= '1';
  
            
            when S24 =>
                c1_sel    <= "010";
                c2_sel    <= "01";
                c5_sel    <= '1';
                aI_sel    <= '1'; 
                aO_sel    <= '1';
                d0_sel    <= '1';
                d1_sel    <= '1';
                r2_load   <= '1';
                r3_load   <= '1';
                d0_load   <= '1';
                d1_load   <= '1';
  
            
            when S25 =>
                c1_sel    <= "011";
                c2_sel    <= "10";
                c5_sel    <= '1';
                aI_sel    <= '1'; 
                aO_sel    <= '1';
                d0_sel    <= '1';
                d1_sel    <= '1';
                r2_load   <= '1';
                r3_load   <= '1';
                d0_load   <= '1';
                d1_load   <= '1';
  
            
            when S26 =>
                c2_sel    <= "11"; 
                r2_load   <= '0';
                r3_load   <= '1';
                d0_load   <= '0';
                d1_load   <= '0';
                c5_sel    <= '1';
                aI_sel    <= '1'; 
                aO_sel    <= '1';
                d0_sel    <= '1';
                d1_sel    <= '1';
  
            
            when S27 =>
                o_done    <= '1';
                o_en      <= '0';
                o_we      <= '0';
  
            
            when S28 =>
                o_done    <= '0';
            
        end case;
    end process;
end Behavioral;