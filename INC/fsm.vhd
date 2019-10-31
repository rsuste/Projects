-- fsm.vhd: Finite State Machine
-- Author(s): 
--
library ieee;
use ieee.std_logic_1164.all;
-- ----------------------------------------------------------------------------
--                        Entity declaration
-- ----------------------------------------------------------------------------
entity fsm is
port(
   CLK         : in  std_logic;
   RESET       : in  std_logic;

   -- Input signals
   KEY         : in  std_logic_vector(15 downto 0);
   CNT_OF      : in  std_logic;

   -- Output signals
   FSM_CNT_CE  : out std_logic;
   FSM_MX_MEM  : out std_logic;
   FSM_MX_LCD  : out std_logic;
   FSM_LCD_WR  : out std_logic;
   FSM_LCD_CLR : out std_logic
);
end entity fsm;

-- ----------------------------------------------------------------------------
--                      Architecture declaration
-- ----------------------------------------------------------------------------
architecture behavioral of fsm is
   type t_state is (ONE,TWO,THREE,FOUR,FIVE,SIX,SEVEN,EIGHT,NINE,TEN,CONFIRM,MSG_WRONG,MSG_OK,FINISH,OTHER);
   signal present_state, next_state : t_state;

begin
-- -------------------------------------------------------
sync_logic : process(RESET, CLK)
begin
   if (RESET = '1') then
      present_state <= ONE;
   elsif (CLK'event AND CLK = '1') then
      present_state <= next_state;
   end if;
end process sync_logic;

-- -------------------------------------------------------
next_state_logic : process(present_state, KEY, CNT_OF)
variable ID: integer;
begin
   case (present_state) is
   -- - - - - - - - - - - - - - - - - - - - - - -
   when ONE =>
      next_state <= ONE;
		if (KEY(1) = '1') then -- v pripade ze byla stisknuta jednicka
			next_state <= TWO; -- postoupi na statment two
		elsif (KEY(15) = '1') then -- v pripade ze byl stisknut #
			next_state <= MSG_WRONG; -- kod neodpovida , vypsat zpravu Zadat znova
		elsif (KEY(14 downto 0) /= "000000000000000") then -- v pripade ze bylo stisknuto cokoliv jineho
			next_state <= OTHER; -- skocime do OTHERS jelikoz jakykoliv zadany kod je jiz spatny
		end if;
   -- - - - - - - - - - - - - - - - - - - - - - -
   when TWO =>
      next_state <= TWO;
		if (KEY(4) = '1') then
			ID:=1;
			next_state <= THREE;
		elsif (KEY(7) = '1') then
			ID:=2;
			next_state <= THREE;
		elsif (KEY(14 downto 0) /= "000000000000000") then
			next_state <= OTHER;
		elsif (KEY(15) = '1') then
			next_state <= MSG_WRONG;
		end if;
   -- - - - - - - - - - - - - - - - - - - - - - -
   when THREE =>
      next_state <= THREE;
		if (KEY(0) = '1') and (ID = 1) then
			next_state <= FOUR;
		elsif (KEY(6) = '1') and (ID = 2) then
			next_state <= FOUR;
		elsif (KEY(14 downto 0) /= "000000000000000") then
			next_state <= OTHER;
		elsif (KEY(15) = '1') then
			next_state <= MSG_WRONG;
		end if;
   -- - - - - - - - - - - - - - - - - - - - - - -
   when FOUR =>
      next_state <= FOUR;
		if (KEY(8) = '1') and (ID = 1) then
			next_state <= FIVE;
		elsif (KEY(1) = '1') and (ID = 2) then
			next_state <= FIVE;
		elsif (KEY(14 downto 0) /= "000000000000000") then
			next_state <= OTHER;
		elsif (KEY(15) = '1') then
			next_state <= MSG_WRONG;
		end if;
   -- - - - - - - - - - - - - - - - - - - - - - -
   when FIVE =>
      next_state <= FIVE;
		if (KEY(9) = '1') and (ID = 1) then
			next_state <= SIX;
		elsif (KEY(1) = '1') and (ID = 2) then
			next_state <= SIX;
		elsif (KEY(14 downto 0) /= "000000000000000") then
			next_state <= OTHER;
		elsif (KEY(15) = '1') then
			next_state <= MSG_WRONG;
		end if;
   -- - - - - - - - - - - - - - - - - - - - - - -
   when SIX =>
      next_state <= SIX;
		if (KEY(4) = '1') and (ID = 1) then
			next_state <= SEVEN;
		elsif (KEY(7) = '1') and (ID = 2) then
			next_state <= SEVEN;
		elsif (KEY(14 downto 0) /= "000000000000000") then
			next_state <= OTHER;
		elsif (KEY(15) = '1') then
			next_state <= MSG_WRONG;
		end if;
   -- - - - - - - - - - - - - - - - - - - - - - -
   when SEVEN =>
      next_state <= SEVEN;
		if (KEY(3) = '1') and (ID = 1) then
			next_state <= EIGHT;
		elsif (KEY(9) = '1') and (ID = 2) then
			next_state <= EIGHT;
		elsif (KEY(14 downto 0) /= "000000000000000") then
			next_state <= OTHER;
		elsif (KEY(15) = '1') then
			next_state <= MSG_WRONG;
		end if;
   -- - - - - - - - - - - - - - - - - - - - - - -
   when EIGHT =>
      next_state <= EIGHT;
		if (KEY(2) = '1') and (ID = 1) then
			next_state <= NINE;
		elsif (KEY(0) = '1') and (ID = 2) then
			next_state <= NINE;
		elsif (KEY(14 downto 0) /= "000000000000000") then
			next_state <= OTHER;
		elsif (KEY(15) = '1') then
			next_state <= MSG_WRONG;
		end if;
   -- - - - - - - - - - - - - - - - - - - - - - -
   when NINE =>
      next_state <= NINE;
		if (KEY(1) = '1') and (ID = 1) then
			next_state <= TEN;
		elsif (KEY(1) = '1') and (ID = 2) then
			next_state <= TEN;
		elsif (KEY(14 downto 0) /= "000000000000000") then
			next_state <= OTHER;
		elsif (KEY(15) = '1') then
			next_state <= MSG_WRONG;
		end if;
   -- - - - - - - - - - - - - - - - - - - - - - -
   when TEN =>
      next_state <= TEN;
		if (KEY(1) = '1') and (ID = 1) then
			next_state <= CONFIRM;
		elsif (KEY(4) = '1') and (ID = 2) then
			next_state <= CONFIRM;
		elsif (KEY(14 downto 0) /= "000000000000000") then
			next_state <= OTHER;
		elsif (KEY(15) = '1') then
			next_state <= MSG_WRONG;
		end if;
   -- - - - - - - - - - - - - - - - - - - - - - -
   when CONFIRM => -- jiz byl zadan cely kod spravne a ceka na potvrzeni
      next_state <= CONFIRM;
		if (KEY(15) = '1')then -- potvrzeni
			next_state <= MSG_OK;
		elsif (KEY(14 downto 0) /= "000000000000000") then -- v pripade pokracovani jump do others a ceka na vypis MSG_WRONG
			next_state <= OTHER;
		
		end if;
   -- - - - - - - - - - - - - - - - - - - - - - -
   when MSG_OK => -- vypise vse z pameti dokud nedostane prikaz CNT_OF
      next_state <= MSG_OK;
      if (CNT_OF = '1') then
         next_state <= FINISH;
      end if;
   -- - - - - - - - - - - - - - - - - - - - - - -
   when MSG_WRONG => -- same jak OK
      next_state <= MSG_WRONG;
      if (CNT_OF = '1') then
         next_state <= FINISH;
      end if;
   -- - - - - - - - - - - - - - - - - - - - - - -
   when OTHER => -- v pripade ze se nachazime zde , vami zadany kod je jiz spatny a uz se jen ceka na potvrzeni
      next_state <= OTHER; -- aby se mohlo pokracovat vypsanim MSG_WRONG
      if ((KEY(15)) = '1') then
         next_state <= MSG_WRONG;
      end if;
   -- - - - - - - - - - - - - - - - - - - - - - -
   when FINISH =>
      next_state <= FINISH;
      if (KEY(15) = '1') then -- ceka na potvrzeni pro 
         next_state <= ONE; 
      end if;
   -- - - - - - - - - - - - - - - - - - - - - - -
   when others =>
      next_state <= ONE;
   end case;
end process next_state_logic;

-- -------------------------------------------------------
output_logic : process(present_state, KEY)
begin
   FSM_CNT_CE     <= '0';
   FSM_MX_MEM     <= '0';
   FSM_MX_LCD     <= '0';
   FSM_LCD_WR     <= '0';
   FSM_LCD_CLR    <= '0';

   case (present_state) is
     -- - - - - - - - - - - - - - - - - - - - - - -
   when MSG_WRONG =>
      FSM_CNT_CE     <= '1'; -- postupny vypis znaku po vypsani vrati CNT_OF
      FSM_MX_LCD     <= '1'; -- vyber vstupu
      FSM_LCD_WR     <= '1'; -- zapis na display
   -- - - - - - - - - - - - - - - - - - - - - - -
   when MSG_OK =>
     FSM_MX_MEM     <= '1'; -- zmena pameti
      FSM_CNT_CE     <= '1';
      FSM_MX_LCD     <= '1';
      FSM_LCD_WR     <= '1';
   -- FSM_MX_MEM     <= '1'; -- zmena pameti
   -- - - - - - - - - - - - - - - - - - - - - - -
   when FINISH =>
      if (KEY(15) = '1') then
         FSM_LCD_CLR    <= '1'; -- vymaze display
	 FSM_MX_MEM     <= '0'; -- nastavi hodnotu zpet na 
      end if;
   -- - - - - - - - - - - - - - - - - - - - - - -
   when others =>
		if (KEY(14 downto 0) /= "000000000000000") then
         FSM_LCD_WR     <= '1'; -- zapis na display
      end if;
      if (KEY(15) = '1') then
         FSM_LCD_CLR    <= '1';
      end if;
   end case;
end process output_logic;

end architecture behavioral;

