create database indeks

use indeks

--omogućuje kreiranje dijagrama baze
alter authorization on database :: [AdventureWorks2016] to sa

/*
Prilikom kreiranja tabela voditi računa o međusobnom odnosu između tabela.
b) Kreirati tabelu radnik koja će imati sljedeću strukturu:
	radnikID, cjelobrojna varijabla, primarni ključ
	drzavaID, 15 unicode karaktera
	loginID, 30 unicode karaktera
	sati_god_odmora, cjelobrojna varijabla
	sati_bolovanja, cjelobrojna varijabla
*/
create table radnik
(
	radnikID INT  constraint PK_radnikID PRIMARY KEY,
	drzavaID NVARCHAR(15),
	loginID NVARCHAR(30),
	sati_god_omora INT,
	sati_bolovanja INT
)

/*
c) Kreirati tabelu kupovina koja će imati sljedeću strukturu:
	kupovinaID, cjelobrojna varijabla, primarni ključ
	status, cjelobrojna varijabla
	radnikID, cjelobrojna varijabla
	br_racuna, 15 unicode karaktera
	naziv_dobavljaca, 50 unicode karaktera
	kred_rejting, cjelobrojna varijabla
*/

create table kupovina
(
	kupovinaID INT constraint PK_kupovinaID PRIMARY KEY,
	status INT,
	radnikID INT,
	br_racuna NVARCHAR(15),
	naziv_dobavljaca NVARCHAR(50),
	kred_rejting INT
	constraint FK_kup_radnik_radnikID foreign key(radnikID) references radnik(radnikID)
)

/*
d) Kreirati tabelu prodaja koja će imati sljedeću strukturu:
	prodavacID, cjelobrojna varijabla, primarni ključ
	prod_kvota, novčana varijabla
	bonus, novčana varijabla
	proslogod_prodaja, novčana varijabla
	naziv_terit, 50 unicode karaktera
*/

create table prodaja
(
	prodavacID INT constraint PK_prodavaID PRIMARY KEY,
	prod_kvota MONEY,
	bonus MONEY,
	proslogod_prodaja MONEY,
	naziv_terit NVARCHAR(50)
	constraint FK_prod_rad_prodavacID foreign key(prodavacID) references radnik(radnikID)
)



--2. Import podataka
/*
a) Iz tabela humanresources.employee baze AdventureWorks2014 u tabelu radnik importovati podatke po sljedećem pravilu:
	BusinessEntityID -> radnikID
	NationalIDNumber -> drzavaID
	LoginID -> loginID
	VacationHours -> sati_god_odmora
	SickLeaveHours -> sati_bolovanja
*/

insert into radnik
select BusinessEntityID, NationalIDNumber, LoginID, VacationHours, SickLeaveHours
from AdventureWorks2016.HumanResources.Employee


/*
b) Iz tabela purchasing.purchaseorderheader i purchasing.vendor baze AdventureWorks2014 u tabelu kupovina
importovati podatke po sljedećem pravilu:
	PurchaseOrderID -> kupovinaID
	Status -> status
	EmployeeID -> radnikID
	AccountNumber -> br_racuna
	Name -> naziv_dobavljaca
	CreditRating -> kred_rejting
*/

insert into kupovina
select POH.PurchaseOrderID, POH.Status, POH.EmployeeID, PV.AccountNumber, PV.Name, PV.CreditRating
from AdventureWorks2016.Purchasing.PurchaseOrderHeader AS POH INNER JOIN AdventureWorks2016.Purchasing.Vendor AS PV
		ON POH.VendorID = PV.BusinessEntityID




/*
c) Iz tabela sales.salesperson i sales.salesterritory baze AdventureWorks2014 u tabelu prodaja
importovati podatke po sljedećem pravilu:
	BusinessEntityID -> prodavacID
	SalesQuota -> prod_kvota
	Bonus -> bonus
	SalesLastYear -> proslogod_prodaja
	Name -> naziv_terit
*/

--napomena:
--SalesLastYear se uzima iz tabele SalesTerritory

insert into prodaja
SELECT SS.BusinessEntityID, SS.SalesQuota, SS.Bonus, ST.SalesLastYear, ST.Name
FROM AdventureWorks2016.Sales.SalesPerson AS SS 
		INNER JOIN AdventureWorks2016.Sales.SalesTerritory AS ST
		ON SS.TerritoryID = ST.TerritoryID



--3.
/*
Iz tabela radnik i kupovina kreirati pogled view_drzavaID koji će imati sljedeću strukturu: 
	- naziv dobavljača,
	- drzavaID
Uslov je da u pogledu budu samo oni zapisi čiji ID države počinje ciframa u rasponu od 40 do 49, te da se 
kombinacije dobavljača i drzaveID ne ponavljaju.
*/
go
create view view_drzavaID 
as
select kupovina.naziv_dobavljaca, radnik.drzavaID
from radnik inner join kupovina on radnik.radnikID = kupovina.radnikID
where  LEFT(radnik.drzavaID,2) between 40 and 49
go

--4.
/*
Koristeći tabele radnik i prodaja kreirati pogled view_klase_prihoda koji će sadržavati ID radnika, ID države,
količnik prošlogodišnje prodaje i prodajne kvote, te oznaku klase koje će biti formirane prema pravilu: 
	- <10			- klasa 1 
	- >=10 i <20	- klasa 2 
	- >=20 i <30	- klasa 3
*/

go
create view view_klase_prihoda
as
select r.radnikID, r.drzavaID, p.proslogod_prodaja/p.prod_kvota AS kolicnik, 
		'klasa 1' as klasa
from radnik r inner join prodaja p
	ON r.radnikID = p.prodavacID
where p.proslogod_prodaja/p.prod_kvota<10
UNION 
select r.radnikID, r.drzavaID, p.proslogod_prodaja/p.prod_kvota AS kolicnik, 
		'klasa 2' as klasa
from radnik r inner join prodaja p
	ON r.radnikID = p.prodavacID
where p.proslogod_prodaja/p.prod_kvota >= 10 and p.proslogod_prodaja/p.prod_kvota <20
UNION
select r.radnikID, r.drzavaID, p.proslogod_prodaja/p.prod_kvota AS kolicnik, 
		'klasa 3' as klasa
from radnik r inner join prodaja p
	ON r.radnikID = p.prodavacID
where p.proslogod_prodaja/p.prod_kvota >= 20  and p.proslogod_prodaja/p.prod_kvota<30
go


select* 
from view_klase_prihoda


--5.
/*
Koristeći pogled view_klase_prihoda kreirati proceduru proc_klase_prihoda koja će prebrojati broj klasa.
Procedura treba da sadrži naziv klase i ukupan broj pojavljivanja u pogledu view_klase_prihoda. 
Sortirati prema broju pojavljivanja u opadajućem redoslijedu.
*/

go 
create procedure proc_klasa_prihoda
as 
begin
select klasa,  COUNT(*) as prebrojano
from view_klase_prihoda
group by klasa
order by 2
end
go

exec proc_klasa_prihoda

--6.
/*
Koristeći tabele radnik i kupovina kreirati pogled view_kred_rejting koji će sadržavati kolone drzavaID, 
kreditni rejting i prebrojani broj pojavljivanja kreditnog rejtinga po ID države.
*/
go
create view view_kred_rejting
as
select r.drzavaID, k.kred_rejting, COUNT(*) as prebrojano
from radnik r inner join kupovina k
	on r.radnikID=k.radnikID
group by r.drzavaID, k.kred_rejting
go

select*
from view_kred_rejting

--7.
/*
Koristeći pogled view_kred_rejting kreirati proceduru proc_kred_rejting koja će davati informaciju o 
najvećem prebrojanom broju pojavljivanja kreditnog rejtinga. Procedura treba da sadrži oznaku kreditnog rejtinga i n
ajveći broj pojavljivanja za taj kreditni rejting. Proceduru pokrenuti za sve kreditne rejtinge (1, 2, 3, 4, 5). 
*/
go 
create procedure proc_kred_rejting
(
	@kred_rejting INT = NULL
)
as
begin
select kred_rejting, MAX(prebrojano)
from view_kred_rejting
where kred_rejting = @kred_rejting
group by kred_rejting
end
go

--8.
/*
Kreirati tabelu radnik_nova i u nju prebaciti sve zapise iz tabele radnik. 
Nakon toga, svim radnicima u tabeli radnik_nova čije se ime u koloni loginID sastoji od 3 i manje slova, 
loginID promijeniti u slučajno generisani niz znakova.
*/

select *
into radnik_nova
from radnik

select loginID
FROM radnik_nova

select LEN(loginID) - 1 - CHARINDEX('\', loginID)
from radnik_nova

update radnik_nova
set loginID = LEFT(NEWID(),30)
WHERE  LEN(loginID) - 1 - CHARINDEX('\', loginID) <=3

--9.
/*
a) Kreirati pogled view_sume koji će sadržavati sumu sati godišnjeg odmora i sumu sati bolovanja za radnike iz 
tabele radnik_nova kojima je loginID promijenjen u slučajno generisani niz znakova 
b) Izračunati odnos (količnik) sume bolovanja i sume godišnjeg odmora. 
Ako je odnos veći od 0.5 dati poruku 'Suma bolovanja je prevelika. Odnos iznosi: ______'. 
U suprotnom dati poruku 'Odnos je prihvaljiv i iznosi: _____'
*/

go
create view view_sume
as
select SUM(sati_god_omora)AS god_odm , SUM(sati_bolovanja) as god_bol
from radnik_nova 
go


select 'Suma bolovanja je prevelika .Odnos iznosi: ' +cast(convert(real, god_bol) / god_odm as nvarchar) 
from view_sume
where god_bol/god_odm >0.5
UNION 
SELECT 'Odnos je prihvaljiv i iznosi: ' + cast(convert(real, god_bol) / god_odm as nvarchar) 
from view_sume
where god_bol/god_odm < 0.5


--10.
/*
a) Kreirati backup baze na default lokaciju.
b) Obrisati bazu.
c) Napraviti restore baze.
*/

backup database indeks
to disk = 'indeks.bak'

use master 

alter database  indeks
set offline

drop database indeks

restore database  indeks
from disk ='indeks.bak'
with replace

use indeks

/*
Kreirati bazu podataka BrojIndeksa sa sljedećim parametrima:
a) primarni i sekundarni data fajl:
- veličina: 		5 MB
- maksimalna veličina: 	neograničena
- postotak rasta:	10%
b) log fajl
- veličina: 		2 MB
- maksimalna veličina: 	neograničena
- postotak rasta:	5%
Svi fajlovi trebaju biti smješteni u folder c:\BP2\data\ koji je potrebno prethodno kreirati.
*/

create database BrojIndeksa1 ON PRIMARY
(
	NAME = 'BrojIndeksa1',
	FILENAME = 'c:\BP2\data\BrojIndeksa1.mdf',
	SIZE = 5MB,
	MAXSIZE = UNLIMITED,
	FILEGROWTH = 10%
),
(
	NAME = 'BrojIndeksa1_sek',
	FILENAME = 'c:\BP2\data\BrojIndeksa1.ndf',
	SIZE= 5MB,
	MAXSIZE = UNLIMITED,
	FILEGROWTH= 10%
)

LOG ON
(
	NAME = 'BrojIndeksa1.log',
	FIleNAME = 'c:\BP2\log\BrojIndeksa_log1.ldf',
	SIZE = 2MB,
	MAXSIZE=UNLIMITED,
	FILEGROWTH= 5%
)
GO



/*
U bazu radna iz baze AdventureWorks2014 šeme Production prekopirati tabele Product, WorkOrder i WorkOrderRouting. 
Zadržati iste nazive tabela. Tabele smjestiti u defaultnu šemu.
*/


create database radna
use radna
select *
into Product
from AdventureWorks2016.Production.Product

select *
into WorkOrder
from AdventureWorks2016.Production.WorkOrder

select *
into WorkOrderRouting
from AdventureWorks2016.Production.WorkOrderRouting

/*
U kopiranim tabelama u bazi radna postaviti iste PK i potrebne FK kako bi se ostvarila veza između tabela.
*/
--

alter table Product
add constraint PK_ProductID PRIMARY KEY (ProductID)

alter table WorkOrder
Add constraint PK_WorkOrderID PRIMARY KEY(WorkOrderID)

alter table WorkOrder
Add constraint FK_ProductID FOREIGN KEY (ProductID) REFERENCES Product(ProductID)

alter table WorkOrderRouting
add constraint PK_WorkOrderRouting 
PRIMARY KEY(WorkOrderID,ProductID, OperationSequence)

alter table WorkOrderRouting
add constraint FK_WorkOrderRouting foreign key (WorkOrderID)
References WorkOrder(WorkOrderID)


/*
a) U tabeli Product kreirati ograničenje nad kolonom ListPrice kojim će biti onemogućen unos negativnog podatka.
b) U tabeli WorkOrder kreirati ograničenje nad kolonom EndDate kojim će se onemogućiti unos podatka manjeg od StartDate.
*/


select *
from Product

alter table Product
add constraint CK_ListPrice check(ListPrice >= 0)

alter table WorkOrder
add constraint CK_EndDate check(EndDate >= StartDate)



/*
Kreirati proceduru koja će izmijeniti podatke u koloni LocationID tabele WorkOrderRouting po sljedećem principu:
	10 -> A
	20 -> B
	30 -> C
	40 -> D
	45 -> E
	50 -> F
	60 -> G
*/

alter table WorkOrderRouting
alter column LocationID char (2)

go
create procedure proc_location1
as
begin
update WorkOrderRouting
set LocationID = 'A'
Where LocationID = '10'
update WorkOrderRouting
set LocationID = 'B'
Where LocationID = '20'
update WorkOrderRouting
set LocationID = 'C'
Where LocationID = '30'
update WorkOrderRouting
set LocationID = 'D'
Where LocationID = '40'
update WorkOrderRouting
set LocationID = 'E'
Where LocationID = '45'
update WorkOrderRouting
set LocationID = 'F'
Where LocationID = '50'
update WorkOrderRouting
set LocationID = 'G'
Where LocationID = '60'
END
GO

exec proc_location1

select *
from WorkOrderRouting

/*
Obrisati ograničenje kojim se definisala veza između tabela Product i WorkOrder.
*/

alter table WorkOrder
drop constraint [FK_ProductID]


/*
Podaci u koloni ProductNumber imaju formu AB-1234. Neka slova označavaju klasu podatka. 
Dati informaciju koliko različitih klasa postoji.
*/

select COUNT(distinct LEFT(ProductNumber,2))
from Product


/*
a) U tabeli Product kreirati kolonu klasa u koju će se smještati klase kolone ProductNumber pri čemu u kolonu
neće biti moguće pohraniti više od dva znaka.
b) Novoformiranu kolonu popuniti klasama iz kolone ProductNumber
*/

alter table Product
add klasa char(5)

alter table Product
add constraint CK_klasa check (len(klasa) <=2)

update Product
set klasa = LEFT(ProductNumber, 2)

select*
From Product

/*
Kreirati tabelu Cost u kojoj će biti kolone WorkOrderID i PlannedCost tabele WorkOrderRouting. 
Nakon toga dodati izračunatu (stalno pohranjenu) kolonu fening u kojoj će biti vrijednost feninga iz kolone PlannedCost.
Vrijednost feninga mora biti izražena kao cijeli broj (ne prihvata se oblik 0.20).
*/

SELECT WorkOrderID ,PlannedCost
into Cost
From WorkOrderRouting

alter table Cost
add fening as convert(int, (PlannedCost - FLOOR(PlannedCost))*100)


/*
U tabeli Cost dodati novu kolonu klasa u kojoj će biti oznaka 1 ako je vrijednost feninga manja od 50, 
odnosno, 2 ako je vrijednost feninga veća ili jednaka od 50.
*/

alter table Cost
add klasa int

go
create procedure proc_fening
AS 
BEGIN
update Cost
set klasa = 1 
WHERE fening <50

UPDATE Cost
set klasa =2
WHERE fening >=50
END 
GO

exec proc_fening

/*
U tabeli Product se nalazi kolona ProductLine. Prebrojati broj pojavljivanja svake od vrijednosti iz ove kolone, 
a zatim dati informaciju koliko je klasa čiji je broj pojavljivanja manji, a koliko veći od srednje vrijednosti
broja pojavljivanja.
*/


go
create view view_br_klasa
as
SELECT ProductLine, COUNT(*) as prebrojano
FROM Product
GROUP BY ProductLine
go

select*
from view_br_klasa

SELECT 'manje',  COUNT(*)
FROM view_br_klasa
WHERE prebrojano <(SELECT AVG(prebrojano) from view_br_klasa)
UNION 
SELECT 'vece ili jednako' , COUNT(*)
FROM view_br_klasa
WHERE prebrojano >= (SELECT AVG(prebrojano) from view_br_klasa)

select ProductLine, prebrojano, 'manje'
from view_br_klasa 
where prebrojano < (select AVG (prebrojano) from view_br_klasa)
union
select ProductLine, prebrojano, 'veće ili jednako'
from view_br_klasa 
where prebrojano >= (select AVG (prebrojano) from view_br_klasa)

/*
Kreirati proceduru kojom će se u tabeli Product za ReorderPoint koji su manji od 100 izvršiti 
uvećanje za unijetu vrijednost parametra povecanje.
*/

go 
create procedure proc_reorderPoint_povecanje
(
	@povecanje INT = NULL
)
AS 
BEGIN
update Product
set ReorderPoint = ReorderPoint + @povecanje
WHeRe ReorderPoint <100
END

/*
Kreirati proceduru kojom će se u tabeli Product vršiti brisanje zapisa prema unijetoj vrijednosti ProductSubcategoryID.
*/

go 
create procedure proc_ProductiSubcategoryID_brisasnje
(
	@ProductSubcategoryID INT = NULL
)
AS 
Begin
delete	Product
WHERE ProductSubcategoryID =  @ProductSubcategoryID
END


/*
Kreirati proceduru kojom će se u tabeli Product vršiti izmjena postojećeg u proizvoljni naziv boje. ž
Npr. Black preimenovati u crna.
*/

GO
CREATE PROCEDURE proc_promjena_boje
(
	@boja NVARCHAR(50) = NULL,
	@novaboja NVARCHAR(50) = NULL
)
AS
BEGIN
update Product
set Color = @novaboja
WHERE Color = @boja
end
GO

exec proc_promjena_boje 'Silver', 'Srebrena'
select *
from Product



--------------------------------------------------------------------------------

/*
Koristeći isključivo SQL kod, kreirati bazu pod vlastitim brojem indeksa sa defaultnim postavkama.
*/

create database Ispit_2019_06_24

use Ispit_2019_06_24

/*
Unutar svoje baze podataka kreirati tabele sa sljedećom struktorom:
--NARUDZBA
a) Narudzba
NarudzbaID, primarni ključ
Kupac, 40 UNICODE karaktera
PunaAdresa, 80 UNICODE karaktera
DatumNarudzbe, datumska varijabla, definirati kao datum
Prevoz, novčana varijabla
Uposlenik, 40 UNICODE karaktera
GradUposlenika, 30 UNICODE karaktera
DatumZaposlenja, datumska varijabla, definirati kao datum
BrGodStaza, cjelobrojna varijabla
*/

create table Narudzba
(
	NarudzbaID INT constraint PK_NarudzbaID PRIMARY KEY,
	Kupac NVARCHAR (40),
	PunaAdresa NVARCHAR(80),
	DatumNarudzbe date,
	Prevoz MONEY,
	Uposlenik NVARCHAR(40),
	GradUposlenika NVARCHAR(30),
	DatumZaposlenja DATE,
	BrGodStaza INT
)

--PROIZVOD
/*
b) Proizvod
ProizvodID, cjelobrojna varijabla, primarni ključ
NazivProizvoda, 40 UNICODE karaktera
NazivDobavljaca, 40 UNICODE karaktera
StanjeNaSklad, cjelobrojna varijabla
NarucenaKol, cjelobrojna varijabla
*/

create table Proizvod
(
	ProizvodID INT constraint PK_ProizvodID PRIMARY KEY,
	NazivProizvoda NVARCHAR(40),
	NazivDobavljaca NVARcHAR(40),
	StanjeNaSklad INT,
	NarucenaKol INT
)


--DETALJINARUDZBE
/*
c) DetaljiNarudzbe
NarudzbaID, cjelobrojna varijabla, obavezan unos
ProizvodID, cjelobrojna varijabla, obavezan unos
CijenaProizvoda, novčana varijabla
Kolicina, cjelobrojna varijabla, obavezan unos
Popust, varijabla za realne vrijednosti
Napomena: Na jednoj narudžbi se nalazi jedan ili više proizvoda.
*/

create table DetaljiNarudzbe
(
	NarudzbaID INT NOT NULL,
	ProizvodID INT NOT NULL,
	CijenaProizvoda MONEY,
	Kolicina INT NOT NULL,
	Popust REAL,
	CONSTRAINT FK_NarudzbaID FOREIGN KEY (NarudzbaID) references Narudzba(NarudzbaID),
	CONSTRAINT FK_ProizvodID foreign key (ProizvodID) references Proizvod(ProizvodID),
	CONSTRAINT PK_NarudzbaID_ProizvodID PRIMARY KEY(NarudzbaID, ProizvodID)
)

--2a) narudzbe
/*
Koristeći bazu Northwind iz tabela Orders, Customers i Employees importovati podatke po sljedećem pravilu:
OrderID -> ProizvodID
ComapnyName -> Kupac
PunaAdresa - spojeno adresa, poštanski broj i grad, pri čemu će se između riječi staviti srednja crta sa razmakom 
prije i poslije nje
OrderDate -> DatumNarudzbe
Freight -> Prevoz
Uposlenik - spojeno prezime i ime sa razmakom između njih
City -> Grad iz kojeg je uposlenik
HireDate -> DatumZaposlenja
BrGodStaza - broj godina od datum zaposlenja
*/

INSERT INTO Narudzba
SELECT O.OrderID, C.CompanyName, 
		C.Address + ' - ' + C.PostalCode + ' - ' + C.City,
		O.OrderDate, O.Freight, E.LastName + ' ' +E.FirstName, E.City, E.HireDate, 
		DATEDIFF(YEAR, E.HireDate, GETDATE())
FROM Northwind.dbo.Customers  AS C INNER JOIN Northwind.dbo.Orders AS O
		ON C.CustomerID = O.CustomerID INNER JOIN Northwind.dbo.Employees AS E
		ON O.EmployeeID = E.EmployeeID

--proizvod
/*
Koristeći bazu Northwind iz tabela Products i Suppliers putem podupita importovati podatke po sljedećem pravilu:
ProductID -> ProizvodID
ProductName -> NazivProizvoda 
CompanyName -> NazivDobavljaca 
UnitsInStock -> StanjeNaSklad 
UnitsOnOrder -> NarucenaKol 
*/
USE Ispit_2019_06_24

INSERT INTO Proizvod
Select P.ProductID, P.ProductName, S.CompanyName, P.UnitsInStock, P.UnitsOnOrder
FROM Northwind.dbo.Products AS P INNER JOIN Northwind.dbo.Suppliers AS S
	ON P.SupplierID = S.SupplierID
WHERE P.ProductID IN (SELECT P.ProductID FROM Northwind.dbo.Products)

--detaljinarudzbe
/*
Koristeći bazu Northwind iz tabele Order Details importovati podatke po sljedećem pravilu:
OrderID -> NarudzbaID
ProductID -> ProizvodID
CijenaProizvoda - manja zaokružena vrijednost kolone UnitPrice, npr. UnitPrice = 3,60 CijenaProizvoda = 3,00
*/

INSERT INTO DetaljiNarudzbe
SELECT O.OrderID, O.ProductID, FLOOR(O.UnitPrice), O.Quantity, O.Discount
FROM Northwind.dbo.[Order Details] AS O

--3a
/*
U tabelu Narudzba dodati kolonu SifraUposlenika kao 20 UNICODE karaktera. 
Postaviti uslov da podatak mora biti dužine tačno 15 karaktera.
*/
--DODAVANJE I POPUNJAVANJE KOLONE SifraUposlenika U NARUDZBA

alter table Narudzba 
ADD SifraUposlenika NVARCHAR(20) CONSTRAINT CK_Sifra CHECK(LEN(SifraUposlenika) = 15)

--3b
/*
Kolonu SifraUposlenika popuniti na način da se obrne string koji se dobije spajanjem grada uposlenika i 
prvih 10 karaktera datuma zaposlenja pri čemu se između grada i 10 karaktera nalazi jedno prazno mjesto. 
Provjeriti da li je izvršena izmjena.
*/

UPDATE Narudzba
set SifraUposlenika =  LEFT(REVERSE(GradUposlenika +' ' +  LEFT(CONVERT(NVARCHAR, DatumZaposlenja), 10)),15)

--3c
/*
U tabeli Narudzba u koloni SifraUposlenika izvršiti zamjenu svih zapisa kojima grad uposlenika završava slovom "d" 
tako da se umjesto toga ubaci slučajno generisani string dužine 20 karaktera. Provjeriti da li je izvršena zamjena.
*/
--BRISANJE OGRANICENJA NA SifraUposlenika

ALTER TABLE Narudzba
DROP constraint CK_Sifra

update Narudzba
set SifraUposlenika = LEFT(NEWID(), 20)
WHERE GradUposlenika LIKE '%d'

SELECT *
FROM Narudzba

/*
Koristeći svoju bazu iz tabela Narudzba i DetaljiNarudzbe kreirati pogled koji će imati sljedeću strukturu: 
Uposlenik, SifraUposlenika, 
ukupan broj proizvoda izveden iz NazivProizvoda, uz uslove da je dužina sifre uposlenika 20 karaktera, 
te da je ukupan broj proizvoda veći od 2. Provjeriti sadržaj pogleda, pri čemu se treba izvršiti sortiranje po 
ukupnom broju proizvoda u opadajućem redoslijedu.*/

CREATE VIEW view_narudzba_detalji AS 
SELECT N.Uposlenik, N.SifraUposlenika, COUNT(P.NazivProizvoda) AS UkupnoProdatihProizvoda
FROM Narudzba AS N INNER JOIN DetaljiNarudzbe AS D
		ON N.NarudzbaID = D.NarudzbaID INNER JOIN Proizvod AS P ON D.ProizvodID = P.ProizvodID
WHERE LEN(N.SifraUposlenika) = 20 
GROUP BY N.Uposlenik, N.SifraUposlenika
HAVING COUNT(NazivProizvoda) > 2

SELECT *
FROM view_narudzba_detalji 
ORDER BY 3 DESC

/*
Koristeći vlastitu bazu kreirati proceduru nad tabelom Narudzbe kojom će se dužina podatka u koloni SifraUposlenika 
smanjiti sa 20 na 4 slučajno generisana karaktera. Pokrenuti proceduru. */

CREATE PROCEDURE proc_sifra
AS
BEGIN 
UPDATE Narudzba
SET SifraUposlenika = LEFT(NEWID(), 4)
WHERE LEN(SifraUposlenika) = 20
END

EXEC proc_sifra

/*
Koristeći vlastitu bazu podataka kreirati pogled koji će imati sljedeću strukturu: NazivProizvoda, 
Ukupno - ukupnu sumu prodaje proizvoda uz uzimanje u obzir i popusta. Suma mora biti zakružena na dvije decimale. 
U pogled uvrstiti one proizvode koji su naručeni, uz uslov da je suma veća od 10000. 
Provjeriti sadržaj pogleda pri čemu ispis treba sortirati u opadajućem redoslijedu po vrijednosti sume.
*/

CREATE VIEW view_nazivproizvoda AS
SELECT P.NazivProizvoda, ROUND(SUM((D.CijenaProizvoda *D.Kolicina * (1-D.Popust))),2) AS Ukupno
FROM Proizvod AS P INNER JOIN DetaljiNarudzbe AS D
		ON P.ProizvodID = D.ProizvodID INNER JOIN Narudzba AS N ON
		D.NarudzbaID = N.NarudzbaID
WHERE P.NarucenaKol >0
GROUP BY P.NazivProizvoda
HAVING ROUND(SUM((D.CijenaProizvoda *D.Kolicina * (1-D.Popust))),2)  > 10000

SELECT *
FROM view_nazivproizvoda
ORDER bY Ukupno DESC

--7a
/*
Koristeći vlastitu bazu podataka kreirati pogled koji će imati sljedeću strukturu: Kupac, NazivProizvoda, 
suma po cijeni proizvoda pri čemu će se u pogled smjestiti samo oni zapisi kod kojih je cijena proizvoda veća od 
srednje vrijednosti cijene proizvoda. Provjeriti sadržaj pogleda pri čemu izlaz treba sortirati u rastućem redoslijedu
izračunatoj sumi.
*/

CREATE VIEW view_kupac_proizvod AS 
SELECT N.Kupac, P.NazivProizvoda, SUM(D.CijenaProizvoda) AS CijenaPoSumi
FROM Proizvod AS P INNER JOIN DetaljiNarudzbe AS D
		ON P.ProizvodID = D.ProizvodID INNER JOIN Narudzba AS N ON
		D.NarudzbaID = N.NarudzbaID 
WHERE D.CijenaProizvoda > (SELECT AVG(CijenaProizvoda) FROM DetaljiNarudzbe)
GROUP BY N.Kupac, P.NazivProizvoda

SELECT *
FROM view_kupac_proizvod
ORDER BY CijenaPoSumi 


--7b
/*
Koristeći vlastitu bazu podataka kreirati proceduru kojom će se, koristeći prethodno kreirani pogled, 

definirati parametri: kupac, NazivProizvoda i SumaPoCijeni.
Proceduru kreirati tako da je prilikom izvršavanja moguće unijeti bilo koji broj parametara 
(možemo ostaviti bilo koji parametar bez unijete vrijednosti), uz uslov da vrijednost sume bude veća od srednje 
vrijednosti suma koje su smještene u pogled. Sortirati po sumi cijene. 
Procedura se treba izvršiti ako se unese vrijednost za bilo koji parametar.
Nakon kreiranja pokrenuti proceduru za sljedeće vrijednosti parametara:
1. SumaPoCijeni = 123
2. Kupac = Hanari Carnes
3. NazivProizvoda = Côte de Blaye
*/
CREATE PROCEDURE proc_sumapocijeni
(
	@SumaPoCijeni INT = NULL,
	@Kupac NVARCHAR(40) = NULL,
	@NazivProizvoda NVARCHAR(40) = NULL
)
AS 
BEGIN 
SELECT Kupac, NazivProizvoda, CijenaPoSumi
FROM view_kupac_proizvod
WHERE CijenaPoSumi > (SELECT AVG(CijenaPoSumi) FROM view_kupac_proizvod) 
AND Kupac = @Kupac OR
	NazivProizvoda = @NazivProizvoda OR
	CijenaPoSumi = @SumaPoCijeni
ORDER BY 3

end

exec proc_sumapocijeni @SumaPoCijeni = 123
exec proc_sumapocijeni @Kupac = 'Hanari Carnes'
exec proc_sumapocijeni @NazivProizvoda = 'Côte de Blaye'

/*
a) Kreirati indeks nad tabelom Proizvod. Potrebno je indeksirati NazivDobavljaca. 
Uključiti i kolone StanjeNaSklad i NarucenaKol. Napisati proizvoljni upit nad tabelom Proizvod koji u 
potpunosti koristi prednosti kreiranog indeksa.*/
--a
CREATE NONCLUSTERED INDEX  IX_StanjNaSklad ON Proizvod
(
	NazivDobavljaca ASC
)
INCLUDE (StanjeNaSklad, NarucenaKol)


SELECT * FROM Proizvod
WHERE NazivDobavljaca = 'Pavlova, Ltd.' AND StanjeNaSklad > 10 AND NarucenaKol < 10

alter index [IX_StanjNaSklad] ON Proizvod
disable

/*Napraviti backup baze podataka na default lokaciju servera.*/
BACKUP DATABASE Ispit_2019_06_24
TO DISK = 'Ispit_2019_06_24.bak'


/*Kreirati proceduru kojom će se u jednom pokretanju izvršiti brisanje svih pogleda i procedura koji su kreirani u 
Vašoj bazi.*/

CREATE PROCEDURE proc_deleteall
AS
BEGIN 
 DROP VIEW [dbo].[view_kupac_proizvod]
 DROP VIEW [dbo].[view_narudzba_detalji]
 DROP VIEW [dbo].[view_nazivproizvoda]
 DROP PROCEDURE  [dbo].[proc_sifra]
 DROP PROCEDURE [dbo].[proc_sumapocijeni]
 END

 exec proc_deleteall

 use master 
 DROP DATABASE Ispit_2019_06_24

 RESTORE  DATABASE Ispit_2019_06_24
 FROM DISK = 'Ispit_2019_06_24.bak'



 -------------------------------------------------------------------------------

 
/*
1.
a) Kreirati bazu pod vlastitim brojem indeksa.
*/
create database BPII_2019_9_I
go
use BPII_2019_9_I
go



/* 
b) Kreiranje tabela.
Prilikom kreiranja tabela voditi računa o odnosima između tabela.
I. Kreirati tabelu narudzba sljedeće strukture:
	narudzbaID, cjelobrojna varijabla, primarni ključ
	dtm_narudzbe, datumska varijabla za unos samo datuma
	dtm_isporuke, datumska varijabla za unos samo datuma
	prevoz, novčana varijabla
	klijentID, 5 unicode karaktera
	klijent_naziv, 40 unicode karaktera
	prevoznik_naziv, 40 unicode karaktera
*/

create table Narudzba
(
	naruzbaID INT constraint PK_narudzbaID PRIMARY KEY,
	dtm_narudzbe DATE,
	dtm_isporuke date,
	prijevoz money,
	klijentID NVARCHAR(5),
	klijent_naziv nvarchar(40),
	prijevoz_naziv nvarchar(40)
)


/*
II. Kreirati tabelu proizvod sljedeće strukture:
	- proizvodID, cjelobrojna varijabla, primarni ključ
	- mj_jedinica, 20 unicode karaktera
	- jed_cijena, novčana varijabla
	- kateg_naziv, 15 unicode karaktera
	- dobavljac_naziv, 40 unicode karaktera
	- dobavljac_web, tekstualna varijabla
*/

create table Proizvod 
(
	proizvodID INT constraint PK_proizvodID PRIMARY KEY,
	mj_jedinica nvarchar(20),
	jed_cijena MONEY,
	kateg_naziv nvarchar(15),
	dobavljac_naziv nvarchar(40),
	dobavljac_web text
)


/*
III. Kreirati tabelu narudzba_proizvod sljedeće strukture:
	- narudzbaID, cjelobrojna varijabla, obavezan unos
	- proizvodID, cjelobrojna varijabla, obavezan unos
	- uk_cijena, novčana varijabla
*/

create table narudzba_proizvod
(
	narudzbaID INT,
	proizvodID INT,
	uk_cijena money,
	constraint FK_narudzba FOREIGN KEY(narudzbaID) references Narudzba(naruzbaID),
	constraint FK_proizvod FOREIGN KEY(proizvodID) references Proizvod(proizvodID),
	constraint PK_narudzba_proizvod PRIMARY KEY(narudzbaID, proizvodID)
)

/*
2. Import podataka
a) Iz tabela Customers, Orders i Shipers baze Northwind importovati podatke prema pravilu:
	- OrderID -> narudzbaID
	- OrderDate -> dtm_narudzbe
	- ShippedDate -> dtm_isporuke
	- Freight -> prevoz
	- CustomerID -> klijentID
	- CompanyName -> klijent_naziv
	- CompanyName -> prevoznik_naziv
*/

insert into Narudzba
SELECT O.OrderID, O.OrderDate, O.ShippedDate, O.Freight, 
		C.CustomerID, C.CompanyName, S.CompanyName
FROM Northwind.dbo.Customers AS C INNER JOIN Northwind.dbo.Orders AS O
	ON C.CustomerID = O.CustomerID INNER JOIN Northwind.dbo.Shippers AS S
	ON O.ShipVia = S.ShipperID


/*
b) Iz tabela Categories, Product i Suppliers baze Northwind importovati podatke prema pravilu:
	- ProductID -> proizvodID
	- QuantityPerUnit -> mj_jedinica
	- UnitPrice -> jed_cijena
	- CategoryName -> kateg_naziv
	- CompanyName -> dobavljac_naziv
	- HomePage -> dobavljac_web
*/

insert into Proizvod
SELECT P.ProductID, P.QuantityPerUnit, P.UnitPrice ,C.CategoryName, S.CompanyName, S.HomePage
FROM Northwind.dbo.Categories AS C INNER JOIN Northwind.dbo.Products AS P
	ON C.CategoryID = P.CategoryID INNER JOIN Northwind.dbo.Suppliers AS S
	ON P.SupplierID = S.SupplierID


/*
c) Iz tabele Order Details baze Northwind importovati podatke prema pravilu:
	- OrderID -> narudzbaID
	- ProductID -> proizvodID
	- uk_cijena <- proizvod jedinične cijene i količine
uz uslov da nije odobren popust na proizvod.
*/

insert into narudzba_proizvod
SELECT O.OrderID, O.ProductID, O.UnitPrice*O.Quantity
from Northwind.dbo.[Order Details] AS O
WHERE O.Discount = 0


/*
3. 
Koristeći tabele proizvod i narudzba_proizvod kreirati pogled view_kolicina koji će imati strukturu:
	- proizvodID
	- kateg_naziv
	- jed_cijena
	- uk_cijena
	- kolicina - količnik ukupne i jedinične cijene
U pogledu trebaju biti samo oni zapisi kod kojih količina ima smisao 
(nije moguće da je na stanju 1,23 proizvoda).
Obavezno pregledati sadržaj pogleda.
*/

create view view_kolicina
AS 
SELECT P.proizvodID, P.kateg_naziv, P.jed_cijena, NP.uk_cijena, 
		CONVERT(INT,FLOOR(NP.uk_cijena / P.jed_cijena)) AS kolicina
from narudzba_proizvod AS NP INNER JOIN Proizvod AS P
	ON NP.proizvodID = P.proizvodID 
WHERE FLOOR(NP.uk_cijena / P.jed_cijena) = NP.uk_cijena / P.jed_cijena

SELect *
from view_kolicina

/*
4. 
Koristeći pogled kreiran u 3. zadatku kreirati proceduru tako da je prilikom izvršavanja moguće 
unijeti bilo koji broj parametara (možemo ostaviti bilo koji parametar bez unijete vrijednosti). 
Proceduru pokrenuti za sljedeće nazive kategorija:
1. Produce
2. Beverages
*/

create procedure proc_kolicina
(
	@proizvodID INT = Null,
	@kateg_naziv nvarchar(15) = null,
	@kolicina int = null
)
as
begin
	select *
	from view_kolicina
	where	 proizvodID = @proizvodID OR
			kateg_naziv = @kateg_naziv OR
			kolicina = @kolicina
end

exec proc_kolicina @kateg_naziv= 'Produce'
exec proc_kolicina @kateg_naziv= 'Beverages'

/*
5.
Koristeći pogled kreiran u 3. zadatku kreirati proceduru proc_br_kat_naziv koja će vršiti prebrojavanja 
po nazivu 
kategorije. Nakon kreiranja pokrenuti proceduru.
*/

create procedure proc_br_kat_naziv
As
begin
	select kateg_naziv,  COUNT(kateg_naziv) AS broj_kateg_naziv
	from view_kolicina
	group by kateg_naziv
end
exec proc_br_kat_naziv

/*
6.
a) Iz tabele narudzba_proizvod kreirati pogled view_suma sljedeće strukture:
	- narudzbaID
	- suma - sume ukupne cijene po ID narudžbe
Obavezno napisati naredbu za pregled sadržaja pogleda.
b) Napisati naredbu kojom će se prikazati srednja vrijednost sume zaokružena na dvije decimale.
c) Iz pogleda kreiranog pod a) dati pregled zapisa čija je suma veća od prosječne sume. 
Osim kolona iz pogleda, potrebno je prikazati razliku sume i srednje vrijednosti. 
Razliku zaokružiti na dvije decimale.
*/

create view view_suma
as 
select narudzbaID, sum(uk_cijena) AS SumaCijena
from narudzba_proizvod 
group by narudzbaID

select *
from view_suma

select ROUND(AVG(SumaCijena),2) AS ProsjecnaVrijednost
from view_suma

select narudzbaID, SumaCijena,  SumaCijena - (select ROUND(AVG(SumaCijena),2) AS ProsjecnaVrijednost
					from view_suma) AS Razlika 
from view_suma
where  SumaCijena > (select ROUND(AVG(SumaCijena),2) AS ProsjecnaVrijednost
					from view_suma)


/*
7.
a) U tabeli narudzba dodati kolonu evid_br, 30 unicode karaktera 
b) Kreirati proceduru kojom će se izvršiti punjenje kolone evid_br na sljedeći način:
	- ako u datumu isporuke nije unijeta vrijednost, evid_br se dobija generisanjem slučajnog niza znakova
	- ako je u datumu isporuke unijeta vrijednost, evid_br se dobija spajanjem datum narudžbe i 
	datuma isprouke uz umetanje donje crte između datuma
Nakon kreiranja pokrenuti proceduru.
Obavezno provjeriti sadržaj tabele narudžba.
*/

alter table Narudzba
add evid_br nvarchar(30)

create procedure proc_evid_br
as 
begin 
	update  Narudzba
	set evid_br = LEFT(NEWID(), 30)
	WHERE dtm_isporuke is null
	update Narudzba
	set evid_br = CONVERT(NVARCHAR,dtm_narudzbe) + '_' + CONVERT(NVARCHAR,dtm_isporuke)
	where dtm_isporuke is not null
end

exec proc_evid_br

/*
8. Kreirati proceduru kojom će se dobiti pregled sljedećih kolona:
	- narudzbaID,
	- klijent_naziv,
	- proizvodID,
	- kateg_naziv,
	- dobavljac_naziv
Uslov je da se dohvate samo oni zapisi u kojima naziv kategorije sadrži samo 1 riječ.
Pokrenuti proceduru.
*/

create procedure proc_narudzba_pregled
AS
BEGIN
SElect N.naruzbaID, N.klijent_naziv, P.proizvodID, P.kateg_naziv, P.dobavljac_naziv
from Proizvod AS P inner join narudzba_proizvod AS NP ON
	P.proizvodID = NP.proizvodID INNER JOIN Narudzba  AS N ON
	NP.narudzbaID = N.naruzbaID
WHERE P.kateg_naziv NOT LIKE '% %' AND 
		P.kateg_naziv NOT LIKE '%/%'
END

exec proc_narudzba_pregled

/*
9.
U tabeli proizvod izvršiti update kolone dobavljac_web tako da se iz kolone dobavljac_naziv uzme prva riječ,
a zatim se formira web adresa u formi www.prva_rijec.com. Update izvršiti pomoću dva upita, 
vodeći računa o broju riječi u nazivu. 
*/
select dobavljac_naziv, CHARINDEX(' ', dobavljac_naziv), LEFT(dobavljac_naziv, CHARINDEX(' ', dobavljac_naziv))
From Proizvod
where CHARINDEX(' ', dobavljac_naziv) != 0

update Proizvod
set dobavljac_web = 'www.' + LEFT(dobavljac_naziv, CHARINDEX(' ', dobavljac_naziv)) + '.com'
where CHARINDEX(' ', dobavljac_naziv) != 0


update Proizvod
set dobavljac_web = 'www.' + dobavljac_naziv + '.com'
WHERE CHARINDEX(' ', dobavljac_naziv) = 0

/*
10.
a) Kreirati backup baze na default lokaciju.
b) Kreirati proceduru kojom će se u jednom izvršavanju obrisati svi pogledi i procedure u bazi. 
Pokrenuti proceduru.
*/

backup database BPII_2019_9_I
to disk = 'BPII_2019_9_I.bak'