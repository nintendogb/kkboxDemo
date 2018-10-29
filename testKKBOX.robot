*** Settings ***
Library     Selenium2Library
Test Setup    Open KKBOX Website
Test Teardown     close all browsers
Library    ./lib.py    WITH NAME    lib
*** Variables ***
${SEARCH_ICON}    xpath=(.//*[normalize-space(text()) and normalize-space(.)='KKBOX'])/following::label[1]
${SEARCH_BAR}    id=pm-search-keywords
${ENTER}    \\13
*** Keywords ***
Open KKBOX Website
    Open Browser    https://www.kkbox.com/    chrome     alias=indexPage

Get Value From URL
    [Arguments]    ${parameter_name}
    ${url}    Get Location
    ${value}    lib.getValueFromURLForKkbox    ${parameter_name}    ${url}
    [Return]    ${value}

Search Specific Type Of Content
    [Arguments]    ${type}    ${pattern}
    Click Element    ${SEARCH_ICON}    
    Input Text    ${SEARCH_BAR}    ${pattern}
    Press Key    ${SEARCH_BAR}    	${ENTER}
    ${word}    Get Value From URL    word
    Log    ${word}
    Should Be Equal As Strings    ${word}    ${pattern}
    Click Element    link=${type}
    ${word}    Get Value From URL    word
    Log    ${word}
    Should Be Equal As Strings    ${word}    ${pattern}
    ${search}    Get Value From URL    search
    Log    ${search}

Search Has Result
    [Arguments]    ${pattern}
    Page Should Contain Element    class=search-group
    Current Frame Should Not Contain    找不到符合「${pattern}」的搜尋結果

Search Has No Result
    [Arguments]    ${pattern}
    Page Should Not Contain Element    class=search-group
    Current Frame Should Contain    找不到符合「${pattern}」的搜尋結果
    
*** Test Cases ***
Search Singer Test
    Search Specific Type Of Content    歌手    Taylor Swift
    Search Has Result    Taylor Swift
    Capture Page Screenshot

    Search Specific Type Of Content    歌手    dfresgytsdfhy
    Search Has No Result    dfresgytsdfhy
    Capture Page Screenshot

Search song Test
    [Tags]    debug
    Search Specific Type Of Content    歌曲    檸檬樹
    Search Has Result    檸檬樹
    Capture Page Screenshot

    Search Specific Type Of Content    歌曲    dfresgytsdfhy
    Search Has No Result    dfresgytsdfhy
    Capture Page Screenshot

Search SongList Test
    Search Specific Type Of Content    歌單    SHE
    Search Has Result    SHE
    Capture Page Screenshot

    Search Specific Type Of Content    歌單    dfresgytsdfhy
    Search Has No Result    dfresgytsdfhy
    Capture Page Screenshot

