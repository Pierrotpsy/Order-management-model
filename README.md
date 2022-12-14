# Order-management-model

This project uses Oracle SQL and Oracle PL/SQL to implement all functionalities.
Power BI is also used at the end in order to produce dashboards using the data from the Oracle Database.

Full GitHub repo available [here](https://github.com/Pierrotpsy/Order-management-model).

## 1. Data Management

As the data is furnished with the subject, we only need to concern ourselves with the data model and the data import.

#### A) Data Model

An overview of the data model was given along with the subject, which is designed to work with the given dataset.

![Image not found](https://github.com/Pierrotpsy/Order-management-model/blob/main/Media/model.PNG)

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

#### B) Data Import

To import the data, we decided to create PL/SQL scripts. This allows us to control the data more accurately and to properly transform data that can't be managed by Oracle SQL (Dates with milliseconds, booleans, etc.), as well as to format strings before adding them to the database (in our case, we deleted unnecessary spaces, but other procedures could be done to make the strings in the database more uniform, maybe letter case management?).

To use the data import scripts, the directory of the project, which is to say the directory of the CSV files, must be indicated.

To facilitate CSV file management, regular expressions were used. They allowed us to precisely select data as well as transform it according to our needs.

As mentioned before, booleans aren't natively supported by Oracle SQL, but they are in Oracle PL/SQL, so we simply converted **true** and **false** to their syntaxically accepted counterparts, **1** and **0**.

When running the script, an error while reading the file may occur. This happens when OracleDB users don't have the authorisation to access the folder in which the data is kep. You will need to add them to the list of authorized users in Read Only mode for the script to properly work.

The script to populate the tables can be found in the `ImportFromCSV.sql` file.

## 2. Data Querying

#### A) Optimized queries

The queries can be found in the `Queries.sql` file.

<details>
    <summary>Display the Vendor names and the product numbers they sell for vendors with a credit rating of 5 and productid greater than 500.</summary>


```sql
select name, productid  
    from vendor   
        inner join productvendor  
            on (vendor.businessentityid = productvendor.businessentityid)  
    where (creditrating = 5) and (productid > 500);  
        -- Cost : 4
```

![Image not found](https://github.com/Pierrotpsy/Order-management-model/blob/main/Media/2.A.PNG)
</details>

<br>

<details>
    <summary>. Display the purchase order number, OrderDate, purchase order detail id, order qty and product number for any purchase order with an order qty greater than 500.</summary>

```sql
select purchaseorderheader.purchaseorderid, orderdate, purchaseorderdetailid, orderqty, productid  
    from purchaseorderheader  
        inner join purchaseorderdetail  
            on (purchaseorderheader.purchaseorderid = purchaseorderdetail.purchaseorderid)  
    where orderqty > 500;  
        -- Cost : 30
```

In order to reduce the cost of our queries, we use materialized views. Those can be used on several queries that are based on the same tables.  
These views also reduce queries' cardinality. This way less storage is used on the computer.

```sql
-- Using materialized view :

create materialized view product1  
    build immediate  
    refresh complete on demand  
    as  
        select purchaseorderheader.purchaseorderid, orderdate, purchaseorderdetailid, orderqty,  
            productid, vendorid, unitprice  
        from purchaseorderheader  
            inner join purchaseorderdetail  
                on (purchaseorderheader.purchaseorderid = purchaseorderdetail.purchaseorderid);  
        
select purchaseorderid, orderdate, purchaseorderdetailid, orderqty, productid  
    from product1  
        where orderqty > 500;  
        -- Cost : 14
```

![Image not found](https://github.com/Pierrotpsy/Order-management-model/blob/main/Media/2.B.PNG)
</details>

<br>

<details>
    <summary>Display the purchase order number, vendor number, purchase order detail id, product number and unit price. For purchase order numbers from 1400 to 1600.</summary>

```sql
select purchaseorderheader.purchaseorderid, vendorid, purchaseorderdetailid, productid, unitprice  
    from purchaseorderheader  
        inner join purchaseorderdetail  
            on (purchaseorderheader.purchaseorderid = purchaseorderdetail.purchaseorderid)  
    where purchaseorderheader.purchaseorderid between 1400 and 1600;  
        -- Cost : 30  

-- Using materialized view :  
      
select purchaseorderid, vendorid, purchaseorderdetailid, productid, unitprice   
    from product1  
        where purchaseorderid between 1400 and 1600;  
        -- Cost : 14  

-- drop materialized view product1;
```

We do not forget to drop every view at the end of its utilisation.

![Image not found](https://github.com/Pierrotpsy/Order-management-model/blob/main/Media/2.C.PNG)
</details>

<br>

<details>
    <summary>Display how many orders are purchased from each vendor and the cost of the orders. Return the results sorted in descending order of highest cost.</summary>

```sql
select count(purchaseorderid) as numberorder,  
    vendorid, sum(subtotal + freight + taxamt) as ordercost  
    from purchaseorderheader  
        inner join vendor  
            on vendorid = businessentityid  
    group by vendorid  
    order by ordercost desc;  
        -- Cost : 14  
        
-- Using materialized view :  
 
create materialized view vendor  
    build immediate  
    refresh complete on demand  
    as  
        select count(purchaseorderid) as numberorder,  
            vendorid, sum(subtotal + freight + taxamt) as ordercost  
        from purchaseorderheader  
            inner join vendor  
                on vendorid = businessentityid  
        group by vendorid;  

select * from vendor  
    order by ordercost desc;  
        -- Cost : 3  
```

![Image not found](https://github.com/Pierrotpsy/Order-management-model/blob/main/Media/2.D.PNG)
</details>

<br>

<details>
    <summary>Display the average number of orders purchased across all vendors and the average cost across all vendors.</summary>

```sql
select round(avg(numberorder), 3), round(avg(ordercost),3)  
    from(  
        select count(purchaseorderid) as numberorder,  
            vendorid, sum(subtotal + freight + taxamt) as ordercost  
            from purchaseorderheader  
                inner join vendor  
                    on vendorid = businessentityid  
            group by vendorid);  
        -- Cost : 13  
        
-- Using materialized view :  
     
select round(avg(numberorder), 3), round(avg(ordercost),3)   
    from vendor;  
        -- Cost : 2  

-- drop materialized view vendor;  
```

![Image not found](https://github.com/Pierrotpsy/Order-management-model/blob/main/Media/2.E.PNG)
</details>

<br>

<details>
    <summary>Display The top ten vendors with the highest percentage of rejected received items.</summary>

```sql
select vendorid, round((100*sum(rejectedqty) / sum(receivedqty)),3) as percentagerejected  
    from purchaseorderheader  
        inner join purchaseorderdetail  
            on (purchaseorderheader.purchaseorderid = purchaseorderdetail.purchaseorderid)  
    group by vendorid  
    order by percentagerejected desc fetch first 10 rows only;  
        -- Cost : 34  

-- Using materialized view :  

create materialized view product2  
    build immediate  
    refresh complete on demand  
    as  
        select vendorid, orderqty, purchaseorderdetailid, rejectedqty, receivedqty, productid  
        from purchaseorderheader  
            inner join purchaseorderdetail  
                on (purchaseorderheader.purchaseorderid = purchaseorderdetail.purchaseorderid);  

select vendorid, round((100*SUM(rejectedqty) / sum(receivedqty)),3) as percentagerejected  
    from product2  
    group by vendorid  
    order by percentagerejected desc fetch first 10 rows only;  
        -- Cost : 14  
```

![Image not found](https://github.com/Pierrotpsy/Order-management-model/blob/main/Media/2.F.PNG)
</details>

<br>

<details>
    <summary>Display The top ten vendors with the largest orders (in terms of quantity purchased).</summary>

```sql
select vendorid, sum(orderqty) as qty  
    from purchaseorderheader  
        inner join purchaseorderdetail  
            on (purchaseorderheader.purchaseorderid = purchaseorderdetail.purchaseorderid)  
    group by vendorid  
    order by qty desc fetch first 10 rows only;  
        -- Cost : 34  

-- Using materialized view :  

select vendorid, sum(orderqty) as qty  
    from product2  
    group by vendorid   
    order by qty desc fetch first 10 rows only;  
        -- Cost : 14        
```

![Image not found](https://github.com/Pierrotpsy/Order-management-model/blob/main/Media/2.G_1.PNG)

We gave this question two different meanings. The first one was to display the top ten vendors with the more ordered articles in general. The following up one is to display the top ten vendors with the largest distinct orders in terms of quantity.

```sql
select vendorid, sum(orderqty) as sumorder  
    from purchaseorderheader  
        inner join purchaseorderdetail  
            on (purchaseorderheader.purchaseorderid = purchaseorderdetail.purchaseorderid)  
    group by purchaseorderdetailid, vendorid  
    order by sumorder desc fetch first 10 rows only;  
-- Can display the same vendor several times?  
        -- Cost : 34  

-- Using materialized view :  

select vendorid, sum(orderqty) as sumorder  
    from product2  
    group by purchaseorderdetailid, vendorid  
    order by sumorder desc fetch first 10 rows only;  
        -- Cost : 14  
```

![Image not found](https://github.com/Pierrotpsy/Order-management-model/blob/main/Media/2.G_2.PNG)
</details>

<br>

<details>
    <summary>Display the top ten products (in terms of quantity purchased).</summary>

```sql
select productid, sum(orderqty) as qtypurchased  
    from purchaseorderdetail  
    group by productid   
    order by qtypurchased desc fetch first 10 rows only;  
        -- Cost : 22  

-- Using materialized view :  

select productid, sum(orderqty) as qtypurchased  
    from product2  
    group by productid  
    order by qtypurchased desc fetch first 10 rows only;  
        -- Cost : 14  
        
-- drop materialized view product2;  
```

![Image not found](https://github.com/Pierrotpsy/Order-management-model/blob/main/Media/2.H.PNG)
</details>

<br>

#### B) Complex queries

<details>
    <summary>Display the price amount of purchased products by year</summary>

```sql
select purchaseorderdetail.productid,  
        sum(purchaseorderdetail.unitprice*purchaseorderdetail.orderqty) as amount,  
        EXTRACT(YEAR from purchaseorderdetail.duedate) as year  
    from purchaseorderdetail  
        inner join productvendor  
            on (purchaseorderdetail.productid = productvendor.productid)  
    group by purchaseorderdetail.productid, EXTRACT(YEAR from purchaseorderdetail.duedate)  
    order by year asc, amount desc;  
        -- Cost : 282  

-- Using materialsed view :  

create materialized view purchase  
    build immediate  
    refresh complete on demand  
    as  
        select purchaseorderdetail.productid, purchaseorderdetail.unitprice, purchaseorderdetail.orderqty,  
            EXTRACT(YEAR from purchaseorderdetail.duedate) as year,  
            businessentityid, rejectedqty, receivedqty  
        from purchaseorderdetail  
            inner join productvendor  
                on (purchaseorderdetail.productid = productvendor.productid);  

select productid, sum(unitprice*orderqty) as amount, year  
    from purchase  
    group by productid, year  
    order by year asc, amount desc;  
        -- Cost : 26  
```

![Image not found](https://github.com/Pierrotpsy/Order-management-model/blob/main/Media/2.I_1.PNG)
</details>

<br>

<details>
    <summary>Display the vendor, vendor id, percentage of rejected articles, ordered, received, and rejected quantity for each vendor ordered by descending rejected percentage.</summary>

```sql
select productvendor.businessentityid, name,  
    round(100*sum(rejectedqty)/sum(receivedqty),3) as rejectedPercentage,  
    sum(orderqty), sum(receivedqty), sum(rejectedqty)  
    from purchaseorderdetail  
        inner join productvendor  
            on (purchaseorderdetail.productid = productvendor.productid)  
        inner join vendor  
            on (productvendor.businessentityid = vendor.businessentityid)  
    group by productvendor.businessentityid, name  
    order by rejectedPercentage desc;  
        -- Cost : 26  

-- Using materialsed view :  

select purchase.businessentityid, name,  
    round(100*su??(rejectedqty)/sum(receivedqty),3) as rejectedPercentage,  
    sum(orderqty), sum(receivedqty), sum(rejectedqty)  
    from purchase  
        inner join vendor  
            on (purchase.businessentityid = vendor.businessentityid)  
    group by purchase.businessentityid, name   
    order by rejectedPercentage desc;  
        -- Cost : 28  
            --> The query that doesn't use the materialzed view is faster than the one using it.   

```

![Image not found](https://github.com/Pierrotpsy/Order-management-model/blob/main/Media/2.I_2.PNG)
</details>

<br>

<details>
    <summary>Display the price amount of purchased product by vendor</summary>

```sql
select productvendor.businessentityid, name,  
    sum(purchaseorderdetail.unitprice*purchaseorderdetail.orderqty) as amount,  
    EXTRACT(YEAR from purchaseorderdetail.duedate) as year  
    from purchaseorderdetail  
        inner join productvendor on (purchaseorderdetail.productid = productvendor.productid)  
        inner join vendor on (productvendor.businessentityid = vendor.businessentityid)  
    group by productvendor.businessentityid, name, EXTRACT(YEAR from purchaseorderdetail.duedate)  
    order by year asc, amount desc;  
        -- Cost : 496  

-- Using materialsed view : 

select purchase.businessentityid, name, sum(unitprice*orderqty) as amount, year 
    from purchase inner join vendor on (purchase.businessentityid = vendor.businessentityid)
    group by purchase.businessentityid, name, year
    order by year asc, amount desc;
        -- Cost : 28
```

![Image not found](https://github.com/Pierrotpsy/Order-management-model/blob/main/Media/2.I_3.PNG)
</details>

<br>

<details>
    <summary>Display the rejected percentage per year per vendor</summary>

```sql
select productvendor.businessentityid, name,  
    round(100*sum(rejectedqty)/sum(receivedqty),3) as rejectedPercentage,  
    EXTRACT(YEAR from purchaseorderdetail.duedate) as year  
    from purchaseorderdetail  
        inner join productvendor on (purchaseorderdetail.productid = productvendor.productid)  
        inner join vendor on (productvendor.businessentityid = vendor.businessentityid)  
    group by productvendor.businessentityid, name, EXTRACT(YEAR from purchaseorderdetail.duedate)  
    order by rejectedPercentage desc;  
        -- Cost : 478  

-- Using materialsed view : 

select purchase.businessentityid, name,  
    round(100*sum(rejectedqty)/sum(receivedqty),3) as rejectedPercentage, year  
    from purchase  
        inner join vendor on (purchase.businessentityid = vendor.businessentityid)  
    group by purchase.businessentityid, name, year  
    order by rejectedPercentage desc;  
        -- Cost : 388  

-- drop materialized view purchase;   
```

![Image not found](https://github.com/Pierrotpsy/Order-management-model/blob/main/Media/2.I_4.PNG)
</details>
<br>

#### C) Triggers

The triggers can be found in the `Triggers.sql` file.

<details>
    <summary>Create a Transaction_History table with the same structure as
PurchaseOrderDetail table. Implement using a trigger "After Update" On
PurchaseOrderDetail table that inserts a row in the Transaction_History table, updates ModifiedDate in PurchaseOrderDetail, updates the PurchaseOrderHeader.SubTotal column.</summary>

<br>

The **TransactionHistory** table was easy to create.

```sql
--drop table TransactionHistory;

create table TransactionHistory(
   purchaseorderid number(10),
   purchaseorderdetailid number(10),
   duedate date,
   orderqty number(10),
   productid number(10),
   unitprice number,
   receivedqty number(10),
   rejectedqty number(10),
   modifieddate date
);
```

As for the trigger, it is asked that the trigger modifies the modified date of the table it applies to. However, this is by definition not permitted by Oracle SQL using an **AFTER UPDATE** trigger and will throw a mutating table error (*ORA-04091*). 
Therefore, we decided to implement a **BEFORE UPDATE** trigger which allows such an update. This doesn't change anything else in the trigger, since the two other functionalities would also work in an **AFTER UPDATE** trigger.

Here is the code for the trigger : 

```sql
--drop trigger Trig_After_POD_Update;

create or replace trigger Trig_Before_POD_Update
before update on PurchaseOrderDetail 
for each row
DECLARE  
BEGIN 
    select CURRENT_TIMESTAMP into :new.modifieddate from dual;
    
    insert into TransactionHistory values (
            :new.purchaseorderid,
            :new.purchaseorderdetailid,
            :new.duedate,
            :new.orderqty,
            :new.productid,
            :new.unitprice,
            :new.receivedqty,
            :new.rejectedqty,
            :new.modifieddate
            );
            
    update PurchaseOrderHeader 
        set subtotal = :new.orderqty*:new.unitprice 
            - :old.orderqty*:old.unitprice 
            + subtotal 
        where purchaseorderid = :new.purchaseorderid;
END;
/

--update PurchaseOrderDetail set unitprice = 10, orderqty = 1 where purchaseorderdetailid = 2;

```

</details>

<br>

<details>
    <summary>Implement using a trigger "Before Update" On PurchaseOrderHeader table that prohibits updates of the PurchaseOrderHeader.SubTotal column if the corresponding data in the PurchaseOrderDetail table is not consistent with the new value of the PurchaseOrderHeader.SubTotal column</summary>

<br>

Here is the code for the trigger : 

```sql
--drop trigger Trig_Before_POH_Update;

create or replace trigger Trig_Before_POH_Update
before update of subtotal on PurchaseOrderHeader 
for each row
DECLARE  
    invalidSubtotal exception;
    subtotalHeader PurchaseOrderHeader.subtotal%TYPE;
    subtotalDetail PurchaseOrderHeader.subtotal%TYPE;
BEGIN 
    select sum(orderqty*unitprice) into subtotalDetail 
        from PurchaseOrderDetail 
        where purchaseorderid = :new.purchaseorderid 
        group by purchaseorderid;

    subtotalHeader := :new.subtotal;
    if(subtotalHeader != subtotalDetail)
    then 
        raise invalidSubtotal;
    end if;
    
EXCEPTION 
    when invalidSubtotal then
    raise_application_error(-20010, 'Subtotal does not match the amounts in the PurchaseOrderDetail table');
END;
/

--update PurchaseOrderHeader set subtotal = 10 where purchaseorderid = 2;
```

![Image not found](link)
</details>

<br>


## 3. Data Visualization

In order to visualize  the data in our database more clearly, we implemented some Power BI Dashboards. 

Connecting an Oracle database to Power BI isn't natively supported by ordinary microsoft connectors.

[This ](https://www.oracle.com/a/ocom/docs/database/microsoft-powerbi-connection-adw.pdf) tutorial was helpful to set it up correctly.

Once that is done, a connection can be established with the database, in our case using `localhost` or `localhost:1521/xe` as server name. But we encountered some difficulties trying to locate all our tables in the importer that pops up afterwards. The only way for us to get data from the database was to directly use queries in our connection.

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

The dashboard was generated using this query :
```sql
select purchaseorderdetail.productid,      
    sum(purchaseorderdetail.unitprice*purchaseorderdetail.orderqty) as amount,  
    EXTRACT(YEAR from purchaseorderdetail.duedate) as year 
    from purchaseorderdetail 
        inner join productvendor on (purchaseorderdetail.productid = productvendor.productid) 
    group by purchaseorderdetail.productid, 
            EXTRACT(YEAR from purchaseorderdetail.duedate) 
    order by year asc, 
        amount desc;

```

A rank column was then generated according to each year, and a filter was applied to only select the first 5 products of each year.

Formatting was then applied to the visual in order to emphasize the values and to sort them correctly.

![Image not found](https://github.com/Pierrotpsy/Order-management-model/blob/main/Media/dahsboards-1.png)
</details>

<br>

- The second one represents the 20 vendors with the least percentage of rejected received items.
<details>
    <summary>Second Dashboard</summary>

The dashboard was generated using this query :
```sql
select productvendor.businessentityid, 
    name, 
    100*sum(rejectedqty)/sum(receivedqty) as rejected
    from purchaseorderdetail 
        inner join productvendor on (purchaseorderdetail.productid = productvendor.productid)
        inner join vendor on (productvendor.businessentityid = vendor.businessentityid) 
    group by productvendor.businessentityid, name 
    order by rejected asc;
```

A rank column was then added and a filter was applied to select the first 20 vendors.

Formatting was then applied to the visual in order to emphasize the values and to sort them correctly.

Although the question asked for the first 5 vendors, that wasn't very interesting since the first 5 vendors all have a percentage of rejected received items of 0. So we decided to include the first 20 vendors to make it more pertinent.

![Image not found](https://github.com/Pierrotpsy/Order-management-model/blob/main/Media/dahsboards-2.png)
</details>

<br>

- The third one shows performance per order by adding the order quantity, the received quantity and the rejected quantity side to side.
<details>
    <summary>Third Dashboard</summary>

This dashboard was generated using this query :
```sql
select purchaseorderid, 
    orderqty, 
    receivedqty, 
    rejectedqty 
    from PurchaseOrderDetail;
```

Formatting was then applied to the visual in order to emphasize the three values and to sort them correctly.

![Image not found](https://github.com/Pierrotpsy/Order-management-model/blob/main/Media/dahsboards-3.png)
</details>

<br>

