drop table ProductVendor; 
drop table PurchaseOrderDetail;
drop table PurchaseOrderHeader;
drop table Vendor;

create table Vendor(
    businessentityid number(10),
    accountnumber varchar2(40),
    name varchar2(100),
    creditrating number(1),
    preferredvendortstatus number(1),
    activeflag number(1),
    purchasingwebserviceurl varchar2(100),
    modifieddate date,
    constraint pk_V_id primary key(businessentityid)
);

create table PurchaseOrderHeader(
    purchaseorderid number(10),
    revisionnumber number(2),
    status number(1),
    employeeid number(10),
    vendorid number(10),
    shipmethodid number(1),
    orderdate date,
    shipdate date,
    subtotal number,
    taxamt number,
    freight number,
    modifieddate date,
    constraint pk_POH_id primary key(purchaseorderid),
    constraint fk_vendorid foreign key(vendorid)references Vendor(businessentityid)
);

create table ProductVendor(
    productid number(10),
    businessentityid number(10),
    averageleadtime number(3),
    standardprice number,
    lastreceiptcost number,
    lastreceiptdate date,
    minorderqty number(10),
    maxorderqty number(10),
    onorderqty number(10),
    unitmeasurecode varchar2(3),
    modifieddate date,
    constraint pk_PV_id primary key(productid, businessentityid),
    constraint fk_businessentityid foreign key (businessentityid) references Vendor(businessentityid)
);

create table PurchaseOrderDetail(
   purchaseorderid number(10),
   purchaseorderdetailid number(10),
   duedate date,
   orderqty number(10),
   productid number(10),
   unitprice number,
   receivedqty number(10),
   rejectedqty number(10),
   modifieddate date,
   constraint pk_POD_id primary key(purchaseorderdetailid, purchaseorderid),
   constraint fk_orderid foreign key(purchaseorderid) references PurchaseOrderHeader(purchaseorderid)
);

alter SESSION set NLS_DATE_FORMAT = 'YYYY-MM-DD HH24:MI:SS';
