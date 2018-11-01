*** Settings ***
Library     Selenium2Library    screenshot_root_directory=./screenshot    timeout=10
Library    Collections
Library    String
Test Setup    Open KKBOX Web Player
Test Teardown     close all browsers
Library    ./lib.py    WITH NAME    lib
*** Variables ***
${BROWSER}    chrome
${WEB_PLAYER_URL}    https://play.kkbox.com
#login information------------------------------------------------------------------------------------
${USER}    test@gmail.com
${PW}    password
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
${AD_CLOSE}    xpath=(.//*[normalize-space(text()) and normalize-space(.)='這歌目前還沒有歌詞'])[1]/following::img[1]
${FIRST_ARTIST}    xpath=//*[@class="cards artists"]/child::li
${FIRST_PLAYLIST}    xpath=//*[@class="cards"]/child::li
${FIRST_SONG}    xpath=//*[@ng-class="{'playing' : app.checkPlayingSong(song.song_id)}"]
${EMPTY_NOTIFY}    xpath=//*[@class="cg-notify-message alert-info cg-notify-message-center"]
${CLOSE_EMPTY_NOTIFY}    xpath=(.//*[normalize-space(text()) and normalize-space(.)='請輸入關鍵字'])[1]/following::span[1]
#-------------------------------------------------------------------------------------------------------
${HAS_RESULT}    ${true}
${HAS_NO_RESULT}    ${false}
${INPUT_KEYWORD_AT_URL_TO_VERIFY_RESULT}    ${false}
${NOT_INPUT_KEYWORD_AT_URL_TO_VERIFY_RESULT}    ${true}
${TEST_SEARCH_COUNTER}    1
${SEARCH_RESULT_PROMPT}    您搜尋的關鍵字為
${NOT_FOUND_MESSAGE}    很抱歉，找不到您要瀏覽的網頁！Page Not Found
${MAX_ARTIST_IN_ROOT}    5
${MAX_SONG_IN_ROOT}    10
${MAX_PLAYLIST_IN_ROOT}    5
${ROOT_FIRST_RESULT}    {'artist': '', 'song': '', 'playlist': ''}
${ROOT_RESULTS_COUNT}    {'artist': 0, 'song': 0, 'playlist': 0}



*** Keywords ***
Open KKBOX Web Player
    Set Suite Variable    ${TEST_SEARCH_COUNTER}    1
    Open Browser    ${WEB_PLAYER_URL}    ${BROWSER}     alias=webPlayer

Close AD
    Click Element    ${AD_CLOSE}

Login Web Player
    Wait Until Element Is Visible    ${USER_BAR}
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
    [Return]    ${resultTypeList}

Click Empty Space To GoBack
    ${width}    ${height}    Get Element Size    ${BACK}
    Click Element At Coordinates    ${BACK}    -${width/2-1}    0

Get Xpath Of Result By Type
    [Arguments]    ${type}
    ${xpath}    Set Variable If
    ...    '${type}' == 'artist'    ${FIRST_ARTIST}
    ...    '${type}' == 'song'    ${FIRST_SONG}
    ...    '${type}' == 'playlist'    ${FIRST_PLAYLIST}
    [Return]    ${xpath}

Get Xpath Of More Button By Type
    [Arguments]    ${type}
    ${button}    Set Variable If
    ...    '${type}' == 'artist'    ${MORE_ARTIST_BUTTON}
    ...    '${type}' == 'song'    ${MORE_SONG_BUTTON}
    ...    '${type}' == 'playlist'    ${MORE_PLAYLIST_BUTTON}
    [Return]    ${button}

First Result Should Be Same As Root Search Page
    [Arguments]    ${type}
    ${xpath}    Get Xpath Of Result By Type    ${type}
    ${rootFirstValue}    Set Variable    ${ROOT_FIRST_RESULT['${type}']}
    ${currentFirstValue}    Get Text    ${xpath}[1]
    Should Be Equal As Strings    ${rootFirstValue}    ${currentFirstValue}

Get Maximium Value Root Can Show By Type
    [Arguments]    ${type}
    ${max}    Set Variable If
    ...    '${type}' == 'artist'    ${MAX_ARTIST_IN_ROOT}
    ...    '${type}' == 'song'    ${MAX_SONG_IN_ROOT}
    ...    '${type}' == 'playlist'    ${MAX_PLAYLIST_IN_ROOT}
    [RETURN]    ${max}

Check More Content
    [Arguments]    ${type}    ${pattern}
    ${button}    Get Xpath Of More Button By Type    ${type}
    ${count}    Set Variable    ${ROOT_RESULTS_COUNT['${type}']}
    ${max}    Get Maximium Value Root Can Show By Type    ${type}
    Should Be Equal As Numbers    ${count}    ${max}
    Click Element    ${button}
    Wait Until Element Is Visible    ${MORE_FRAMER}
    Location Should Contain    ${type}
    Element Should Be Visible    ${RESULT_FRAMER}
    First Result Should Be Same As Root Search Page    ${type}
    Capture Page Screenshot    ${TEST_SEARCH_COUNTER}_more_${type}.png
    Click Empty Space To GoBack
    Run Keyword And Ignore Error    Wait Until Element Is Not Visible    ${MORE_FRAMER}

Check Result By Input Keyword At Url 
    [Arguments]    ${result_exist}    ${type}    ${pattern}    ${notTestUrlSearch}
    ${xpath}    Get Xpath Of Result By Type    ${type}
    Return From Keyword If    ${notTestUrlSearch}
    ${url_keyword}    Get Keyword From Url
    Open Browser    ${WEB_PLAYER_URL}/search/${type}/${url_keyword}    ${BROWSER}
    Login Web Player
    Wait Until Page Contains    ${SEARCH_RESULT_PROMPT} ${pattern}
    Capture Page Screenshot    ${TEST_SEARCH_COUNTER}_url_${type}.png
    Run Keyword If    ${result_exist}    Element Should Be Visible    ${xpath}
    ...    ELSE    Element Should Not Be Visible    ${xpath}
    Run Keyword If    ${result_exist}    First Result Should Be Same As Root Search Page    ${type}
    Close Browser
    Switch Browser    webPlayer

Check Search By Type
    [Arguments]    ${type}   ${typeExist}    ${pattern}    ${notTestUrlSearch}
    Run Keyword If    ${typeExist}['${type}Button']    Check More Content    ${type}    ${pattern}
    Check Result By Input Keyword At Url    ${HAS_RESULT}    ${type}    ${pattern}    ${notTestUrlSearch}

Set Root Page Result To Suite Variable By Type
    [Arguments]    ${type}
    ${xpath}    Get Xpath Of Result By Type    ${type}
    ${res}    Get Text    ${xpath}[1]
    ${count}    Get Element Count    ${xpath}
    Set Suite Variable    ${ROOT_FIRST_RESULT['${type}']}    ${res}
    Set Suite Variable    ${ROOT_RESULTS_COUNT['${type}']}    ${count}   

Get Root Page Result Of Each Exist Type
    [Arguments]    ${existDict}
    Run Keyword If    ${existDict}['artist']    Set Root Page Result To Suite Variable By Type    artist 
    Run Keyword If    ${existDict}['song']    Set Root Page Result To Suite Variable By Type    song
    Run Keyword If    ${existDict}['playlist']    Set Root Page Result To Suite Variable By Type    playlist

Counter Plus For Screenshot
    ${res}    Evaluate    ${TEST_SEARCH_COUNTER} + 1
    Set Suite Variable    ${TEST_SEARCH_COUNTER}    ${res}     

Examine Search Function
    [Arguments]    ${pattern}    ${notTestUrlSearch}
    ${resultTypeList}    Get Type of Search Results
    ${existDict}    lib.checkIfTypeExist    ${resultTypeList}
    Get Root Page Result Of Each Exist Type    ${existDict}
    Run Keyword If    ${existDict}['artist']    Check Search By Type    artist    ${existDict}    ${pattern}    ${notTestUrlSearch}
    ...    ELSE    Check Result By Input Keyword At Url    ${HAS_NO_RESULT}    artist    ${pattern}    ${notTestUrlSearch}

    Run Keyword If    ${existDict}['song']    Check Search By Type    song    ${existDict}    ${pattern}    ${notTestUrlSearch}
    ...    ELSE    Check Result By Input Keyword At Url    ${HAS_NO_RESULT}    song    ${pattern}    ${notTestUrlSearch}

    Run Keyword If    ${existDict}['playlist']    Check Search By Type    playlist    ${existDict}    ${pattern}    ${notTestUrlSearch}
    ...    ELSE    Check Result By Input Keyword At Url    ${HAS_NO_RESULT}    playlist    ${pattern}    ${notTestUrlSearch} 
    Counter Plus For Screenshot
  

Test Search Function By Input
    [Arguments]    ${pattern}    ${notTestUrlSearch}
    Wait Until Element Is Visible    ${SEARCH_BAR}
    Input Text     ${SEARCH_BAR}    ${pattern}
    Click Element    ${SEARCH_BUTTON}
    Url Keyword Should Same As Input After Decode    ${pattern}
    Wait Until Page Contains    ${SEARCH_RESULT_PROMPT} ${pattern}
    Capture Page Screenshot    ${TEST_SEARCH_COUNTER}_root.png
    Examine Search Function    ${pattern}    ${notTestUrlSearch}

Search Empty String
    Wait Until Element Is Visible    ${SEARCH_BAR}
    ${urlBefore}    Get Location
    Clear Element Text    ${SEARCH_BAR}
    Click Element    ${SEARCH_BUTTON}
    Element Should Be Visible    ${EMPTY_NOTIFY}
    Capture Page Screenshot    input_empty_test.png
    Click Element    ${CLOSE_EMPTY_NOTIFY}
    ${urlAfter}    Get Location
    Should Be Equal As Strings    ${urlBefore}    ${urlAfter}

Search Space Only String
    Wait Until Element Is Visible    ${SEARCH_BAR}
    ${urlBefore}    Get Location
    Input Text     ${SEARCH_BAR}    ${SPACE}${SPACE}${SPACE}${SPACE}
    Click Element    ${SEARCH_BUTTON}
    Element Should Be Visible    ${EMPTY_NOTIFY}
    Capture Page Screenshot    input_space_test.png
    Click Element    ${CLOSE_EMPTY_NOTIFY}
    ${urlAfter}    Get Location
    Should Be Equal As Strings    ${urlBefore}    ${urlAfter}

Expect Page Not Found
    [Arguments]    ${pattern}
    Wait Until Element Is Visible    ${SEARCH_BAR}
    Input Text     ${SEARCH_BAR}    ${pattern}
    Click Element    ${SEARCH_BUTTON}
    Wait Until Page Contains    ${NOT_FOUND_MESSAGE}
    Capture Page Screenshot    ${TEST_SEARCH_COUNTER}_page_not_found_test.png
    Location Should Contain    ${WEB_PLAYER_URL}/404
    Counter Plus For Screenshot

*** Test Cases ***
Search Test
    [Tags]    normal
    Login Web Player
    Test Search Function By Input    檸檬樹    ${INPUT_KEYWORD_AT_URL_TO_VERIFY_RESULT}
    Test Search Function By Input    SHE    ${INPUT_KEYWORD_AT_URL_TO_VERIFY_RESULT}
    Test Search Function By Input    fly me to the moon    ${INPUT_KEYWORD_AT_URL_TO_VERIFY_RESULT}
    Test Search Function By Input    二人暮らし    ${INPUT_KEYWORD_AT_URL_TO_VERIFY_RESULT}
    Test Search Function By Input    %%    ${NOT_INPUT_KEYWORD_AT_URL_TO_VERIFY_RESULT}
    Test Search Function By Input    %64    ${NOT_INPUT_KEYWORD_AT_URL_TO_VERIFY_RESULT}
    Test Search Function By Input    ??    ${NOT_INPUT_KEYWORD_AT_URL_TO_VERIFY_RESULT}
    Test Search Function By Input    !!    ${NOT_INPUT_KEYWORD_AT_URL_TO_VERIFY_RESULT}

Input Is Needed Notifitation Test
    [Tags]    empty
    Login Web Player
    Search Empty String
    Search Space Only String

Page Not Found Test
    [Tags]    404
    Login Web Player
    Expect Page Not Found    /
    Expect Page Not Found    /989