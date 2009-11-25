#!/usr/bin/env python

"""
This script is a fork of netgrowl.py that is shipped with Growl application.
The main change is adding gnome-osd-client support, then this script can be
used to:
   * send On Screen Display notification to local linux machine
   * send NetGrowl notification to local or remote Mac machine

"""

# URL for this script: http://the.taoofmac.com/space/Projects/netgrowl.py
"""Growl 0.6 Network Protocol Client for Python"""
__version__ = "0.6" # will always match Growl version
__author__ = "Rui Carmo (http://the.taoofmac.com)"
__copyright__ = "(C) 2004 Rui Carmo. Code under BSD License."
__contributors__ = "Ingmar J Stein (Growl Team)"


import os
import sys
import optparse
import struct
import md5
#import subprocess
from socket import AF_INET, SOCK_DGRAM, socket

GROWL_UDP_PORT=9887
GROWL_PROTOCOL_VERSION=1
GROWL_TYPE_REGISTRATION=0
GROWL_TYPE_NOTIFICATION=1

execfile(os.path.expanduser("~/.netgrowlrc"))

class GrowlRegistrationPacket:
    """Builds a Growl Network Registration packet.
       Defaults to emulating the command-line growlnotify utility."""

    def __init__(self, application="growlnotify", password = None ):
        self.notifications = []
        self.defaults = [] # array of indexes into notifications
        self.application = application.encode("utf-8")
        self.password = password
    #   end def

    def addNotification(self, notification="Command-Line Growl Notification", enabled=True):
        """Adds a notification type and sets whether it is enabled on the GUI"""
        self.notifications.append(notification)
        if enabled:
            self.defaults.append(len(self.notifications)-1)
    #   end def

    def payload(self):
        """Returns the packet payload."""
        self.data = struct.pack( "!BBH",
                                 GROWL_PROTOCOL_VERSION,
                                 GROWL_TYPE_REGISTRATION,
                                 len(self.application) )
        self.data += struct.pack( "BB",
                                  len(self.notifications),
                                  len(self.defaults) )
        self.data += self.application
        for notification in self.notifications:
            encoded = notification.encode("utf-8")
            self.data += struct.pack("!H", len(encoded))
            self.data += encoded
        for default in self.defaults:
            self.data += struct.pack("B", default)
        self.checksum = md5.new()
        self.checksum.update(self.data)
        if self.password:
            self.checksum.update(self.password)
        self.data += self.checksum.digest()
        return self.data
    #   end def
  # end class

class GrowlNotificationPacket:
    """Builds a Growl Network Notification packet.
       Defaults to emulating the command-line growlnotify utility."""

    def __init__(self, application="growlnotify",
                 notification="Command-Line Growl Notification", title="Title",
                 description="Description", priority = 0, sticky = False, password = None ):
        self.application  = application.encode("utf-8")
        self.notification = notification.encode("utf-8")
        self.title        = title.encode("utf-8")
        self.description  = description.encode("utf-8")
        flags = (priority & 0x07) * 2
        if priority < 0:
            flags |= 0x08
        if sticky:
            flags = flags | 0x0001
        self.data = struct.pack( "!BBHHHHH",
                                 GROWL_PROTOCOL_VERSION,
                                 GROWL_TYPE_NOTIFICATION,
                                 flags,
                                 len(self.notification),
                                 len(self.title),
                                 len(self.description),
                                 len(self.application) )
        self.data += self.notification
        self.data += self.title
        self.data += self.description
        self.data += self.application
        self.checksum = md5.new()
        self.checksum.update(self.data)
        if password:
            self.checksum.update(password)
        self.data += self.checksum.digest()
    # end def

    def payload(self):
        """Returns the packet payload."""
        return self.data
    # end def
  # end class

def unit_test():
    print "Starting Unit Test"
    print " - please make sure Growl is listening for network notifications"
    #addr = ("localhost", GROWL_UDP_PORT)
    addr = ("192.168.0.192", GROWL_UDP_PORT)
    s = socket(AF_INET,SOCK_DGRAM)
    print "Assembling registration packet like growlnotify's (no password)"
    p = GrowlRegistrationPacket(password='hello')
    p.addNotification()
    print "Sending registration packet"
    s.sendto(p.payload(), addr)

    print "Assembling standard notification packet"
    p = GrowlNotificationPacket(password='hello')
    print "Sending standard notification packet"
    s.sendto(p.payload(), addr)

    print "Assembling priority -2 (Very Low) notification packet"
    p = GrowlNotificationPacket(priority=-2, password='hello')
    print "Sending priority -2 notification packet"
    s.sendto(p.payload(), addr)

    print "Assembling priority 2 (Very High) sticky notification packet"
    p = GrowlNotificationPacket(priority=2,sticky=True,password='hello')
    print "Sending priority 2 (Very High) sticky notification packet"
    s.sendto(p.payload(), addr)
    s.close()
    print "Done."

def _send_notify_by_growl(name, message, password='', host='',
                         port=GROWL_UDP_PORT, quiet=True, sticky=False):
    addr = (host, port)
    s = socket(AF_INET, SOCK_DGRAM)
    if not quiet:
        print "Assembling standard notification packet"
    #TODO: guess the encoding of message and decode them
    p = GrowlNotificationPacket(title=name.decode('utf-8'),
                                description=message.decode('utf-8'),
                                password=password,
                               sticky=sticky)
    if not quiet:
        print "Sending standard notification packet"
    s.sendto(p.payload(), addr)
    s.close()


def _send_notify_by_notifydaemon(name, message, icon, time):
    message = message.replace('&', '&amp;')
    message = message.replace('<', '&lt;')
    message = message.replace('>', '&gt;')
    message = message.replace("'", '&apos;')
    message = message.replace('"', '&quot;')
    #message = message.replace('~', '&tilde;')
    #message = message.replace('-', '&ndash;')

    cmd = 'gnome-osd-client "(%s): %s"' % (name, message)
    os.system(cmd)

def send_notify(profile, options):
    if profile=='linux':
        _send_notify_by_notifydaemon(options.name or "NetGrowl",
                                    options.message or "Nortification",
                                    options.icon,
                                    options.time)
    elif profile=='darwin':
        _send_notify_by_growl(options.name or "NetGrowl",
                             options.message or "Nortification",
                             options.password,
                             options.host, options.port, options.quiet,
                             options.sticky)
    else:
        print "I don't know this kind of OS."

def play_sound_effect(options):
    if not options.sound:
        return

    host = options.host or 'localhost'
    sound_file = options.sound_file or '~/sound/glass.aiff'

    # there are more sound effect files in /System/Library/Sounds
    # to use esdplay, you need to install esound or esound-clients package
    cmd = ' '.join(['esdplay', '-s', host, sound_file])
    os.system(cmd)

if __name__ == '__main__':
    parser = optparse.OptionParser(usage="%prog [OPTION]...",
                                   version="%prog1.0")
    parser.add_option('-n', '--name', dest='name',
                      help='Set the name of the application that sends the \
                      notification [Default: growlnotify]')
    parser.add_option('-s', '--sticky', dest='sticky', default=False,
                      help='Make the notification sticky')
    parser.add_option('-m', '--message', dest='message',
                      help='Sets the message to be used instead of using stdin')
    parser.add_option('-p', '--priority', dest='priority',
                       help='Specify an int or named key (default is 0)')
    parser.add_option('-H', '--host', dest='host', default='',
                       help='Specify a hostname to which to send a remote \
                       notification.')
    parser.add_option('-P', '--password', dest='password', default="",
                      help = 'Password used for remote notifications.')
    parser.add_option('', '--port',  dest='port', default=GROWL_UDP_PORT,
                      help = 'Port number for UDP notifications.')
    parser.add_option('-S', '--sound', dest='sound',
                      action='store_true', help="play sound effect file")
    parser.add_option('-f', '--soundfile', dest='sound_file', default="",
                      help="play which sound effect file")
    parser.add_option('-i', '--icon', dest='icon', default="",
                      help='specify an icon for notification message')
    parser.add_option('-t', '--time', dest='time', default=5000,
                      help='specify how long should the notification display')
    parser.add_option('-q', '--quiet', dest='quiet', default=False,
                      action="store_true", help="don't print debug info")

    options, args = parser.parse_args()

    if not args and not options:
        unit_test()
    else:
        profile = local_configs['active']
        for entry in local_configs[profile]:
            if not hasattr(options, entry) or not getattr(options, entry):
                setattr(options, entry, local_configs[profile][entry])

        send_notify(profile, options)
        play_sound_effect(options)


