import urllib, urllib2
import cookielib

USERNAME="XXXXX"
PASSWORD="XXXXX"

cj = cookielib.LWPCookieJar()
opener = urllib2.build_opener(urllib2.HTTPCookieProcessor(cj))
urllib2.install_opener(opener)

HEADERS= {'User-agent': 'Mozilla/4<...>; MSIE 5.5; Windows NT)'}
#TODO: to use this script, you must use your real username and passwd to replace the fields 'USERNAME' and 'PASSWORD'
#params = urllib.urlencode({'username':'USERNAME','passwd':'PASSWORD','domain':'5460.net'})
params = urllib.urlencode({'username':USERNAME,'passwd':PASSWORD,'domain':'5460.net'})
req=urllib2.Request("http://www.5460.net/gy5460/jsp/login/loginMain.jsp",params,HEADERS)
urllib2.urlopen(req)

#TODO: use the current max page number to replace 294
CurPageCount = 294
urltempl = "http://www.5460.net/gy5460/jsp/liuyan/liuyan.jsp?classID=434480&PageNum=%d&pageCount=%d"
for index in xrange(CurPageCount):
    f2 = urllib2.urlopen(urltempl%(index+1,CurPageCount))
    ff = open("page%d.txt"%(CurPageCount-index),"w")
    ff.write(f2.read())
    ff.close()

