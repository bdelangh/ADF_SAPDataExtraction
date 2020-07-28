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

<b>Note :</b>
Technical Key or Semantic Key :
If you set the Technical Key flag, a unique key is added. This consists of the technical fields OHREQUID (open hub request SID), DATAPAKID (data package ID), and RECORD (sequential number of a data record to be added to the table in a data package). These fields display the individual key fields for the table.
Using a technical key with a target table is particularly useful if you want to extract data to a table that is not deleted before extraction. If an extracted record has the same key as an existing record, this duplication causes a short dump.
If you set the Semantic Key flag, the system selects all suitable fields in the field list as semantic keys. You can change this selection in the field list. Note however that using a semantic key can result in duplicate records. The records are not aggregated. Instead each extracted record is saved in the table.

Extraction Types :
* Delete data and insert data records: The fields are overwritten. The table is completely deleted before every extraction and regenerated. We recommend this if you do not want to store the history of the data in the table.
* Retain data and insert data records: The data records are inserted. The table is generated just once prior to the first extraction. This allows you to obtain the history of the extracted data.
* Retain data and change data records: You can only do this if you have selected Semantic Key.

<img src="Images\BW_OpenHub\OHDestination.jpg">

You can have a look at the field definitions.

<img src="Images\BW_OpenHub\OHFieldDefinitions.jpg">

Activate the OpenHub Destination.
In background this will generate the Data Transfer Process and the Actual table which will contain the exported data. Go to the Data Dictonary (transaction se11) to have a look.
<b>Note : </b>The generated database table has the prefix /BIC/OHxxx, xxx being the technical name of the destination.

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

## Function Modules
* Get List of Open Hub Destinations : RSB_API_OHS_DEST_GETLIST with DESTTYPE = "TAB"
* Get Detail of Open Hub Destination : RSB_API_OHS_DEST_GETDETAIL with OHDEST = "OH_NW_C01"
* Read data from the database table in the BW system : RSB_API_OHS_DEST_READ_DATA_RAW with
** OHDEST = "OH_NW_C01"
** RequestId = "9880"

* RFC_FUNCTION_SEARCH
* RFC_METADATA_GET
* /SAPDS/RFC_READ_TABLE2

* OHTable : /BIC/OHOH_NW_C01

## Parallellization
To speed up the data loading, you can set parallelCopies on the copy activity to load data from SAP BW Open Hub in parallel. For example, if you set parallelCopies to four, Data Factory concurrently executes four RFC calls, and each RFC call retrieves a portion of data from your SAP BW Open Hub table partitioned by the DTP request ID and package ID. This applies when the number of unique DTP request ID + package ID is bigger than the value of parallelCopies. When copying data into file-based data store, it's also recommanded to write to a folder as multiple files (only specify folder name), in which case the performance is better than writing to a single file.
See [Copy Activity Properties](https://docs.microsoft.com/en-us/azure/data-factory/connector-sap-business-warehouse-open-hub#copy-activity-properties)

Multiple PackageIds???

