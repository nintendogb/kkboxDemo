#-*- coding: utf-8 -*-
#url = 'https://www.kkbox.com/tw/tc/search.php?search=artist&word=%E6%AA%B8%E6%AA%AC%E6%A8%B9'
import urlparse
def getValueFromURL(index, url):
    try:
        par = urlparse.parse_qs(urlparse.urlparse(url.encode()).query)
        word = par[index.encode()][0].decode('utf-8')
    except:
        return 'Error had happen'
    else:
        return word
