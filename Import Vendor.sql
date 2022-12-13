create or replace directory PROJECT_DIR as 'C:\Users\33769\Documents\GitHub\Order-management-model\Data';
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
            
            --REGEXP_REPLACE(REGEXP_SUBSTR(V_LINE, '[^;]+', 1, 12), '(([.]...))', '');
            
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