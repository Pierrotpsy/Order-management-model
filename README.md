# Order-management-model

This project uses Oracle SQL and Oracle PL/SQL to implement all functionalities.

## 1. Data Management

As the data is furnished with the subject, we only need to concern ourselves with the data model and the data import.

#### a) Data Model

An overview of the data model was given along with the subject, which is designed to work with the given dataset.

![Image not found](link)

Therefore, the only challenge was to transform the model in SQL language and add constraints to the created tables.

The code to create the tables can be found in the `Tables.SQL` file. 

As is the norm with SQL tables, we needed to try to add primary and foreign keys to tables where applicable.

As such, the following constraints were added : 
- A primary key constraint on **Vendor** which concerns *businessentityid*.
- A primary key constraint on **PurchaseOrderHeader** which concerns *purchaseorderid*.
- A foreign key constraint on **PurchaseOrderHeader** which concerns *vendorid*, and **Vendor**.*businessentityid*.
- A primary key constraint on **ProductVendor** which concerns both *productid* and *businessentityid*.
- A foreign key constraint on **ProductVendor** which concerns *businessentityid* and **Vendor**.*businessentityid*.
- A primary key contraint on **PurchaseOrderDetail** which concerns both *purchaseorderdetailid* and *purchaseorderid*.
- A foreign key constraint on **PurchaseOrderDetail** which concerns *purchaseorderid* and **PurchaseOrderHeader**.*purchaseorderid*.

#### b) Data Import

To import the data, we decided to create PL/SQL scripts. This allows us to control the data more accurately and to properly transform data that can't be managed by Oracle SQL (Dates with milliseconds, booleans, etc.), as well as to format strings before adding them to the database (in our case, we deleted unnecessary spaces, but other procedures could be done to make the strings in the database more uniform, maybe letter case management?).

To use the data import scripts, the directory of the project, which is to say the directory of the CSV files, must be indicated.

To facilitate CSV file management, regular expressions were used. They allowed us to precisely select data as well as transform it according to our needs.

As mentioned before, booleans aren't natively supported by Oracle SQL, but they are in Oracle PL/SQL, so we simply converted **true** and **false** to their syntaxically accepted counterparts; **1** and **0**.

When running the script, an error while reading the file may occur. This happens when OracleDB users don't have the authorisation to access the folder in which the data is kep. You will need to add them to the list of authorized users in Read Only mode for the script to properly work.

## 2. Data Querying



## 3. Data Visualization

In order to visualize  the data in our database more clearly, we implemented some Power BI Dashboards. 

Connecting an Oracle database to Power BI isn't natively supported by ordinary microsoft connectors.

[This ](https://www.oracle.com/a/ocom/docs/database/microsoft-powerbi-connection-adw.pdf) tutorial was helpful to set it up correctly.

Once that is done, a connection can be established with the database; in our case using `localhost` or `localhost:1521/xe` as server name. But we encountered some difficulties trying to locate all our tables in the importer that pops up afterwards. The only way for us to get data from the database was to directly use queries in our connection.

[Power BI Dashboards online](https://app.powerbi.com/links/u8K7Vs41tz?ctid=88eebcae-d6e6-4ef7-bba4-4c34f4c2d5e0&pbi_source=linkShare&bookmarkGuid=72f1d9bc-bd99-4682-88e8-1821c84fd1d5)

<details>
    <summary>Markdown Power BI Integration</summary>

<iframe title="dahsboards" width="1140" height="541.25" src="https://app.powerbi.com/reportEmbed?reportId=f206ee89-df15-4f9b-9e49-79dd3a160089&autoAuth=true&ctid=88eebcae-d6e6-4ef7-bba4-4c34f4c2d5e0" frameborder="0" allowFullScreen="true"></iframe>
</details>

<br>



We made 3 dashboards :
- The first one represents the 5 best-selling products per year

<details>
    <summary>First Dashboard</summary>

![Image not found](https://github.com/Pierrotpsy/Order-management-model/blob/main/Media/dahsboards-1.png)
</details>

<br>

- The second one represents the 20 vendors with the least percentage of rejected received items.
<details>
    <summary>Second Dashboard</summary>

![Image not found](https://github.com/Pierrotpsy/Order-management-model/blob/main/Media/dahsboards-2.png)
</details>

<br>

- The third one shows performance per order by adding the order quantity, the received quantity and the rejected quantity side to side.
<details>
    <summary>Third Dashboard</summary>

![Image not found](https://github.com/Pierrotpsy/Order-management-model/blob/main/Media/dahsboards-3.png)
</details>

<br>

