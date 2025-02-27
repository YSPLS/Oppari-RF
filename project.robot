*** Settings ***

Library    OperatingSystem
Library    String
Library    Collections
Library    DatabaseLibrary

*** Variables ***

${PATH}    C:\\
# Polku jokaisella erilainen

# Database Variables
${dbname}    rpakurssi
${dbuser}    robotuser
${dbpassword}    ---
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