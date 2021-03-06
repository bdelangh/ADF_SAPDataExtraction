SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[spOverwriteS4HSO] @SalesOrders [dbo].[S4HSalesOrder] READONLY
AS
BEGIN
  MERGE [dbo].[S4HSalesOrders] AS target
  USING @SalesOrders AS source
  ON (target.SALESDOCUMENT = source.SALESDOCUMENT)
  WHEN MATCHED THEN
    UPDATE SET  SALESDOCUMENT = source.SALESDOCUMENT,
				SDDOCUMENTCATEGORY = source.SDDOCUMENTCATEGORY,
                SALESDOCUMENTTYPE = source.SALESDOCUMENTTYPE,
				SALESDOCUMENTPROCESSINGTYPE = source.SALESDOCUMENTPROCESSINGTYPE,
				CREATIONDATE = source.CREATIONDATE,
				CREATIONTIME = source.CREATIONTIME,
				LASTCHANGEDATE = source.LASTCHANGEDATE,
				LASTCHANGEDATETIME = source.LASTCHANGEDATETIME,
				SALESORGANIZATION = source.SALESORGANIZATION,
				DISTRIBUTIONCHANNEL = source.DISTRIBUTIONCHANNEL,
				ORGANIZATIONDIVISION = source.ORGANIZATIONDIVISION,
				SALESGROUP = source.SALESGROUP,
				SALESOFFICE = source.SALESOFFICE,
				PURCHASEORDERBYCUSTOMER = source.PURCHASEORDERBYCUSTOMER,
				TRANSACTIONCURRENCY = source.TRANSACTIONCURRENCY,
				PRICINGDATE = source.PRICINGDATE,
				RETAILPROMOTION = source.RETAILPROMOTION,
				SALESDOCUMENTCONDITION = source.SALESDOCUMENTCONDITION,
				ODQ_CHANGEMODE = source.ODQ_CHANGEMODE,
				ODQ_ENTITYCNTR = source.ODQ_ENTITYCNTR
  WHEN NOT MATCHED THEN
    INSERT (	
				SALESDOCUMENT,
                SDDOCUMENTCATEGORY,
				SALESDOCUMENTTYPE,
				SALESDOCUMENTPROCESSINGTYPE,
				CREATIONDATE,
				CREATIONTIME,
				LASTCHANGEDATE,
				LASTCHANGEDATETIME,
				SALESORGANIZATION,
				DISTRIBUTIONCHANNEL,
				ORGANIZATIONDIVISION,
				SALESGROUP,
				SALESOFFICE,
				PURCHASEORDERBYCUSTOMER,
				TRANSACTIONCURRENCY,
				PRICINGDATE,
				RETAILPROMOTION,
				SALESDOCUMENTCONDITION,
				ODQ_CHANGEMODE,
				ODQ_ENTITYCNTR
			)
		VALUES (
				source.SALESDOCUMENT,
                source.SDDOCUMENTCATEGORY,
				source.SALESDOCUMENTTYPE,
				source.SALESDOCUMENTPROCESSINGTYPE,
				source.CREATIONDATE,
				source.CREATIONTIME,
				source.LASTCHANGEDATE,
				source.LASTCHANGEDATETIME,
				source.SALESORGANIZATION,
				source.DISTRIBUTIONCHANNEL,
				source.ORGANIZATIONDIVISION,
				source.SALESGROUP,
				source.SALESOFFICE,
				source.PURCHASEORDERBYCUSTOMER,
				source.TRANSACTIONCURRENCY,
				source.PRICINGDATE,
				source.RETAILPROMOTION,
				source.SALESDOCUMENTCONDITION,
				source.ODQ_CHANGEMODE,
				source.ODQ_ENTITYCNTR
			);
END
GO
