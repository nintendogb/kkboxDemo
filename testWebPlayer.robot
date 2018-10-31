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
#-------------------------------------------------------------------------------------------------------
${SHOULD_EXIST}    ${true}
${SHOULD_NOT_EXIST}    ${false}
${TEST_SEARCH_BY_URL}    ${false}
${NOT_TEST_SEARCH_BY_URL}    ${true}
${SEARCH_TEST_COUNTER}    1
${SEARCH_RESULT_PROMPT}    您搜尋的關鍵字為
${MAX_ARTIST_IN_ROOT}    5
${MAX_SONG_IN_ROOT}    10
${MAX_PLAYLIST_IN_ROOT}    5
${FIRST_ARTIST_RESULT}    #Will be set at runtime
${FIRST_SONG_RESULT}     #Will be set at runtime
${FIRST_PLAYLIST_RESULT}    #Will be set at runtime
${FIRST_ARTIST_COUNT}    #Will be set at runtime
${FIRST_SONG_COUNT}     #Will be set at runtime
${FIRST_PLAYLIST_COUNT}    #Will be set at runtime
*** Keywords ***
Open KKBOX Web Player
    Open Browser    https://play.kkbox.com/    chrome     alias=webPlayer

Close AD
    Click Element    ${AD_CLOSE}

Login Web Player
    Wait Until Element Is Visible    ${USER_BAR}    #timeout=${REFRESH_TIMEOUT}
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

    ${count}    Set Variable If
    ...    '${type}' == 'artist'    ${FIRST_ARTIST_COUNT}
    ...    '${type}' == 'song'    ${FIRST_SONG_COUNT}
    ...    '${type}' == 'playlist'    ${FIRST_PLAYLIST_COUNT}

    ${max}    Set Variable If
    ...    '${type}' == 'artist'    ${MAX_ARTIST_IN_ROOT}
    ...    '${type}' == 'song'    ${MAX_SONG_IN_ROOT}
    ...    '${type}' == 'playlist'    ${MAX_PLAYLIST_IN_ROOT}

    Should Be Equal As Numbers    ${count}    ${max}

    Click Element    ${button}
    Wait Until Element Is Visible    ${MORE_FRAMER}    #timeout=${REFRESH_TIMEOUT}
    Location Should Contain    ${type}
    Element Should Be Visible    ${RESULT_FRAMER}
    Capture Page Screenshot    ${SEARCH_TEST_COUNTER}_more_${type}.png
    Click Empty Space To GoBack
    Run Keyword And Ignore Error    Wait Until Element Is Not Visible    ${MORE_FRAMER}    #timeout=${REFRESH_TIMEOUT}
    Element Should Not Be Visible    ${MORE_FRAMER}

First Result Is Same As Root Search Page
    [Arguments]    ${type}
    ${xpath}    Set Variable If
    ...    '${type}' == 'artist'    ${FIRST_ARTIST}
    ...    '${type}' == 'song'    ${FIRST_SONG}
    ...    '${type}' == 'playlist'    ${FIRST_PLAYLIST}

    ${rootFirstValue}    Set Variable If
    ...    '${type}' == 'artist'    ${FIRST_ARTIST_RESULT}
    ...    '${type}' == 'song'    ${FIRST_SONG_RESULT}
    ...    '${type}' == 'playlist'    ${FIRST_PLAYLIST_RESULT}


    ${currentFirstValue}    Get Text    ${xpath}[1]
    Log    ${rootFirstValue}
    Log    ${currentFirstValue}
    Should Be Equal As Strings    ${rootFirstValue}    ${currentFirstValue}

Check Result Of Url Search 
    [Arguments]    ${result_exist}    ${type}    ${pattern}    ${notTestUrlSearch}
    Return From Keyword If    ${notTestUrlSearch} 
    ${url_keyword}    Get Keyword From Url
    Open Browser    https://play.kkbox.com/search/${type}/${url_keyword}    chrome
    Login Web Player
    Wait Until Page Contains    ${SEARCH_RESULT_PROMPT} ${pattern}    #timeout=${REFRESH_TIMEOUT}
    Capture Page Screenshot    ${SEARCH_TEST_COUNTER}_url_${type}.png
    Run Keyword If    ${result_exist}    Element Should Be Visible    ${RESULT_FRAMER}
    ...    ELSE    Element Should Not Be Visible    ${RESULT_FRAMER}
    Run Keyword If    ${result_exist}    First Result Is Same As Root Search Page    ${type}
    Close Browser
    Switch Browser    webPlayer

Check Search By Type
    [Arguments]    ${type}   ${typeExist}    ${pattern}    ${notTestUrlSearch}
    Run Keyword If    ${typeExist}['${type}Button']    Check More Content    ${type}    ${pattern}
    Check Result Of Url Search    ${SHOULD_EXIST}    ${type}    ${pattern}    ${notTestUrlSearch}

Set Root Page Result Of Artist To Suite Variable
    ${res}    Get Text    ${FIRST_ARTIST}[1]
    ${count}    Get Element Count    ${FIRST_ARTIST}
    Set Suite Variable    ${FIRST_ARTIST_RESULT}    ${res}         
    Set Suite Variable    ${FIRST_ARTIST_COUNT}    ${count}
    Log    ${FIRST_ARTIST_COUNT} 

Set Root Page Result Of Song To Suite Variable
    ${res}    Get Text    ${FIRST_SONG}[1]
    ${count}    Get Element Count    ${FIRST_SONG}
    Set Suite Variable    ${FIRST_SONG_RESULT}    ${res}
    Set Suite Variable    ${FIRST_SONG_COUNT}    ${count}
    Log    ${FIRST_SONG_COUNT}          

Set Root Page Result Of Playlist To Suite Variable
    ${res}    Get Text    ${FIRST_PLAYLIST}[1]
    ${count}    Get Element Count    ${FIRST_PLAYLIST}
    Set Suite Variable    ${FIRST_PLAYLIST_RESULT}    ${res}
    Set Suite Variable    ${FIRST_PLAYLIST_COUNT}    ${count}
    Log    ${FIRST_PLAYLIST_COUNT}          

Get Root Page Result Of Each Exist Type
    [Arguments]    ${existDict}
    Run Keyword If    ${existDict}['artist']    Set Root Page Result Of Artist To Suite Variable  
    Run Keyword If    ${existDict}['song']    Set Root Page Result Of Song To Suite Variable
    Run Keyword If    ${existDict}['playlist']    Set Root Page Result Of Playlist To Suite Variable

Examine Search Function
    [Arguments]    ${pattern}    ${notTestUrlSearch}
    ${resultTypeList}    Get Type of Search Results
    ${existDict}    lib.checkIfTypeExist    ${resultTypeList}
    Get Root Page Result Of Each Exist Type    ${existDict}
    Run Keyword If    ${existDict}['artist']    Check Search By Type    artist    ${existDict}    ${pattern}    ${notTestUrlSearch}
    ...    ELSE    Check Result Of Url Search    ${SHOULD_NOT_EXIST}    artist    ${pattern}    ${notTestUrlSearch}    
    Run Keyword If    ${existDict}['song']    Check Search By Type    song    ${existDict}    ${pattern}    ${notTestUrlSearch}
    ...    ELSE    Check Result Of Url Search    ${SHOULD_NOT_EXIST}    song    ${pattern}    ${notTestUrlSearch}
    Run Keyword If    ${existDict}['playlist']    Check Search By Type    playlist    ${existDict}    ${pattern}    ${notTestUrlSearch}
    ...    ELSE    Check Result Of Url Search    ${SHOULD_NOT_EXIST}    playlist    ${pattern}    ${notTestUrlSearch} 
    
    ${res}    Evaluate    ${SEARCH_TEST_COUNTER} + 1
    Set Suite Variable    ${SEARCH_TEST_COUNTER}    ${res}   

Test Search Function
    [Arguments]    ${pattern}    ${notTestUrlSearch}
    Wait Until Element Is Visible    ${SEARCH_BAR}    #timeout=${REFRESH_TIMEOUT}
    Input Text     ${SEARCH_BAR}    ${pattern}
    Click Element    ${SEARCH_BUTTON}
    Url Keyword Should Same As Input After Decode    ${pattern}
    Wait Until Page Contains    ${SEARCH_RESULT_PROMPT} ${pattern}    #timeout=${REFRESH_TIMEOUT}
    Capture Page Screenshot    ${SEARCH_TEST_COUNTER}_root.png
    Examine Search Function    ${pattern}    ${notTestUrlSearch}
   
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