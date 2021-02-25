# sqlserver19-ephemeral
non-root ephemeral sqlserver19 on RHEL image w/ restored backup for ci/cd use-case for use with OpenShift

## Deploying buildconfig 
The buildconfig below will do the following in the `mssql` namespace:
- Build a docker image using the s2i docker build process
- Import and Restore a DB backup called `WideWorldImporters`
- Create and publish image to an imagestream named `sqlserver-ephemeral`
- Deploy the sqlserver-ephemeral instance using DeploymentConfig

If you want to simulate deployment of a user with low-privileges use the `--as` command like below:
```
oc create -f buildconfig-mssql.yaml --as <developer>
```

## View restored database:
In the pod terminal run the following command:
```
/opt/mssql-tools/bin/sqlcmd -S localhost,1433 -U SA -P $SA_PASSWORD -Q"USE WideWorldImporters;SELECT name, SCHEMA_NAME(schema_id) as schema_name FROM sys.objects WHERE type = 'U' ORDER BY name" -Y30
```

### Output should look identical to below:
```
sh-4.4$ /opt/mssql-tools/bin/sqlcmd -S localhost,1433 -U SA -P $SA_PASSWORD -Q"USE WideWorldImporters;SELECT name, SCHEMA_NAME(schema_id) as schema_name FROM sys.objects WHERE type = 'U' ORDER BY name" -Y30
Changed database context to 'WideWorldImporters'.
name                           schema_name                   
------------------------------ ------------------------------
BuyingGroups                   Sales                         
BuyingGroups_Archive           Sales                         
Cities                         Application                   
Cities_Archive                 Application                   
ColdRoomTemperatures           Warehouse                     
ColdRoomTemperatures_Archive   Warehouse                     
Colors                         Warehouse                     
Colors_Archive                 Warehouse                     
Countries                      Application                   
Countries_Archive              Application                   
CustomerCategories             Sales                         
CustomerCategories_Archive     Sales                         
Customers                      Sales                         
Customers_Archive              Sales                         
CustomerTransactions           Sales                         
DeliveryMethods                Application                   
DeliveryMethods_Archive        Application                   
InvoiceLines                   Sales                         
Invoices                       Sales                         
OrderLines                     Sales                         
Orders                         Sales                         
PackageTypes                   Warehouse                     
PackageTypes_Archive           Warehouse                     
PaymentMethods                 Application                   
PaymentMethods_Archive         Application                   
People                         Application                   
People_Archive                 Application                   
PurchaseOrderLines             Purchasing                    
PurchaseOrders                 Purchasing                    
SpecialDeals                   Sales                         
StateProvinces                 Application                   
StateProvinces_Archive         Application                   
StockGroups                    Warehouse                     
StockGroups_Archive            Warehouse                     
StockItemHoldings              Warehouse                     
StockItems                     Warehouse                     
StockItems_Archive             Warehouse                     
StockItemStockGroups           Warehouse                     
StockItemTransactions          Warehouse                     
SupplierCategories             Purchasing                    
SupplierCategories_Archive     Purchasing                    
Suppliers                      Purchasing                    
Suppliers_Archive              Purchasing                    
SupplierTransactions           Purchasing                    
SystemParameters               Application                   
TransactionTypes               Application                   
TransactionTypes_Archive       Application                   
VehicleTemperatures            Warehouse                     

(48 rows affected)
```