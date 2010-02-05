import os

def get_imap_passwd():
  cmd = "/Applications/MacPorts/CocoaDialog.app/Contents/MacOS/CocoaDialog secure-standard-inputbox --string-output --title 'OfflineIMAP: please input your password'"
  return os.popen(cmd).readlines()[1][:-1]
