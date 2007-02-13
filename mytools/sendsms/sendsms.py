#! /usr/bin/python
import urllib
import sys
import os
import string
import time

COOKIE="Webtrends=221.218.4.111.1830541158242909207; JSESSIONID=0000wl7z3OjnldNqvw1u_937Zgg:111p3q768"

MY_MOBILE_NUMBER = '13671208709'

def make_params(mobiles, msg_content):
    assert len(mobiles)>1, \
            "there must be at least on mobile number in mobiles arrry"
    cur_time = time.localtime()
    params = urllib.urlencode(
                     {'operation':'SelfDefined',
                      'smsSave':'smsSave',
                      'maxlengths':70,
                      'destinationAddr':string.join(mobiles, ',')+',',
                      'sourceAddrhidden':MY_MOBILE_NUMBER,
                      'msgContent':msg_content,
                      'delay':'no',
                      'delayYear':cur_time[0],
                      'delayMonth':cur_time[1],
                      'delayDay':cur_time[2],
                      'delayHour':cur_time[3],
                      'delayMinut':0,
                     })

    other_params = "mobilehidden=%"+MY_MOBILE_NUMBER+"%29&lbl_limit=%C4%FA%D2%D1%BE%AD%CA%E4%C8%EB+51+%D7%D6%A3%AC%B7%D6%CE%AA+1+%CC%F5%B7%A2%CB%CD%2C%C3%BF%CC%F5%B6%CC%D0%C5%CA%D5%B7%D10.15%D4%AA%A1%A3"
    return params +'&' + other_params

def do_request(params):
    os.system("curl -b '%s' -d '%s' 'http://szx.bjmcc.net/szx/wsms/smswrite' 1>/dev/null"%(COOKIE,params))

if __name__=="__main__":
    if len(sys.argv)<1:
        print "You must give me the mobile number to send message to"
        exit(1)
    msg_content = 'éäè®æ¾é´ææää èèïçää¶çæ¥çåç½äºä æ«äïæäæ¯æå«çç¼æéä åäïåää½ä²ççççåä æ¦ä¡ã'
    msg_content = msg_content.decode('utf-8').encode('gb2312')
    argv = sys.argv
    while argv:
        mobiles = argv[:5]
        argv = argv[5:]
        params = make_params(mobiles, msg_content)
        #do_request(params)
