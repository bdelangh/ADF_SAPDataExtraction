#Create a Service Principal used by DataBricks to access AzureDataLake

#Service Principal Name
$spName = "spdatabricks_sap"

#Role to be assigned on Storage Account level
#$role ="Storage Blob Data Contributor"
$role ="Storage Account Contributor"

#DataBricks
$resGroupDBr = "databricks_adf_bdl"
$dataBricks = "adf_databricks"

#Storage Account
$resGroupSAc = "azdatalake_gen2_bdl"
$storageAccount = "azdatalakegen2bdl"

#Login to Azure
az login

#Create the Service Principal (and retain the password)
#Retain the output xml, the password can not be retrieved afterwards
az ad sp create-for-rbac --name $spName
$objectId = az ad sp list --display-name=$spName --show-mine --query [0].objectId


#Assign role Storage Blob Data Contributor to the service principal on Storage account level
# see https://docs.microsoft.com/en-us/azure/storage/common/storage-auth-aad-rbac-cli?toc=/azure/storage/blobs/toc.json
$scopeId = az storage account show --name $storageAccount --resource-group $resgroupSAc --query id
#az role assignment create --role $role --assignee-object-id $test --scope $scopeId --assignee-principal-type ServicePrincipal
# Note : this registers the role at Storage Account level
# Role added manually!!!

#Helpfull commands
az role definition list --out table --query "[?contains(Name, 'storage')]"
$appId = az ad sp list --display-name=$spName --show-mine --query [0].appId
$tenantId = az ad sp list --display-name=$spName --show-mine --query [0].appOwnerTenantId
$password = az ad sp create-for-rbac --name $spName --query password

