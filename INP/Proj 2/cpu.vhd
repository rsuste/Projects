-- cpu.vhd: Simple 8-bit CPU (BrainF*ck interpreter)
-- Copyright (C) 2018 Brno University of Technology,
--                    Faculty of Information Technology
-- Author(s): Radim Šustek (xsuste11)
--

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;

-- ----------------------------------------------------------------------------
--                        Entity declaration
-- ----------------------------------------------------------------------------
entity cpu is
 port (
   CLK   : in std_logic;  -- hodinovy signal
   RESET : in std_logic;  -- asynchronni reset procesoru
   EN    : in std_logic;  -- povoleni cinnosti procesoru
 
   -- synchronni pamet ROM
   CODE_ADDR : out std_logic_vector(11 downto 0); -- adresa do pameti
   CODE_DATA : in std_logic_vector(7 downto 0);   -- CODE_DATA <- rom[CODE_ADDR] pokud CODE_EN='1'
   CODE_EN   : out std_logic;                     -- povoleni cinnosti
   
   -- synchronni pamet RAM
   DATA_ADDR  : out std_logic_vector(9 downto 0); -- adresa do pameti
   DATA_WDATA : out std_logic_vector(7 downto 0); -- mem[DATA_ADDR] <- DATA_WDATA pokud DATA_EN='1'
   DATA_RDATA : in std_logic_vector(7 downto 0);  -- DATA_RDATA <- ram[DATA_ADDR] pokud DATA_EN='1'
   DATA_RDWR  : out std_logic;                    -- cteni z pameti (DATA_RDWR='1') / zapis do pameti (DATA_RDWR='0')
   DATA_EN    : out std_logic;                    -- povoleni cinnosti
   
   -- vstupni port
   IN_DATA   : in std_logic_vector(7 downto 0);   -- IN_DATA obsahuje stisknuty znak klavesnice pokud IN_VLD='1' a IN_REQ='1'
   IN_VLD    : in std_logic;                      -- data platna pokud IN_VLD='1'
   IN_REQ    : out std_logic;                     -- pozadavek na vstup dat z klavesnice
   
   -- vystupni port
   OUT_DATA : out  std_logic_vector(7 downto 0);  -- zapisovana data
   OUT_BUSY : in std_logic;                       -- pokud OUT_BUSY='1', LCD je zaneprazdnen, nelze zapisovat,  OUT_WE musi byt '0'
   OUT_WE   : out std_logic                       -- LCD <- OUT_DATA pokud OUT_WE='1' a OUT_BUSY='0'
 );
end cpu;


-- ----------------------------------------------------------------------------
--                      Architecture declaration
-- ----------------------------------------------------------------------------
architecture behavioral of cpu is

 -- zde dopiste potrebne deklarace signalu
 --PC counter -ukazatel do pameti programu
 signal pc_counter: std_logic_vector(11 downto 0) := (others => '0');
 signal pc_inc: std_logic := '0';
 signal pc_dec: std_logic := '0';
 
 --CNT counter -korektnımu urceni odpovıdajıcıho zacatku/konce prıkazu (pocitadlo zavorek) 
 signal cnt_counter: std_logic_vector(7 downto 0) := (others => '0');
 signal cnt_inc: std_logic := '0';
 signal cnt_dec: std_logic := '0';
 
 --PTR counter -ukazatel do pameti da
 signal ptr_counter: std_logic_vector(9 downto 0) := (others => '0');
 signal ptr_inc: std_logic := '0';
 signal ptr_dec: std_logic := '0';
 
 
 --multiplexor
 signal multiplex : std_logic_vector(1 downto 0) := "11";
 
 --FSM automat
 type fsm_state is (
        state_fetch,
		state_decode, --decodovani instrukce
		state_none,  -- nedefinovane stavy (others)
		state_return, -- NULL
		
	--pointer -- 
		-- <>
		state_ptr_inc, state_ptr_dec,
		
	--variable
		--+
		state_var_inc_01,state_var_inc_02,
		-- -
		state_var_dec_01,state_var_dec_02,
	--print
        state_put, --.
	--load	
		state_get, -- ,
	--loop
		-- While [ ]
        state_while_start_1, state_while_start_2, state_while_start_3, state_while_start_4,
        state_while_end_1, state_while_end_2, state_while_end_3, state_while_end_4,state_while_end_5,
		
	--comments	
		-- #
        state_block_skip, -- slouzi k preskakovani znaku 
		state_block_start, state_block_end,
		
	--numbers/letters
		-- 1-9
        state_numbers,
		-- A-F
		state_letters
    );
	
 --tmp -pomocna data pro pocitani HEX cisel 
 signal tmp: std_logic_vector(7 downto 0) := (others => '0');

  --stavy
 signal present_state: fsm_state; --soucasny stav
 signal next_state: fsm_state; -- nasledujici stav
	
 

begin
	
	multiplexor: process(IN_DATA, DATA_RDATA,multiplex,tmp)
    begin
        case (multiplex) is
            when "11" => DATA_WDATA <= IN_DATA;
            when "10" => DATA_WDATA <= DATA_RDATA + 1;
            when "01" => DATA_WDATA <= DATA_RDATA - 1;
            when "00" => DATA_WDATA <= tmp;
            when others =>
        end case ;
    end process;
  
    -- programovy cıtac
    PC_PROC: process(CLK, RESET,pc_counter,pc_inc,pc_dec)
    begin
        if (RESET = '1') then
            pc_counter <= (others => '0');
        elsif (CLK'event and CLK = '1') then
            if (pc_inc = '1') then
                pc_counter <= pc_counter + 1;
            elsif (pc_dec = '1') then
                pc_counter <= pc_counter - 1;
            end if;
        end if;
    end process;
    CODE_ADDR <= pc_counter;
	
 
	-- ukazatel do pameti ram
    PTR_PROC: process(CLK, RESET,ptr_counter,ptr_inc,ptr_dec)
    begin
        if (RESET = '1') then
            ptr_counter <= (others => '0');
        elsif (CLK'event and CLK = '1') then
            if (ptr_inc = '1') then
                ptr_counter <= ptr_counter + 1;
            elsif (ptr_dec = '1') then
                ptr_counter <= ptr_counter - 1;
            end if;
        end if;
    end process;
    DATA_ADDR <= ptr_counter;
	
 
 
 

 
	-- pocet oteviracich a zaviracich zavorek, slouzi ke konkretnimu urceni zacatku/konce prikazu
    CNT_PROC: process(CLK, RESET,cnt_counter,cnt_inc,cnt_dec)
    begin
        if (RESET = '1') then
            cnt_counter <= (others => '0');
        elsif (CLK'event and CLK = '1') then
            if (cnt_inc = '1') then
                cnt_counter <= cnt_counter + 1;
            elsif (cnt_dec = '1') then
                cnt_counter <= cnt_counter - 1;
            end if;
        end if;
    end process;
	
	--zpracovani aktualniho stavu
    present_fsm_state: process(CLK, RESET)
    begin
        if (RESET = '1') then
            present_state <= state_fetch;
        elsif (CLK'event and CLK = '1') then
            if (EN = '1') then
                present_state <= next_state;
            end if;
        end if;
    end process;
	
	
	--zpracovani nasledujiciho stavu
    next_fsm_state: process(CODE_DATA, IN_VLD, OUT_BUSY, DATA_RDATA, cnt_counter, present_state)
    begin
	--priprava promenych pred spustenim
        
		--promene pro pristup k datum, a dyspleji
	    CODE_EN <= '1'; --povoleni cinosti programu
        DATA_EN <= '0'; --povoleni pristup k ram
	    OUT_WE <= '0'; -- povoleni vystup na displaj
        IN_REQ <= '0'; -- povoleni vstupu z klavesnice
		DATA_RDWR <= '0';
        
		--promene pro pristup do pameti
		ptr_inc <= '0';
		ptr_dec <= '0';
       
	   --pocitadlo stavu
		pc_dec <= '0';
        pc_inc <= '0';
		
		--zanoreni
        cnt_inc <= '0';
        cnt_dec <= '0';
		
		--	multiplexor
        multiplex  <= "11";
        
		--V pripade ze byl zavolan nacteni dalsiho stavu	
        case present_state is
            when state_fetch =>
                CODE_EN <= '1';
                next_state <= state_decode; -- zavola se stavovu automat decode pro urceni co se ma delat
 
            --stavovy automat ktery v zavislosti na to co dostane na CODE_DATA zvoli vhodny stav pro pokracovani
			when state_decode =>
                case CODE_DATA is
					--relacni operatory
                    when X"3E" 		=> next_state <=	 state_ptr_inc; -- >
                    when X"3C" 		=> next_state <=	 state_ptr_dec; -- <
                    
					-- inc/dec
					when X"2B" 		=> next_state <=	 state_var_inc_01; -- +
                    when X"2D" 		=> next_state <=	 state_var_dec_01; -- -
					
					--while cykly
                    when X"5B" 		=> next_state <=	 state_while_start_1; -- [
                    when X"5D" 		=> next_state <=	 state_while_end_1; -- ]
					
                    when X"2E" 		=> next_state <=	 state_put; -- .
                    when X"2C" 		=> next_state <=	 state_get; -- ,
					
				--block comment
					--narazili jsme na zacatek blockoveho komntare	
                    when X"23" 		=> next_state <=	 state_block_skip; -- #
					
				--HEXA
					--numbers 0-9
                    when X"30" 		=> next_state <=	 state_numbers;
                    when X"31" 		=> next_state <=	 state_numbers;
                    when X"32" 		=> next_state <=	 state_numbers;
                    when X"33" 		=> next_state <=	 state_numbers;
                    when X"34" 		=> next_state <=	 state_numbers;
                    when X"35" 		=> next_state <=	 state_numbers;
                    when X"36" 		=> next_state <=	 state_numbers;
                    when X"37" 		=> next_state <=	 state_numbers;
                    when X"38" 		=> next_state <=	 state_numbers;
                    when X"39" 		=> next_state <=	 state_numbers;
					
					--letters A-F
                    when X"41"		=> next_state <=	 state_letters;
                    when X"42" 		=> next_state <=	 state_letters;
                    when X"43" 		=> next_state <=	 state_letters;
                    when X"44" 		=> next_state <=	 state_letters;
                    when X"45" 		=> next_state <=	 state_letters;
                    when X"46" 		=> next_state <=	 state_letters;
					
				--NULL
					when X"00" 		=> next_state <=	 state_return; -- null
                    
					when others => next_state <= state_none; -- zadny z vyse uvedenych stavu
                end case;
	--ukazatel	
			--inkrementace hodnoty ukazatel
            when state_ptr_inc =>
                ptr_inc <= '1'; -- inc ukazatele
                pc_inc <= '1'; -- posun v programu
                next_state <= state_fetch; -- novy stav
			-- dekrementace hodnoty ukazatele	
            when state_ptr_dec =>
                ptr_dec <= '1';
                pc_inc <= '1';
                next_state <= state_fetch;
	--hodnota
			--inkrementace hodnoty aktualnı bunky	
            when state_var_inc_01 => -- slouzi k nacteni
                DATA_EN <= '1'; -- je treba vzdy nastavit na 1 pred praci s daty
                DATA_RDWR <= '1'; -- povolit zapis/cteni
                next_state <= state_var_inc_02;
			--pomocny stav pro inkrementace hodnoty aktualnı bunky
            when state_var_inc_02 => -- slouzi k zapisu
                multiplex <= "10";
                DATA_EN <= '1';
                DATA_RDWR <= '0';
                pc_inc <= '1';
                next_state <= state_fetch;
			--dekrementace hodnoty aktualnı bunky	
            when state_var_dec_01 =>
                DATA_EN <= '1';
                DATA_RDWR <= '1';
                next_state <= state_var_dec_02;
			--pomocny stav pro dekrementace hodnoty aktualnı bunky	
            when state_var_dec_02 =>
                multiplex <= "01";
                DATA_EN <= '1';
                DATA_RDWR <= '0';
                pc_inc <= '1';
                next_state <= state_fetch;
			
	--tisk		
			--vytiskni hodnotu aktualnı bunky	
            when state_put =>
                if (OUT_BUSY = '1') then -- pokud je displaj aktualne zaneprazdnen, zavolej tento stav znovu
                    next_state <= state_put;
                else
                    DATA_EN <= '1'; -- povoleni prace s daty
                    DATA_RDWR <= '1'; -- cteni dat
					OUT_DATA <= DATA_RDATA; -- presun data na vystup
					OUT_WE <= '1'; -- povoleni tisku
					pc_inc <= '1'; -- posun v programu
					next_state <= state_fetch; -- novy stav
				end if;    
	--load
			--nacte hodnotu a uloz ji do aktualnı bunky
            when state_get =>
                IN_REQ <= '1';
                if (IN_VLD = '0') then
                    next_state <= state_get;
                else
                    multiplex <= "11";
                    DATA_EN <= '1';
                    DATA_RDWR <= '0';
                    pc_inc <= '1';
                    next_state <= state_fetch;
                end if;
	--cykly

            --while start 
	    when state_while_start_1 =>
                DATA_EN <= '1'; -- povolit praci s daty
                DATA_RDWR <= '1'; -- nacist data
				pc_inc <= '1'; -- posun v programu
                next_state <= state_while_start_2;
            when state_while_start_2 =>
                if (DATA_RDATA = X"00") then -- zda jsou data prazdna
                    next_state <= state_while_start_3;
                else
                    next_state <= state_fetch;
                end if;
            when state_while_start_3 =>
                if (cnt_counter = X"00") then -- pokud je pocitadlo prazdne
					cnt_inc <= '1';	-- pricti
                    next_state <= state_fetch;
                else
                    CODE_EN <= '1';
                    next_state <= state_while_start_4;
                end if;
			--reseni vnorenych zavorek 	
            when state_while_start_4 =>
                if (CODE_DATA = X"5B") then     --[
                    cnt_inc <= '1';
                elsif (CODE_DATA = X"5D") then -- ]
                    cnt_dec <= '1';
                end if;
                pc_inc <= '1'; -- posun v programu
                next_state <= state_while_start_3;
	
	    --while end		
            when state_while_end_1 =>
                DATA_EN <= '1';
                DATA_RDWR <= '1';
                next_state <= state_while_end_2;
            when state_while_end_2 =>
                if (DATA_RDATA = X"00") then
                    pc_inc <= '1';
                    next_state <= state_fetch;
                else
					cnt_inc <= '1';
					pc_dec <= '1';
                    next_state <= state_while_end_3;
                end if;
            when state_while_end_3 =>
                if (cnt_counter = X"00") then
                    next_state <= state_fetch;
                else
                    CODE_EN <= '1';
                    next_state <= state_while_end_4;
                end if;
            when state_while_end_4 =>
                if (CODE_DATA = X"5D") then
                    cnt_inc <= '1';
                elsif (CODE_DATA = X"5B") then
                    cnt_dec <= '1';
                end if;
                next_state <= state_while_end_5;
            when state_while_end_5 =>
                if (cnt_counter = X"00") then
                    pc_inc <= '1';
                else
                    pc_dec <= '1';
                end if;
                next_state <= state_while_end_3;
	--comment
			--vsechny nactene znaky mezi timto a nasledujicim timto znakem jsou ignorovany(povazovany za blokovy komentar)
            when state_block_skip =>
                pc_inc <= '1';
                next_state <= state_block_start;
            when state_block_start =>
                CODE_EN <= '1'; -- umoznuje praci s daty
                next_state <= state_block_end;
            when state_block_end =>
                if (CODE_DATA = X"23") then -- pokud jsme narazili na ukonceni blockoveho komentare, tak z nej vylezem
                    pc_inc <= '1';
                    next_state <= state_fetch;
                else
                    next_state <= state_block_skip; -- pokud jeste nejsme na konci blockoveho komentare pokracujeme preskakovanim znaku
                end if;
	--HEXA
			--1-9
            when state_numbers =>
                DATA_EN <= '1';
                pc_inc <= '1';
                multiplex <= "00";
                tmp <= CODE_DATA(3 downto 0) & X"0";
                next_state <= state_fetch;
			--A-F
            when state_letters =>
                DATA_EN <= '1';
                pc_inc <= '1';
                multiplex <= "00";
                tmp <= (CODE_DATA(3 downto 0) + std_logic_vector(conv_unsigned(9, tmp'LENGTH)(3 downto 0))) & "0000";
                next_state <= state_fetch;
			
	--NULL			
            when state_return =>
                next_state <= state_return;
	--nedefinovane stavy			
            when state_none =>
                pc_inc <= '1';
                next_state <= state_fetch;
 
        end case;
    end process;
end behavioral;
