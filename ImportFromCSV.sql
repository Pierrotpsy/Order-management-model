create or replace directory PROJECT_DIR as 'C:\Users\aurel\Documents\GitHub\Order-management-model\Data';
grant read, write on directory PROJECT_DIR to public;
set SERVEROUTPUT on;
alter SESSION set NLS_DATE_FORMAT = 'YYYY-MM-DD HH24:MI:SS';
alter SESSION set NLS_NUMERIC_CHARACTERS = '.,';

DECLARE
    FILE UTL_FILE.FILE_TYPE;
    V_LINE varchar2(1000);
    businessentityid Vendor.businessentityid%TYPE;
    accountnumber Vendor.accountnumber%TYPE;
    name Vendor.name%TYPE;
    creditrating Vendor.creditrating%TYPE;
    preferredvendortstatus Vendor.preferredvendortstatus%TYPE;
    activeflag Vendor.activeflag%TYPE;
    purchasingwebserviceurl Vendor.purchasingwebserviceurl%TYPE;
    modifieddate Vendor.modifieddate%TYPE;
    
BEGIN
    -- open file
    FILE := UTL_FILE.FOPEN ('PROJECT_DIR', 'Vendor.csv', 'R');
    IF UTL_FILE.IS_OPEN(File) THEN
        UTL_FILE.GET_LINE(FILE, V_LINE, 1000);
      LOOP
        BEGIN
            -- read line from file
            UTL_FILE.GET_LINE(FILE, V_LINE, 1000);
            -- verify that line is not empty
            IF V_LINE IS NULL THEN
                EXIT;
            END IF;
            
            -- extract data from line
            businessentityid := REGEXP_SUBSTR(V_LINE, '[^;]+', 1, 1);
            IF businessentityid IS NULL THEN
                CONTINUE;
            END IF;
            accountnumber := REGEXP_SUBSTR(V_LINE, '[^;]+', 1, 2);
            name := REGEXP_REPLACE(REGEXP_SUBSTR(V_LINE, '[^;]+', 1, 3), '( ){2,}', '');
            creditrating := REGEXP_SUBSTR(V_LINE, '[^;]+', 1, 4);
            preferredvendortstatus := REGEXP_REPLACE(REGEXP_REPLACE(REGEXP_REPLACE(REGEXP_SUBSTR(V_LINE, '[^;]+', 1, 5), '( ){1,}', ''), '(true)', '1'),'false','0');
            activeflag := REGEXP_REPLACE(REGEXP_REPLACE(REGEXP_REPLACE(REGEXP_SUBSTR(V_LINE, '[^;]+', 1, 6), '( ){1,}', ''), '(true)', '1'),'false','0');
            purchasingwebserviceurl := REGEXP_REPLACE(REGEXP_SUBSTR(V_LINE, '[^;]+', 1, 7), '( ){1,}', '');
            modifieddate := REGEXP_REPLACE(REGEXP_SUBSTR(V_LINE, '[^;]+', 1, 8), '(([.]...))', '');
            
            -- insert extracted data into destination table
            insert into Vendor values (
            businessentityid,
            accountnumber,
            name,
            creditrating,
            preferredvendortstatus,
            activeflag,
            purchasingwebserviceurl,
            modifieddate
            );
            COMMIT;
        EXCEPTION
            WHEN NO_DATA_FOUND THEN
                EXIT;
        END;
      END LOOP;
    END IF;
    -- close file
    UTL_FILE.FCLOSE(FILE);
END;
/

DECLARE
    FILE UTL_FILE.FILE_TYPE;
    V_LINE varchar2(1000);
    purchaseorderid PurchaseOrderHeader.purchaseorderid%TYPE;
    revisionnumber PurchaseOrderHeader.revisionnumber%TYPE;
    status PurchaseOrderHeader.status%TYPE;
    employeeid PurchaseOrderHeader.employeeid%TYPE;
    vendorid PurchaseOrderHeader.vendorid%TYPE;
    shipmethodid PurchaseOrderHeader.shipmethodid%TYPE;
    orderdate PurchaseOrderHeader.orderdate%TYPE;
    shipdate PurchaseOrderHeader.shipdate%TYPE;
    subtotal PurchaseOrderHeader.subtotal%TYPE;
    taxamt PurchaseOrderHeader.taxamt%TYPE;
    freight PurchaseOrderHeader.freight%TYPE;
    modifieddate PurchaseOrderHeader.modifieddate%TYPE;
    
BEGIN
    -- open file
    FILE := UTL_FILE.FOPEN ('PROJECT_DIR', 'purchaseorderheader.csv', 'R');
    
    IF UTL_FILE.IS_OPEN(File) THEN
        UTL_FILE.GET_LINE(FILE, V_LINE, 1000);
      LOOP
        BEGIN
            -- read line from file
            UTL_FILE.GET_LINE(FILE, V_LINE, 1000);
            -- verify that line is not empty
            IF V_LINE IS NULL THEN
                EXIT;
            END IF;
            
            -- extract data from line
            purchaseorderid := REGEXP_SUBSTR(V_LINE, '[^;]+', 1, 1);
            IF purchaseorderid IS NULL THEN
                CONTINUE;
            END IF;
            revisionnumber := REGEXP_SUBSTR(V_LINE, '[^;]+', 1, 2);
            status := REGEXP_SUBSTR(V_LINE, '[^;]+', 1, 3);
            employeeid := REGEXP_SUBSTR(V_LINE, '[^;]+', 1, 4);
            vendorid := REGEXP_SUBSTR(V_LINE, '[^;]+', 1, 5);
            shipmethodid := REGEXP_SUBSTR(V_LINE, '[^;]+', 1, 6);
            orderdate := REGEXP_REPLACE(REGEXP_SUBSTR(V_LINE, '[^;]+', 1, 7), '(([.]...))', '');
            shipdate := REGEXP_REPLACE(REGEXP_SUBSTR(V_LINE, '[^;]+', 1, 8), '(([.]...))', '');
            subtotal := REGEXP_SUBSTR(V_LINE, '[^;]+', 1, 9);
            taxamt := REGEXP_SUBSTR(V_LINE, '[^;]+', 1, 10);
            freight := REGEXP_SUBSTR(V_LINE, '[^;]+', 1, 11);
            modifieddate := REGEXP_REPLACE(REGEXP_SUBSTR(V_LINE, '[^;]+', 1, 12), '(([.]...))', '');
            
            
            -- insert extracted data into destination table
            insert into PurchaseOrderHeader values (
            purchaseorderid,
            revisionnumber,
            status,
            employeeid,
            vendorid,
            shipmethodid,
            orderdate,
            shipdate,
            subtotal,
            taxamt,
            freight,
            modifieddate
            );
            COMMIT;
        EXCEPTION
            WHEN NO_DATA_FOUND THEN
                EXIT;
        END;
      END LOOP;
    END IF;
    -- close file
    UTL_FILE.FCLOSE(FILE);
END;
/

DECLARE
    FILE UTL_FILE.FILE_TYPE;
    V_LINE varchar2(1000);
   purchaseorderid PurchaseOrderDetail.purchaseorderid%TYPE;
   purchaseorderdetailid PurchaseOrderDetail.purchaseorderdetailid%TYPE;
   duedate PurchaseOrderDetail.duedate%TYPE;
   orderqty PurchaseOrderDetail.orderqty%TYPE;
   productid PurchaseOrderDetail.productid%TYPE;
   unitprice PurchaseOrderDetail.unitprice%TYPE;
   receivedqty PurchaseOrderDetail.receivedqty%TYPE;
   rejectedqty PurchaseOrderDetail.rejectedqty%TYPE;
   modifieddate PurchaseOrderDetail.modifieddate%TYPE;
    
BEGIN
    -- open file
    FILE := UTL_FILE.FOPEN ('PROJECT_DIR', 'purchaseorderdetail.csv', 'R');
    
    IF UTL_FILE.IS_OPEN(File) THEN
        UTL_FILE.GET_LINE(FILE, V_LINE, 1000);
      LOOP
        BEGIN
            -- read line from file
            UTL_FILE.GET_LINE(FILE, V_LINE, 1000);
            -- verify that line is not empty
            IF V_LINE IS NULL THEN
                EXIT;
            END IF;
            
            -- extract data from line
            purchaseorderid := REGEXP_SUBSTR(V_LINE, '[^;]+', 1, 1);
            IF purchaseorderid IS NULL THEN
                CONTINUE;
            END IF;
            purchaseorderdetailid := REGEXP_SUBSTR(V_LINE, '[^;]+', 1, 2);
            duedate := REGEXP_REPLACE(REGEXP_SUBSTR(V_LINE, '[^;]+', 1, 3), '(00:00:00.000)', '');
            orderqty := REGEXP_SUBSTR(V_LINE, '[^;]+', 1, 4);
            productid := REGEXP_SUBSTR(V_LINE, '[^;]+', 1, 5);
            unitprice := REGEXP_SUBSTR(V_LINE, '[^;]+', 1, 6);
            receivedqty := REGEXP_SUBSTR(V_LINE, '[^;]+', 1, 7);
            rejectedqty := REGEXP_SUBSTR(V_LINE, '[^;]+', 1, 8);
            modifieddate := REGEXP_REPLACE(REGEXP_SUBSTR(V_LINE, '[^;]+', 1, 9), '(([.]...))', '');
            
            
            --REGEXP_REPLACE(REGEXP_SUBSTR(V_LINE, '[^;]+', 1, 12), '(([.]...))', '');
            
            -- insert extracted data into destination table
            insert into PurchaseOrderDetail values (
            purchaseorderid,
            purchaseorderdetailid,
            duedate,
            orderqty,
            productid,
            unitprice,
            receivedqty,
            rejectedqty,
            modifieddate
            );
            COMMIT;
        EXCEPTION
            WHEN NO_DATA_FOUND THEN
                EXIT;
        END;
      END LOOP;
    END IF;
    -- close file
    UTL_FILE.FCLOSE(FILE);
END;
/

DECLARE
    FILE UTL_FILE.FILE_TYPE;
    V_LINE varchar2(1000);
    productid ProductVendor.productid%TYPE;
    businessentityid ProductVendor.businessentityid%TYPE;
    averageleadtime ProductVendor.averageleadtime%TYPE;
    standardprice ProductVendor.standardprice%TYPE;
    lastreceiptcost ProductVendor.lastreceiptcost%TYPE;
    lastreceiptdate ProductVendor.lastreceiptdate%TYPE;
    minorderqty ProductVendor.minorderqty%TYPE;
    maxorderqty ProductVendor.maxorderqty%TYPE;
    onorderqty ProductVendor.onorderqty%TYPE;
    unitmeasurecode ProductVendor.unitmeasurecode%TYPE;
    modifieddate ProductVendor.modifieddate%TYPE;
    
BEGIN
    -- open file
    FILE := UTL_FILE.FOPEN ('PROJECT_DIR', 'productvendor.csv', 'R');
    
    IF UTL_FILE.IS_OPEN(File) THEN
        UTL_FILE.GET_LINE(FILE, V_LINE, 1000);
      LOOP
        BEGIN
            -- read line from file
            UTL_FILE.GET_LINE(FILE, V_LINE, 1000);
            -- verify that line is not empty
            IF V_LINE IS NULL THEN
                EXIT;
            END IF;
            
            -- extract data from line
            productid := REGEXP_SUBSTR(V_LINE, '[^;]+', 1, 1);
            IF productid IS NULL THEN
                CONTINUE;
            END IF;
            businessentityid := REGEXP_SUBSTR(V_LINE, '[^;]+', 1, 2);
            averageleadtime := REGEXP_SUBSTR(V_LINE, '[^;]+', 1, 3);
            standardprice := REGEXP_SUBSTR(V_LINE, '[^;]+', 1, 4);
            lastreceiptcost := TO_NUMBER(REGEXP_SUBSTR(V_LINE, '[^;]+', 1, 5));
            lastreceiptdate := REGEXP_REPLACE(REGEXP_SUBSTR(V_LINE, '[^;]+', 1, 6), '(([.]...))', '');
            minorderqty := REGEXP_REPLACE(REGEXP_SUBSTR(V_LINE, '[^;]+', 1, 7), '( ){1,}', '');
            maxorderqty := REGEXP_REPLACE(REGEXP_SUBSTR(V_LINE, '[^;]+', 1, 8), '( ){1,}', '');
            onorderqty := REGEXP_REPLACE(REGEXP_SUBSTR(V_LINE, '[^;]+', 1, 9), '( ){1,}', '');
            unitmeasurecode := REGEXP_REPLACE(REGEXP_SUBSTR(V_LINE, '[^;]+', 1, 10), '( ){1,}', '');
            modifieddate := REGEXP_REPLACE(REGEXP_SUBSTR(V_LINE, '[^;]+', 1, 11), '(([.]...))', '');
            
            
            -- insert extracted data into destination table
            insert into ProductVendor values (
            productid,
            businessentityid,
            averageleadtime,
            standardprice,
            lastreceiptcost,
            lastreceiptdate,
            minorderqty,
            maxorderqty,
            onorderqty,
            unitmeasurecode,
            modifieddate
            );
            COMMIT;
        EXCEPTION
            WHEN NO_DATA_FOUND THEN
                EXIT;
        END;
      END LOOP;
    END IF;
    -- close file
    UTL_FILE.FCLOSE(FILE);
END;
/