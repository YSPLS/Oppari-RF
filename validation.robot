*** Settings ***
Library    validate.py
Library    String

*** Keywords ***
Check amount from invoice
    [Arguments]    ${TotalSumFromHeaders}    ${TotalSumFromRows}
    ${status}=    Set Variable    ${False}

    ${TotalSumFromHeaders}=    Convert To Number    ${TotalSumFromHeaders}
    ${TotalSumFromRows}=    Convert To Number    ${TotalSumFromRows}
    ${diff}=    Convert To Number    0.01
    ${status}=    Is Equal    ${TotalSumFromHeaders}    ${TotalSumFromRows}    ${diff}

    RETURN    ${status}

*** Keywords ***
Check IBAN
    [Arguments]    ${iban}
    ${status}=    Set Variable    ${False}
    ${iban}=    Remove String    ${iban}    ${SPACE}
    ${lenght}=    Get Length    ${iban}
    IF    ${lenght} == 18
        ${status}    Set Variable    ${True}
    END
    RETURN     ${status}

*** Tasks ***
testi
    ${sumstatus}=    Check amount from invoice    33    33.01

    IF    ${sumstatus}
        Log    Summat täsmää
    ELSE
        Log    Summat eivät ole samat
    END
    
    ${ibanValue}=    Set Variable    FI12 3456 7890 1234 56
    ${ibancheck}=    Check IBAN    ${ibanValue}

    IF    ${ibancheck}
        Log     IBAN ok
    ELSE
        Log    Huono IBAN
    END