library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_arith.all;
use IEEE.std_logic_unsigned.all;

entity ledc8x8 is
port ( -- Sem doplnte popis rozhrani obvodu.
	RESET : IN std_Logic;
	SMCLK : IN std_Logic;
	ROW   : OUT std_logic_vector(7 downto 0);
	LED   : OUT std_logic_vector(7 downto 0)

);
end ledc8x8;

architecture main of ledc8x8 is
-- SMCLK 7372800
signal CNT : std_logic_vector(14 downto 0) := (others => '0'); --SMCLK/256
signal ce  : std_logic := '0'; -- clock enable

--SMCLK/4
signal CHANGE_STATE : std_logic_vector(20 downto 0) := (others => '0');
signal STATE : std_logic_vector(1 downto 0) := "00";

--Pomocne signaly

signal LED_DIOD : std_logic_vector(0 to 7) := (others => '0');
signal rows     : std_logic_vector(7 downto 0) := (others => '0');
begin
    -- Sem doplnte definice vnitrnich signalu.
	
GEN_CL:	process(RESET, SMCLK) -- snizeni frekvence
begin
   if (RESET='1') then
     CNT  <= (others => '0');
   elsif rising_edge(SMCLK) then --detekce nastupne hrany
		CNT <= CNT + 1;
   end if;
end process GEN_CL;

GEN_CHANGE:	process(RESET, SMCLK) -- pocitaldo na zmeneni stavu STATE
begin
   if (RESET='1') then
     CHANGE_STATE<= (others => '0');
   elsif rising_edge(SMCLK) then
	   CHANGE_STATE <= CHANGE_STATE +1;
		if CHANGE_STATE = "111000010000000000000" then -- V pripade ze CHANGE_STATE dosahlo ~250ms
			STATE <= STATE +1; -- Hodnotu STATE posune o 1
			CHANGE_STATE <= (others => '0'); -- CHANGE_STATE nastavi zpet na 00... aby pocitadlo mohlo zacit nanovo
		end if;
   end if;
end process GEN_CHANGE;

ce <='1' when CNT = "111000010000000" else '0'; -- Detekce SMCLK/256


ROTATION: process (RESET,ce,SMCLK) -- rotace radku
begin
	if RESET = '1' then
		rows <= "10000000";
	elsif (SMCLK = '1' and SMCLK'event and ce = '1') then
		rows <= rows(0) & rows(7 downto 1); -- konjunkci pridava 0 pred jednicku cimz projde vsechny radky
	end if;
end process ROTATION;

dekoder: process(rows,STATE)
begin
-- R
	if STATE = "00" then 
		case rows is -- Case pro jednotlive radky
			when "00000001" => LED_DIOD <= "11111111";
			when "00000010" => LED_DIOD <= "10000000";
			when "00000100" => LED_DIOD <= "10111100";
			when "00001000" => LED_DIOD <= "10111100";
			when "00010000" => LED_DIOD <= "10000000";
			when "00100000" => LED_DIOD <= "11001000";
			when "01000000" => LED_DIOD <= "10011000";
			when "10000000" => LED_DIOD <= "00111000";
			when others =>     LED_DIOD <= "11111111";
		end case;
-- S 
	elsif STATE = "10" then
		case rows is
			when "00000001" => LED_DIOD <= "11011011";
			when "00000010" => LED_DIOD <= "11100111";
			when "00000100" => LED_DIOD <= "10000001";
			when "00001000" => LED_DIOD <= "11111001";
			when "00010000" => LED_DIOD <= "10000001";
			when "00100000" => LED_DIOD <= "10011111";
			when "01000000" => LED_DIOD <= "10011111";
			when "10000000" => LED_DIOD <= "10000001";
			when others =>     LED_DIOD <= "11111111";
		end case;
	else
		case rows is -- osetreni 2 zbylich stavu STATE = (01,11) kde ledky maji byt zhasnute
			when others =>     LED_DIOD <= "11111111";
		end case;
	

	end if;
end process dekoder;
	
	
	
	LED <= LED_DIOD;
	ROW <= rows;



    -- Sem doplnte popis obvodu. Doporuceni: pouzivejte zakladni obvodove prvky
    -- (multiplexory, registry, dekodery,...), jejich funkce popisujte pomoci
    -- procesu VHDL a propojeni techto prvku, tj. komunikaci mezi procesy,
    -- realizujte pomoci vnitrnich signalu deklarovanych vyse.

    -- DODRZUJTE ZASADY PSANI SYNTETIZOVATELNEHO VHDL KODU OBVODOVYCH PRVKU,
    -- JEZ JSOU PROBIRANY ZEJMENA NA UVODNICH CVICENI INP A SHRNUTY NA WEBU:
    -- http://merlin.fit.vutbr.cz/FITkit/docs/navody/synth_templates.html.

    -- Nezapomente take doplnit mapovani signalu rozhrani na piny FPGA
    -- v souboru ledc8x8.ucf.

end architecture main;
