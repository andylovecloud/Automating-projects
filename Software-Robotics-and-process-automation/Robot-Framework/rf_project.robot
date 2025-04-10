*** Settings ***
Library    String
Library    Collections
Library    OperatingSystem
Library    DatabaseLibrary
Library    DateTime
Library    validate.py

*** Variables ***
# Global variables
${PATH}    C:/Users/student/Desktop/RB_Exercise/Project-RPA/
@{ListToDB}
${InvoiceNumber}    empty

# database related variables
${dbname}    rpacourse
${dbuser}    robotuser
${dbpass}    password
${dbhost}    localhost
${dbport}    3306

*** Keywords ***
Make Connection
	[Arguments]  ${dbtoconnect}
	Connect To Database  dbapiModuleName=pymysql  dbName=${dbtoconnect}  dbUsername=${dbuser}  dbPassword=${dbpass}  dbHost=${dbhost}  dbPort=${dbport}

*** Keywords ***
Add Row Data to List
    # own keyword for handling data row to be written to database
    [Arguments]    ${items}
    
    @{AddInvoiceRowData}=    Create List
    Append To List    ${AddInvoiceRowData}    ${InvoiceNumber}
    Append To List    ${AddInvoiceRowData}    ${items}[8]
    Append To List    ${AddInvoiceRowData}    ${items}[0]
    Append To List    ${AddInvoiceRowData}    ${items}[1]
    Append To List    ${AddInvoiceRowData}    ${items}[2]
    Append To List    ${AddInvoiceRowData}    ${items}[3]
    Append To List    ${AddInvoiceRowData}    ${items}[4]
    Append To List    ${AddInvoiceRowData}    ${items}[5]
    Append To List    ${AddInvoiceRowData}    ${items}[6]
    
    Append To List    ${ListToDB}    ${AddInvoiceRowData}

*** Keywords ***
Ensure Invoice Status Exists
    Make Connection    ${dbname}
    ${count}=    Query    SELECT COUNT(*) FROM invoicestatus;
    ${count}=    Convert To Integer    ${count}[0][0]
    
    IF    ${count} == 0
        Log To Console    [INFO] Inserting default statuses into invoicestatus table.
        Execute Sql String    INSERT INTO invoicestatus (id, name) VALUES (0, 'Approved'), (1, 'Reference Error'), (2, 'IBAN Error'), (3, 'Amount Mismatch'), (4, 'Due Date Error');
    ELSE
        Log To Console    [INFO] Invoice status table already populated.
    END

*** Keywords ***

    
Add Invoice Header To DB
    # own keyword for writing header data to database
    #     Validations:
    #        * Reference number check
    #        * IBAN check
    #        * Invoice row amount vs. header amount
    [Arguments]    ${items}    ${rows}
    Make Connection    ${dbname}
    
    # 1) Convert dates to correct format
    ${innvoiceDate}=    Convert Date    ${items}[3]    date_format=%d.%m.%Y    result_format=%Y-%m-%d
    ${dueDate}=    Convert Date    ${items}[4]    date_format=%d.%m.%Y    result_format=%Y-%m-%d

     Set Global Variable    ${innvoiceDate}
     Set Global Variable    ${dueDate}
    # 3) DB create to decimal(10,2)
    ${statusOfInvoice}=    Set Variable    0
    ${commentOfInvoice}=    Set Variable    All ok
    
    ${refResult}=    Is Ref Correct    ${items}[2]
    
    IF    not ${refResult}
        ${statusOfInvoice}=    Set Variable    1
        ${commentOfInvoice}=    Set Variable    Reference number error
    END

    ${ibanResult}=    Check IBAN    ${items}[6]
    
    IF    not ${ibanResult}
        ${statusOfInvoice}=    Set Variable    2
        ${commentOfInvoice}=    Set Variable    IBAN number error
    END

    ${sumResult}=    Check Amounts From Invoice    ${items}[9]    ${rows}
    IF    not ${sumResult}
        ${statusOfInvoice}=    Set Variable    3
        ${commentOfInvoice}=    Set Variable    Amount difference
    END

    #Group33: Validate if due date is in the past
    ${innvoiceDate}=    Convert Date    ${items}[3]    date_format=%d.%m.%Y    result_format=%Y-%m-%d
    ${dueDate}=    Convert Date    ${items}[4]    date_format=%d.%m.%Y    result_format=%Y-%m-%d
    ${dueDateDifference}=   Subtract Date From Date   ${dueDate}     ${innvoiceDate} 
    IF    ${dueDateDifference} < 0
        ${statusOfInvoice}=    Set Variable    4
        ${commentOfInvoice}=    Set Variable    Check the due date
    END

    ${insertStmt}=    Set Variable    insert into invoiceheader (invoicenumber, companyname, companycode, referencenumber, invoicedate, duedate, bankaccountnumber, amountexclvat, vat, totalamount, invoicestatus_id, comments) values ('${items}[0]', '${items}[1]', '${items}[5]', '${items}[2]', '${innvoiceDate}', '${dueDate}', '${items}[6]', '${items}[7]', '${items}[8]', '${items}[9]', '${statusOfInvoice}', '${commentOfInvoice}');
    #Log    ${insertStmt}
    Execute Sql String    ${insertStmt}

*** Keywords ***
Check Amounts From Invoice
    [Arguments]    ${totalSumFromHeader}    ${invoiceRows}
    ${status}=    Set Variable    ${False}
    ${totalRowsAmount}=    Evaluate    0

    FOR    ${element}    IN    @{invoiceRows}
        #Log To Console   ${element}[8]
        ${totalRowsAmount}=    Evaluate    ${totalRowsAmount}+${element}[8]
    END

    ${totalSumFromHeader}=    Convert To Number    ${totalSumFromHeader}
    ${totalRowsAmount}=    Convert To Number    ${totalRowsAmount}
    ${diff}=    Convert To Number    0.01
    
    ${status}=    Is Equal    ${totalSumFromHeader}    ${totalRowsAmount}    ${diff}

    [Return]    ${status}

*** Keywords ***
Check IBAN
    [Arguments]    ${iban}
    #Log To Console   ${iban}
    ${status}=    Set Variable    ${False}
    ${iban}=    Remove String    ${iban}    ${SPACE}

    ${length}=    Get Length    ${iban}

    #Log To Console    ${length}

    IF    ${length} == 18
        ${status}=    Set Variable    ${True}
    END
    [Return]    ${status}

*** Keywords ***
Add Invoice Row To DB
    # own keyword for writing header data to database
    [Arguments]    ${items}
    Make Connection    ${dbname}
    ${insertStmt}=    Set Variable    insert into invoicerow (invoicenumber, rownumber, description, quantity, unit, unitprice, vatpercent, vat, total) values ('${items}[0]', '${items}[1]', '${items}[2]', '${items}[3]', '${items}[4]', '${items}[5]', '${items}[6]', '${items}[7]', '${items}[8]');
    Execute Sql String    ${insertStmt}


*** Test Cases ***
Read CSV file to list
    #Make Connection    ${dbname}
    ${outputHeader}=    Get File    ${PATH}InvoiceHeaderData.csv
    ${outputRows}=    Get File    ${PATH}InvoiceRowData.csv
    Log    ${outputHeader}
    Log    ${outputRows}

    # Each row read as an element to list 
    @{headers}=    Split String    ${outputHeader}    \n
    @{rows}=    Split String    ${outputRows}    \n
    
    # Remove last row and first row from lists (last=empty and first=header)
    ${length}=    Get Length    ${headers}
    ${length}=    Evaluate    ${length}-1
    ${index}=    Convert To Integer    0
    
    Remove From List    ${headers}    ${length}
    Remove From List    ${headers}    ${index}

    ${length}=    Get Length    ${rows}
    ${length}=    Evaluate    ${length}-1

    Remove From List    ${rows}    ${length}
    Remove From List    ${rows}    ${index}
    
    # Set as global, that we can use same variables in other test cases
    Set Global Variable    ${headers}
    Set Global Variable    ${rows}



*** Test Cases ***
Initialize Database
    Ensure Invoice Status Exists


*** Test Cases ***
Validate VAT Percentage in InvoiceRowData.csv
#Group33
    ${outputRows}=    Get File    ${PATH}InvoiceRowData.csv
    @{rows}=    Split String    ${outputRows}    \n

    # Remove header row and last empty row (if applicable)
    ${length}=    Get Length    ${rows}
    ${length}=    Evaluate    ${length}-1
    Remove From List    ${rows}    ${length}
    Remove From List    ${rows}    0

    # Loop through invoice rows to check VAT percentage
    FOR    ${element}    IN    @{rows}
        @{items}=    Split String    ${element}    ;
        
        # Convert float VAT percent to integer
        ${vatpercent}=    Evaluate    int(${items}[4])

        # If VAT percent is different from 24, log an error and fail the test
        IF    ${vatpercent} != 24
            Log    [ERROR] VAT percentage is incorrect: ${vatpercent}. Expected: 24.
            Fail    VAT percentage validation failed! Found: ${vatpercent}, Expected: 24
        ELSE
            Log    [INFO] VAT percentage is correct: ${vatpercent}
        END
    END


*** Test Cases ***
Loop all invoicerows
    # Loop through all elementis in row list
    FOR    ${element}    IN    @{rows}
        Log    ${element}
        
        # Read all different values as an element from CSV row to items-list
        @{items}=    Split String    ${element}    ;

        # Invoice number can be found from index 7
        ${rowInvoiceNumber}=    Set Variable    ${items}[7]

        Log    ${rowInvoiceNumber}
        Log    ${InvoiceNumber}

        # Process diagram shows that first we need to check if our invoice number is changing
        IF    '${rowInvoiceNumber}' == '${InvoiceNumber}'
            Log    Let's add rows to the invoice
            
            # Add data to global list using own keyword
            Add Row Data to List    ${items}

        ELSE
            # If invoice number changes, we need to check if there are rows going to database
            Log    We need to check if there are already rows in the database list
            ${length}=    Get Length    ${ListToDB}
            IF    ${length} == ${0}
                Log    The case of the first invoice
                # update invoice number to be handled and set as global
                ${InvoiceNumber}=    Set Variable    ${rowInvoiceNumber}
                Set Global Variable    ${InvoiceNumber}

                # Add data to global list using own keyword
                Add Row Data to List    ${items}
            ELSE
                Log    The invoice changes, the header data must also be processed
                # If invoice is changing we need to find header data
                FOR    ${headerElement}    IN    @{headers}
                    ${headerItems}=    Split String    ${headerElement}    ;
                    IF    '${headerItems}[0]' == '${InvoiceNumber}'
                        Log    The invoice was found

                        # TODO: Validations!

                        # Add header data to database using own keyword
                        Add Invoice Header To DB    ${headerItems}    ${ListToDB}

                        # Add row data to database using own keyword
                        FOR    ${rowElement}    IN    @{ListToDB}
                            Add Invoice Row To DB    ${rowElement}
                        END                
                    END
                    
                END            
               

                # Set process for new round
                @{ListToDB}    Create List
                Set Global Variable    ${ListToDB}
                ${InvoiceNumber}=    Set Variable    ${rowInvoiceNumber}
                Set Global Variable    ${InvoiceNumber}

                # Add data to global list using own keyword
                Add Row Data to List    ${items}
            END


        END

    END

    # Case for last invoice
    ${length}=    Get Length    ${ListToDB}
    IF    ${length} > ${0}
        Log    Last invoice header processing
        # Find invoice header
        FOR    ${headerElement}    IN    @{headers}
            ${headerItems}=    Split String    ${headerElement}    ;
            IF    '${headerItems}[0]' == '${InvoiceNumber}'
                Log    invoice was found

                # Add header data to database using own keyword
                Add Invoice Header To DB    ${headerItems}    ${ListToDB}

                # Add row data to database using own keyword
                FOR    ${rowElement}    IN    @{ListToDB}
                    Add Invoice Row To DB    ${rowElement}
                END                
            END
            
        END
    END