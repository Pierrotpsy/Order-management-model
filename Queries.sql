-- Exercise 1 : 
-- 1. A)
SELECT name, productid FROM vendor inner JOIN productvendor on (vendor.businessentityid = productvendor.businessentityid) WHERE (creditrating = 5) AND (productid > 500);

-- B)
SELECT purchaseorderheader.purchaseorderid, orderdate, purchaseorderdetailid, orderqty, productid FROM purchaseorderheader JOIN purchaseorderdetail on (purchaseorderheader.purchaseorderid = purchaseorderdetail.purchaseorderid) WHERE orderqty > 500;

-- C)
SELECT purchaseorderheader.purchaseorderid, vendorid, purchaseorderdetailid, productid, unitprice FROM purchaseorderheader JOIN purchaseorderdetail on (purchaseorderheader.purchaseorderid = purchaseorderdetail.purchaseorderid) WHERE purchaseorderheader.purchaseorderid BETWEEN 1400 AND 1600;

-- D)
SELECT COUNT(purchaseorderid), vendorid, SUM(subtotal + freight + taxamt)AS ordercost
FROM purchaseorderheader JOIN vendor ON vendorid = businessentityid GROUP BY vendorid ORDER BY ordercost DESC;

-- E)
SELECT round(AVG(numberorder), 3), round(AVG(ordercost),3) FROM (
SELECT COUNT(purchaseorderid) AS numberorder, vendorid, SUM(subtotal + freight + taxamt)AS ordercost
FROM purchaseorderheader JOIN vendor ON vendorid = businessentityid GROUP BY vendorid);

-- F)
SELECT vendorid, round((100*SUM(rejectedqty) / SUM(receivedqty)),3) AS percentagerejected FROM purchaseorderheader inner join purchaseorderdetail on (purchaseorderheader.purchaseorderid = purchaseorderdetail.purchaseorderid)
GROUP BY vendorid ORDER BY percentagerejected DESC FETCH FIRST 10 ROWS ONLY;

-- G)
SELECT vendorid, SUM(orderqty) AS qty FROM purchaseorderheader INNER JOIN purchaseorderdetail on (purchaseorderheader.purchaseorderid = purchaseorderdetail.purchaseorderid)
GROUP BY vendorid ORDER BY qty DESC FETCH FIRST 10 ROWS ONLY;

-- Or :

SELECT vendorid, SUM(orderqty) AS sumorder FROM purchaseorderheader INNER JOIN purchaseorderdetail on (purchaseorderheader.purchaseorderid = purchaseorderdetail.purchaseorderid)
GROUP BY purchaseorderdetailid, vendorid  ORDER BY sumorder DESC FETCH FIRST 10 ROWS ONLY;
-- Can display the same vendor several times?

-- H)
SELECT productid, SUM(orderqty) AS qtypurchased FROM purchaseorderdetail GROUP BY productid ORDER BY qtypurchased DESC FETCH FIRST 10 ROWS ONLY;

-- I)

--Add complex queries
