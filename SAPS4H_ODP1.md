# Extracting data via Operational Data Provision - ODP
In this part we will use the ODP principle to extract data from SAP ECC. The ODP service will need to be oData enabled for our ADF connectors to be able to pick it up.

For data extraction scenarios from S/4HANA the following requirements have typically to be met:
* Logical data models abstracting the complexity SAP source tables and corresponding columns
* The data source must be delta-/CDC-enabled to avoid full delta loads
* Open interfaces and protocols to support the customer demand for cloud-based architectures.
* Support of frequent intraday data-loads instead of nightly batches
* Supports the extraction of transactional and master data

The updated ODP-OData feature in SAP NW 7.5 is the enabling technology for achieving the requirements describe above.

<img src="ImagesS4H_ODP\odpoverview.jpg">

## Setup
For this demo I'm using a S/4Hana system deployed via [SAP CAL](https://cal.sap.com) into Microsoft Azure.

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
Note the field `LastChangeDateTime` which is used for delta calculation.

Use eclipse to create and activate this view.
* 
* Create a Data Definition
<img src="Images\S4H_ODP\datadefinition.jpg">

<img src="Images\S4H_ODP\datadefinition2.jpg">

* Insert the code into the view
* Save and activate the view

Note: You can use the Data Dictionary (transaction `SE11`)within the SAP system to check if your view is correctly generated. 
The name of the view is the `@AbapCatalog.sqlViewName` viewname property. You can also check the contents via this transaction.

<img src="Images\S4H_ODP\se11_viewContents.jpg">
<img src="Images\S4H_ODP\se11_viewDict.jpg">

### oData Enablement
This part is executed using the SAPGui.
* Use transaction `SEGW - SAP Gateway Service Builder`
* Create a new project
* Generate the oData extraction classes. Use Menu: Redefine - ODP Extraction

<img src="Images\S4H_ODP\redefine.jpg">

* Search for your view and press `Add ODP`

<img src="Images\S4H_ODP\addODP.jpg">

* The system will now ask for the name of the classes to implement the Data Model and the oData Service. Thses classes will be generated for you.

<img src="Images\S4H_ODP\odpclasses.jpg>

* Select all Entity Types, Function Imports and Associations

<img src="Images\S4H_ODP\odpgenerate.jpg>

* Finish the wizard
* Back in `SEGW`, Generate the Runtime Objects

<img src="Images\S4H_ODP\odpgenerate2.jpg">

* Register the oData Service at the Gateway

<img src="Images\S4H_ODP\odpregistration.jpg">

Note: If you're unable to register the SAP Gateway, see [OSS Note 2550286 - Unable to Register service in SEGW transaction](https://launchpad.support.sap.com/#/notes/2550286)

You can check the registered service in the HTTP Service Hierarchy (transaction `SICF`). The path to the service is `/default_host/sap/opu/odata/sap/ZBD_ISALESDOC_1_SRV`.

## Generated oData Service

<img src="Images\S4H_ODP\oDataImplementation.jpg">

The meta data form the oData service can be retrieved using `http://vhcals4hci.dummy.nodomain:50000/sap/opu/odata/SAP/ZBD_ISALESDOC_1_SRV/$metadata`
Note: The SAP CAL image uses a fixed host name for the S4Hana system. In your hostz file you can map this hostname to the external IP address of the system.

The generated oData Service will have 2 entity sets :
* AttrOfZBD_ISALESDOC_1 : this Entity set can be used to extract the sales orders from the underlying view.
Use `http://vhcals4hci.dummy.nodomain:50000/sap/opu/odata/SAP/ZBD_ISALESDOC_1_SRV/AttrOfZBD_ISALESDOC_1` to retrieve the data.
This is the basic OData service. You can also apply filters like with any oData Service.

<img src="Images\S4H_ODP\salesorders.jpg">

* DeltaLinksOf AttrOfZBD_ISALESDOC_1 : This service can used to retrieve the delta tokens. Delta tokens are used to identify the changed Sales Orders.

Additionaly there are 2 Function Imports :
* SubscribedToAttrOfZBAD_ISALESDOC1 : this service checks if you're subscribed to receive delta loads
* TerminateDeltasForAttrOfZBD_ISALESDOC_1 : this service terminates your delta subscription

## ODP Flow
The goal is to first do an initial load and afterwards execute delta loads containing only the changed sales orders since the last load.
To be able to retrieve delta you first need to subscribe to the delta queue.

### Initial Load
You can do this during the initial load using a specific http header: 'Prefer = odata.track-changes'.
The initial download is executed using ´http://vhcals4hci.dummy.nodomain:50000/sap/opu/odata/SAP/ZBD_ISALESDOC_1_SRV/AttrOfZBD_ISALESDOC_1´. 

<img src="Images\S4H_ODP\getSalesOrdersAndSubscribe.jpg">

If you now execute the function `SubscribedToAttrOfZBD_ISALESDOC_1`, this should reurn `true`.
Use `http://vhcals4hci.dummy.nodomain:50000/sap/opu/odata/SAP/ZBD_ISALESDOC_1_SRV/SubscribedToAttrOfZBD_ISALESDOC_1`.

<img src="Images\S4H_ODP\subscribed.jpg">

You can also see the subscription in the 'Monitor Delta Queue Subscriptions' (transaction `odqmon`).

<img src="Images\S4H_ODP\odqmon.jpg">

### Delta Load
During the initial load, the SAP system generated a delta token. You can find this token at the end of the Initial Load response.

<img src="Images\S4H_ODP\initialdeltatoken.jpg">

This delta token can be used in a subsequent delta load to retrieve the changes since the previous load. This delta load when then again return a delta token which can be used to retrieve changes since this last load, etc ... .

Since our example is about sales orders you can use transaction `VA02 - Change Sales Order` to update a sales order.

The changed sales orders can be retrieved via the `DeltaLinksOfAttrOfZBD_ISALESDOC_1` Entity set and the delta token. Note the `ChangesAfter`.

`http://vhcals4hci.dummy.nodomain:50000/sap/opu/odata/SAP/ZBD_ISALESDOC_1_SRV/DeltaLinksOfAttrOfZBD_ISALESDOC_1('D20200826154617_000019000')/ChangesAfter`

<img src="Images\S4H_ODP\changesafter.jpg">

Also here the response contains a new delta token which can be used to track subsequent changes.

## Documentation
* [Extracting and Replicating Data with Operational Data Provisioning Framework](https://help.sap.com/viewer/107a6e8a38b74ede94c833ca3b7b6f51/2.0.0/en-US/202710d1cee84333a4f4d593324bdf51.html)
* [Operational Data Provisioning (ODP) and Delta Queue (ODQ)](https://wiki.scn.sap.com/wiki/pages/viewpage.action?pageId=449284646)
* [ODP-Based Data Extraction via OData](https://help.sap.com/viewer/ccc9cdbdc6cd4eceaf1e5485b1bf8f4b/7.5.18/en-US/11853413cf124dde91925284133c007d.html)
* [Using the OData Service for Extracting ODP Data](https://help.sap.com/viewer/ccc9cdbdc6cd4eceaf1e5485b1bf8f4b/7.5.18/en-US/50f4ee6253134d3cafa25b9444f0c5a9.html)
* [ODP based data extraction from S/4Hana via oData Client](https://github.com/ROBROICH/SAP_ODP_ODATA_CLIENT/blob/master/README.md)