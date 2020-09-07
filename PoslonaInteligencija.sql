use master

use autobuski_prevoz

select * 
from radnik_kval

alter table radnik
drop column F5, F6, F7, F8, F9, F10, F11, F12

alter table radnik_kval
add constraint PK_radnik_kval primary key (radnik_kval_ID)


alter table radnik
add constraint PK_radnik_ID primary key(radnik_ID)

alter table radnik
add constraint FK_radnik_radnik_kval FOREIGN KEY (radnik_kval_ID) REFERENCES radnik_kval (radnik_kval_ID)

select *
from voznja$




alter table voznja$
add constraint PK_voznjaID  PRIMARY KEY (linija_ID)


delete from voznja$
WHERE linija_ID IS NULL

/* importoati sve tabele
vjerovatno treba kompozitni ključ 
jer linija ne može da bude primarni ključ
linijaID nije jednistvena
vjerovatno treba sa linijaID voziloID
*/

alter table voznja$
alter column linija_ID int NOT NULL


use prihodi

alter table dbo.polisa_osiguranja
ADD KlasaOsiguranja As CAST
(
	CASE 
	WHEN uk_iznos < 800 THEN 1
	WHEN uk_iznos >=800 and uk_iznos <1000 THEN 2
	ELSE 3
	END AS iNT
)

select *
from dbo.red_prihodi

alter table dbo.red_prihodi
add KlasaRedovnogPrihodaNeto AS CAST
(
	CASE 
	WHEN neto < 800 then 1
	WHEN neto >= 800 and neto <1100 then 2
	when neto >=1100 and neto <1400 then 3
	when neto >=1400 and neto <1700 then 4
	else 5
	end as int
)

alter table dbo.red_prihodi
add KlasaRedovnogPrihodaBruto AS CAST
(
	CASE
	WHEN bruto < 1250 then 1
	when bruto >=1250 and bruto <1800 then 2
	when bruto >=1800 and bruto <2350 then 3
	else 4
	end as int
)


create table KlasaRedovnogPrihodaNeto
(
	KlasaRedovnogPrihodaNetoID INT CONSTRAINT PK_KlasaRedovnogPrihodaNetoID PRIMARY KEY(KlasaRedovnogPrihodaNetoID)  IDENTITY(1,1),
	NazivKlasaredovnogPrihodaNeto NVARCHAR(20)
)

create table KlasaRedovnogPrihodaBruto
(
	KlasaRedovnogPrihodaBrutoID INT CONSTRAINT PK_KlasaRedovnogPrihodaBrutoID PRIMARY KEY(KlasaRedovnogPrihodaBrutoID)  IDENTITY(1,1),
	NazivKlasaredovnogPrihodaBruto NVARCHAR(20)
)

insert into KlasaRedovnogPrihodaBruto(NazivKlasaredovnogPrihodaBruto) 
values ('klasa1'), ('klasa2'), ('klasa3'), ('klasa4')

alter table dbo.red_prihodi
add  klasa_neto INT 

update red_prihodi
set klasa_neto = KlasaRedovnogPrihodaNeto

alter table dbo.red_prihodi
add klasa_bruto INT

update red_prihodi
set klasa_bruto = KlasaRedovnogPrihodaBruto

alter table dbo.red_prihodi
add constraint FK_red_prihodi_klasa_neto FOREIGN KEY (klasa_neto) REFERENCES dbo.KlasaRedovnogPrihodaNeto(KlasaRedovnogPrihodaNetoID)

alter table dbo.red_prihodi
add constraint FK_red_prihodi_klasa_bruto FOREIGN KEY (klasa_bruto) REFERENCES dbo.KlasaRedovnogPrihodaBruto(KlasaRedovnogPrihodaBrutoID)

alter authorization on database :: prihodi to sa


update  red_prihodi
set 
	neto = 0,
	zdravstveno = 0,
	penzijsko = 0,
	bruto = 0
	WHERE neto is null 

select *
from red_prihodi
WHERE neto is null

create database prihodi_DW

use prihodi_DW

create table DimOsoba
(
	OsobaKey INT CONSTRAINT PK_OsobaKey PRIMARY KEY(OsobaKey) IDENTITY(1,1),
	OsobaID INT,
	PoslodavacID INT,
	GradID INT
)

create table DimTipRedovnogPrihoda
(
	TipRedovnogPrihodaKey INT CONSTRAINT PK_TipRedovnogPrihodaKey PRIMARY KEY(TipRedovnogPrihodaKey) IDENTITY(1,1),
	TipRedovnogPrihodaID INT,
	NazivRedovnogPrihoda NVARCHAR(30)
)

create table DimKlasaRedovnogPrihodaNeto
(
	KlasaRedovnogPrihodaNetoKey INT CONSTRAINT PK_KlasaRedovnogPrihodaNetoKey PRIMARY KEY(KlasaRedovnogPrihodaNetoKey) IDENTITY(1,1),
	KlasaRedovnogPrihodaNetoID INT, 
	NazivKlasaredovnogPrihodaNeto NVARCHAR(20)
)

create table DimKlasaRedovnogPrihodaBruto
(
	KlasaRedovnogPrihodaBrutoKey INT CONSTRAINT PK_KlasaRedovnogPrihodaBrutoKey PRIMARY KEY(KlasaRedovnogPrihodaBrutoKey) IDENTITY(1,1),
	KlasaRedovnogPrihodaBrutoID INT,
	NazivKlasaRedovnogPrihodaBruto NVARCHAR(20)
)

create table FactRedovniPrihodi
(
	FactRedovniPrihodiKey INT CONSTRAINT PK_FactRedovniPrihodiKey PRIMARY KEY(FactRedovniPrihodiKey) IDENTITY(1,1),
	OsobaKey INT CONSTRAINT FK_osobaKey FOREIGN KEY (OsobaKey) REFERENCES DimOsoba(OsobaKey),
	TipRedovnogPrihodaKey INT CONSTRAINT FK_TipRedovnogPrihodaKey FOREIGN KEY (TipRedovnogPrihodaKey) REFERENCES DimTipRedovnogPrihoda(TipRedovnogPrihodaKey),
	KlasaRedovnogPrihodaNetoKey INT CONSTRAINT FK_KlasaRedovnogPrihodaNetoKey FOREIGN KEY (KlasaRedovnogPrihodaNetoKey) REFERENCES DimKlasaRedovnogPrihodaNeto(KlasaRedovnogPrihodaNetoKey),
	KlasaRedovnogPrihodaBrutoKey INT CONSTRAINT FK_KlasaRedovnogPrihodaBrutoKey FOREIGN KEY(KlasaRedovnogPrihodaBrutoKey) REFERENCES DimKlasaRedovnogPrihodaBruto(KlasaRedovnogPrihodaBrutoKey),
	RedovniPrihodiID int,
	RedovniPrihodi_Neto decimal(6,2),
	RedovniPrihodi_Bruto decimal(6,2)
)


use Northwind

select *
into order_details
from [Order Details]

delete order_details

select *
from order_details

use redovni_prihodi_DW

select *
from DimKlasaRedovnogPrihodaNeto

 select *
 from FactRedovniPrihodi

 
use redovni_prihodi_DW

select *
from [redovni_prihodi_DW].dbo.dim_red_prihodi


select *
into [redovni_prihodi_DW].dbo.dim_red_prihodi
from [prihodi].[dbo].[red_prihodi]

delete [redovni_prihodi_DW].dbo.dim_red_prihodi

use prihodi
select *
from vanr_prihodi

alter table vanr_prihodi
add kategorija as cast
(
	case 
	when iznos >=500 and iznos <1000 then 1	
	when iznos >=1000 and iznos <1500 then 2
	else  3
	end as int
)
alter table vanr_prihodi
drop column kategorija

use redovni_prihodi_DW

select *
into dim_uk_red_prihodi

from prihodi.dbo.vanr_prihodi

delete dim_vanr_prihodi
select *
from [dbo].[uk_red_prihodi]

use prihodi
select *

from [dbo].[tip_vanr_prihoda]

select osobaID, ime, prezime
into uk_red_prihodi
from prihodi.dbo.osoba

alter table uk_red_prihodi
add uk_bruto int
 
delete uk_red_prihodi

//-------ISPITNI ZADACI----------------------------------------

use publikacija_DW

select *
from dim_izdavac