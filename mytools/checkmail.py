#! /usr/bin/python 
import sys
import os
import time
import stat
import optparse
import netgrowl

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
        # we arrive here because: 
        # since we found some new mails in mailbox, 
        # user have not read the new mail, it is normal,
        # don't need to send notification again 
        pass

    new_mail_infos[mailbox_file]["mailboxsize"] = mailboxsize
    return has_new_mail

if __name__ == '__main__':
    parser = optparse.OptionParser(usage="%prog [OPTION] mailfile1 [mailfile2 ... mailfileN]",
                                   version="%prog1.0")
    parser.add_option('-u', '--update', dest='update_interval', default=30.0,
                      help='how often(in second) to check new mail, default is 30 secs')
    parser.add_option('-H', '--host', dest='host', default='localhost',
                       help='Specify a hostname to which to send a remote \
                       notification.')

    options, args = parser.parse_args()

    if len(args)==0:
        print "You must specify a mail file to check!"
        system.exit(1)

    for mf in args:
        new_mail_infos[mf] = {'mailboxsize':0,
                               'new_mails':[]}
    while True:
        for mf in new_mail_infos:
            if check_mail(mf):
                print "Found new mails in %s. " % mf
                print "Send new mail notification to %s" % options.host
                #netgrowl.send_notify_by_growl(name="Mail",
                    #message="You got a new mail in %s." % mf,
                                             #sticky=True,
                                             #host=options.host)
                options.name = "Mail"
                options.message="You got a new mail in %s." % mf
                netgrowl.send_notify(options)
                #netgrowl.play_sound_effect(True, options.host)
        time.sleep(float(options.update_interval))

