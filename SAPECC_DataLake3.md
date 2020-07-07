# ADF SAP ECC Adapter - Azure Data Lake - Data Factory Integration

## Overview
[Part 1 - ECC Adapter & DataLake](SAPECC_DataLake.md) describes how the ECC adapter can be used to download ECC data to Azure data lake folders. 
[Part 2 - Delta Handling](SAPECC_DataLake2.md) describes the tooling to upload an initial download into a delta table and to merge delta changes into the delta table.
[Part 3 - Azure Data Factory Integration](SAPECC_DataLake3.md) describes how to integrate the tools from Part 2 into Azure Data Factory.

This part will integrate the delta handling into an Azure DataLake pipeline.

