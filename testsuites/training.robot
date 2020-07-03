*** Settings ***
Library                      RequestsLibrary
Library                      OperatingSystem
Library                      String

Suite Setup                   Get Access Token  ABC    P@ssW@rd   200

*** Variable ***
${backend_url}               https://demo5460031.mockable.io
${token_path}                /token
${order_path}                /orders
${order_failed_path}         /orders/failed
${test_path}                 /test
${template_order_payload}    testdata/json/testdata_orders_api.json

*** Test Cases ***
TC01
    [Documentation]     Ensure that user can create the orders successfully
    ...     - Expected response code = 201 Created
    Comment  =========== Test Data ===================
    ${price}        Set Variable   300
    ${amount}       Set Variable   100
    ${side}         Set Variable   buy
    ${symbol}       Set Variable   PTTBK
    ${order_type}   Set Variable   limit
    Comment  =========== Test step ===================

	# Get Access Token   ABC    P@ssW@rd   200
	Create orders payload  ${symbol}  ${side}  ${price}  ${amount}  ${order_type}
    Create Order API       ${order_path}     ${access_token}   ${request_body}   201
    Validate Response Message   201  successful

TC02
    [Documentation]     Ensure that user can create the orders successfully
    ...     - Expected response code = 201 Created
    Comment  =========== Test Data ===================
    ${price}        Set Variable   300
    ${amount}       Set Variable   100
    ${side}         Set Variable   sell
    ${symbol}       Set Variable   PTTBK
    ${order_type}   Set Variable   limit
    Comment  =========== Test step ===================

	# Get Access Token  ABC    P@ssW@rd   200
	Create orders payload  ${symbol}  ${side}  ${price}  ${amount}  ${order_type}
    Create Order API       ${order_failed_path}     ${access_token}   ${request_body}   400
    Validate Response Message   400  Price has too many decimal places

TC03
    [Tags]  test
    Get Order API       ${test_path}   200
    Validate Response Message   200  Hello World.

*** Keywords ***
Get Access Token
    [Arguments]  ${username}  ${password}  ${expected_resp_status}
    #------ Request Preparation
    ${alias}    Set Variable   token
    ${url}      Set Variable   ${backend_url}
    ${path}     Set Variable   ${token_path}
    ${headers}  Create Dictionary   Content-Type=application/json  
    ${data}     Create Dictionary   username=${username}  password=${password}
    Create Session   ${alias}  ${url}  ${headers}  verify=True
    ${resp}   Post Request  ${alias}   ${path}   data=${data}  params=None  headers=${headers}
    #------- Response data
    Should Be Equal As Strings  ${expected_resp_status}  ${resp.status_code}
    ${request_json}   Set Variable  ${resp.json()}
    Log   ${request_json}
    ${access_token}   Set Variable   ${request_json}[result][access_token]
    Log   ${access_token}
    Set Global Variable   ${access_token}  ${access_token}

Create Orders payload
    [Arguments]    ${market_symbol}  ${side}   ${price}   ${amount}  ${order_type}
    ${request_body}   Get File   ${template_order_payload}
    ${request_body}   Replace String    ${request_body}   VAR_SYMBOL   ${market_symbol}
    ${request_body}   Replace String    ${request_body}   VAR_SIDE   ${side}
    ${request_body}   Replace String    ${request_body}   VAR_PRICE   ${price}
    ${request_body}   Replace String    ${request_body}   VAR_ORDER_TYPE   ${order_type}
    ${request_body}   Replace String    ${request_body}   VAR_AMOUNT   ${amount}
    Log   ${request_body}
    Set Test Variable  ${request_body}  ${request_body}

Create Order API          
    [Arguments]  ${order_path}  ${access_token}  ${request_body}  ${expected_response}
    #------ Request Preparation
    ${alias}    Set Variable   orders
    ${url}      Set Variable   ${backend_url}
    ${path}     Set Variable   ${order_path}
    ${headers}  Create Dictionary   Content-Type=application/json  
    ...                             Authorization=bearer ${access_token}
    ${data}     Set Variable   ${request_body}
    Create Session   ${alias}  ${url}  ${headers}  verify=True
    ${resp}   Post Request  ${alias}   ${path}   data=${data}  params=None  headers=${headers}
    #------- Response data
    Should Be Equal As Strings  ${expected_response}  ${resp.status_code}
    ${request_json}   Set Variable  ${resp.json()}
    Log   ${request_json}
    Set Test Variable   ${request_json}  ${request_json}

Validate Response Message
    [Arguments]  ${expected_resp_status}   ${expected_resp_message}
    Run Keyword If  '${expected_resp_status}'=='200'
    ...              Should Be Equal   '${expected_resp_message}'   '${request_json}[msg]'
    Run Keyword If  '${expected_resp_status}'=='201'
    ...              Should Be Equal   '${expected_resp_message}'   '${request_json}[result][message]'
    Run Keyword If  '${expected_resp_status}'=='400'
    ...              Should Be Equal   '${expected_resp_message}'   '${request_json}[error][message]'
    # ${resp_error_list}   Set Variable If  '${expected_response}'=='400'  ${t_resp_json}[errors]
    # Run Keyword If  '${expected_response}'=='400'  Extract Error Message  ${resp_error_list}

Get Order API
    [Arguments]  ${test_path}   ${expected_resp_status}
    #------ Request Preparation
    ${alias}    Set Variable   test
    ${url}      Set Variable   ${backend_url}
    ${path}     Set Variable   ${test_path}
    ${headers}  Create Dictionary   Content-Type=application/json  
    Create Session   ${alias}  ${url}  ${headers}  verify=True
    ${resp}   Get Request  ${alias}   ${path}   data=None  params=None  headers=${headers}
    #------- Response data
    Should Be Equal As Strings  ${expected_resp_status}  ${resp.status_code}
    ${request_json}   Set Variable  ${resp.json()}
    Log   ${request_json}
    Set Test Variable   ${request_json}  ${request_json}