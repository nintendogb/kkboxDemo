*** Settings ***
Library     Selenium2Library
Library    Collections
Test Setup    Open KKBOX Web Player
Test Teardown     close all browsers
Library    ./lib.py    WITH NAME    lib
*** Variables ***
${USER}    test@gmail.com
${PW}    password
${USER_BAR}    id=uid
${PW_BAR}    id=pwd
${SEARCH_BAR}    xpath=//*[@id="search_form"]/input
${LOGIN_BUTTON}    id=login-btn
${SEARCH_BUTTON}    xpath=//*[@id="search_btn_cnt"]/i
${REFRESH_TIMEOUT}    10
${SEARCH_RESULT_PROMPT}    您搜尋的關鍵字為
${RESULT_FRAMER}    xpath=//*[@class="results"]
${MORE_ARTIST_BUTTON}    //*[@ng-click="app.go('search/artist', {keyword:search.keyword})"]
${MORE_SONG_BUTTON}    //*[@ng-click="app.go('search/song', {keyword:search.keyword})"]
${MORE_PLAYLIST_BUTTON}    //*[@ng-click="app.go('search/playlist', {keyword:search.keyword})"]
#${BACK}    //*[@class="results"][last()]/div[1]
${BACK}    //*[@class="main-content"]/following::div[1]

*** Keywords ***
Open KKBOX Web Player
    Open Browser    https://play.kkbox.com/    chrome     alias=webPlayer

Login Web Player
    Wait Until Element Is Visible    ${USER_BAR}    timeout=${REFRESH_TIMEOUT}
    Input Text    ${USER_BAR}    ${USER}
    Input Text    ${PW_BAR}    ${PW}
    Click Element    ${LOGIN_BUTTON}

Check If Url Keyword Is Same As Input
    [Arguments]    ${pattern}
    ${url}    Get Location
    ${res}    lib.getValueFromUrlForWebPlayer    ${url}
    Should Be Equal As Strings    ${res}    ${pattern}

Get Type of Search Results
    ${count}    Get Element Count    ${RESULT_FRAMER}
    ${resultTypeList}    Create List
    :FOR    ${i}    IN RANGE    1     ${count} + 1
    \    ${tmp}    Get Text     ${RESULT_FRAMER}[${i}]//h2
    \    Append To List    ${resultTypeList}    ${tmp}
    Log       ${resultTypeList}
    [Return]    ${resultTypeList}

Test Click More
    [Arguments]    ${type}    ${pattern}
    ${button}    Set Variable If
    ...    '${type}' == 'artist'    ${MORE_ARTIST_BUTTON}
    ...    '${type}' == 'song'    ${MORE_SONG_BUTTON}
    ...    '${type}' == 'playlist'    ${MORE_PLAYLIST_BUTTON}

    Click Element    ${button}
    Wait Until Page Contains    ${SEARCH_RESULT_PROMPT} ${pattern}    timeout=${REFRESH_TIMEOUT}
    Click Element At Coordinates    ${BACK}    5    5
    Sleep    1

Test Search By Type
    [Arguments]    ${type}   ${typeExist}    ${pattern}
    Run Keyword If    ${typeExist}['${type}Button']    Test Click More    ${type}    ${pattern}


Test Search Function
    [Arguments]    ${pattern}
    Wait Until Element Is Visible    ${SEARCH_BAR}    timeout=${REFRESH_TIMEOUT}
    Input Text     ${SEARCH_BAR}    ${pattern}
    Click Element    ${SEARCH_BUTTON}
    Check If Url Keyword Is Same As Input    ${pattern}
    Wait Until Page Contains    ${SEARCH_RESULT_PROMPT} ${pattern}    timeout=${REFRESH_TIMEOUT}
    Capture Page Screenshot
    ${resultTypeList}    Get Type of Search Results
    ${existDict}    lib.checkIfTypeExist    ${resultTypeList}
    Run Keyword If    ${existDict}['artist']    Test Search By Type    artist    ${existDict}    ${pattern}  
    Run Keyword If    ${existDict}['song']    Test Search By Type    song    ${existDict}    ${pattern}  
    Run Keyword If    ${existDict}['playlist']    Test Search By Type    playlist    ${existDict}    ${pattern}  
    


    
*** Test Cases ***
Search Test
    Login Web Player
    Test Search Function    檸檬樹
    Test Search Function    %%
    Test Search Function    %64
