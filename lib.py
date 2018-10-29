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
def getValueFromUrlForWebPlayer(url):
    try:
        index = url.rindex('/')
        word = url[(index + 1):]
        unicodeStr = unquote(word.encode()).decode('utf-8')
        
    except:
        return 'Error had happen'
    else:
        return unicodeStr