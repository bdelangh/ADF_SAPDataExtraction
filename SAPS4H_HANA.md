# Extract data from S4H using the HANA connector

In this example we'll use the HANA connector to extract SAP from the HANA database.
The demo system is the S4H Fully Activated Appliance deployed via [SAP CAL](https://cal.sap.com).

The SAP HANA connector supports:
* Copying data from any version of SAP HANA database.
* Copying data from HANA information models (such as Analytic and Calculation views) and Row/Column tables.
* Copying data using Basic or Windows authentication.
* Parallel copying from a SAP HANA source.

Please refer to the documentation at [Copy data from SAP HANA using Azure Data Factory](https://docs.microsoft.com/en-us/azure/data-factory/connector-sap-hana) for more info.

## Setup
To use this SAP HANA connector, you need to:
* Set up a Self-hosted Integration Runtime. See Self-hosted Integration Runtime article for details.
* Install the SAP HANA ODBC driver on the Integration Runtime machine. You can download the SAP HANA ODBC driver from the SAP Software Download Center.

### Install a Self-Hosted Integration Runtime
See [Integration runtime in Azure Data Factory](https://docs.microsoft.com/en-us/azure/data-factory/concepts-integration-runtime).

### Download and install the ODBC Driver
The HANA ODBC Driver can be downloaded from the SAP Download Center via the SAP Download Manager.

<img src="Images\S4H_HANA\odbc_download.jpg">

This will result in a *.sar file which is unpacked using SAPCAR.exe. This tool can also be downloaded from the SAP Download Center.

```
sapcar.exe -xvf *.sar
```

Install via hdbsetup.exe for a GUI guided installation.

<img src="Images\S4H_HANA\odbc_installation.jpg">

You can verify if the driver was correctly installed via the 'ODBC Data Source Administator'. When adding a new Data Source the HANA ODBC driver should show up as a possible driver.

<img src="Images\S4H_HANA\odbc_driver.jpg">

### HANA Setup
The S4Hana tables are within the SAPHANADB schema. For ADF to be able to connect to these schema, you'll need a user which has access to this schema. 

<img src="Images\S4H_HANA\hanadb_schema_mara.jpg">

The owner of this schema is the user `SAPHANADB`. Note that this is also the user used by the ABAP runtime is `SAPHANADB`. You can use this user in ADF or create a specific user for ADF. 

Use the 'SYSTEM' user to create a new user, eg. ADFUser.
Grant the 'CATALOG READ' System privilege.

<img src="Images\S4H_HANA\ADFUser.jpg">

Switch to user 'SAPHANADB' and grant Object privileges to access the 'SAPHANADB' schema. Choose the privileges according to your needs.

<img src="Images\S4H_HANA\ADFUser2.jpg">

Swith to the ADF User and verify if you have access to the 'SAPHANADB' schema.
Also try if you can access table contents via SQL.

```sql
SELECT TOP 1000 * FROM "SAPHANADB"."MARA"
```

<img src="Images\S4H_HANA\ADFUser_Mara.jpg">

### ADF Setup
#### Linked Service
In ADF you first need to setup a linked service.

<img src="Images\S4H_HANA\hana_linked_service.jpg">

<img src="Images\S4H_HANA\hana_linked_service_details.jpg">

Note: For the SQL port number, see [TCP/IP Ports of All SAP Products](https://help.sap.com/viewer/ports).
The convention for the port number is 3<SysNr of HANA DB>15 for a MDC setup.
In the S4HANA image from SAP CAL, the port nr is 30215, since the HANA db has 'O2' as instance nr and the SAPHANADB schema is installed in the first tenant database.  

#### Data Set
The next step is to create a dataset.
In the dataset you can enter the table you want to retrieve data from. Eg. the MARA table containing material master data.

<img src="Images\S4H_HANA\hana_dataset.jpg">

Using preview, you can test if the connection works.

<img src="Images\S4H_HANA\mara_preview.jpg">

### ADF Pipeline
In turn this dataset is used in a copy action within an ADF pipeline.

<img src="Images\S4H_HANA\pipeline_source.jpg">

As sink I chose a csv file within Azure DataLake. For more info on how to set this up see [ADF SAP ECC Adapter - Azure Data Lake](SAPECC_DataLake.md).

<img src="Images\S4H_HANA\sink_dataset.jpg">

You can now trigger the pipeline for execution. The resulting csv file looks as follows.

<img src="Images\S4H_HANA\mara_csv.jpg">

### Query
Note that although in the DataSet you can specify the table, you can query any table using the `Query` option. 
You could for example extract all Maintenance Order headers using the following query :

```sql
select * from "SAPHANADB"."AUFK" where "AUTYP"=30
```
<img src="Images\S4H_HANA\aufk_source.jpg">

Data Preview results in :

<img src="Images\S4H_HANA\aufk_preview.jpg">

### Mandant
Since the HANA Connector is acting directly on the DB level, the connector retrieves all data from all clients/mandants. This in contradiction with the ABAP layer where the ABAP layer automically filters on the mandant using the sy-mandt from the ABAP context. This is the mandant where the user running the query is logged on to. If you use multiple clients in your SAP system you should be aware of this.

The S4Hana image from SAP CAL uses multiple client. If you execute the following SQL statement :

```sql
SELECT distinct "MANDT" FROM "SAPHANADB"."MARA"
```  

then the system returns multiple client/mandants for the S4Hana.

<img src="Images\S4H_HANA\mandt_query.jpg">

<img src="Images\S4H_HANA\mandt_preview.jpg">

## Related Documentation
* [Copy data from SAP HANA using Azure Data Factory](https://docs.microsoft.com/en-us/azure/data-factory/connector-sap-hana)
* [Integration runtime in Azure Data Factory](https://docs.microsoft.com/en-us/azure/data-factory/concepts-integration-runtime)
* [TCP/IP Ports of All SAP Products](https://help.sap.com/viewer/ports)