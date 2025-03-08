*** Settings ***

Library    OperatingSystem
Library    String
Library    Collections
Library    DatabaseLibrary
Library    DateTime

*** Variables ***

${PATH}    ${CURDIR}/
# Polku jokaisella erilainen

# Database Variables
${dbname}    rpakurssi
${dbuser}    robotuser
${dbpassword}    password
${dbhost}    localhost
${dbport}    3306

*** Keywords ***
Make connection
    [Arguments]    ${dbconnect}
    Connect To Database    pymysql    ${dbconnect}    ${dbuser}    ${dbpassword}    ${dbhost}    ${dbport}
*** Keywords ***
Add Invoice Header to DB
    [Arguments]    ${items}
    Make connection    ${dbname}

    ${invoiceDate}=    Convert Date    ${items}[3]    date_format=%d.%m.%Y    result_format=%Y.%m.%d
    ${dueDate}=    Convert Date    ${items}[4]    date_format=%d.%m.%Y    result_format=%Y.%m.%d

    ${insertStmt}=    Set Variable    INSERT INTO invoiceheader(invoicenumber, companyname, companycode, referencenumber, invoicedate,duedate, bankaccountnumber, amountexclvat, vat, totalamount, invoicestatus_id, comments)values('${items}[0]','${items}[1]','${items}[5]','${items}[2]','${invoiceDate}', '${dueDate}','${items}[6]',${items}[7],${items}[8],${items}[9],-1, 'processing');
    Log    ${insertStmt}
    Execute Sql String    ${insertStmt}
    Disconnect From Database


*** Keywords ***
Add Invoice Row to DB
    [Arguments]    ${items}
    Make connection    ${dbname}

    ${insertStmt}=    Set Variable    insert into invoicerow(invoicenumber, rownumber, description, quantity, unit, unitprice, vatpercent, vat, total) values ('${items}[7]','${items}[8]','${items}[0]','${items}[1]','${items}[2]','${items}[3]','${items}[4]','${items}[5]','${items}[6]')
    Execute Sql String    ${insertStmt}
    Disconnect From Database
    
*** Tasks ***

Read CSV file to list and add to database
    Make connection    ${dbname}
    ${outputHeader}=    Get File    ${PATH}InvoiceHeaderData.csv
    ${outputRows}=    Get File    ${PATH}InvoiceRowData.csv
    Log    ${outputHeader}
    Log    ${outputRows}

    #Row row row

    @{headers}=    Split String    ${outputHeader}    \n
    @{Rows}=    Split String    ${outputRows}    \n

    #cleanup

    ${Length}=    Get Length    ${headers}
    ${Length}=    Evaluate    ${Length}-1
    ${index}=    Convert To Integer     0
    Remove From List    ${headers}    ${Length}
    Remove From List    ${headers}    ${index}

    ${Length}=    Get Length    ${Rows}
    ${Length}=    Evaluate    ${Length}-1
    ${index}=    Convert To Integer     0
    Remove From List    ${Rows}    ${Length}
    Remove From List    ${Rows}    ${index}

    Log    ${Rows}
    Log    ${headers}

    ###New database shit

    FOR    ${headersElement}    IN    @{headers}
        @{HeadersItem}=    Split String    ${headersElement}    ;
        Log    ${HeadersItem}
        Add Invoice Header to DB    ${HeadersItem}
    END

    ##Rowdata
    FOR    ${rowElement}    IN    @{Rows}
        Log    ${rowElement}
        @{rowItems}=    Split String    ${rowElement}    ;

        Add Invoice Row to DB    ${rowItems}
        
    END

*** Tasks ***
Validation

    Make connection    ${dbname}

    ${Invoices}=    Query    select invoicenumber, referrencenumber, bankaccountnumber, totalamount from invoiceheader where invoicestatus_id = 1; 
    FOR    ${element}    IN    @{Invoices}
        Log    ${element}
        ${invoiceStatus}=    Set Variable    0
        ${InvoiceComment}=    Set Variable    All ok


        @{params}=    Create List    ${invoiceStatus}    ${InvoiceComment}    ${element}[0]
        ${updateStmt}=    Set Variable    update invoiceheader set invoicestatus_id = %s, comments = %s where invoicenumber = %s;
        Execute Sql String    ${updateStmt}    parameters=${params}
    END