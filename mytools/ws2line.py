#! /usr/bin/python
import os
import sre
import sys
if len(sys.argv)<1:
	raise "pls input some path!"
sys.argv=sys.argv[1:]
print "input arguments is %s"%sys.argv
for i in range(0,len(sys.argv),1):
	print "dir is %s"%sys.argv[i]
	if not os.path.isdir(sys.argv[i]):
		raise "pls input a valid path!"
	flist = os.listdir(sys.argv[i])
	print "fileslist is %s"%flist
	for f in range(0,len(flist),1):
		print "filename is: %s"%flist[f]
		newname = sre.sub(r' +','_',flist[f])
		print newname,flist[f]
		print "rename file..."
		os.rename(sys.argv[i]+os.sep+flist[f],sys.argv[i]+os.sep+newname)

		

