#! /usr/bin/env python 

import time
import xmlrpclib
from optparse import OptionParser

"""
    Use the XML-RPC interface of livejournal.com to send blog.

    TODO: there are several things need to do later:
        * set tags in the post 
"""
server_url = "http://www.livejournal.com/interface/xmlrpc"

if __name__=="__main__":
    parser = OptionParser(usage="%prog <username> <password> <subject>\
                          <content>")
    parser.add_option("-u", "--username", dest="username",
                      help="username for livejournal.com", metavar="USER")
    parser.add_option("-w", "--password", dest="password",
                      help="your password", metavar="PASSWORD")
    parser.add_option("-s", "--subject", dest="subject",
                      help="the subject of this post",
                      metavar="SUBJECT")
    parser.add_option("-c", "--content", dest="content",
                      help="the content of the post",
                      metavar="CONTENT")

    options, args = parser.parse_args()

    server = xmlrpclib.ServerProxy(server_url)
    time_tuple = time.localtime()
    post_data = {'username' : options.username,
                 'password' : options.password,
                 'event'    : options.content,
                 'subject'  : options.subject,
                 'year'     : time_tuple[0],
                 'mon'      : time_tuple[1],
                 'day'      : time_tuple[2],
                 'hour'     : time_tuple[3],
                 'min'      : time_tuple[4]
                }
    for key in post_data:
        if not post_data[key]:
            print "%s's value(%s) is invalid!"
            parser.print_help()
            sys.exit(1)

    response = server.LJ.XMLRPC.postevent(post_data)
    print response

