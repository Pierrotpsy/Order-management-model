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
            
    update PurchaseOrderHeader set subtotal = :new.orderqty*:new.unitprice - :old.orderqty*:old.unitprice + subtotal where purchaseorderid = :new.purchaseorderid;
END;
/

--update PurchaseOrderDetail set unitprice = 10, orderqty = 1 where purchaseorderdetailid = 2;

--drop trigger Trig_Before_POH_Update;

create or replace trigger Trig_Before_POH_Update
before update of subtotal on PurchaseOrderHeader 
for each row
DECLARE  
    invalidSubtotal exception;
    subtotalHeader PurchaseOrderHeader.subtotal%TYPE;
    subtotalDetail PurchaseOrderHeader.subtotal%TYPE;
BEGIN 
    select sum(orderqty*unitprice) into subtotalDetail from PurchaseOrderDetail where purchaseorderid = :new.purchaseorderid group by purchaseorderid;
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
