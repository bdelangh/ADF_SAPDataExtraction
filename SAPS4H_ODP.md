# Extracting data via Operational Data Provision - ODP
In this part we will use the ODP principle to extract data from SAP ECC. The ODP service will need to be oData enabled for our ADF connectors to be able to pick it up.

For data extraction scenarios from S/4HANA the following requirements have typically to be met:
* Logical data models abstracting the complexity SAP source tables and corresponding columns
* The data source must be delta-/CDC-enabled to avoid full delta loads
* Open interfaces and protocols to support the customer demand for cloud-based architectures.
* Support of frequent intraday data-loads instead of nightly batches
* Supports the extraction of transactional and master data

The updated ODP-OData feature in SAP NW 7.5 is the enabling technology for achieving the requirements describe above.

<img src="Images\S4H_ODP\odp_overview.png" height=400>

## Setup
For this demo I'm using a S/4Hana system deployed via [SAP CAL](https://cal.sap.com) into Microsoft Azure. The rest of this demo will focus on ODP enablement of ABAP CDS Views.

### Setup of ABAP CDS View
An ABAP CDS view will serve as data source. The setup of the CDS view and the oData enablement is described in the blog of Roman Broich.

Beneath the view used in the rest of the document :

```
@AbapCatalog.sqlViewName: 'ZBD_ISALESDOC_1'
@AbapCatalog.compiler.compareFilter: true
@AccessControl.authorizationCheck: #CHECK
@EndUserText.label: 'CDS for Extraction I_SalesDocument'
@Analytics:{dataCategory:#DIMENSION ,
            dataExtraction.enabled:true}
@Analytics.dataExtraction.delta.byElement.name:'LastChangeDateTime'
@Analytics.dataExtraction.delta.byElement.maxDelayInSeconds: 1800
@VDM.viewType: #BASIC

define view ZBD_I_Salesdocument as select from I_SalesDocument {
    key SalesDocument,

    //Category
    SDDocumentCategory,
    SalesDocumentType,
    SalesDocumentProcessingType,

    CreationDate,
    CreationTime,
    LastChangeDate,
    //@Semantics.systemDate.lastChangedAt: true
    LastChangeDateTime,

    //Organization
    SalesOrganization,
    DistributionChannel,
    OrganizationDivision,
    SalesGroup,
    SalesOffice,
    PurchaseOrderByCustomer,
      
    //Pricing
    //TotalNetAmount,
    TransactionCurrency,
    PricingDate,
    RetailPromotion,
    //PriceDetnExchangeRate,
    SalesDocumentCondition
    
}   

```
>Note the field `LastChangeDateTime` which is used for delta calculation.

Use eclipse to create and activate this view.

* Create a Data Definition\
<img src="Images\S4H_ODP\data_definition.jpg" height=300>\
\
<img src="Images\S4H_ODP\data_definition2.jpg" height=150>

* Insert the code into the view
* Save and activate the view

Note: You can use the Data Dictionary (transaction `SE11`)within the SAP system to check if your view is correctly generated. 
The name of the view is the `@AbapCatalog.sqlViewName` viewname property. You can also check the contents via this transaction.

<img src="Images\S4H_ODP\se11_viewContents.jpg">\
\
<img src="Images\S4H_ODP\se11_viewDict.jpg">

### oData Enablement
This part is executed using the SAPGui.
* Use transaction `SEGW - SAP Gateway Service Builder`
* Create a new project
* Generate the oData extraction classes. Use Menu: Redefine - ODP Extraction

<img src="Images\S4H_ODP\redefine.jpg" height=200>\

* Search for your view and press `Add ODP`

<img src="Images\S4H_ODP\addODP.jpg">

* The system will now ask for the name of the classes to implement the Data Model and the oData Service. Thses classes will be generated for you.

<img src="Images\S4H_ODP\odpclasses.jpg">

* Select all Entity Types, Function Imports and Associations

<img src="Images\S4H_ODP\odpgenerate.jpg">

* Finish the wizard
* Back in `SEGW`, Generate the Runtime Objects

<img src="Images\S4H_ODP\odpgenerate2.jpg" height=200>

* Register the oData Service at the Gateway

<img src="Images\S4H_ODP\odpregistration.jpg" height=200>\

> Note: If you're unable to register the SAP Gateway, see [OSS Note 2550286 - Unable to Register service in SEGW transaction](https://launchpad.support.sap.com/#/notes/2550286)

You can check the registered service in the HTTP Service Hierarchy (transaction `SICF`). The path to the service is `/default_host/sap/opu/odata/sap/ZBD_ISALESDOC_1_SRV`.

## Generated oData Services

<img src="Images\S4H_ODP\oDataImplementation.jpg" height=300 >

The meta data form the oData service can be retrieved using `http://vhcals4hci.dummy.nodomain:50000/sap/opu/odata/SAP/ZBD_ISALESDOC_1_SRV/$metadata`
Note: The SAP CAL image uses a fixed host name for the S4Hana system. In your hostz file you can map this hostname to the external IP address of the system.

The generated oData Service will have 2 entity sets :
* <b>AttrOfZBD_ISALESDOC_1</b> : this Entity set can be used to extract the sales orders from the underlying view.
Use `http://vhcals4hci.dummy.nodomain:50000/sap/opu/odata/SAP/ZBD_ISALESDOC_1_SRV/AttrOfZBD_ISALESDOC_1` to retrieve the data.
This is the basic OData service. You can also apply filters like with any oData Service.

<img src="Images\S4H_ODP\salesorders.jpg">

* <b>DeltaLinksOf AttrOfZBD_ISALESDOC_1</b> : This service can used to retrieve the delta tokens. Delta tokens are used to identify the changed Sales Orders.

Additionaly there are 2 Function Imports :
* <b>SubscribedToAttrOfZBAD_ISALESDOC1</b> : this service checks if you're subscribed to receive delta loads
* <b>TerminateDeltasForAttrOfZBD_ISALESDOC_1</b> : this service terminates your delta subscription

## ODP Flow
The goal is to first do an initial load and afterwards execute delta loads containing only the changed sales orders since the last load.
To be able to retrieve delta you first need to subscribe to the delta queue.

### Initial Load
You can do this during the initial load using a specific http header: `Prefer = odata.track-changes`.\
The initial download is executed using `http://vhcals4hci.dummy.nodomain:50000/sap/opu/odata/SAP/ZBD_ISALESDOC_1_SRV/AttrOfZBD_ISALESDOC_1`. 

<img src="Images\S4H_ODP\getSalesOrdersAndSubscribe.jpg">

If you now execute the function `SubscribedToAttrOfZBD_ISALESDOC_1`, this should return `true`.\
Use `http://vhcals4hci.dummy.nodomain:50000/sap/opu/odata/SAP/ZBD_ISALESDOC_1_SRV/SubscribedToAttrOfZBD_ISALESDOC_1`.

<img src="Images\S4H_ODP\subscribed.jpg">

You can also see the subscription in the `Monitor Delta Queue Subscriptions` (transaction `odqmon`).

<img src="Images\S4H_ODP\odqmon.jpg">

### Delta Load
During the initial load, the SAP system generated a delta token. You can find this token at the end of the Initial Load response.

<img src="Images\S4H_ODP\initialdeltatoken.jpg" height=200>

This delta token can be used in a subsequent delta load to retrieve the changes since the previous load. This delta load when then again return a delta token which can be used to retrieve changes since this last load, etc ... .

Since our example is about sales orders you can use transaction `VA02 - Change Sales Order` to update a sales order.

The changed sales orders can be retrieved via the `DeltaLinksOfAttrOfZBD_ISALESDOC_1` Entity set, the delta token and the `ChangesAfter` function.

`http://vhcals4hci.dummy.nodomain:50000/sap/opu/odata/SAP/ZBD_ISALESDOC_1_SRV/DeltaLinksOfAttrOfZBD_ISALESDOC_1('D20200826154617_000019000')/ChangesAfter`

<img src="Images\S4H_ODP\changesafter.jpg">

Also here the response contains a new delta token which can be used to track subsequent changes.

A call to the plain `DeltaLinksOfAttrOfZBD_ISALESDOC_1` Entity set will retrieve a list of the available delta tokens.
`http://vhcals4hci.dummy.nodomain:50000/sap/opu/odata/SAP/ZBD_ISALESDOC_1_SRV/DeltaLinksOfAttrOfZBD_ISALESDOC_1`.

<img src="Images\S4H_ODP\deltaTokenList.jpg">

### Integration with ADF
Disclaimer: this part will just explain the concept. Additional development will be needed to mold this into a production worthy flow.

The initial download can easily be done using the ADF SAP ECC Adapter, since it's oData based. Unfortunately I haven't found a way to :
1. Put the header variable to subscribe for deltas
2. Extract the delta token from the response

So I suggest to do this step via other means. (An Azure Function might be an option)
For the delta handling I see 2 possibilities.
1. You extract the delta token from the reponse of the current call and store this for subsequent calls.
2. Or you retrieve the list of delta tokens and select the latest, based upond the 'createdAt' property.

Further I could image you want to keep track of the delta tokes used to indicate a state if the load was successfull or not.
Subsequent jobs can then pickup failed delta loads.

A generic sketch of possible flows.

#### Option A - get last delta token
1. Retrieve list of deltatokens
	a. If no tokens then initial download
2. Retrieve last not confirmed
3. Loop over tokens to retrieve corresponding changes
    a. execute the data flow
    b. if successfull, confirm the token so it's not picked up by step 1
    c. if not successfull, stop (subsequent deltas could overwrite deltas from the previous delta)

#### Option B - rolling update
The option assumes seperate storage to store the 'next delta' token.
1. Retrieve next delta token from db table
	a. If no token then initial download
		i. This will also deliver an next deltatoken
2. Execute delta pipeline to get updated rows
	a. Update the sink
	b. Retrieve the next delta token and store in db table

#### Example implementation of Option A - Get Last Delta Token
Beneath you can find an example implementation for the 'Get Last Delta Token' option.

The pipeline in Azure DataFactory would consist of 2 steps :
1. Retrieve Latest Delta Token
2. Execute the Delta Load

In order to retrieve the last delta token by calling the DeltaLinksOfAttrOfZBD_ISALESDOC_1 function and select the latest by using the `CreatedAt` property. Unfortunately SAP did not implement the `$orderby`option so an Azure Function is needed to execute this task.
 
 `http://vhcals4hci.dummy.nodomain:50000/sap/opu/odata/SAP/ZBD_ISALESDOC_1_SRV/DeltaLinksOfAttrOfZBD_ISALESDOC_1?$orderby=CreatedAt` is not implemented.

<img src="Images\S4H_ODP\orderby_error.jpg">

In the end the ADF pipeline looks as follows.

<img src="Images\S4H_ODP\ADFpipeline.jpg">

For more info on how to integrate an Azure Function into Azure Data Factory, see [Azure Function activity in Azure Data Factory](https://docs.microsoft.com/en-us/azure/data-factory/control-flow-azure-function-activity).\
Sample code for the Azure Function can be found at (Scripts\ODP\GetODPDeltaToken.cs).\
This function returns the last delta token. The response looks as follows:

```json
{
    "DeltaToken": "D20200826161002_000029000"
}
```
The `DeltaToken` property will be used later to retrieve the token. 

ADF needs a `Function Linked Service` to connect to the Azure Function.

<img src="Images\S4H_ODP\FunctionLinkedService.jpg" height=400> 

The first action in the ADF pipeline is connected to this Linked Service.

<img src="Images\S4H_ODP\ADFfunction.jpg">

The next step in the pipeline is the `Copy` action.\ 
First we need to setup a Linked Service for the SAP system based on the SAP ECC Connector.
Here we enter the base URL of the oData Service.

`http://x.x.x.x:50000/sap/opu/odata/SAP/ZBD_ISALESDOC_1_SRV`

<img src="Images\S4H_ODP\LinkedService.jpg" height=300>

Next we need to create a dataset. Here we need to enter the rest of the path for reading out the delta changes. Since the deltatoken is 'part' of this url, we need to construct the URL dynamically.
`.../sap/opu/odata/SAP/ZBD_ISALESDOC_1_SRV/DeltaLinksOfAttrOfZBD_ISALESDOC_1('<deltatoken>')/ChangesAfter`
Since the token is the output of the previous step, we need to introduce a parameter to capture this output. Here we introduce the parameter `token`. For testing purposes you can give in a default value.

<img src="Images\S4H_ODP\TokenParameter.jpg" height=150>

Enter the following as path :
```
@concat('DeltaLinksOfAttrOfZBD_ISALESDOC_1(%27',dataset().Token, '%27)/ChangesAfter')
```

<img src="Images\S4H_ODP\DataSet.jpg">

As a next step we create the copy action in the ADF pipeline. The source of this step is our SAP oData Dataset. The output of the Azure Function step needs to be linked to the `token` input parameter of the DataSet
In the source dataset properties enter the following to retrieve the delta token from the function response:

```
@activity('Get DeltaToken').output.DeltaToken
```

<img src="Images\S4H_ODP\sourceDataSet.jpg">

A SQL DB server can be used as a sink.

<img src="Images\S4H_ODP\sinkDataSet.jpg">

You can now test this delta load by changing some sales orders and verifying the result in the destination.

>Note : The initial download can be done by another pipeline using the plain entityset and providing the subscription paramater in the HTTP header.


## Documentation
* [Extracting and Replicating Data with Operational Data Provisioning Framework](https://help.sap.com/viewer/107a6e8a38b74ede94c833ca3b7b6f51/2.0.0/en-US/202710d1cee84333a4f4d593324bdf51.html)
* [Operational Data Provisioning (ODP) and Delta Queue (ODQ)](https://wiki.scn.sap.com/wiki/pages/viewpage.action?pageId=449284646)
* [ODP-Based Data Extraction via OData](https://help.sap.com/viewer/ccc9cdbdc6cd4eceaf1e5485b1bf8f4b/7.5.18/en-US/11853413cf124dde91925284133c007d.html)
* [Using the OData Service for Extracting ODP Data](https://help.sap.com/viewer/ccc9cdbdc6cd4eceaf1e5485b1bf8f4b/7.5.18/en-US/50f4ee6253134d3cafa25b9444f0c5a9.html)
* [ODP based data extraction from S/4Hana via oData Client](https://github.com/ROBROICH/SAP_ODP_ODATA_CLIENT/blob/master/README.md)
* [Azure Function activity in Azure Data Factory](https://docs.microsoft.com/en-us/azure/data-factory/control-flow-azure-function-activity).