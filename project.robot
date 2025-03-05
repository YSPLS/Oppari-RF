*** Settings ***

Library    OperatingSystem
Library    String
Library    Collections
Library    DatabaseLibrary

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
    ${insertStmt}=    Set Variable    INSERT INTO invoiceheader(invoicenumber, companyname, companycode, referencenumber, invoicedate,duedate, bankaccountnumber, amountexclvat, vat, totalamount, invoicestatus_id, comments)values('${items}[0]','${items}[1]','${items}[5]','${items}[2]','2001-01-01', '2001-01-01','${items}[6]',0,0,0,-1, 'processing');
    Log    ${insertStmt}
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