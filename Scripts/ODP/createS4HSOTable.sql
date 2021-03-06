SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[S4HSalesOrders](
	[SALESDOCUMENT] [nvarchar](10) NOT NULL,
	[SDDOCUMENTCATEGORY] [nvarchar](4) NULL,
	[SALESDOCUMENTTYPE] [nvarchar](4) NULL,
	[SALESDOCUMENTPROCESSINGTYPE] [nvarchar](1) NULL,
	[CREATIONDATE] [datetime] NULL,
	[CREATIONTIME] [time](7) NULL,
	[LASTCHANGEDATE] [datetime] NULL,
	[LASTCHANGEDATETIME] [decimal](18, 0) NULL,
	[SALESORGANIZATION] [nvarchar](4) NULL,
	[DISTRIBUTIONCHANNEL] [nvarchar](2) NULL,
	[ORGANIZATIONDIVISION] [nvarchar](2) NULL,
	[SALESGROUP] [nvarchar](3) NULL,
	[SALESOFFICE] [nvarchar](4) NULL,
	[PURCHASEORDERBYCUSTOMER] [nvarchar](35) NULL,
	[TRANSACTIONCURRENCY] [nvarchar](5) NULL,
	[PRICINGDATE] [datetime] NULL,
	[RETAILPROMOTION] [nvarchar](10) NULL,
	[SALESDOCUMENTCONDITION] [nvarchar](10) NULL,
	[ODQ_CHANGEMODE] [nvarchar](1) NULL,
	[ODQ_ENTITYCNTR] [decimal](18, 0) NULL
) ON [PRIMARY]
GO
SET ANSI_PADDING ON
GO
ALTER TABLE [dbo].[S4HSalesOrders] ADD PRIMARY KEY CLUSTERED 
(
	[SALESDOCUMENT] ASC
)WITH (STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ONLINE = OFF) ON [PRIMARY]
GO
