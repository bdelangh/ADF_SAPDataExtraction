# Extract data from SAP BW using MDX (SAP BW Adapter)

## Install the SAP RFC Library
The MDX Adapter retrieves data via a RFC call. Therefore you need to install the SAP RFC Libraries on the Runtime Integration Engine.
See [SAP BW Adapter - Prerequisites](https://docs.microsoft.com/en-us/azure/data-factory/connector-sap-business-warehouse#prerequisites).
The latest version is NW RFC SDK 7.50, see [SAP Note 2573790](https://launchpad.support.sap.com/#/notes/2573790).

I placed the RFC SDK in a seperate directory and added the lib folder to the `PATH` variable.

## Azure Data Factory Configuration
### Linked Service
First you need to create a linked service for the SAP BW MDX Adapter.

<img src="Images\BW_MDX\linkedServiceOverview.jpg">

Select `SAP BW via MDX`.
Enter the SAP Connection information and execute the connection test.

<img src="Images\BW_MDX\linkedService.jpg">

### DataSet
Create a DataSet nased upon the MDX Linked Service

<img src="Images\BW_MDX\dataSet.jpg">

### Pipeline
Create a new pipeline and insert the copy activity.

Select the MDX data Set as the Source.

<img src="Images\BW_MDX\sourceActivity1.jpg">

Use the `Browse SAP Cubes`link to get an overview on the InfoCubes and Queries which can be used.

<img src="Images\BW_MDX\SAPExplorer.jpg">

You can also use the explorer to help building your MDX statement.

Fill in your MDX statement in the Query field of the Source.

Example :
```
select {[Measures].[0D_NW_NETV], [Measures].[0D_NW_OORV]} on columns,
   [0D_NW_CNTRY].[LEVEL01] on rows
from [$0D_NW_C01]
```

<img src="Images\BW_MDX\sourceCopy.jpg">

<b>Tip</b> : Use transaction `MDXTEST` in SAPGui to build and test your MDX query on SAP side.

Use the preview Data button to execute a first test of your query.

You can configure the sink as in the previous examples.


## Documentation
* [SAP BW Adapter](https://docs.microsoft.com/en-us/azure/data-factory/connector-sap-business-warehouse)

<!-- Encoutered Error :
"Access to SAP Business Warehouse requires SAP client tools to be installed, including the latest version of SAP Netweaver RFC." 

-->
 <!-- Users
 BWDEVELOPER / Appl1ance
 MDXUSER / Appl1ance

 -->

<!-- 
MDX Test Environment : https://blogs.sap.com/2011/04/08/bw-730-new-mdx-test-environment/

 Transaction : MDXTEST
 Transaction : RSCRM_BAPI

 InfoCube : $0D_NW_C01
 Table : /BI0/F0D_NW_C01 (??)

 MDX Statements
select {[Measures].[0D_NW_NETV]}
on columns,
   [0D_NW_CNTRY].[DE]
on rows
from [$0D_NW_C01]


select {[Measures].[0D_NW_NETV], [Measures].[0D_NW_OORV]} on columns,
   [0D_NW_CNTRY].[LEVEL01] on rows
from [$0D_NW_C01]

select {[Measures].[0D_NW_NETV],[Measures].[0D_NW_OORV]} on columns,
  [0D_NW_REGIO                   0D_NW_REGIO_HIER].[LEVEL04] on rows
from [$0D_NW_C01]


select [Measures].[GrossAmt] on columns,
[2CREPM_SOANLYC1-COMPANYNAME].Members on rows
from [2CREPM_SOANLYC1/2CREPM_SOANLYQ1]

-->

<!--
Functions
BAPI_MDPROVIDER_GET_CATALOGS
RFC_GET_FUNCTION_INTERFACE
RFC_GET_NAMETAB

-->