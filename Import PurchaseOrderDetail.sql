create or replace directory PROJECT_DIR as 'C:\Users\33769\Documents\GitHub\Order-management-model\Data';
grant read, write on directory PROJECT_DIR to public;
set SERVEROUTPUT on;
alter SESSION set NLS_DATE_FORMAT = 'YYYY-MM-DD HH24:MI:SS';
alter SESSION set NLS_NUMERIC_CHARACTERS = '.,';

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