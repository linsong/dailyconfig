#! /usr/bin/python

import os
import re
import getpass

replacement_pat = re.compile(r'\$([^$]+)\$')

if __name__=='__main__':
    fetchmail_rc_path = os.path.join(os.environ['HOME'], '.fetchmailrc')
    print "start to reading configs from %s" % fetchmail_rc_path
    f = file(fetchmail_rc_path)
    orig_config_lines = f.readlines()
    f.close()

    config_lines = []

    print "start processing config ..."
    for line in orig_config_lines:
        line = line.lstrip()
        if not line or line[0]=='#':
            continue

        m = replacement_pat.search(line)
        if m and len(m.groups()):
            passwd = getpass.getpass("Password for %s: " % m.groups()[0])
            line = replacement_pat.sub(passwd, line)
        config_lines.append(line)

    print "configs: "
    print config_lines
    print "stop running fetchmail ..."
    os.system("fetchmail -q")

    print "launching fetchmail ..."
    fetchmail_app = os.popen("fetchmail -f -", "w")
    fetchmail_app.write("".join(config_lines))
    fetchmail_app.close()

