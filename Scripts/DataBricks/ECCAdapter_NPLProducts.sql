/*NPL Products */
truncate table NPLProducts;
drop table NPLProducts;

create table NPLProducts (
	id nvarchar(25) not null,
	currencycode nvarchar(3),
	stockquantity int,
	name nvarchar(50),
	description text,
	subcategoryid nvarchar(50),
	subcategoryname nvarchar(50),
	maincategoryid nvarchar(50),
	maincategoryname nvarchar(50),
	supplierid nvarchar(50),
	suppliername nvarchar(50),
	lastmodified date,
	price decimal,
	quantityunit nvarchar(10),
	measureunit nvarchar(10),
	PRIMARY KEY (id)
);

/*Product Type Description */
CREATE TYPE NPLProductsType As TABLE(
	id nvarchar(25) not null,
	currencycode nvarchar(3),
	stockquantity int,
	name nvarchar(50),
	description text,
	subcategoryid nvarchar(50),
	subcategoryname nvarchar(50),
	maincategoryid nvarchar(50),
	maincategoryname nvarchar(50),
	supplierid nvarchar(50),
	suppliername nvarchar(50),
	lastmodified date,
	price decimal,
	quantityunit nvarchar(10),
	measureunit nvarchar(10)
);

/*Create procedure to overwrite the product*/
drop procedure spOverwriteProducts

CREATE PROCEDURE spOverwriteProducts @Products [dbo].[NPLProductsType] READONLY
AS
BEGIN
  MERGE [dbo].[NPLProducts] AS target
  USING @Products AS source
  ON (target.id = source.id)
  WHEN MATCHED THEN
    UPDATE SET id = source.id,
				 currencycode  = source.currencycode,
				 stockquantity = source.stockquantity,
				 name = source.name,
				 description = source.description,
				 subcategoryid = source.subcategoryid,
				 subcategoryname = source.subcategoryname,
				 maincategoryid = source.maincategoryid,
				 maincategoryname = source.maincategoryname,
				 supplierid = source.supplierid,
				 suppliername = source.suppliername,
				 lastmodified = source.lastmodified,
				 price = source.price,
				 quantityunit = source.quantityunit,
				 measureunit = source.measureunit
  WHEN NOT MATCHED THEN
    INSERT (	
				id,
				currencycode,
				stockquantity,
				name,
				description,
				subcategoryid,
				subcategoryname,
				maincategoryid,
				maincategoryname,
				supplierid,
				suppliername,
				lastmodified,
				price,
				quantityunit,
				measureunit
			)
		VALUES (
				source.id,
				source.currencycode,
				source.stockquantity,
				source.name,
				source.description,
				source.subcategoryid,
				source.subcategoryname,
				source.maincategoryid,
				source.maincategoryname,
				source.supplierid,
				source.suppliername,
				source.lastmodified,
				source.price,
				source.quantityunit,
				source.measureunit
			);
END

/*Test the stored procedure*/
Declare @ProductsList NPLProductsType
Insert @ProductsList ( id, currencycode, stockquantity, name, description, subcategoryid, subcategoryname, maincategoryid, maincategoryname, supplierid, suppliername, lastmodified, price, quantityunit, measureunit)
Values ('1- HT-Test', 'USD', 149, 'Test1 - Notebook Basic 15', 'Test Description 1', 'NoteBooks', 'Notebooks', 'ComputerSystems', 'ComputerSystems', '100000000', 'SAP', '2018-10-15T19:16:37.1892050', 956, 'EA', 'each' ),
       ('2- HT-Test', 'USD', 155, 'Test2 - Notebook Basic 15', 'test Description 2', 'NoteBooks', 'Notebooks', 'ComputerSystems', 'ComputerSystems', '100000000', 'SAP', '2018-10-15T19:16:37.1892050', 956, 'EA', 'each' );
	   
exec spOverWriteProducts @ProductsList

/*Test Description Update */
select id, description from NPLProducts where id='HT-1022';



