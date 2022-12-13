create or replace directory PROJECT_DIR as 'C:\Users\33769\Documents\GitHub\Order-management-model\Data';
grant read, write on directory PROJECT_DIR to public;
set SERVEROUTPUT on;
alter SESSION set NLS_DATE_FORMAT = 'YYYY-MM-DD HH24:MI:SS';
alter SESSION set NLS_NUMERIC_CHARACTERS = '.,';

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