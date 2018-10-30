#-*- coding: utf-8 -*-
import urlparse
def getValueFromUrlForKkbox(index, url):
    try:
        par = urlparse.parse_qs(urlparse.urlparse(url.encode()).query)
        word = par[index.encode()][0].decode('utf-8')
    except:
        return 'Error had happen'
    else:
        return word

from urllib2 import unquote
def getDecodeValueFromUrlForWebPlayer(url):
    try:
        index = url.rindex('/')
        word = url[(index + 1):]
        unicodeStr = unquote(word.encode()).decode('utf-8')
        
    except:
        return 'Error had happen'
    else:
        return unicodeStr

def isMoreButtonExist(text):
    if u'更多' in text:
        return True
    else:
        return False

def checkIfTypeExist(list):
    itemExist = { 
        'artist': False,  
        'song': False,  
        'playlist': False,  
        'artistButton': False,  
        'songButton': False,  
        'playlistButton': False  
    }

    for i in range(len(list)):
        if u'歌手' in list[i]:
            itemExist['artist'] = True
            itemExist['artistButton'] = isMoreButtonExist(list[i])
        elif u'歌曲' in list[i]:
            itemExist['song'] = True
            itemExist['songButton'] = isMoreButtonExist(list[i])
        elif u'歌單' in list[i]:
            itemExist['playlist'] = True
            itemExist['playlistButton'] = isMoreButtonExist(list[i])

    return itemExist