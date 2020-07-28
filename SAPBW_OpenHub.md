# Extract data from SAP BW using OpenHub

## Prerequisites
Since the OpenHub connector executes RFC calls towards the SAP BW system you'll need the .Net connector installed on the Integration Runtime.
See [Prerequisites for the OpenHub Adapter](https://docs.microsoft.com/en-us/azure/data-factory/connector-sap-business-warehouse-open-hub#prerequisites).

## SAP BW Setup
### OpenHub Destination
In the SAP BW system we first need to setup an OpenHub Destination with destination type "Database Table". In my example I want to export data from infocube `0D_NW_DEMO - Actual for NW Demo` from Info Area `OD_NW_C01 - Netweaver Demo`.
(This infocube is delivered via my ABAP Development system, which also includes a BW system.)

First go to the Data Warehousing Workbench. (Transaction RSA1)

<img src="Images\BW_OpenHub\datawarehousingWB.jpg">

Right-Click on the infocube and select `Create OpenHub Destination`.

Enter the source InfoCube data.

<img src="Images\BW_OpenHub\createOHDestination.jpg">

In the Destination definition :
* Select Destination Type : Database Table
* Key of the Table : technical key
* Extraction : Keep Data and Insert Records into Table

<img src="Images\BW_OpenHub\OHDestination.jpg">

You can have a look at the field definitions.

<img src="Images\BW_OpenHub\OHFieldDefinitions.jpg">

Activate the OpenHub Destination.
In background this will generate the Data Transfer Process and the Actual table which will contain the exported data. Go to the Data Dictonary (transaction se11) to have a look.

<img src="Images\BW_OpenHub\activatedOHD.jpg>

<img src="Images\BW_OpenHub\generatedDTP.jpg>

<img src="Images\BW_OpenHub\OHTable.jpg">

### Execute the Data Transfer Process

<img src="Images\BW_OpenHub\executeDTP.jpg">
<img src="Images\BW_OpenHub\monitorDTP.jpg">

Upon successfull execution the generated table is now filled. You can verify this using the Data Browser (transaction se16).

<img src="Images\BW_OpenHub\databrowser.jpg">


## Azure Data Factory Pipeline
### Linked Service
In Azure Data Factory, you first need to create a linked service based on the SAP BW Open Hub adapter.

<img src="Images\BW_OpenHub\adaptersOverview.jpg">

Enter the SAP BW Connection Settings

<img src="Images\BW_OpenHub\connectionSettings.jpg">

### DataSet
Create a data set based upon SAP BW OpenHub.

<img src="Images\BW_OpenHub\OHdataSet.jpg">

<!-- Note : preview data doesn't work -->

### Pipeline


## Documentation
* [SAP BW OpenHub Extractor](https://docs.microsoft.com/en-us/azure/data-factory/connector-sap-business-warehouse-open-hub)
* [Load BW Data via OpenHub](https://docs.microsoft.com/en-us/azure/data-factory/load-sap-bw-data)
