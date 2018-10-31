*** Settings ***
Library     Selenium2Library    screenshot_root_directory=./screenshot    timeout=10
Library    Collections
Library    String
Test Setup    Open KKBOX Web Player
Test Teardown     close all browsers
Library    ./lib.py    WITH NAME    lib
*** Variables ***
#login information------------------------------------------------------------------------------------
${USER}    test@gmail.com
${PW}    password

#${REFRESH_TIMEOUT}    10
${SCREENSHOOT_DIR}
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
${FIRST_ARTIST}    xpath=//*[@class="cards artists"]/child::li
${FIRST_PLAYLIST}    xpath=//*[@class="cards"]/child::li
${FIRST_SONG}    xpath=//*[@ng-class="{'playing' : app.checkPlayingSong(song.song_id)}"]
${EMPTY_ALERT}    xpath=//*[@class="cg-notify-message alert-info cg-notify-message-center"]
#-------------------------------------------------------------------------------------------------------
${HAS_RESULT}    ${true}
${HAS_NO_RESULT}    ${false}
${USING_URL_KEYWORD_TO_VERIFY_RESULT}    ${false}
${NOT_USING_URL_KEYWORD_TO_VERIFY_RESULT}    ${true}
${TEST_SEARCH_COUNTER}    1
${SEARCH_RESULT_PROMPT}    您搜尋的關鍵字為
${MAX_ARTIST_IN_ROOT}    5
${MAX_SONG_IN_ROOT}    10
${MAX_PLAYLIST_IN_ROOT}    5
${ROOT_FIRST_RESULT}    {'artist': '', 'song': '', 'playlist': ''}
${ROOT_FIRST_RESULT}    {'artist': '', 'song': '', 'playlist': ''}
${ROOT_RESULTS_COUNT}    {'artist': 0, 'song': 0, 'playlist': 0}



*** Keywords ***
Open KKBOX Web Player
    Open Browser    https://play.kkbox.com/    chrome     alias=webPlayer

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

    ${count}    Set Variable    ${ROOT_RESULTS_COUNT['${type}']}
    ${max}    Set Variable If
    ...    '${type}' == 'artist'    ${MAX_ARTIST_IN_ROOT}
    ...    '${type}' == 'song'    ${MAX_SONG_IN_ROOT}
    ...    '${type}' == 'playlist'    ${MAX_PLAYLIST_IN_ROOT}

    Should Be Equal As Numbers    ${count}    ${max}

    Click Element    ${button}
    Wait Until Element Is Visible    ${MORE_FRAMER}
    Location Should Contain    ${type}
    Element Should Be Visible    ${RESULT_FRAMER}
    First Result Is Same As Root Search Page    ${type}
    Capture Page Screenshot    ${TEST_SEARCH_COUNTER}_more_${type}.png
    Click Empty Space To GoBack
    Run Keyword And Ignore Error    Wait Until Element Is Not Visible    ${MORE_FRAMER}


First Result Is Same As Root Search Page
    [Arguments]    ${type}
    ${xpath}    Set Variable If
    ...    '${type}' == 'artist'    ${FIRST_ARTIST}
    ...    '${type}' == 'song'    ${FIRST_SONG}
    ...    '${type}' == 'playlist'    ${FIRST_PLAYLIST}
    ${rootFirstValue}    Set Variable    ${ROOT_FIRST_RESULT['${type}']}
    ${currentFirstValue}    Get Text    ${xpath}[1]
    Should Be Equal As Strings    ${rootFirstValue}    ${currentFirstValue}

Check Result Of Url Search 
    [Arguments]    ${result_exist}    ${type}    ${pattern}    ${notTestUrlSearch}
    ${xpath}    Set Variable If
    ...    '${type}' == 'artist'    ${FIRST_ARTIST}
    ...    '${type}' == 'song'    ${FIRST_SONG}
    ...    '${type}' == 'playlist'    ${FIRST_PLAYLIST}
    Return From Keyword If    ${notTestUrlSearch}
    ${url_keyword}    Get Keyword From Url
    Open Browser    https://play.kkbox.com/search/${type}/${url_keyword}    chrome
    Login Web Player
    Wait Until Page Contains    ${SEARCH_RESULT_PROMPT} ${pattern}    #timeout=${REFRESH_TIMEOUT}
    Capture Page Screenshot    ${TEST_SEARCH_COUNTER}_url_${type}.png
    Run Keyword If    ${result_exist}    Element Should Be Visible    ${xpath}
    ...    ELSE    Element Should Not Be Visible    ${xpath}
    Run Keyword If    ${result_exist}    First Result Is Same As Root Search Page    ${type}
    Close Browser
    Switch Browser    webPlayer

Check Search By Type
    [Arguments]    ${type}   ${typeExist}    ${pattern}    ${notTestUrlSearch}
    Run Keyword If    ${typeExist}['${type}Button']    Check More Content    ${type}    ${pattern}
    Check Result Of Url Search    ${HAS_RESULT}    ${type}    ${pattern}    ${notTestUrlSearch}

Set Root Page Result Of Artist To Suite Variable
    ${res}    Get Text    ${FIRST_ARTIST}[1]
    ${count}    Get Element Count    ${FIRST_ARTIST}
    Set Suite Variable    ${ROOT_FIRST_RESULT['artist']}    ${res}
    Set Suite Variable    ${ROOT_RESULTS_COUNT['artist']}    ${count}

Set Root Page Result Of Song To Suite Variable
    ${res}    Get Text    ${FIRST_SONG}[1]
    ${count}    Get Element Count    ${FIRST_SONG}
    Set Suite Variable    ${ROOT_FIRST_RESULT['song']}    ${res}
    Set Suite Variable    ${ROOT_RESULTS_COUNT['song']}    ${count}         

Set Root Page Result Of Playlist To Suite Variable
    ${res}    Get Text    ${FIRST_PLAYLIST}[1]
    ${count}    Get Element Count    ${FIRST_PLAYLIST}
    Set Suite Variable    ${ROOT_FIRST_RESULT['playlist']}    ${res}
    Set Suite Variable    ${ROOT_RESULTS_COUNT['playlist']}    ${count}

Set Root Page Result To Suite Variable By Type
    [Arguments]    ${type}
    ${xpath}    Set Variable If
    ...    '${type}' == 'artist'    ${FIRST_ARTIST}
    ...    '${type}' == 'song'    ${FIRST_SONG}
    ...    '${type}' == 'playlist'    ${FIRST_PLAYLIST}
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
    ...    ELSE    Check Result Of Url Search    ${HAS_NO_RESULT}    artist    ${pattern}    ${notTestUrlSearch}    
    Run Keyword If    ${existDict}['song']    Check Search By Type    song    ${existDict}    ${pattern}    ${notTestUrlSearch}
    ...    ELSE    Check Result Of Url Search    ${HAS_NO_RESULT}    song    ${pattern}    ${notTestUrlSearch}
    Run Keyword If    ${existDict}['playlist']    Check Search By Type    playlist    ${existDict}    ${pattern}    ${notTestUrlSearch}
    ...    ELSE    Check Result Of Url Search    ${HAS_NO_RESULT}    playlist    ${pattern}    ${notTestUrlSearch} 
    
    Counter Plus For Screenshot
  

Test Search Function
    [Arguments]    ${pattern}    ${notTestUrlSearch}
    Wait Until Element Is Visible    ${SEARCH_BAR}
    Input Text     ${SEARCH_BAR}    ${pattern}
    Click Element    ${SEARCH_BUTTON}
    Url Keyword Should Same As Input After Decode    ${pattern}
    Wait Until Page Contains    ${SEARCH_RESULT_PROMPT} ${pattern}
    Capture Page Screenshot    ${TEST_SEARCH_COUNTER}_root.png
    Examine Search Function    ${pattern}    ${notTestUrlSearch}

Test Search Empty
    Wait Until Element Is Visible    ${SEARCH_BAR}
    ${urlBefore}    Get Location
    Clear Element Text    ${SEARCH_BAR}
    Click Element    ${SEARCH_BUTTON}
    Element Should Be Visible    ${EMPTY_ALERT}
    Capture Page Screenshot    input_empty_test.png
    Run Keyword And Ignore Error    Wait Until Element Is Not Visible    ${EMPTY_ALERT}
    ${urlAfter}    Get Location
    Should Be Equal As Strings    ${urlBefore}    ${urlAfter}

Test Search Space
    Wait Until Element Is Visible    ${SEARCH_BAR}
    ${urlBefore}    Get Location
    Input Text     ${SEARCH_BAR}    ${SPACE}${SPACE}${SPACE}${SPACE}
    Click Element    ${SEARCH_BUTTON}
    Element Should Be Visible    ${EMPTY_ALERT}
    Capture Page Screenshot    input_space_test.png
    Run Keyword And Ignore Error    Wait Until Element Is Not Visible    ${EMPTY_ALERT}
    ${urlAfter}    Get Location
    Should Be Equal As Strings    ${urlBefore}    ${urlAfter}

*** Test Cases ***
Search Test
    Login Web Player
    Test Search Function    檸檬樹    ${USING_URL_KEYWORD_TO_VERIFY_RESULT}
    Test Search Function    SHE    ${USING_URL_KEYWORD_TO_VERIFY_RESULT}
    Test Search Function    fly me to the moon    ${USING_URL_KEYWORD_TO_VERIFY_RESULT}
    Test Search Function    二人暮らし    ${USING_URL_KEYWORD_TO_VERIFY_RESULT}
    Test Search Function    %%    ${NOT_USING_URL_KEYWORD_TO_VERIFY_RESULT}
    Test Search Function    %64    ${NOT_USING_URL_KEYWORD_TO_VERIFY_RESULT}
    Test Search Function    ??    ${NOT_USING_URL_KEYWORD_TO_VERIFY_RESULT}
    Test Search Function    ??    ${NOT_USING_URL_KEYWORD_TO_VERIFY_RESULT}
    Test Search Function    !!    ${NOT_USING_URL_KEYWORD_TO_VERIFY_RESULT}
Input Is Needed Notifitation Test
    Login Web Player
    Test Search Empty
    Test Search Space