#! /usr/bin/python 

import sys
import os
import urllib
import netgrowl
import time
from modules.BeautifulSoup import BeautifulSoup

def fetch_stock():
    f = urllib.urlopen("http://www.szse.cn/szseWeb/common/szse/webservice/zqhqpage.jsp?txtStockCode=000875&cycle=&actionid=&randnum=0.8005739768343246")
    resp = f.read()
    resp = resp.decode("gbk").encode('utf-8')
    if resp:
        soup = BeautifulSoup(resp)
        tables = soup.findAll("table", {'id':'ZQHQ1_GridA'})
        assert len(tables)==1
        table = tables[0]
        rows = table.findAll("tr")
        assert len(rows)==9
        # omit the last row because there is nothing inside
        rows = rows[:7]
        messages = []
        for row in rows:
            tds = row.findAll('td')
            assert len(tds)==2
            name = tds[0].string
            value = ""
            if tds[1].string:
                value = tds[1].string
            else:
                value = tds[1].font.string
            messages.append(name + " : " + value)
        if messages:
            message = "\n".join(messages)
            netgrowl.send_notify_by_growl(name="Stock",
                                         message=message.encode("utf-8"),
                                         host="localhost")

if __name__=="__main__":
    while True:
        fetch_stock()
        time.sleep(10*60)
