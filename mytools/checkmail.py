#! /usr/bin/python 
import sys
import os
import time
import stat
import optparse

new_mail_infos = {}

def check_mail(mailbox_file):
    """
    check for new mails in mailbox

    """
    st = os.stat(mailbox_file)
    mailboxsize = st[stat.ST_SIZE]
    readSinceLastWrite = st[stat.ST_ATIME] > st[stat.ST_MTIME]

    has_new_mail = False
    if mailboxsize==0:
        has_new_mail = False
    elif readSinceLastWrite:
        has_new_mail = False
    elif mailboxsize != new_mail_infos[mailbox_file]["mailboxsize"]:
        has_new_mail = True
    else:
        # we can not arrive here 
        raise Exception("We should not arrive here!")

    new_mail_infos[mailbox_file]["mailboxsize"] = mailboxsize
    return has_new_mail

if __name__ == '__main__':
    parser = optparse.OptionParser(usage="%prog [OPTION] mailfile1 [mailfile2 ... mailfileN]",
                                   version="%prog1.0")
    parser.add_option('-u', '--update', dest='update_interval', default=60,
                      help='how often(in second) to check new mail, default is 60 secs')
    parser.add_option('-f', '--resultfile', dest='result_file',
                      help='write result into this file')

    options, args = parser.parse_args()

    if len(args)==0:
        print "You must specify a mail file to check!"
        system.exit(1)
    
    for mf in args:
        new_mail_infos[mf] = {'mailboxsize':0,
                               'new_mails':[]}

    if not options.result_file:
        result_file = os.path.join(os.environ["HOME"], "new_mail_result")
    else:
        result_file = options.result_file

    update_interval = options.update_interval
    while True:
        result = file(result_file, "w")
        for mf in new_mail_infos:
            if check_mail(mf):
                print "Found new mails in %s. " % mf
                result.write("New mails in %s." % mf)
        result.close()
        time.sleep(update_interval)

