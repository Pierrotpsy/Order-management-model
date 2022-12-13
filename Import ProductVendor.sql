create or replace directory PROJECT_DIR as 'C:\Users\33769\Documents\GitHub\Order-management-model\Data';
grant read, write on directory PROJECT_DIR to public;
set SERVEROUTPUT on;
alter SESSION set NLS_DATE_FORMAT = 'YYYY-MM-DD HH24:MI:SS';
alter SESSION set NLS_NUMERIC_CHARACTERS = '.,';

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