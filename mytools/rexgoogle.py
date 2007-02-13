# -*- coding: gb2312 -*-
import sys
import urllib
import urllib2
import cookielib
import re
import StringIO
import htmllib,urlparse,formatter
import HTMLParser
import signal


HEADERS = {'User-agent' : 'Mozilla/4.0 (compatible; MSIE 5.5; Windows NT)'}
BUFSIZE = 8192

class GoogleWrapper:
    def __init__(self):
        self.searchurl = 'http://www.google.com/search?%s'
        cj = cookielib.LWPCookieJar()
        opener = urllib2.build_opener(urllib2.HTTPCookieProcessor(cj))
        urllib2.install_opener(opener)
        self.reset()

    def reset(self):
        self.keywords = ""
        self.resultNum = 100
        self.startIndex = 0
        self.pagedata = None
        
    def Search(self,keywords):
        self.keywords = keywords.encode('utf-8')
        #params = urllib.urlencode({'q':self.keywords,'hl':'zh-CN','start':self.startIndex,'sa':'N'})
        params = urllib.urlencode({'q':self.keywords,'btnG':'Google','hl':'zh-CN'})
        req=urllib2.Request(self.searchurl%params,None,HEADERS)
        f = urllib2.urlopen(req)
        self.pagedata = StringIO.StringIO(f.read())
        numpat = re.compile(r'<b>((\d+,)*\d+)</b>.{3,10}<b>%s</b>'%self.keywords)
        mat = numpat.search(self.pagedata.getvalue())
        if mat:
            self.resultNum = int(mat.group(1).replace(",",""))
        else:
            self.resultNum = 0
        # TODO: get the search result number
        

    def NextPage(self):
        if self.pagedata:
            tmp = None
            tmp,self.pagedata=self.pagedata,tmp
            return tmp
            
        self.startIndex += 10
        if self.startIndex>=self.resultNum:
            return None

        params = urllib.urlencode({'q':self.keywords,'hl':'zh-CN','start':self.startIndex,'sa':'N'})
        req = urllib2.Request(self.searchurl%params,None,HEADERS)
        f = urllib2.urlopen(req)
        return StringIO.StringIO(f.read())


class DataParser(HTMLParser.HTMLParser):
    def __init__(self):
        HTMLParser.HTMLParser.__init__(self)
        self.data = ""
    def handle_data(self,data):
        self.data += data
        return 

    def handle_starttag(self, tag, attributes):
        return 

    def handle_endtag(self,tag):
        return


class RexSearchInfo:
    def __init__(self):
        self.seen = {}
        self.fmter = htmllib.HTMLParser(formatter.NullFormatter())
        self.rexpat = ""
        self.pat = re.compile(r"[^.]+\.google\..+")
        pass

    def isGoogleURL(self,url):
        pieces = urlparse.urlparse(url)
        return self.pat.match(pieces[1]) or (not pieces[1]) or (pieces[2]=='/search')
            
    
    def RexSearchFile(self,pagefile):
        if not self.rexpat:
            self.rexpat = re.compile(raw_input("Please input a regular expression pattern: \n"))

        while True:
            data = pagefile.read(BUFSIZE)
            if not data: break
            self.fmter.feed(data)
        self.fmter.close()

        for url in self.fmter.anchorlist:
            if url in self.seen: continue
            self.seen[url] = True

            # check if the url comes from google,if not,then we will search it with a regular express
            if self.isGoogleURL(url):
                #print "  === %s"%url
                pass
            else:
                self.DiveInRexSearch(url)

    def DiveInRexSearch(self,url):
        print "  >>> %s"%url
        req=urllib2.Request(url,None,HEADERS)
        try:
            f = urllib2.urlopen(req)
        except urllib2.URLError:
            # go with the next url
            return
        except :
            # ignore all excetions
            return
       
        myparser = DataParser()

        try:
            while True:
                data = f.read(BUFSIZE)
                if not data: break
                myparser.feed(data)
            myparser.close()
        except HTMLParser.HTMLParseError:
            pass

        
        if self.rexpat.search(myparser.data):
            print "  *** FIND: %s"%url
        

def sighandler(signum,frame):
    print "Exit by User!"
    sys.exit(0)

if __name__=='__main__':
    signal.signal(signal.SIGINT,sighandler)
    g = GoogleWrapper()
    keywords = raw_input("Please input some words for google search: \n");
    g.Search(unicode(keywords,'gb2312'))
    
    rexsearch = RexSearchInfo()
    
    pagefile = g.NextPage()
    while (pagefile):
        rexsearch.RexSearchFile(pagefile)
        pagefile = g.NextPage()

    print "Done!"
        

#theurl = 'http://www.google.com/search?%s'
#txheaders =  {'User-agent' : 'Mozilla/4.0 (compatible; MSIE 5.5; Windows NT)'}
#txdata = urllib.urlencode({'q':'python ipython vim','btnG':'Google','hl':'zh-CN'})
#req=urllib2.Request(theurl%txdata,None,txheaders)
#f = urllib2.urlopen(req)

#f = open('test.html','r')
#import htmllib,urlparse,formatter
#p = htmllib.HTMLParser(formatter.NullFormatter(  ))
#BUFSIZE = 8192
#while True:
    #data = f.read(BUFSIZE)
    #if not data: break
    #p.feed(data)
#p.close(  )

#for url in p.anchorlist:
    #if url in seen: continue
    #seen[url] = True
    #pieces = urlparse.urlparse(url)

    # check if the url comes from google,if not,then we will search it with a regular express
    #if pat.match(pieces[1]) or (not pieces[1]):
        #print "  === %s"%url
        #pass
    #else:
        #print "  >>> %s"%url
        #DiveInRexSearch()
    

