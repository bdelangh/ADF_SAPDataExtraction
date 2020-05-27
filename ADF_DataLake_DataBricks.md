# Azure Data Lake and Azure DataBricks SetUp

## Service Principal creation
Databricks uses a service principal to mount the dataLake file system.

To create the service principal using Azure CLI :
```ps1
az ad sp create-for-rbac --name <spName>

```
You'll need the appId, tenantID ans secret later on to mount the datalake filesystem in DataBricks./
Upon successfull creation, the service principal can be found under App Registrations in your Azure Active Directory

<img src="Images/ADF_DataBricks/AppRegistration.jpg>

Assign the role 'Storage Blob Data Contributor' on the Azure Data Lake Storage Gen2 account.

<img src="Images/ADF_DataBricks/RoleAssignment.jpg">

https://docs.microsoft.com/en-us/azure/databricks/data/data-sources/azure/azure-datalake-gen2


## Create DataBricks

## Create a cluster within DataBricks

## Create a python notebook

configs = {"fs.azure.account.auth.type": "OAuth",
       "fs.azure.account.oauth.provider.type": "org.apache.hadoop.fs.azurebfs.oauth2.ClientCredsTokenProvider",
       "fs.azure.account.oauth2.client.id": "<appId>",
       "fs.azure.account.oauth2.client.secret": "<clientSecret>",
       "fs.azure.account.oauth2.client.endpoint": "https://login.microsoftonline.com/<tenant>/oauth2/token",
       "fs.azure.createRemoteFileSystemDuringInitialization": "true"}

dbutils.fs.mount(
source = "abfss://<container-name>@<storage-account-name>.dfs.core.windows.net/folder1",
mount_point = "/mnt/flightdata",
extra_configs = configs)


## Azure Key Vault Creation

## Azure

# ToDo
* [] Role assignment via script

# Tutorial
https://docs.microsoft.com/en-us/azure/storage/blobs/data-lake-storage-use-databricks-spark
