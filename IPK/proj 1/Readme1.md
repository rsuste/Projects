Implementační dokumentace k 1. projektu do IPK 2018/2019
Jméno a příjmení: Radim Šustek
Login: xsuste11

# Zadaní
Naším úkolem bylo vytvořit WEB server, se kterým bude možné komunikovat pomocí HTTP. Server bude poslouchat na námi zadaném portu a podle url vytvářet správné HTTP odpovědi. Komunikovat se serverem má být umožněna pomocí nástroje curl nebo wget.
Parametry:
- Skript by mělo být možné spouštět pomocí Makefile příkazu: ```make run port=12345```
- Skrip může mít volitelný parametr ```port=12345```který udává na kterém portu bude server naslouchat.Defaultní port je 12345.


# Řešení
Skript jsem vytvořil v jazyce Python3 a je založen na knihovně socket.
### 1. Zpracování requestu
Prvně věc kterou je třeba udělat je navázat spojení se serverem na námi zadané adrese hosta a portu. Ze zadání je řečeno že adresa bude ```localhost``` a port libovolný.
Spojení se serverem navážeme pomocí příkazu: ```self.socket.bind((self.host,self.port))```

Poté budeme v nekonečném cyklu čekat na připojení hosta pomocí příkazů:
``` 
self.socket.listen(5)
conn, addr = self.socket.accept()
```
První z nich udává maximální možný počet připojení k serveru v tentýž čas. Ostatní připojení jsou odmítána.
Druhý je pro přijmutí připojení od hosta přičemž do addr adresa hosta a do conn se uloží soket k hostovy.

Následně jsou od hosta přijaty data pomocí
```data = conn.recv(1024) ```. Na základě dat jsou poté vybrány HTTP odpovědi hostovy, které jsou zaslány pomocí ```conn.send(server_response)```.
Po odeslání odpovědi hostovy je spojení uzavřeno ```conn.close()```.


### 2. Zpracována jednotlivých úloh
Před zpracováním jednotlivých úloh jsou ověřeny parametry requestu. Request musí být HTML verzi 1.1, metoda pro získání dat je GET a hostem zadaná cesta existuje.
- ### a. Hostname
Tato úloha má za úkol vypsat hostname serveru. Tuto hodnotu získáme pomocí příkazu
``` result = subprocess.run(['hostname'], stdout=subprocess.PIPE) ``` která načte hostname z příkazu hostname.
- ### b. cpu-name
Cílem je vypsat jméno CPU serveru. Tato uloha je funguje správně pouze pokud server běží na linuxovém OS, protože jméno bere ze souboru ```/proc/cpuinfo ```.

- ### c. load
Cílem je vypsat procentuální hodnotu využití procesoru. Tato úloha je funguje správně pouze pokud server běží na linuxovém OS, protože jméno bere ze souboru ```/proc/stat ```. Z tohoto souboru jsou získány data, která jsou následně podle návodu [zde ](https://stackoverflow.com/questions/23367857/accurate-calculation-of-cpu-usage-given-in-percentage-in-linux) vypočítána.
- ### d. load?refresh=5
Tato úloha je rozšíření úlohy load. Rozšíření spočívá v tom že je vypočtená hodnota aktualizovaná každých X sekund, přičemž počet sekund zadává host. Přičemž refresh je řešen pomocí meta refreshe v hlavičce
```<head><meta http-equiv="refresh" content=5'></head>```

# Souhrn
Skript spouští Web server který na základě url vrátí danou odpověď. Skrip je napsán v jazyce Python3 a je spustitelný pomocí Makefile. Skript byl testován na serveru ```merlin@fit.vutbr.cz``` a vytvořen pomocí Pycharm Community Edition.

