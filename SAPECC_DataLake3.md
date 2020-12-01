# ADF SAP ECC Adapter - Azure Data Lake - Data Factory Integration

## Overview
[Part 1 - ECC Adapter & DataLake](SAPECC_DataLake.md) describes how the ECC adapter can be used to download ECC data to Azure data lake folders.\
[Part 2 - Delta Handling](SAPECC_DataLake2.md) describes the tooling to upload an initial download into a delta table and to merge delta changes into the delta table.\
[Part 3 - Azure Data Factory Integration](SAPECC_DataLake3.md) describes how to integrate the tools from Part 2 into Azure Data Factory.\

This part will integrate the delta handling into an Azure DataLake pipeline.

## SetUp
In a first step the DataFactory needs a connection to DataBricks.

### Access Token
DataFactory needs an access token to access DataBricks. This token is generated from the DataBricks Workspace.
See [Generate a personal access token](https://docs.databricks.com/dev-tools/api/latest/authentication.html#generate-token).

Within the DataBricks Workspace, choose `user settings` and go to `Access Tokens`.

<img src="Images/ECC_ADF3/userSettings.jpg" height=300>\
\
<img src="Images/ECC_ADF3/accessTokens.jpg">

Generate a new token. Leave the lifetime empty so the token lives indefinetly.

<img src="Images/ECC_ADF3/generateToken.jpg" height=140>

Make sure to copy the generated token. You won't be able to access it again.

<img src="Images/ECC_ADF3/token.jpg" height=100>\
\
<img src="Images/ECC_ADF3/generatedToken.jpg">\

### DataBricks Linked Service
You can now create a linked service for DataBricks.

In DataFactory, choose connections.

<img src="Images/ECC_ADF3/connections.jpg" height=100>

Next create a new linked service. Select `compute`, followed by `Azure DataBricks`.

<img src="Images/ECC_ADF3/linkedService.jpg" height=200>\

Enter the settings for the DataBricks service :
* enter a name for the linked service
* choose your Azure Subscription
* use the access token generated above
* select your DataBricks workspace
* select existing interactive cluster. Make sure the cluster is running. 
* select your cluster

<img src="Images/ECC_ADF3/newLinkedService.jpg" height=600>

Test the connection.

Note : the `existing cluster` is the cluster where the DataLake filesystem is mounted and where the `products`table is loaded. If you would choose `new cluster`, then each time the pipeline is run a new cluster is created. You would then need to mount the filesystem and load the `products`table from storage.

## Data Factory Pipeline
Now you can create the data factory pipeline.

<img src="Images/ECC_ADF3/newPipeline.jpg" height=250>

Insert a DataBricks notebook activity.

<img src="Images/ECC_ADF3/dataBricksActivity.jpg" height=200>

Link the activity to the DataBricks Linked Service.

<img src="Images/ECC_ADF3/dataBricksActivityLink.jpg" height=150>

Select the path to your notebook.

<img src="Images/ECC_ADF3/chooseNotebook.jpg" height=350>

Save and publish the pipeline.
Put some csv files with product updates in your source directory and trigger the pipeline.
Use the monitor tool to examine the progress.

<img src="Images/ECC_ADF3/pipelineRun.jpg">

>Note: when an error occurs ADF provides a link to the databricks log of your pipeline run.
>
><img src="Images/ECC_ADF3/runtimeError.jpg" height=200>\
>\
><img src="Images/ECC_ADF3/dataBricksRuntimeError.jpg" height=200>\


Upon successfull completion of the pipeline run, you can use sql to query the results and verify if the csv files are moved to the processed folder.

#### SQL Query
<img src="Images/ECC_ADF3/updateSQLResults.jpg">

#### Processed Folder
<img src="Images/ECC_ADF3/processedFolder.jpg">

As a last step you can combine this pipeline with the pipeline created in [Part 2 - Delta Handling](SAPECC_DataLake2.md) to have the complete process in one pipeline.

#### Complete Pipeline
<img src="Images/ECC_ADF3/completePipeline.jpg">

## Documentation
* [Run a Databricks notebook with the Databricks Notebook Activity in Azure Data Factory](https://docs.microsoft.com/en-us/azure/data-factory/transform-data-using-databricks-notebook)

## Disclaimer
This code example describes the principle, the code is not for production usage.


