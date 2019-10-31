/**
xsuste11
 */


drop table Hotove CASCADE CONSTRAINTS;
drop table CreditCard CASCADE CONSTRAINTS;
drop table Prevod CASCADE CONSTRAINTS;
drop table sluzby_provedene CASCADE CONSTRAINTS;
drop table sluzby CASCADE CONSTRAINTS;
DROP TABLE Payment CASCADE CONSTRAINTS;
drop table zpusob_platby CASCADE CONSTRAINTS;
drop table Pobyt CASCADE CONSTRAINTS;
drop table rezervace_pokoju CASCADE CONSTRAINTS;
drop table Rezervace CASCADE CONSTRAINTS;
drop table pokoje CASCADE CONSTRAINTS;
drop table TypyPokoju CASCADE CONSTRAINTS;
Drop TABLE Hosts CASCADE CONSTRAINTS;
Drop sequence HostID_sekvence;
drop procedure Kdo_vyuzil_sluzbu;
drop procedure OBSAZENOST_HOTELU;
drop view pohled_hosts;
drop materialized view pohled_hosts_materialization;




create table Hosts(
  HostID NUMBER not null PRIMARY KEY,
  FirstName varchar(255) NOT NULL,
  LastName varchar(255) NOT NULL,
  Email varchar (255) NOT NULL,
  PhoneNumber varchar(15) NOT NULL
);

create table TypyPokoju(
  TypID NUMBER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  PocetPosteli int NOT NULL,
  Popis varchar2(255)
);

create table Pokoje(
  PokojID NUMBER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  stav varchar(255) NOT NULL,
  TypPokoje NUMBER NOT NULL,
  CONSTRAINT Fkey_typ FOREIGN KEY (TypPokoje) REFERENCES TypyPokoju(TypID)
);

create table sluzby(
  Jmeno varchar2(50) primary key not null ,
  popis varchar2(250),
  cena NUMBER NOT NULL
);

create table Rezervace(
  RezervaceID NUMBER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  OD DATE NOT NULL,
  DO DATE NOT NULL,
  RegistrationDate DATE NOT NULL,
  DobaPobytu int,
  CenaZaDen int,
  HostID NUMBER NOT NULL,
  CONSTRAINT Fkey_HOSTrezerv FOREIGN KEY (HostID) REFERENCES Hosts(HostID) ON DELETE CASCADE

);

CREATE TABLE rezervace_pokoju(
    RezervaceID NUMBER NOT NULL,
    PokojID NUMBER NOT NULL,
    CONSTRAINT Fkey_rezerv FOREIGN KEY (RezervaceID) REFERENCES Rezervace(RezervaceID) ON DELETE CASCADE,
    CONSTRAINT Fkey_pokoje FOREIGN KEY (PokojID) REFERENCES Pokoje(PokojID),
    CONSTRAINT Pkey_rezervPokoj PRIMARY KEY (RezervaceID,PokojID)

);

create table Pobyt(
  PobytID NUMBER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  CHECK_IN date NOT NULL,
  CKECK_OUT date NOT NULL,
  HostID NUMBER NOT NULL ,
  PokojID NUMBER NOT NULL ,
  CONSTRAINT Fkey_HOSTpobyt FOREIGN KEY (HostID) REFERENCES Hosts(HostID),
  CONSTRAINT Fkey_Pokojpobyt FOREIGN KEY (PokojID) REFERENCES Pokoje(PokojID)

);


create table zpusob_platby(
  zpusobID NUMBER GENERATED ALWAYS AS IDENTITY PRIMARY KEY ,
  firstName varchar2(50),
  lastName varchar2(50)
);
create table Hotove(
  PK NUMBER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  ZpusobID NUMBER NOT NULL,
  CONSTRAINT Fkey_zpusob1 FOREIGN KEY (ZpusobID) REFERENCES zpusob_platby(zpusobID)
);
create table CreditCard(
  PK NUMBER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  ZpusobID NUMBER NOT NULL,
  cardNumber varchar2(16) NOT NULL,
  banka varchar2(50) ,
  CONSTRAINT Fkey_zpusob2 FOREIGN KEY (ZpusobID) REFERENCES zpusob_platby(zpusobID)
);
create table Prevod(
  PK NUMBER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  ZpusobID NUMBER NOT NULL,
  cisloUctu varchar2(10) NOT NULL,
  predcisli varchar2(8),
  kodBanky varchar2(4) NOT NULL,
  Banka varchar2(50),
  CONSTRAINT Fkey_zpusob3 FOREIGN KEY (ZpusobID) REFERENCES zpusob_platby(zpusobID)
);



Create table Payment(
  PaymentID NUMBER GENERATED ALWAYS AS IDENTITY PRIMARY KEY ,
  CenaZaSluzby int,
  CenaZaRezervaci int,
  CenaCelkem int,
  RezervaceID NUMBER NOT NULL ,
  ZpusobPlatby NUMBER NOT NULL ,
  CONSTRAINT Fkey_zpusoby FOREIGN KEY (ZpusobPlatby) REFERENCES zpusob_platby(zpusobID),
  CONSTRAINT Fkey_Rezervace FOREIGN KEY (RezervaceID) REFERENCES Rezervace(RezervaceID) ON DELETE CASCADE
                    );
create table sluzby_provedene(
  sluzbaID varchar2(50) ,
  HostID NUMBER NOT NULL ,
  PaymentID NUMBER NOT NULL,
  CONSTRAINT Fkey_sluzba foreign key (sluzbaID) REFERENCES Sluzby(Jmeno),
  CONSTRAINT Fkey_HOSTsluzba foreign key (HostID) REFERENCES Hosts(HostID),
  CONSTRAINT Fkey_payment FOREIGN KEY (PaymentID) REFERENCES Payment(PaymentID),
  CONSTRAINT Pkey_sluzhostpay PRIMARY KEY (sluzbaID,HostID,PaymentID)

);

ALTER TABLE Rezervace
ADD CONSTRAINT CHK_datedif CHECK (OD < DO);

alter table Payment
add constraint CHK_soucet CHECK ( CenaZaSluzby+CenaZaRezervaci=CenaCelkem );
---////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
---////////////////////////////////////////////////////////////////////////////PROJ4///////////////////////////////////////////////////////////////////
---////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

---Trigers
CREATE SEQUENCE HostID_sekvence; -- vytvori hostID sekvenci

--- Triger navyseni ID tabulky
CREATE OR REPLACE TRIGGER Navyseni_HostsID BEFORE
    INSERT ON Hosts
    FOR EACH ROW
    WHEN ( new.HostID IS NULL )
BEGIN
    :new.HostID := HostID_sekvence.nextval;
END;


--Triger Kontrola vypoctu ceny
CREATE OR REPLACE TRIGGER Kontrola_vypoctu_ceny BEFORE
    INSERT OR UPDATE OF CenaZaRezervaci,CenaZaSluzby,CenaCelkem,RezervaceID,PaymentID ON Payment
    FOR EACH ROW
DECLARE
    RezDen   NUMBER;
    RezDoba  NUMBER;
    RezCelk  NUMBER;
    SluSUM   NUMBER;
    CELEK    NUMBER;

BEGIN
  ---rezervace
    SELECT R.CenaZaDen
    INTO RezDen
    FROM Rezervace R
    WHERE R.RezervaceID =:new.RezervaceID;

    SELECT R.DobaPobytu
    INTO RezDoba
    FROM Rezervace R
    WHERE R.RezervaceID =:new.RezervaceID;

    RezCelk := RezDen*RezDoba;

    IF
        (:new.CenaZaRezervaci != RezCelk )
    THEN
        raise_application_error(-20203,'Cena za rezervaci v payment neodpovida cene v rezervaci');
    END IF;
/*
  ---sluzby
  SELECT SUM(sl.cena)
  INTO SluSUM
  FROM sluzby_provedene sl_p
  JOIN sluzby sl ON sl_p.sluzbaID = sl.Jmeno
  JOIN Payment P on sl_p.PaymentID = P.PaymentID
  where P.PaymentID = :new.PaymentID;

  IF
        (:new.CenaZaSluzby != SluSUM )
  THEN
        raise_application_error(-20203,'Cena za sluzby v payment neodpovida cene v rezervaci');
  END IF;

  ---Cena Celkem
  CELEK := SluSUM + RezCelk;

  IF
        (:new.CenaCelkem != CELEK )
  THEN
        raise_application_error(-20203,'Cena Celkem neodpovida souctu cen');
  END IF;
  */
END;

---procedury

--Procedura vypise procentualni obsazeni hotelu
CREATE OR REPLACE PROCEDURE Obsazenost_hotelu IS

    curs_stav    pokoje.stav%TYPE;
    pocet_pokoju NUMBER;
    Obsazeno     NUMBER;
    CURSOR curs_pokoje IS
      SELECT stav FROM Pokoje;

BEGIN
    Obsazeno := 0;
    SELECT COUNT(*) INTO pocet_pokoju
    FROM pokoje;

    OPEN curs_pokoje;
    LOOP
      FETCH curs_pokoje INTO curs_stav;
      EXIT WHEN curs_pokoje%notfound;

      IF (curs_stav = 'Obsazen')
      THEN Obsazeno := Obsazeno + 1;
      END IF;

    END LOOP;

    dbms_output.put_line('Je celkem '|| Obsazeno / pocet_pokoju * 100  || '% pokoju v hotelu obsazeno. Takze je ' || Obsazeno ||  ' ze '
    || pocet_pokoju || ' pokoju obsazeno');

EXCEPTION
    WHEN zero_divide THEN
        dbms_output.put_line('Zadny z pokoju neni obsazeny');
END;



--Vyuzil sluzebu
CREATE OR REPLACE PROCEDURE Kdo_vyuzil_sluzbu (
    jmeno IN VARCHAR2
) IS
    curs_sluzba  sluzby.Jmeno%TYPE;
	  curs_hostID  Hosts.HostID%TYPE;
	  email  Hosts.Email%TYPE;
    firstname Hosts.Firstname%TYPE;
    lastname Hosts.LastName%TYPE;

	CURSOR curs_sluzby IS
		SELECT sluzbaID,HostID FROM sluzby_provedene;
BEGIN
	OPEN curs_sluzby;
  dbms_output.put_line('Sluzbu vyuzil:');
	LOOP
		FETCH curs_sluzby INTO curs_sluzba,curs_hostID;
		EXIT WHEN curs_sluzby%NOTFOUND;

		SELECT Hosts.Email INTO email
		FROM hosts
		WHERE curs_hostID = HostID;

		SELECT Hosts.FirstName INTO firstname
		FROM hosts
		WHERE curs_hostID = HostID;

		SELECT Hosts.LastName INTO lastname
		FROM hosts
		WHERE curs_hostID = HostID;

		IF (curs_sluzba = jmeno) THEN
			dbms_output.put_line(firstname || ' ' || lastname || ' (' || email || ')');
		END IF;
	END LOOP;
END;





insert into Hosts(FirstName, LastName, Email, PhoneNumber)
  values ('John', 'doe', 'jogn@aselk.com', '123456789');
insert into Hosts(FirstName, LastName, Email, PhoneNumber)
  values ('petr', 'lok', 'jekln@flkv.com', '123456843');
insert into Hosts(FirstName, LastName, Email, PhoneNumber)
  values ('anak', 'likn', 'posktn@asesdfg.com', '123488789');
insert into Hosts(FirstName, LastName, Email, PhoneNumber)
  values ('Petr', 'KEEL', 'test@asesdfg.com', '123999999');
insert into Hosts(FirstName, LastName, Email, PhoneNumber)
  values ('Service', 'Tester', 'service@test.com', '111222333');
insert into Hosts(FirstName, LastName, Email, PhoneNumber)
  values ('Procedure', 'Test', 'procedure@test.com', '111222333');

insert into TypyPokoju(pocetposteli, popis)
  values (2,'dvouluzko');
insert into TypyPokoju(pocetposteli, popis)
  values (1,'jednoluzko');
insert into TypyPokoju(pocetposteli, popis)
  values (3,'Trojluzko');

insert into sluzby(jmeno, popis, cena)
  values ('dodani na pokoj','xxxx',30);
insert into sluzby(jmeno, popis, cena)
  values ('masaz','masaz',600);
insert into sluzby(jmeno, popis, cena)
  values ('test1','testovaci sluzba', 500);
insert into sluzby(jmeno, popis, cena)
  values ('test2','testovaci sluzba', 700);


insert into Pokoje(stav, TypPokoje)
  values ('Obsazen',1);
insert into Pokoje(stav, TypPokoje)
  values ('Obsazen',2);
insert into Pokoje(stav, TypPokoje)
  values ('Obsazen',2);
insert into Pokoje(stav, TypPokoje)
  values ('volny',2);
insert into Pokoje(stav, TypPokoje)
  values ('volny',1);
insert into Pokoje(stav, TypPokoje)
  values ('volny',3);
insert into Pokoje(stav, TypPokoje)
  values ('volny',2);
insert into Pokoje(stav, TypPokoje)
  values ('Obsazen',2);
insert into Pokoje(stav, TypPokoje)
  values ('Obsazen',2);

insert into Rezervace( od, do, registrationdate, dobapobytu, cenazaden, HostID)
  values ('22/04/2019','30/04/2019','15/03/2019',8,600,1);
insert into Rezervace( od, do, registrationdate, dobapobytu, cenazaden, HostID)
  values ('12/04/2019','22/04/2019','10/03/2019',10,700,2);
insert into Rezervace( od, do, registrationdate, dobapobytu, cenazaden, HostID)
  values ('13/04/2019','25/04/2019','01/03/2019',12,650,3);
insert into Rezervace( od, do, registrationdate, dobapobytu, cenazaden, HostID)
  values ('13/04/2019','25/04/2019','01/03/2019',12,650,5);
insert into Rezervace( od, do, registrationdate, dobapobytu, cenazaden, HostID)
  values ('13/04/2019','25/04/2019','01/03/2019',12,650,6);

insert into rezervace_pokoju(rezervaceid, pokojid)
  values (1,1);
insert into rezervace_pokoju(rezervaceid, pokojid)
  values (2,1);
insert into rezervace_pokoju(rezervaceid, pokojid)
  values (3,3);
insert into rezervace_pokoju(rezervaceid, pokojid)
  values (4,8);
insert into rezervace_pokoju(rezervaceid, pokojid)
  values (5,9);


insert into Pobyt(check_in, ckeck_out, hostid, pokojid)
  values ('12/03/2019','23/03/2019',1,1);
insert into Pobyt(check_in, ckeck_out, hostid, pokojid)
  values ('25/03/2019','23/03/2019',2,2);
insert into Pobyt(check_in, ckeck_out, hostid, pokojid)
  values ('22/04/2019','30/04/2019',3,1);
insert into Pobyt(check_in, ckeck_out, hostid, pokojid)
  values ('22/04/2019','23/03/2019',4,4);
insert into Pobyt(check_in, ckeck_out, hostid, pokojid)
  values ('13/04/2019','25/04/2019',5,8);
insert into Pobyt(check_in, ckeck_out, hostid, pokojid)
  values ('13/04/2019','25/04/2019',6,9);

insert into zpusob_platby(firstName, lastName)
  values ((Select Hosts.Firstname from Payment join Rezervace on Rezervace.RezervaceID = Payment.RezervaceID
   join Hosts on Hosts.HostID = Rezervace.HostID),(Select Hosts.LastName from Payment join Rezervace on Rezervace.RezervaceID = Payment.RezervaceID
   join Hosts on Hosts.HostID = Rezervace.HostID));

insert into zpusob_platby(firstName, lastName)
  values ((Select Hosts.Firstname from Payment join Rezervace on Rezervace.RezervaceID = Payment.RezervaceID
   join Hosts on Hosts.HostID = Rezervace.HostID),(Select Hosts.LastName from Payment join Rezervace on Rezervace.RezervaceID = Payment.RezervaceID
   join Hosts on Hosts.HostID = Rezervace.HostID));

insert into zpusob_platby(firstName, lastName)
  values ((Select Hosts.Firstname from Payment join Rezervace on Rezervace.RezervaceID = Payment.RezervaceID
   join Hosts on Hosts.HostID = Rezervace.HostID),(Select Hosts.LastName from Payment join Rezervace on Rezervace.RezervaceID = Payment.RezervaceID
   join Hosts on Hosts.HostID = Rezervace.HostID));

insert into zpusob_platby(firstName, lastName)
  values ((Select Hosts.Firstname from Payment join Rezervace on Rezervace.RezervaceID = Payment.RezervaceID
   join Hosts on Hosts.HostID = Rezervace.HostID),(Select Hosts.LastName from Payment join Rezervace on Rezervace.RezervaceID = Payment.RezervaceID
   join Hosts on Hosts.HostID = Rezervace.HostID));

insert into zpusob_platby(firstName, lastName)
  values ((Select Hosts.Firstname from Payment join Rezervace on Rezervace.RezervaceID = Payment.RezervaceID
   join Hosts on Hosts.HostID = Rezervace.HostID),(Select Hosts.LastName from Payment join Rezervace on Rezervace.RezervaceID = Payment.RezervaceID
   join Hosts on Hosts.HostID = Rezervace.HostID));

insert into CreditCard(ZpusobID, cardNumber, banka)
  values (1,'1111222233334444','ING');
insert into CreditCard(ZpusobID, cardNumber, banka)
  values (2,'1111555533334444','AIRBANK');
insert into Hotove(ZpusobID)
values (3);
insert into CreditCard(ZpusobID, cardNumber, banka)
  values (4,'1111555555554444','AIRBANK');
insert into CreditCard(ZpusobID, cardNumber, banka)
  values (5,'1111555533334333','AIRBANK');


insert into Payment(CenaZaSluzby, CenaZaRezervaci, CenaCelkem, RezervaceID, ZpusobPlatby)
values (0,4800,4800,1,1);
insert into Payment(CenaZaSluzby, CenaZaRezervaci, CenaCelkem, RezervaceID, ZpusobPlatby)
values (0,7000,7000,2,2);
insert into Payment(CenaZaSluzby, CenaZaRezervaci, CenaCelkem, RezervaceID, ZpusobPlatby)
values (0,7800,7800,3,3);
insert into Payment(CenaZaSluzby, CenaZaRezervaci, CenaCelkem, RezervaceID, ZpusobPlatby)
values (1800,7800,9600,4,4);
insert into Payment(CenaZaSluzby, CenaZaRezervaci, CenaCelkem, RezervaceID, ZpusobPlatby)
values (600,7800,8400,5,5);

insert into sluzby_provedene(sluzbaID, HostID, PaymentID)
values ('test1',5,4);
insert into sluzby_provedene(sluzbaID, HostID, PaymentID)
values ('test2',5,4);
insert into sluzby_provedene(sluzbaID, HostID, PaymentID)
values ('masaz',5,4);
insert into sluzby_provedene(sluzbaID, HostID, PaymentID)
values ('masaz',6,5);

---///////////////////////////////////////////
--testovaci select pro triger
SELECT SUM(sl.cena)
  FROM sluzby_provedene sl_p
  JOIN sluzby sl ON sl_p.sluzbaID = sl.Jmeno
  JOIN Payment P on sl_p.PaymentID = P.PaymentID
  GROUP BY P.PaymentID;
---///////////////////////////////////////////

/*proj3*/



----Vyhledat hosty kteri zaplatili vic nez 5000

  SELECT Hosts.Email, Hosts.FirstName, Hosts.LastName
  from Rezervace
  join Hosts on Rezervace.HostID = Hosts.HostID
  join Payment on Rezervace.RezervaceID = Payment.RezervaceID
  where Payment.CenaCelkem > 5000
  GROUP BY Hosts.Email,Hosts.LastName,Hosts.FirstName;

----Vyhleda vsechny pokoje ktere jsou volne a dvouluzkove
  SELECT Pokoje.PokojID from Pokoje
  join TypyPokoju on Pokoje.TypPokoje = TypyPokoju.TypID
  where PocetPosteli = 2 and pokoje.stav = 'volny';

----Vyhleda vsecny hosty kteri si rezervovali pokoj c. 1

  SELECT H.Email, H.FirstName, H.LastName from Pobyt
  join Hosts H on Pobyt.HostID = H.HostID
  join Pokoje P on Pobyt.PokojID = P.PokojID
  where P.PokojID = 1
  group by H.Email, H.LastName, H.FirstName;

--- Vyhleda hosty kteri dali rezeraci v mesici dubnu
  SELECT H.Email, H.FirstName, H.LastName from Rezervace
  join Hosts H on Rezervace.HostID = H.HostID
  where Rezervace.OD > '01/04/2019' and Rezervace.OD <'30/04/2019'
  group by H.Email, H.LastName, H.FirstName;

---vypise vsechny pokoje ktere jsou rezervovany
  SELECT P.PokojID from Pokoje P
  where EXISTS(
    Select RezervaceID FROM rezervace_pokoju
    WHERE rezervace_pokoju.PokojID = P.PokojID
          );

----Vypise vsechny hosty kteri byli ubytovani v pokoji c. 1

  SELECT H.Email, H.FirstName, H.LastName from Hosts H
  where H.HostID IN(
    Select Pobyt.HostID from Pobyt
    join Pokoje P on Pobyt.PokojID = P.PokojID
    where P.PokojID = 1

    )
  GROUP BY H.Email, H.LastName, H.FirstName;

---- Vypise vsechny Hosty kteri platili creditni kartou a zaplatili vice nez 5000 za rezervaci
  SELECT Hosts.Email, Hosts.FirstName, Hosts.LastName
  from Rezervace
  join Hosts on Rezervace.HostID = Hosts.HostID
  join Payment on Rezervace.RezervaceID = Payment.RezervaceID
  join zpusob_platby zp on Payment.ZpusobPlatby = zp.zpusobID
  join CreditCard CC on zp.zpusobID = CC.ZpusobID
  where CenaCelkem > 5000;

---vyhleda pokoje s poctem uskutecnenych pobytu
  SELECT P.PokojID, COUNT(Pobyt.PokojID) AS POCET from Pobyt
  join Pokoje P on Pobyt.PokojID = P.PokojID
  having COUNT(Pobyt.PokojID) > 1
  group by P.PokojID;
---//////////////////////////////////////////////////////////////////////////////////////////////////////////////////

---pristupova prava
---///////////////////////////////////////////
GRANT ALL ON Hosts to xsuste11;
GRANT ALL ON Pokoje to xsuste11;
GRANT ALL ON Payment to xsuste11;
GRANT ALL ON Prevod to xsuste11;
GRANT ALL ON Pobyt to xsuste11;
GRANT ALL ON sluzby to xsuste11;
GRANT ALL ON sluzby_provedene to xsuste11;
GRANT ALL ON Rezervace to xsuste11;
GRANT ALL ON rezervace_pokoju to xsuste11;
GRANT ALL ON CreditCard to xsuste11;
GRANT ALL ON Hotove to xsuste11;
GRANT ALL On zpusob_platby to xsuste11;
GRANT ALL ON TypyPokoju to xsuste11;


GRANT ALL ON Hosts to xstrna11;
GRANT ALL ON Pokoje to xstrna11;
GRANT ALL ON Payment to xstrna11;
GRANT ALL ON Prevod to xstrna11;
GRANT ALL ON Pobyt to xstrna11;
GRANT ALL ON sluzby to xstrna11;
GRANT ALL ON sluzby_provedene to xstrna11;
GRANT ALL ON Rezervace to xstrna11;
GRANT ALL ON rezervace_pokoju to xstrna11;
GRANT ALL ON CreditCard to xstrna11;
GRANT ALL ON Hotove to xstrna11;
GRANT ALL On zpusob_platby to xstrna11;
GRANT ALL ON TypyPokoju to xstrna11;


---/////////////////////////////////////////////

--- Materializovany pohled

  CREATE VIEW pohled_hosts AS
    SELECT Email, FirstName, LastName from xsuste11.Hosts;

  CREATE MATERIALIZED VIEW pohled_hosts_materialization AS
        SELECT Email, FirstName, LastName from xsuste11.Hosts;

  ---vlozeni ukazkove polozky
  insert into xsuste11.Hosts(FirstName, LastName, Email, PhoneNumber)
  values ('View', 'Example', 'Example@email.com', '999999999');

  ---Ukazkovy select
     SELECT Email,FirstName,LastName from pohled_hosts;
     SELECT Email, FirstName, LastName from pohled_hosts_materialization;

---///////////////////////////////////////////
---explain plan
---///////////////////////////////////////////
  ALTER TABLE Pokoje
  DROP PRIMARY KEY CASCADE;
---///////////////////////////////////////////
  DROP INDEX EXP_IND;
---///////////////////////////////////////////
--Bez indexu
  EXPLAIN PLAN FOR
  SELECT P.PokojID, COUNT(Pobyt.PokojID) AS POCET from Pobyt
  join Pokoje P on Pobyt.PokojID = P.PokojID
  having COUNT(Pobyt.PokojID) > 1
  group by P.PokojID;

  SELECT * FROM TABLE(dbms_xplan.display);
---///////////////////////////////////////////
---///////////////////////////////////////////
---///////////////////////////////////////////

--s indexem

  CREATE UNIQUE INDEX EXP_IND ON Pokoje(PokojID);

  EXPLAIN PLAN FOR
  SELECT P.PokojID, COUNT(Pobyt.PokojID) AS POCET from Pobyt
  join Pokoje P on Pobyt.PokojID = P.PokojID
  having COUNT(Pobyt.PokojID) > 1
  group by P.PokojID;

  SELECT * FROM TABLE(dbms_xplan.display);

---///////////////////////////////////////////
---///////////////////////////////////////////
---///////////////////////////////////////////


--pomocne selecty
select * from Payment;
select * from sluzby_provedene;













/*
drop table Hotove;
drop table CreditCard;
drop table Prevod;
drop table sluzby_provedene;
drop table sluzby;
DROP TABLE Payment;
drop table zpusob_platby;
drop table Pobyt;
drop table rezervace_pokoju;
drop table Rezervace;
drop table pokoje;
drop table TypyPokoju;
Drop TABLE Hosts;
*/

