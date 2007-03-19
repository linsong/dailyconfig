#! /usr/bin/python 

import sys
import os
import urllib
import re

TMP_HTML_FILE='/tmp/tianya-feeling.html'

if __name__=="__main__":
    if len(sys.argv)==1:
        print "%s: " % sys.argv[0]
        print " %s web_page_url" % sys.argv[0]
        sys.exit(1)
    next_page_url = sys.argv[1]
    base_url = next_page_url[:next_page_url.rfind('/')]
    link_match_pat = re.compile(r'href=([^>]+)>\xcf\xc2\xd2\xbb\xd2\xb3')
    txt_match_pat = re.compile(
        r'^\s+\xe4\xbd\x9c\xe8\x80\x85\xef\xbc\x9a\s*([^\s]*)\s*(\xe6\x8f\x90\xe4\xba\xa4\xe6\x97\xa5\xe6\x9c\x9f\xef\xbc\x9a|\xe3\x80\x80\xe5\x9b\x9e\xe5\xa4\x8d\xe6\x97\xa5\xe6\x9c\x9f\xef\xbc\x9a)')
    author_nick = sys.argv[2]

    while True:
        print "### fetching web page %s" % next_page_url
        page = urllib.urlopen(next_page_url)
        source = page.read()
        result = link_match_pat.search(source)
        if result and result.groups():
            next_page_url = result.groups()[0]
            if not next_page_url.startswith('http://'):
                next_page_url = base_url + '/' + next_page_url
        else:
            next_page_url = None
            break

        f = file(TMP_HTML_FILE, "w")
        f.write(source)
        f.close()
        txt = os.popen("w3m -I gbk -O utf-8 -dump %s" % TMP_HTML_FILE)
        line = txt.readline()
        start = False
        while line:
            txt_mat_result = txt_match_pat.search(line)
            if txt_mat_result and txt_mat_result.groups():
                if txt_mat_result.groups()[0]==author_nick:
                    start=True
                else:
                    start=False
            if start:
                print line
            line = txt.readline()
    print "Done. Exiting ... "





