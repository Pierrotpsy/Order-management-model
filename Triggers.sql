drop table TransactionHistory;

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

create or replace trigger Trig_After_POD_Update
before update on PurchaseOrderDetail 
for each row
DECLARE  
    newtotal PurchaseOrderHeader.subtotal%TYPE;
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
            
    update PurchaseOrderHeader set subtotal = (:new.orderqty-:old.orderqty)*(:new.unitprice) + subtotal;
END;
/
