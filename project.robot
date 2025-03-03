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

*** Tasks ***

Read CSV file to list
    Make connection    ${dbname}
    ${outputHeader}=    Get File    ${PATH}InvoiceHeaderData.csv
    ${outputRows}=    Get File    ${PATH}InvoiceRowData.csv
    Log    ${outputHeader}
    Log    ${outputRows}

    #Row row row

    @{headers}=    Split String    ${outputHeader} \n
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