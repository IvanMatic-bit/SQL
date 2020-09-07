

USE AdventureWorks2016
select ProductID, Name, ProductNumber, ListPrice, Color
FROM Production.Product
where Name LIKE '[ST]%' AND Color IN ('Blue', 'Black') AND ListPrice BETWEEN 100 AND 1000
Order by  ProductID  


SELECT CONVERT(nvarchar, OrderDate, 104)AS DatumNarudzbe, Status, ShipDate, SubTotal
FROM Sales.SalesOrderHeader
WHERE OrderDate BETWEEN '7/1/2013' AND '12/31/2013'
 AND TotalDue > 100000


SELECT ISNULL(Title, 'N\A'),  FirstName + ' '+LastName AS 'Ime i prezime', MiddleName
FROM Person.Person
WHERE MiddleName IS NULL



SELECT TOP 10 SUBSTRING(LoginID, CHARINDEX('\', LoginID)+1, 50),
		JobTitle, 
		HireDate, 
		DATEDIFF(YEAR, BirthDate, GETDATE()) AS 'Starost',
		DATEDIFF(YEAR, HireDate, GETDATE()) AS 'Staz'
FROM HumanResources.Employee
WHERE JobTitle LIKE '%Manager%'
ORDER BY Starost DESC


SELECT TOP 10 SalesOrderDetailID, CONVERT(nvarchar, OrderQty) + ' kom' AS 'Kolicina' ,CONVERT(nvarchar, UnitPrice)+ ' KM' AS 'Cijena', 
		UnitPrice*OrderQty AS 'Iznos'
FROM Sales.SalesOrderDetail
ORDER BY Iznos DESC



Use Northwind
SELECT CompanyName AS 'Ime kompanije', City AS 'Grad', Fax 
FROM Customers
WHERE (CompanyName LIKE '%Restaurant%' OR City = 'Madrid') AND Fax IS NOT NULL
ORDER BY CompanyName 

--------------------------------------------------------------------------------------

SELECT CompanyName, Country
FROM Suppliers
WHERE Country IN ('Germany', 'France') AND CompanyName LIKE '[AEP]%'

--------------------------------------------------------------------------------------

USE pubs
SELECT title, type, price, price - (price * 0.2) AS 'Cijena sa popustom'
FROM titles
WHERE price -(price*0.2) BETWEEN 10 AND 20
Order by type, [Cijena sa popustom] DESC

----------------------------------------------------------------------------------

USE AdventureWorks2016 
SELECT MIN(ListPrice) AS 'Minimalna cijena proizvoda', MAX(ListPrice) AS 'Maximalna cijena', AVG(ListPrice) As 'Prosjecna cijena'
FROM Production.Product
WHERE ListPrice != 0


---------------------------------------------------------------------------

USE AdventureWorks2016 
SELECT TOP 10 ProductID, SUM(OrderQty) AS Kolicina, SUM(OrderQty*UnitPrice) AS Zarada
FROM Sales.SalesOrderDetail
Group by ProductID
ORDER BY Kolicina DESC

---------------------------------------------------------------------------

USE AdventureWorks2016 
SELECT TOP 10 ProductID,  SUM(OrderQty*UnitPrice) AS Zarada
FROM Sales.SalesOrderDetail
Group by ProductID
HAVING SUM(OrderQty * UnitPrice) >30000
ORDER BY Zarada DESC

----------------------------------------------------------------------------
USE  Northwind 
SELECT  LOWER(LastName + '.'+ FirstName + '@' + City + '.Com') AS Email,
		DATEDIFF(YEAR, BirthDate, GETDATE()) AS Starost,
		RIGHT(REPLACE(SUBSTRING(REVERSE(CONVERT(nvarchar(MAX), Notes) + Title + Address), 10,15), ' ', '#'), 8)
FROM Employees



------------------------------------------------------------------------------


USE AdventureWorks2016 
SELECT TerritoryID, COUNT(CustomerID) AS 'Broj korisnika'
FROM Sales.Customer
GROUP BY TerritoryID
HAVING  COUNT(CustomerID) > 1000

---------------------------------------------------------------------------

SELECT  ProductModelID, COUNT(ProductID)
FROM Production.Product
WHERE ProductModelID IS NOT NULL 
GROUP BY  ProductModelID
HAVING COUNT(ProductID)>1

-------------------------------------------------------------------------------

USE AdventureWorks2016
SELECT TOP 10 WITH TIES ProductID, SUM(OrderQty) AS Kolicina
FROM Sales.SalesOrderDetail
GROUP BY ProductID
ORDER BY Kolicina DESC

----------------------------------------------------------------------------------

USE AdventureWorks2016 
SELECT ProductID, 
		ROUND(SUM(OrderQty*UnitPrice),2) AS 'Zarada bez popusta',
		ROUND(SUM((OrderQty*UnitPrice) - (OrderQty*UnitPrice*UnitPriceDiscount)),2) AS 'Zarada sa popustom' ,
		ROUND(SUM(LineTotal),2) AS 'Line total'
FROM Sales.SalesOrderDetail
WHERE UnitPriceDiscount > 0
GROUP BY ProductID
Order by [Zarada bez popusta] DESC


---------------------------------------------------------------------------------

USE AdventureWorks2016
SELECT DATEPART(month, OrderDate) AS 'Mjesec',
	   MIN(TotalDue) AS 'Minimalna zarada',
	   MAX(TotalDue) AS 'Maksimalna zarada',
	   AVG(TotalDue) AS 'Prosjecna zarada'
FROM Sales.SalesOrderHeader
WHERE YEAR(OrderDate) = 2013
GROUP BY DATEPART(month, OrderDate)
Order by Mjesec


-----------------------------------------------------------------------------------

USE Northwind
SELECT   E.FirstName + ' ' + E.LastName AS 'Ime i prezime',
		COUNT(O.EmployeeID) AS 'Broj narudzbi'
FROM Employees AS E INNER JOIN Orders AS O
		ON E.EmployeeID = O.EmployeeID
Group by E.FirstName, E.LastName
Order by [Broj narudzbi] DESC
----------------------------------------------------------------------------------

USE Northwind
SELECT   E.FirstName + ' ' + E.LastName AS 'Ime i prezime',
		COUNT(O.EmployeeID) AS 'Broj narudzbi'
FROM Employees AS E INNER JOIN Orders AS O
		ON E.EmployeeID = O.EmployeeID
WHERE OrderDate BETWEEN '7/1/1997' AND '7/31/1997'
Group by E.FirstName, E.LastName
HAVING COUNT(O.EmployeeID) >= 5
Order by [Broj narudzbi] DESC

------------------------------------------------------------------------------------


USE Northwind
SELECT S.CompanyName AS 'Naziv dobavljača',
		S.Phone AS 'Broj telefona',
		P.ProductName AS Proizvod,
		P.UnitsInStock AS Zalihe,
		SUM(O.Quantity)
FROM Suppliers AS S INNER JOIN Products AS P
	ON S.SupplierID = P.SupplierID INNER JOIN [Order Details] AS O 
	ON P.ProductID = O.ProductID
	WHERE P.UnitsInStock = 0
GROUP BY S.CompanyName, S.Phone, P.ProductName, P.UnitsInStock

-----------------------------------------------------------------------------------------

USE pubs
SELECT P.pub_name,
		ST.stor_name,
		T.title,
		SUM(T.price * SA.qty) AS Zarada
FROM stores AS ST INNER JOIN sales AS SA 
		ON ST.stor_id = SA.stor_id INNER JOIN titles AS T
		ON T.title_id = SA.title_id INNER JOIN publishers AS P
		ON P.pub_id = T.pub_id
WHERE P.pub_name LIKE 'New Moon Books'
GROUP BY P.pub_name, ST.stor_name, T.title
ORDER BY ST.stor_name, T.title

--------------------------------------------------------------

USE AdventureWorks2016
SELECT P.FirstName, P.LastName, CC.CardType,
		CC.CardNumber, SOH.SalesOrderNumber, SOH.OrderDate
FROM Sales.Customer AS C INNER JOIN Person.Person AS P
		ON C.PersonID = P.BusinessEntityID INNER JOIN
		Sales.PersonCreditCard AS PCC ON
		P.BusinessEntityID = PCC.BusinessEntityID INNER JOIN
		Sales.CreditCard AS CC ON
		PCC.CreditCardID = CC.CreditCardID INNER JOIN
		Sales.SalesOrderHeader AS SOH ON
		CC.CreditCardID = SOH.CreditCardID
WHERE P.FirstName LIKE 'Jordan' AND P.LastName LIKE 'Green'

---------------------------------------------------------------------------------

USE Northwind 
SELECT  TOP 1 C.CompanyName, C.Address, C.Phone, 
		 CONVERT(money, SUM(OD.Quantity*OD.UnitPrice))    AS  Potroseno
		
FROM Customers AS C INNER JOIN Orders AS O
	ON C.CustomerID = O.CustomerID INNER JOIN [dbo].[Order Details]
	AS OD ON O.OrderID = OD.OrderID
	WHERE C.City = 'London' AND MONTH(O.OrderDate) = 2
GROUP BY C.CompanyName, C.Address, C.Phone
ORDER BY [Potroseno] DESC

-----------------------------------------------------------------------

USE Northwind 
SELECT C.CompanyName, C.ContactName,
		C.City, C.Phone
FROM Customers AS C
WHERE (SELECT MAX(OD.Quantity * OD.UnitPrice)
		FROM Orders AS O  JOIN [Order Details] As OD
		ON O.OrderID = OD.OrderID
		WHERE C.CustomerID = O.CustomerID) > 100

-------------------------------------------------------------

USE Northwind

CREATE PROCEDURE usp_Products_Insert
(
	@ProductName NVARCHAR(40),
	@SupplierID INT = NULL,
	@CategoryID INT = NULL,
	@QuantityPerUnit NVARCHAR(20) = NULL,
	@UnitPrice MONEY = NULL,
	@UnitInStock SMALLINT = NULL,
	@UnitInOrder SMALLINT = NULL,
	@ReorderedLevel SMALLINT = NULL,
	@Discontinued BIT 
)
AS
BEGIN 
	INSERT INTO Products
	VALUES(@ProductName, @SupplierID, @CategoryID, @QuantityPerUnit, @UnitPrice, @UnitInStock, @UnitInOrder, @ReorderedLevel, @Discontinued) 
	END


EXEC usp_Products_Insert @ProductName = 'Coca Cola',
						@SupplierID  = 1,
						@CategoryID = 1,
						@UnitPrice = 5,
						@UnitInStock = 50,
						@UnitInOrder = 0,
						@Discontinued = 1

SELECT *
FROM Products 
WHERE ProductName LIKE '%Cola'

------------------------------------------------------

CREATE PROCEDURE usp_Products_Update
(
	@ProductID INT,
	@ProductName NVARCHAR(40),
	@SupplierID INT = NULL,
	@CategoryID INT = NULL,
	@QuantityPerUnit NVARCHAR(20) = NULL,
	@UnitPrice MONEY = NULL,
	@UnitInStock SMALLINT = NULL,
	@UnitInOrder SMALLINT = NULL,
	@ReorderedLevel SMALLINT = NULL,
	@Discontinued BIT 
)
AS
BEGIN 
	UPDATE Products
	SET @ProductName =  @ProductName,
	SupplierID =  @SupplierID, 
	CategoryID =  @CategoryID, 
	QuantityPerUnit =  @QuantityPerUnit, 
	UnitPrice =  @UnitPrice , 
 	UnitsInStock =  @UnitInStock,
	UnitsOnOrder =  @UnitInOrder,
	ReorderLevel =  @ReorderedLevel,
	Discontinued =  @Discontinued

	WHERE ProductID = @ProductID
	END

EXEC usp_Products_Update @ProductID = 78,
						@ProductName = 'Coca Cola',
						@SupplierID = 1,
						@CategoryID = 1,
						@UnitPrice = 7,
						@UnitInStock = 50,
						@UnitInOrder = 0,
						@Discontinued = 1

----------------------------------------------------------------

CREATE PROCEDURE usp_Products_Delete
(	
	@ProductID INT
)
AS 
BEGIN
	DELETE FROM Products
	WHERE ProductID = @ProductID
	
END

EXEC usp_Products_Delete @ProductID = 78


--------------------------------------------------------------------------

CREATE DATABASE Test

USE Test
CREATE TABLE Kupci 
( KupacID INT PRIMARY KEY IDENTITY(1,1),
	Ime NVARCHAR(50),
	Prezime NVARCHAR(50),
	Adresa NVARCHAR(100),
)

CREATE TABLE KupciAudit
(
	AuditID INT PRIMARY KEY IDENTITY (1,1),
	KupacID INT ,
	Ime NVARCHAR(50),
	Prezime NVARCHAR(50),
	Adresa NVARCHAR(100),
	Komanda NVARCHAR(10),
	Korisnik NVARCHAR(50),
	Datum DATETIME	
)


CREATE TRIGGER tr_Kupci_Insert
ON Kupci AFTER INSERT AS
 INSERT INTO KupciAudit
	(KupacID, Ime, Prezime,	Adresa, Komanda, Korisnik, Datum)
	SELECT	i.KupacID,
			i.Ime,
			i.Prezime,
			i.Adresa,
			'INSERT',
			SYSTEM_USER,
			GETDATE()

	FROM inserted AS i

INSERT INTO Kupci (Ime, Prezime, Adresa) VALUES ('Ivan', 'Matic', 'FIT')
INSERT INTO Kupci(Ime, Prezime, Adresa) VALUES ('Mia', 'Matic', 'MMD')

SELECT * FROM Kupci


------------------------------------------------------------------------------------------

		--::::::::::::::::::::PRIPREMA ZA ISPIT:::::::::::::::::::::::::::::::::::

------------------------------------------------------------------------------------------

CREATE DATABASE StudentskaSluzba ON PRIMARY 
(
	NAME = N'StudentskaSluzba',
	FILENAME = N'C:\Program Files\Microsoft SQL Server\MSSQL14.MSSQLSERVER_OLAP\MSSQL\DATA\StudentskaSluzba.mdf',
	SIZE = 5 MB,
	MAXSIZE = UNLIMITED,
	FILEGROWTH = 10%

)

LOG ON 
(	
	NAME = N'StudentskaSluzba_log',
	FILENAME = N'C:\Program Files\Microsoft SQL Server\MSSQL14.MSSQLSERVER_OLAP\MSSQL\DATA\StudentskaSluzba_log.ldf',
	SIZE = 2  MB,
	MAXSIZE = UNLIMITED,
	FILEGROWTH = 10%

)




----------------------------------------------------------------------------------------------------------------------
--									2019-06-24




Create database IB160139_1
Use IB160139_1

Create table Narudzba
(
	NarudzbaID INT CONSTRAINT PK_Narudzba PRIMARY KEY (NarudzbaID) ,
	Kupac NVARCHAR(40),
	PunaAdresaa NVARCHAR(80),
	DatumNarudzbe DATE,
	Prevoz Money,
	Uposlenik NVARCHAR(40),
	GradUposlenik NVARCHAR(30),
	DatumZaposlenja DATE,
	BrGodStaza INT

)

Create table Proizvod 
(
	ProizvodID INT CONSTRAINT PK_Proizvod PRIMARY KEY (ProizvodID),
	NazivProizvoda NVARCHAR(40),
	NazivDobavljaca NVARCHAR(40),
	StanjeNaSklad INT,
	NarucenaKol INT
)


CREATE TABLE DetaljiNarudzbe
(
	NarudzbaID INT NOT NULL,
	ProizvodID INT NOT NULl,
	CijenaProizvoda MONEY,
	Kolicina INT NOT NULL,
	Popust REAL,
	CONSTRAINT FK_Detalji_Narudzba FOREIGN KEY(NarudzbaID) REFERENCES Narudzba(NarudzbaID),
	CONSTRAINT FK_Detalji_Proizvod FOREIGN KEY(ProizvodID) REFERENCES Proizvod(ProizvodID),
	CONSTRAINT PK_DetaljiNarudzbe PRIMARY KEY (NarudzbaID, ProizvodID)
)

/*
Koristeći bazu Northwind iz tabela Orders, Customers i Employees importovati podatke po sljedećem pravilu:
OrderID -> ProizvodID
ComapnyName -> Kupac
PunaAdresa - spojeno adresa, poštanski broj i grad, pri čemu će se između riječi staviti srednja crta sa razmakom prije i poslije nje
OrderDate -> DatumNarudzbe
Freight -> Prevoz
Uposlenik - spojeno prezime i ime sa razmakom između njih
City -> Grad iz kojeg je uposlenik
HireDate -> DatumZaposlenja
BrGodStaza - broj godina od datum zaposlenja
*/



USE Northwind
USE IB160139_1
INSERT INTO Narudzba
SELECT O.OrderID,
		C.CompanyName,
		C.Address + ' - ' + C.PostalCode + ' - '+ C.City,
		O.OrderDate,
		Freight,
		E.FirstName + ' ' + E.LastName,
		E.City,
		E.HireDate,
		DATEDIFF(YEAR, E.HireDate, GETDATE())

FROM Northwind.dbo.Employees AS E INNER JOIN  Northwind.dbo.Orders AS O 
	ON E.EmployeeID = O.EmployeeID INNER JOIN Northwind.dbo.Customers AS C
	ON C.CustomerID = O.CustomerID

SELECT * FROM Narudzba


--proizvod
/*
Koristeći bazu Northwind iz tabela Products i Suppliers putem podupita importovati podatke po sljedećem pravilu:
ProductID -> ProizvodID
ProductName -> NazivProizvoda 
CompanyName -> NazivDobavljaca 
UnitsInStock -> StanjeNaSklad 
UnitsOnOrder -> NarucenaKol 
*/

USE Northwind
USE IB160139_1
INSERT INTO Proizvod
SELECT P.ProductID,
		P.ProductName,
		S.CompanyName,
		P.UnitsInStock,
		P.UnitsOnOrder
FROM Northwind.dbo.Suppliers AS S INNER JOIN Northwind.dbo.Products AS P
		ON S.SupplierID = P.SupplierID
WHERE P.ProductID IN 
(SELECT P.ProductID
FROM Northwind.dbo.Products)

SELECT * FROM Proizvod

--detaljinarudzbe
/*
Koristeći bazu Northwind iz tabele Order Details importovati podatke po sljedećem pravilu:
OrderID -> NarudzbaID
ProductID -> ProizvodID
CijenaProizvoda - manja zaokružena vrijednost kolone UnitPrice, npr. UnitPrice = 3,60 CijenaProizvoda = 3,00
*/

USE Northwind
USE IB160139_1
INSERT INTO DetaljiNarudzbe
SELECT  O.OrderID, O.ProductID, FLOOR(O.UnitPrice), O.Quantity, O.Discount
FROM Northwind.dbo.[Order Details] AS O


/*
U tabelu Narudzba dodati kolonu SifraUposlenika kao 20 UNICODE karaktera. Postaviti uslov da podatak mora biti dužine tačno 15 karaktera.
*/

ALTER TABLE Narudzba
ADD SifraUposlenika NVARCHAR(20) CONSTRAINT CK_Sifra CHECK(LEN (SifraUposlenika)=15)


/*
Kolonu SifraUposlenika popuniti na način da se obrne string koji se dobije spajanjem grada uposlenika i 
prvih 10 karaktera datuma zaposlenja pri čemu se između grada i 10 karaktera nalazi jedno prazno mjesto. 
Provjeriti da li je izvršena izmjena.
*/


UPDATE Narudzba
SET SifraUposlenika=  LEFT(REVERSE(GradUposlenik +' ' +LEFT(CONVERT(NVARCHAR, DatumZaposlenja), 10)),15)

SELECT *
FROM Narudzba

--3c
/*
U tabeli Narudzba u koloni SifraUposlenika izvršiti zamjenu svih zapisa kojima grad uposlenika završava slovom "d" 
tako da se umjesto toga ubaci slučajno generisani string dužine 20 karaktera. Provjeriti da li je izvršena zamjena.
*/
--BRISANJE OGRANICENJA NA SifraUposlenika

ALTER TABLE Narudzba
DROP CONSTRAINT CK_Sifra

UPDATE Narudzba
SET SifraUposlenika = LEFT(NEWID(), 20)
WHERE GradUposlenik LIKE '%d'

select * from Narudzba

/*
Koristeći svoju bazu iz tabela Narudzba i DetaljiNarudzbe kreirati pogled koji će imati sljedeću strukturu:
Uposlenik, SifraUposlenika, 
ukupan broj proizvoda izveden iz NazivProizvoda, uz uslove da je dužina sifre uposlenika 20 karaktera, 
te da je ukupan broj proizvoda veći od 2. Provjeriti sadržaj pogleda, 
pri čemu se treba izvršiti sortiranje po ukupnom broju proizvoda u opadajućem redoslijedu.*/


CREATE VIEW view_SifraUposlenika AS
SELECT N.Uposlenik, N.SifraUposlenika,  COUNT(P.NazivProizvoda) AS UkupnoProdatihProizvoda
FROM Narudzba AS N INNER JOIN DetaljiNarudzbe AS D
		ON N.NarudzbaID = D.NarudzbaID INNER JOIN Proizvod AS P
		ON D.ProizvodID = P.ProizvodID
WHERE LEN(N.SifraUposlenika) = 20
Group by N.Uposlenik, N.SifraUposlenika
HAVING COUNT(P.NazivProizvoda) >2


SELECT* FROM view_SifraUposlenika
ORDER BY UkupnoProdatihProizvoda DESC


/*
Koristeći vlastitu bazu kreirati proceduru nad tabelom Narudzbe kojom će se dužina podatka u koloni SifraUposlenika
smanjiti sa 20 na 4 slučajno generisana karaktera. Pokrenuti proceduru. */


CREATE PROCEDURE sifra_Narudzbe AS 
BEGIN 
UPDATE Narudzba
SET SifraUposlenika = LEFT(NEWID(), 4)
WHERE LEN(SifraUposlenika) = 20
END

EXEC sifra_Narudzbe

/*
Koristeći vlastitu bazu podataka kreirati pogled koji će imati sljedeću strukturu: 
NazivProizvoda, Ukupno - ukupnu sumu prodaje proizvoda uz uzimanje u obzir i popusta. 
Suma mora biti zakružena na dvije decimale. U pogled uvrstiti one proizvode koji su naručeni, 

uz uslov da je suma veća od 10000. Provjeriti sadržaj pogleda pri čemu ispis treba sortirati u 
opadajućem redoslijedu po vrijednosti sume.
*/
SELECT Popust
FROM DetaljiNarudzbe


CREATE VIEW view_Ukupno AS
SELECT P.NazivProizvoda, ROUND(SUM((DN.CijenaProizvoda*DN.Kolicina) - (DN.CijenaProizvoda*DN.Kolicina*DN.Popust)),2)AS Ukupno
FROM DetaljiNarudzbe AS DN INNER JOIN Proizvod AS P
		ON DN.ProizvodID = P.ProizvodID
WHERE P.NarucenaKol > 0
GROUP BY P.NazivProizvoda
HAVING ROUND(SUM((DN.CijenaProizvoda*DN.Kolicina) - (DN.CijenaProizvoda*DN.Kolicina*DN.Popust)),2) > 10000
ORDER BY 1

SELECT * FROM view_Ukupno

/*
Koristeći vlastitu bazu podataka kreirati pogled koji će imati sljedeću strukturu: Kupac, NazivProizvoda, 
suma po cijeni proizvoda pri čemu će se u pogled smjestiti samo oni zapisi kod kojih je cijena 
proizvoda veća od srednje vrijednosti cijene proizvoda.
Provjeriti sadržaj pogleda pri čemu izlaz treba sortirati u rastućem redoslijedu izračunatoj sumi.
*/

CREATE VIEW view_sr_vrij_cijene AS
SELECT N.Kupac, P.NazivProizvoda, SUM(DN.CijenaProizvoda) AS 'Cijena'
FROM Narudzba AS N INNER JOIN DetaljiNarudzbe AS DN ON
	N.NarudzbaID = DN.NarudzbaID INNER JOIN Proizvod AS P
	ON P.ProizvodID = DN.ProizvodID
	WHERE DN.CijenaProizvoda > (SELECT AVG(CijenaProizvoda) FROM DetaljiNarudzbe)
GROUP BY N.Kupac, P.NazivProizvoda




SELECT AVG(CijenaProizvoda)
FROM DetaljiNarudzbe

--7b
/*
Koristeći vlastitu bazu podataka kreirati proceduru kojom će se, koristeći prethodno kreirani pogled, 
definirati parametri: kupac, NazivProizvoda i SumaPoCijeni. 
Proceduru kreirati tako da je prilikom izvršavanja moguće unijeti bilo koji broj parametara 
(možemo ostaviti bilo koji parametar bez unijete vrijednosti), uz uslov da vrijednost sume bude veća od 
srednje vrijednosti suma koje su smještene u pogled. Sortirati po sumi cijene. 
Procedura se treba izvršiti ako se unese vrijednost za bilo koji parametar.
Nakon kreiranja pokrenuti proceduru za sljedeće vrijednosti parametara:
1. SumaPoCijeni = 123
2. Kupac = Hanari Carnes
3. NazivProizvoda = Côte de Blaye
*/


CREATE PROCEDURE view_INSERT_7b
(
	@Kupac NVARCHAR(40) = NULL,
	@NazivProizvoda NVARCHAR(40) = NULL,
	@Cijena MONEY = NULL
) 
AS 
BEGIN 
	SELECT Kupac, NazivProizvoda, Cijena
	FROM view_sr_vrij_cijene
	WHERE Cijena > (SELECT AVG(Cijena) FROM view_sr_vrij_cijene) AND 
	Kupac = @Kupac OR 
	NazivProizvoda =  @NazivProizvoda OR 
	Cijena = @Cijena
	ORDER BY 3

END

EXEC view_INSERT_7b @Cijena = 123
EXEC view_INSERT_7b @Kupac = 'Hanari Carnes'
EXEC view_INSERT_7b @NazivProizvoda = 'Côte de Blaye'

/*
a) Kreirati indeks nad tabelom Proizvod. Potrebno je indeksirati NazivDobavljaca. 
Uključiti i kolone StanjeNaSklad i NarucenaKol. Napisati proizvoljni upit nad tabelom 
Proizvod koji u potpunosti koristi prednosti kreiranog indeksa.*/
--a

CREATE NONCLUSTERED INDEX IX_StanjeNaSklad ON Proizvod
(
 NazivDobavljaca ASC
)
INCLUDE (StanjeNaSklad, NarucenaKol)

SELECT * FROM Proizvod
WHERE NazivDobavljaca = 'Pavlova, Ltd.' AND StanjeNaSklad > 10 AND NarucenaKol < 10

alter index IX_StanjeNaSklad 
ON Proizvod Disable




------------------------------------------------------------------------------------------------------------------

							--::2019-09-19::--



CREATE DATABASE BP_20190919

USE BP_20190919

--b) Kreiranje tabela.
/*
Prilikom kreiranja tabela voditi računa o međusobnom odnosu između tabela.
I. Kreirati tabelu kreditna sljedeće strukture:
	- kreditnaID - cjelobrojna vrijednost, primarni ključ
	- br_kreditne - 25 unicode karatera, obavezan unos
	- dtm_evid - datumska varijabla za unos datuma
*/

CREATE TABLE Kreditna
(
	kreditnaID INT  CONSTRAINT PK_Kreditna PRIMARY KEY,
	br_kreditne NVARCHAR (25) NOT NULL,
	dtm_evid date NOT NULL
)

/*
II. Kreirati tabelu osoba sljedeće strukture:
	osobaID - cjelobrojna vrijednost, primarni ključ
	kreditnaID - cjelobrojna vrijednost, obavezan unos
	mail_lozinka - 128 unicode karaktera
	lozinka - 10 unicode karaktera 
	br_tel - 25 unicode karaktera
*/

CREATE TABLE Osoba
(
	osobaID INT CONSTRAINT PK_Osoba PRIMARY KEY(osobaID),
	kreditnaID INT NOT NULL,
	mail_lozinka NVARCHAR (128),
	lozinka NVARCHAR(10),
	br_tel NVARCHAR(25)
	constraint FK_osoba_Kreditna FOREIGN KEY (kreditnaID) REFERENCES Kreditna(kreditnaID)
)

/*
III. Kreirati tabelu narudzba sljedeće strukture:
	narudzbaID - cjelobrojna vrijednost, primarni ključ
	kreditnaID - cjelobrojna vrijednost
	br_narudzbe - 25 unicode karaktera
	br_racuna - 15 unicode karaktera
	prodavnicaID - cjelobrojna varijabla
*/

CREATE TABLE Narudzba 
(
	narudzbaID INT CONSTRAINT OK_narudzba PRIMARY KEY(narudzbaID),
	kreditnaID INT,
	br_narudzbe NVARCHAR(25),
	br_racuna NVARCHAR(15),
	prodavnicaID INT ,
	CONSTRAINT FK_Narudzba_Kreditna FOREIGN KEY(kreditnaID) REFERENCES Kreditna(kreditnaID)
)

--2. Import podataka
/*
a) Iz tabele CreditCard baze AdventureWorks2017 importovati podatke u tabelu kreditna na sljedeći način:
	- CreditCardID -> kreditnaID
	- CardNUmber -> br_kreditne
	- ModifiedDate -> dtm_evid
*/


INSERT INTO Kreditna
SELECT C.CreditCardID, C.CardNumber, C.ModifiedDate
FROM AdventureWorks2016.Sales.CreditCard As C


/*
b) Iz tabela Person, Password, PersonCreditCard i PersonPhone baze AdventureWorks2017 koje se nalaze 
u šemama Sales i Person importovati podatke u tabelu osoba na sljedeći način:
	- BussinesEntityID -> osobaID
	- CreditCardID -> kreditnaID
	- PasswordHash -> mail_lozinka
	- PasswordSalt -> lozinka
	- PhoneNumber -> br_tel
*/


INSERT INTO Osoba
SELECT P.BusinessEntityID, CC.CreditCardID, PP.PasswordHash, PP.PasswordSalt, PPP.PhoneNumber
FROM AdventureWorks2016.Person.Password AS PP INNER JOIN  AdventureWorks2016.Person.Person AS P ON PP.BusinessEntityID = P.BusinessEntityID INNER JOIN AdventureWorks2016.Sales.PersonCreditCard AS PCC
	ON P.BusinessEntityID = PCC.BusinessEntityID INNER JOIN AdventureWorks2016.Sales.CreditCard AS CC 
	ON PCC.CreditCardID = CC.CreditCardID INNER JOIN AdventureWorks2016.Person.PersonPhone AS PPP ON PPP.BusinessEntityID = P.BusinessEntityID


/*
c) Iz tabela Customer i SalesOrderHeader baze AdventureWorks2017 koje se nalaze u šemi Sales 
importovati podatke u tabelu narudzba na sljedeći način:
	- SalesOrderID -> narudzbaID
	- CreditCardID -> kreditnaID
	- PurchaseOrderNumber -> br_narudzbe
	- AccountNumber -> br_racuna
	- StoreID -> prodavnicaID
*/

INSERT INTO Narudzba
SELECT SO.SalesOrderID, SO.CreditCardID, SO.PurchaseOrderNumber, SO.AccountNumber, C.StoreID
FROM AdventureWorks2016.Sales.Customer AS C INNER JOIN AdventureWorks2016.Sales.SalesOrderHeader AS SO
	ON C.CustomerID=SO.CustomerID


	/*
3. Kreirati pogled view_kred_mail koji će se sastojati od kolona: 
	- br_kreditne, 
	- mail_lozinka, 
	- br_tel i 
	- br_cif_br_tel, 
	pri čemu će se kolone puniti na sljedeći način:
	- br_kreditne - odbaciti prve 4 cifre 
 	- mail_lozinka - preuzeti sve znakove od 10. znaka (uključiti i njega) uz odbacivanje znaka jednakosti 
	koji se nalazi na kraju lozinke
	- br_tel - prenijeti cijelu kolonu
	- br_cif_br_tel - broj cifara u koloni br_tel
*/

CREATE VIEW view_kred_mail
AS 
SELECT SUBSTRING(K.br_kreditne, 5, 50) AS novi_br_kreditne,
		 LEFT(O.mail_lozinka, 10) AS novi_mail_lozinka,
		O.br_tel, LEN(O.br_tel) AS duzina_tel_br
FROM Osoba AS O INNER JOIN Kreditna AS K ON O.kreditnaID = K.kreditnaID INNER JOIN 
	Narudzba AS N ON K.kreditnaID = N.kreditnaID

SELECT *
FROM view_kred_mail

/*
4. Koristeći tabelu osoba kreirati proceduru proc_kred_mail u kojoj će biti sve kolone iz tabele. 
Proceduru kreirati tako da je prilikom izvršavanja moguće unijeti bilo koji broj parametara 
(možemo ostaviti bilo koji parametar bez unijete vrijednosti) uz uslov da se prenesu samo oni zapisi u kojima je 
unijet predbroj u koloni br_tel. Npr. (123) 456 789 je zapis u kojem je unijet predbroj. 
Nakon kreiranja pokrenuti proceduru za sljedeću vrijednost:
br_tel = 1 (11) 500 555-0132
*/


CREATE PROCEDURE proc_kred_mail 
(
	@osobaID INT = NULL ,
	@kreditnaID INT =NULL,
	@mail_lozinka NVARCHAR(128) = NULL,
	@lozinka NVARCHAR(10) = NULL,
	@br_tel NVARCHAR(25) = NULL
)
AS
BEGIN 
	SELECT *
	FROM Osoba
	WHERE br_tel LIKE '%(%' AND  
	( @osobaID	=  osobaID OR 
		@kreditnaID = kreditnaID OR 
		@mail_lozinka = mail_lozinka OR 
		@lozinka = lozinka OR 
		@br_tel = br_tel)
END


EXEC proc_kred_mail @br_tel= '1 (11) 500 555-0132'


/*
5. 
a) Kopirati tabelu kreditna u kreditna1, 
b) U tabeli kreditna1 dodati novu kolonu dtm_izmjene čija je default vrijednost aktivni datum sa vremenom. 
Kolona je sa obaveznim unosom.
*/

SELECT  * INTO kreditna1
FROM Kreditna

ALTER TABLE kreditna1
ADD dtm_izmjene datetime NOT NULL default(GETDATE())

/*
6.
a) U zapisima tabele kreditna1 kod kojih broj kreditne kartice počinje ciframa 1 ili 3 vrijednost broja kreditne kartice
zamijeniti slučajno generisanim nizom znakova.
b) Dati ifnormaciju (prebrojati) broj zapisa u tabeli kreditna1 kod kojih se datum evidencije nalazi u 
intevalu do najviše 6 godina u odnosu na datum izmjene.
c) Napisati naredbu za brisanje tabele kreditna1
*/

UPDATE kreditna1
set br_kreditne = LEFT(NEWID(), 25)
WHERE br_kreditne LIKE '[1|3]%'

SELECT br_kreditne 
FROM kreditna1
ORDER BY br_kreditne ASC

SELECT *
FROM kreditna1

SELECT COUNT(DATEDIFF(YEAR, dtm_evid, dtm_izmjene))
FROM kreditna1
WHERE DATEDIFF(YEAR, dtm_evid, dtm_izmjene) < 7


DROP TABLE kreditna1

-----------------------------------------


/*
7.
a) U tabeli narudzba izvršiti izmjenu svih null vrijednosti u koloni br_narudzbe slučajno generisanim nizom znakova.
b) U tabeli narudzba izvršiti izmjenu svih null vrijednosti u koloni prodavnicaID po sljedećem pravilu.
	- ako narudzbaID počinje ciframa 4 ili 5 u kolonu prodavnicaID preuzeti posljednje 3 cifre iz kolone narudzbaID  
	- ako narudzbaID počinje ciframa 6 ili 7 u kolonu prodavnicaID preuzeti posljednje 4 cifre iz kolone narudzbaID  
*/

--a
UPDATE Narudzba
SET br_narudzbe = LEFT(NEWID(),25)
WHERE br_narudzbe IS NULL

--b

UPDATE Narudzba
SET prodavnicaID = RIGHT(narudzbaID, 3)
WHERE prodavnicaID IS NULL AND narudzbaID LIKE '[4|5]%'

UPDATE Narudzba
SET prodavnicaID = RIGHT(narudzbaID, 4)
WHERE prodavnicaID IS NULL AND narudzbaID LIKE '[6|7]%'


/*
8.
Kreirati proceduru kojom će se u tabeli narudzba izvršiti izmjena svih vrijednosti u koloni br_narudzbe u 
kojima se ne nalazi slučajno generirani niz znakova tako da se iz podatka izvrši uklanjanje prva dva znaka. 
*/

SELECT *
FROM Narudzba

CREATE PROCEDURE proc_skracivanje
AS 
BEGIN 
	UPDATE Narudzba 
	SET br_narudzbe = SUBSTRING(br_narudzbe ,2, 22)
	where len (br_narudzbe) < 25
END

EXEC proc_skracivanje



/*
9.
a) Iz tabele narudzba kreirati pogled koji će imati sljedeću strukturu:
	- duz_br_nar 
	- prebrojano - prebrojati broj zapisa prema dužini podatka u koloni br_narudzbe 
	(npr. 1000 zapisa kod kojih je dužina podatka u koloni br_narudzbe 10)
Uslov je da se ne prebrojavaju zapisi u kojima je smješten slučajno generirani niz znakova. 
Provjeriti sadržaj pogleda.
b) Prikazati minimalnu i maksimalnu vrijednost kolone prebrojano
c) Dati pregled zapisa u kreiranom pogledu u kojima su vrijednosti u koloni prebrojano veće od srednje vrijednosti 
kolone prebrojano 
*/


SELECT LEN(br_narudzbe), COUNT(LEN(br_narudzbe))
FROM Narudzba
GROUP BY  LEN(br_narudzbe)

CREATE VIEW view_narudzba
AS 
SELECT LEN(br_narudzbe) AS duz_br_nar,
COUNT(LEN(br_narudzbe)) AS prebrojano
FROM Narudzba
WHERE LEN(br_narudzbe)<25
GROUP BY  LEN(br_narudzbe)

SELECT *
FROM view_narudzba
ORDER BY 1


SELECT *
FROM view_narudzba
WHERE prebrojano > (SELECT AVG(prebrojano)
						FROM view_narudzba)


/*
10.
a) Kreirati backup baze na default lokaciju.
b) Obrisati bazu.
*/

BACKUP DATABASE BP_20191919
TO DISC = 'BP_20191919_BU.bak'

DROP DATABASE BP_20190919


create view view_agregacija
as
select len (br_narudzbe) as duz_br_nar, count(len (br_narudzbe)) as prebrojano from Narudzba
where len (br_narudzbe) < 25
group by len (br_narudzbe)

select * from view_agregacija
order by 1