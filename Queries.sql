-- Exercise 1 : 
-- 1. 

-- A)
SELECT name, productid FROM vendor INNER JOIN productvendor ON (vendor.businessentityid = productvendor.businessentityid) WHERE (creditrating = 5) AND (productid > 500);
        -- Cost : 4
        
-- B)
SELECT purchaseorderheader.purchaseorderid, orderdate, purchaseorderdetailid, orderqty, productid 
    FROM purchaseorderheader INNER JOIN purchaseorderdetail ON (purchaseorderheader.purchaseorderid = purchaseorderdetail.purchaseorderid) 
        WHERE orderqty > 500;
        -- Cost : 30

-- Using materialized view :

CREATE materialized view product1 
    build immediate 
    refresh complete on demand
    as
        SELECT purchaseorderheader.purchaseorderid, orderdate, purchaseorderdetailid, orderqty, productid, vendorid, unitprice
        FROM purchaseorderheader INNER JOIN purchaseorderdetail ON (purchaseorderheader.purchaseorderid = purchaseorderdetail.purchaseorderid);
        
SELECT purchaseorderid, orderdate, purchaseorderdetailid, orderqty, productid 
    FROM product1 
        WHERE orderqty > 500;
        -- Cost : 14

-- C)
SELECT purchaseorderheader.purchaseorderid, vendorid, purchaseorderdetailid, productid, unitprice 
    FROM purchaseorderheader INNER JOIN purchaseorderdetail ON (purchaseorderheader.purchaseorderid = purchaseorderdetail.purchaseorderid) 
        WHERE purchaseorderheader.purchaseorderid BETWEEN 1400 AND 1600;
        -- Cost : 30

-- Using materialized view :
      
SELECT purchaseorderid, vendorid, purchaseorderdetailid, productid, unitprice 
    FROM product1
        WHERE purchaseorderid BETWEEN 1400 AND 1600;
        -- Cost : 14

DROP materialized view product1;

-- D)
SELECT COUNT(purchaseorderid) AS numberorder, vendorid, SUM(subtotal + freight + taxamt)AS ordercost
    FROM purchaseorderheader INNER JOIN vendor ON vendorid = businessentityid 
    GROUP BY vendorid 
    ORDER BY ordercost DESC;
        -- Cost : 14
        
-- Using materialized view :
 
CREATE materialized view vendor
    build immediate 
    refresh complete on demand
    as
        SELECT COUNT(purchaseorderid) AS numberorder, vendorid, SUM(subtotal + freight + taxamt) AS ordercost
        FROM purchaseorderheader INNER JOIN vendor ON vendorid = businessentityid
        GROUP BY vendorid;

SELECT * FROM vendor
    ORDER BY ordercost DESC;
        -- Cost : 3

-- E)
SELECT round(AVG(numberorder), 3), round(AVG(ordercost),3) 
    FROM(
        SELECT COUNT(purchaseorderid) AS numberorder, vendorid, SUM(subtotal + freight + taxamt) AS ordercost
            FROM purchaseorderheader INNER JOIN vendor ON vendorid = businessentityid 
            GROUP BY vendorid);
        -- Cost : 13
        
-- Using materialized view :
     
SELECT round(AVG(numberorder), 3), round(AVG(ordercost),3) 
    FROM vendor;
        -- Cost : 2

DROP materialized view vendor;

-- F)
SELECT vendorid, round((100*SUM(rejectedqty) / SUM(receivedqty)),3) AS percentagerejected 
    FROM purchaseorderheader INNER JOIN purchaseorderdetail ON (purchaseorderheader.purchaseorderid = purchaseorderdetail.purchaseorderid)
    GROUP BY vendorid 
    ORDER BY percentagerejected DESC FETCH FIRST 10 ROWS ONLY;
        -- Cost : 34

-- Using materialized view :

CREATE materialized view product2
    build immediate 
    refresh complete on demand
    as
        SELECT vendorid, orderqty, purchaseorderdetailid, rejectedqty, receivedqty, productid
        FROM purchaseorderheader INNER JOIN purchaseorderdetail ON (purchaseorderheader.purchaseorderid = purchaseorderdetail.purchaseorderid);

SELECT vendorid, round((100*SUM(rejectedqty) / SUM(receivedqty)),3) AS percentagerejected  FROM product2
    GROUP BY vendorid
    ORDER BY percentagerejected DESC FETCH FIRST 10 ROWS ONLY;
        -- Cost : 14

-- G)
SELECT vendorid, SUM(orderqty) AS qty FROM purchaseorderheader INNER JOIN purchaseorderdetail ON (purchaseorderheader.purchaseorderid = purchaseorderdetail.purchaseorderid)
    GROUP BY vendorid 
    ORDER BY qty DESC FETCH FIRST 10 ROWS ONLY;
        -- Cost : 34

-- Or :

SELECT vendorid, SUM(orderqty) AS sumorder FROM purchaseorderheader INNER JOIN purchaseorderdetail ON (purchaseorderheader.purchaseorderid = purchaseorderdetail.purchaseorderid)
    GROUP BY purchaseorderdetailid, vendorid 
    ORDER BY sumorder DESC FETCH FIRST 10 ROWS ONLY;
-- Can display the same vendor several times?
        -- Cost : 34
        
-- Using materialized view :

SELECT vendorid, SUM(orderqty) AS qty FROM product2
    GROUP BY vendorid 
    ORDER BY qty DESC FETCH FIRST 10 ROWS ONLY;
        -- Cost : 14

-- Or :

SELECT vendorid, SUM(orderqty) AS sumorder FROM product2
    GROUP BY purchaseorderdetailid, vendorid 
    ORDER BY sumorder DESC FETCH FIRST 10 ROWS ONLY;
        -- Cost : 14

-- H)
SELECT productid, SUM(orderqty) AS qtypurchased FROM purchaseorderdetail 
    GROUP BY productid 
    ORDER BY qtypurchased DESC FETCH FIRST 10 ROWS ONLY;
        -- Cost : 22

-- Using materialized view :

SELECT productid, SUM(orderqty) AS qtypurchased FROM product2
    GROUP BY productid 
    ORDER BY qtypurchased DESC FETCH FIRST 10 ROWS ONLY;
        -- Cost : 14
        
DROP materialized view product2;

-- I)

--Add complex queries

SELECT purchaseorderdetail.productid, SUM(purchaseorderdetail.unitprice*purchaseorderdetail.orderqty) AS amount, EXTRACT(YEAR FROM purchaseorderdetail.duedate) AS year 
    FROM purchaseorderdetail INNER JOIN productvendor ON (purchaseorderdetail.productid = productvendor.productid) 
    GROUP BY purchaseorderdetail.productid, EXTRACT(YEAR from purchaseorderdetail.duedate) 
    ORDER BY year asc, amount desc;
        -- Cost : 282

SELECT productvendor.businessentityid, name, 100*SUM(rejectedqty)/SUM(receivedqty) AS rejected, SUM(orderqty), SUM(receivedqty), SUM(rejectedqty) 
    FROM purchaseorderdetail INNER JOIN productvendor ON (purchaseorderdetail.productid = productvendor.productid)
    INNER JOIN vendor ON (productvendor.businessentityid = vendor.businessentityid) 
    GROUP BY productvendor.businessentityid, name 
    ORDER BY rejected asc;
        -- Cost : 26
        
-- Using materialsed view :

CREATE materialized view purchase
    build immediate 
    refresh complete on demand
    as
        SELECT purchaseorderdetail.productid, purchaseorderdetail.unitprice, purchaseorderdetail.orderqty, EXTRACT(YEAR FROM purchaseorderdetail.duedate) AS year, businessentityid, rejectedqty, receivedqty
        FROM purchaseorderdetail INNER JOIN productvendor ON (purchaseorderdetail.productid = productvendor.productid);

SELECT productid, SUM(unitprice*orderqty) AS amount, year 
    FROM purchase 
    GROUP BY productid, year
    ORDER BY year asc, amount desc;
        -- Cost : 26

SELECT purchase.businessentityid, name, 100*SUM(rejectedqty)/SUM(receivedqty) AS rejected, SUM(orderqty), SUM(receivedqty), SUM(rejectedqty) 
    FROM purchase INNER JOIN vendor ON (purchase.businessentityid = vendor.businessentityid) 
    GROUP BY purchase.businessentityid, name 
    ORDER BY rejected asc;
        -- Cost : 28 
            --> The query that doesn't use the materialzed view is faster than the one using it.

DROP materialized view purchase;