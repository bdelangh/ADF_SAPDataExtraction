# Azure Data Lake and Azure DataBricks SetUp

## Service Principal creation
Databricks uses a service principal to mount the dataLake file system.

To create the service principal using Azure CLI :
```ps1
az ad sp create-for-rbac --name <spName>

```

The service principal can be found under App Registrations in your Azure Active Directory



Assign the role 'Storage Blob Data Contributor' on the Azure Data Lake Storage Gen2 account.

<img src="Images/ADF_DataBricks/RoleAssignment.jpg">

https://docs.microsoft.com/en-us/azure/databricks/data/data-sources/azure/azure-datalake-gen2

<img src="Images/ADF_DataBricks/AppRegistration.jpg>


## Azure Key Vault Creation

## Azure

# ToDo
* [] Role assignment via script

# Tutorial
https://docs.microsoft.com/en-us/azure/storage/blobs/data-lake-storage-use-databricks-spark
