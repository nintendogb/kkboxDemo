*** Settings ***
Library     Selenium2Library
Library    Collections
Library    String
Test Setup    Open KKBOX Web Player
Test Teardown     close all browsers
Library    ./lib.py    WITH NAME    lib
*** Variables ***
#login information------------------------------------------------------------------------------------
${USER}    test@gmail.com
${PW}    password

${REFRESH_TIMEOUT}    10
#Element location--------------------------------------------------------------------------------------
${USER_BAR}    id=uid
${PW_BAR}    id=pwd
${SEARCH_BAR}    xpath=//*[@id="search_form"]/input

${LOGIN_BUTTON}    id=login-btn
${SEARCH_BUTTON}    xpath=//*[@id="search_btn_cnt"]/i
${MORE_ARTIST_BUTTON}    xpath=//*[@ng-click="app.go('search/artist', {keyword:search.keyword})"]
${MORE_SONG_BUTTON}    xpath=//*[@ng-click="app.go('search/song', {keyword:search.keyword})"]
${MORE_PLAYLIST_BUTTON}    xpath=//*[@ng-click="app.go('search/playlist', {keyword:search.keyword})"]


${RESULT_FRAMER}    xpath=//*[@class="results"]
${MORE_FRAMER}    xpath=//*[@class="search-more-framer"]

${BACK}    xpath=//*[@class="main-content"]/following::div[1]
${AD_CLOSE}    xpath=//*[@class="close"]
#-------------------------------------------------------------------------------------------------------
${SHOULD_EXIST}    ${true}
${SHOULD_NOT_EXIST}    ${false}
${TEST_SEARCH_BY_URL}    ${false}
${NOT_TEST_SEARCH_BY_URL}    ${true}
${SEARCH_RESULT_PROMPT}    您搜尋的關鍵字為
*** Keywords ***
Open KKBOX Web Player
    Open Browser    https://play.kkbox.com/    chrome     alias=webPlayer

Close AD
    Click Element    ${AD_CLOSE}

Login Web Player
    Wait Until Element Is Visible    ${USER_BAR}    timeout=${REFRESH_TIMEOUT}
    Input Text    ${USER_BAR}    ${USER}
    Input Text    ${PW_BAR}    ${PW}
    Click Element    ${LOGIN_BUTTON}
    Run Keyword And Ignore Error   Close AD 


Url Keyword Should Same As Input After Decode
    [Arguments]    ${pattern}
    ${url}    Get Location
    ${res}    lib.getDecodeValueFromUrlForWebPlayer    ${url}
    Should Be Equal As Strings    ${res}    ${pattern}

Get Keyword From Url
    ${url}    Get Location
    ${url_keyword}    Fetch From Right    ${url}    /
    [Return]    ${url_keyword}

Get Type of Search Results
    ${count}    Get Element Count    ${RESULT_FRAMER}
    ${resultTypeList}    Create List
    :FOR    ${i}    IN RANGE    1     ${count} + 1
    \    ${tmp}    Get Text     ${RESULT_FRAMER}[${i}]//h2
    \    Append To List    ${resultTypeList}    ${tmp}
    Log       ${resultTypeList}
    [Return]    ${resultTypeList}

Click Empty Space To GoBack
    ${width}    ${height}    Get Element Size    ${BACK}
    Click Element At Coordinates    ${BACK}    -${width/2-1}    0

Check More Content
    [Arguments]    ${type}    ${pattern}
    ${button}    Set Variable If
    ...    '${type}' == 'artist'    ${MORE_ARTIST_BUTTON}
    ...    '${type}' == 'song'    ${MORE_SONG_BUTTON}
    ...    '${type}' == 'playlist'    ${MORE_PLAYLIST_BUTTON}

    Click Element    ${button}
    Wait Until Element Is Visible    ${MORE_FRAMER}    timeout=${REFRESH_TIMEOUT}
    Location Should Contain    ${type}
    Element Should Be Visible    ${RESULT_FRAMER}
    Capture Page Screenshot
    Click Empty Space To GoBack
    Wait Until Element Is Not Visible    ${MORE_FRAMER}    timeout=${REFRESH_TIMEOUT}  

Check Result Of Url Search 
    [Arguments]    ${result_exist}    ${type}    ${pattern}    ${notTestUrlSearch}
    Return From Keyword If    ${notTestUrlSearch} 
    ${url_keyword}    Get Keyword From Url
    Open Browser    https://play.kkbox.com/search/${type}/${url_keyword}    chrome
    Login Web Player
    Wait Until Page Contains    ${SEARCH_RESULT_PROMPT} ${pattern}    timeout=${REFRESH_TIMEOUT}
    Capture Page Screenshot
    Run Keyword If    ${result_exist}    Element Should Be Visible    ${RESULT_FRAMER}
    ...    ELSE    Element Should Not Be Visible    ${RESULT_FRAMER}
    Close Browser
    Switch Browser    webPlayer



Test Search By Type
    [Arguments]    ${type}   ${typeExist}    ${pattern}    ${notTestUrlSearch}
    Run Keyword If    ${typeExist}['${type}Button']    Check More Content    ${type}    ${pattern}
    Check Result Of Url Search    ${SHOULD_EXIST}    ${type}    ${pattern}    ${notTestUrlSearch}


Test Search Function
    [Arguments]    ${pattern}    ${notTestUrlSearch}
    Wait Until Element Is Visible    ${SEARCH_BAR}    timeout=${REFRESH_TIMEOUT}
    Input Text     ${SEARCH_BAR}    ${pattern}
    Click Element    ${SEARCH_BUTTON}
    Url Keyword Should Same As Input After Decode    ${pattern}
    Wait Until Page Contains    ${SEARCH_RESULT_PROMPT} ${pattern}    timeout=${REFRESH_TIMEOUT}
    Capture Page Screenshot
    ${resultTypeList}    Get Type of Search Results
    ${existDict}    lib.checkIfTypeExist    ${resultTypeList}
    Run Keyword If    ${existDict}['artist']    Test Search By Type    artist    ${existDict}    ${pattern}    ${notTestUrlSearch}
    ...    ELSE    Check Result Of Url Search    ${SHOULD_NOT_EXIST}    artist    ${pattern}    ${notTestUrlSearch}    
    Run Keyword If    ${existDict}['song']    Test Search By Type    song    ${existDict}    ${pattern}    ${notTestUrlSearch}
    ...    ELSE    Check Result Of Url Search    ${SHOULD_NOT_EXIST}    song    ${pattern}    ${notTestUrlSearch}
    Run Keyword If    ${existDict}['playlist']    Test Search By Type    playlist    ${existDict}    ${pattern}    ${notTestUrlSearch}
    ...    ELSE    Check Result Of Url Search    ${SHOULD_NOT_EXIST}    playlist    ${pattern}    ${notTestUrlSearch}  
    


    
*** Test Cases ***
Search Test
    Login Web Player
    Test Search Function    檸檬樹    ${TEST_SEARCH_BY_URL}
    Test Search Function    SHE    ${TEST_SEARCH_BY_URL}
    Test Search Function    fly me to the moon    ${TEST_SEARCH_BY_URL}
    Test Search Function    %%    ${NOT_TEST_SEARCH_BY_URL}
    Test Search Function    %64    ${NOT_TEST_SEARCH_BY_URL}
    Test Search Function    ??    ${NOT_TEST_SEARCH_BY_URL}
    Test Search Function    ??    ${NOT_TEST_SEARCH_BY_URL}
    Test Search Function    !!    ${NOT_TEST_SEARCH_BY_URL}