#!/usr/bin/python

# gtd.py - Getting Things Done to-do list manager
#
# Copyright (C) 2004 Keith D. Martin, http://96db.com
# This software is released under the Gnu Public License.

revision = '$Revision: 1.16 $'

history = """
$Log: gtd.py,v $
Revision 1.16  2005/01/07 15:23:20  km9725
Minor fixes. Added ability in todo() to process multiple todo lists simultaneously.

Revision 1.11  2004/12/22 21:45:50  km9725
Major refactoring. Now uses regexps on whole file rather than line by line parsing.

Revision 1.10  2004/12/21 18:23:01  km9725
Lots of cleanup and refactoring. Added (L)ocation tags.
Added ability to filter on location using -c (--context) flag.

Revision 1.7  2004/12/17 18:50:10  km9725
Added contexts and support for prerequisite tasks

Revision 1.5  2004/12/08 21:12:59  km9725
S=YYYY-MM-DD now allowed to specify task start date

Revision 1.4  2004/12/08 18:22:17  km9725
Fixed importing new tasks from todo file and normalized all filenames

Revision 1.2  2004/11/30 15:00:00  km9725
Added Sean Reifschneider's command-line options

Revision 1.1  2004/11/29 13:56:13  km9725
Fixed handling of recurring tasks
"""

MAKEBACKUPS = False
DATADIR = '.'
TODOFILE = './todo.gtd'
DONEFILE = './done.gtd'
LINESEP = '\n'
VERBOSE=False

DAYINHOURS = 8
NUMWORKDAYS = 5
WEEKINHOURS = NUMWORKDAYS*DAYINHOURS
DEFAULTS = {'U':1, 'I':3, 'T': '1H'}
PARAMS = {'U': ('urgency', 1, True, int),
          'I': ('importance', 3, True, int),
          'T': ('time', '1H', False, str),
          'R': ('recurrence', '', False, str),
          'C': ('complete', 0, False, int),
          'S': ('start', '', True, str),
          'D': ('due', '', True, str),
          'L': ('context', '', True, str),
          'ID': ('id', 0, False, int),
          'CRC': ('crc', '', False, str)}

INHERITED = 101
LOCAL = 102

import re
paramRegexps = [re.compile('(?i)\s+(I|U|T|S|R|D|C|ID)=(\d{4}-\d{2}-\d{2}\+\d+[WDMY]|\d{4}-\d{2}-\d{2}|\d+[HWDYM]?)'),
                re.compile('(?i)\s+([Ll])=(\S+)'),
                re.compile('(?i)\s+(PRE)=([^=]+\|\d+|\d+)'),
                re.compile('(?i)\s+(CRC)=([\dA-F]{4})')]

class Task(object):
    def __init__(self, data='', taskType=0, parent=None):
        self.notes = ''
        self.extradata = ''
        if taskType and type(taskType) == type(''):
            self.type = int(taskType)
        else:
            self.type = 0
        self.parent = None
        self.kids = []
        self.prerequisites = []
        self.initializeParams()
        if parent:
            self.attachToParent( parent )
        if '\n' not in data:
            self.title = data
        else:
            self.updateFromString( data )

    def initializeParams(self):
        for key, (attribute, value, inherited, paramtype) in PARAMS.iteritems():
            if inherited:
                value = (value, INHERITED)
            self.__setattr__(attribute, value)

    def updateParams(self, paramLine):
        for (key,value) in _getParamsFromLine(paramLine):
            key = key.upper()
            if key == 'PRE':
                file = self.getRootTitle()
                for p in map(lambda x: re.sub('^(\d+)$',''.join([file,'|',r'\1']),x),
                                                 re.findall('(?:((?:[^\|]+\|)?\d+),?)',value)):
                    if p not in self.prerequisites:
                        self.prerequisites.append(p)
            else:
                (attribute, default, inherited, paramtype) = PARAMS[key]
                if not inherited:
                    self.__setattr__(attribute, paramtype(value))
                elif self.__getattribute__(attribute)[0] != paramtype(value):
                    self.__setattr__(attribute, (paramtype(value), LOCAL))
        
    def attachToParent( self, parent ):
        if self.parent != parent:
            if self.parent:
                self.parent.kids.remove(self)
            self.parent = parent
            parent.kids.append( self )
        for key, (attribute, value, inherited, paramtype) in PARAMS.iteritems():
            if inherited and self.__getattribute__(attribute)[1] != LOCAL:
                self.__setattr__(attribute, (parent.__getattribute__(attribute)[0], INHERITED))
        for prereq in parent.prerequisites:
            if prereq not in self.prerequisites:
                self.prerequisites.append( prereq )

    def updateFromString( self, s ):
        try:
            title, params, note = re.split('\s*\n', s, 2)
        except:
            title, params = re.split('\s*\n', s, 1)
            note = ''
        if not _isParamLine(params):
            note = LINESEP.join( [params, note] )
            params = ''
        self.title = title
        self.notes = note
        self.updateParams(params)

    def maxSubtaskID( self ):
        maxID = 0
        if self.id > maxID:
            maxID = self.id
        for kid in self.kids:
            m = kid.maxSubtaskID()
            if m > maxID:
                maxID = m
        return maxID

    def assignIDs( self, maxID ):
        if not self.id:
            maxID += 1
            self.id = maxID
        for kid in self.kids:
            maxID = kid.assignIDs(maxID)
        return maxID

    def findSubtaskWithID( self, ID ):
        if self.id == ID:
            return self
        else:
            for kid in self.kids:
                item = kid.findSubtaskWithID( ID )
                if item:
                    return item
        return None

    def getRootTitle( self):
        if self.parent:
            return self.parent.getRootTitle()
        else:
            return self.title    

    def hours(self,recurse=True):
        T = float(self.time[:-1])*{'M':1./60,
                                   'H':1,
                                   'D':DAYINHOURS,
                                   'W':WEEKINHOURS}[self.time[-1]]*(100.0-self.complete)/100
        cT = 0
        if recurse:
            for child in self.kids:
                cT += child.hours()
        return max(T,cT)

    def effort(self):
        from math import log
        h = self.hours()
        if h:
            return max(1,log(self.hours())/log(3)+1.0)
        else:
            return 0

    def priority( self ):
        from math import sqrt
        I = self.importance[0]
        P = min(self.urgency[0]+2,self.schedulePressure())
        U = max(self.urgency[0], P)
        E = self.effort()
        return sqrt(2*U*U+2*I*I+E*E)/sqrt(5)

    def schedulePressure( self ):
        import time
        if self.due[0]:
            G = re.search('(\d{4})(-(\d{2})(-(\d{2}))?)?',self.due[0]).groups()
            yr = int(G[0])
            if len(G)<3:
                mo = 1
            else:
                mo = int(G[2])
            if len(G)<5:
                dy = 1
            else:
                dy = int(G[4])
            due = time.mktime((yr,mo,dy,23,59,59,0,0,-1))
            now = time.time()
            avail = (due-now)/60/60
            needed = self.hours()/WEEKINHOURS*24*7
            delta = avail-needed
            if delta<0:
                P = 6 # overdue
            elif delta<24:
                P = 5
            elif delta<24*7:
                P = 4
            elif delta<24*30:
                P = 3
            elif delta<24*90:
                P = 2
            else:
                P = 1
        else:
            P = self.urgency[0]
        parent = self.parent
        while parent:
            PP = parent.schedulePressure()
            if PP > P:
                P = PP
            parent = parent.parent
        return P

    def hasIncompleteSubtasks(self):
        for kid in self.kids:
            if kid.complete < 100 or kid.hasIncompleteSubtasks():
                return True
        return False

    def hasRecurringSubtask(self):
        if self.recurrence:
            return True
        for kid in self.kids:
            if kid.hasRecurringSubtask():
                return True
        return False

    def tasks(self):
        import time
        today = '%d-%02d-%02d'%time.localtime(time.time())[:3]
        if not self.kids:
            if self.complete < 100:
                if re.match('\d{4}-\d{2}-\d{2}',self.start[0]):
                    if self.start[0]<=today:
                        return [self]
                    else:
                        return []                           
                elif (not self.start[0] or not self.due[0] or \
                        _dateDelta(self.start[0],self.due[0],-1)<=today):
                    return [self]
                else:
                    return []
            else:
                return []
        else:
            todolist = []
            lowestUndone = None
            for child in self.kids:
                if child.type == 0:
                    todolist += child.tasks()
                if child.type > 0 and child.complete<100 and \
                   (not lowestUndone or child.type<lowestUndone.type):
                    lowestUndone = child
            if lowestUndone:
                todolist += lowestUndone.tasks()
            if self.recurrence and not todolist:
                print "clearing recurring item"
                self.clearComplete()
                try:
                    start, interval = re.match('(\d{4}-\d{2}-\d{2})\+(\d+[DWMY])',
                                               self.recurrence).groups()
                except:
                    interval = self.recurrence
                    start = None
                self.due = (_dateDelta( interval, start ),LOCAL)
            if self.parent and not todolist and self.complete<100 and \
               not self.hasRecurringSubtask() and not self.hasIncompleteSubtasks() and \
               (not self.start[0] or not self.due[0] or \
               _dateDelta(self.start[0],self.due[0],-1)<=today) and \
               (not re.match('\d{4}-\d{2}-\d{2}',self.start[0]) or self.start[0]<=today):
                todolist = [self]
            return todolist

    def clearComplete( self ):
        self.complete = 0
        for kid in self.kids:
            kid.clearComplete()

    def calcCRC(self):
        return '%04X'%_crc16(self.asToDo(includeCRC=False))       

    def asToDo(self,includeCRC=True):
        mins = int(round(self.hours(recurse=False)*60))
        h,m = mins/60, mins%60
        s = []
        if includeCRC:
            s.append( "%4.2f "%self.priority() )
            if mins<10*60:
                s.append( "%d:%02d "%(h,m) )
            else:
                s.append( "%3dH "%round(mins/60.) )
        s.append( "%s%s"%(self.title,LINESEP) )
        s.append( '          C=%d'%self.complete )
        if includeCRC:
            s.append( ' P=%d'%self.schedulePressure() )
            s.append( ' CRC=%s'%self.calcCRC() )
        for key in ['I','U','T','S','D','R','L','ID']:
            attribute, default, inherited, attrtype = PARAMS[key]
            if not inherited:
                value = str(self.__getattribute__(attribute))
            else:
                value = str(self.__getattribute__(attribute)[0])
            if value:
                s.append(' %s=%s'%(key,str(value)) )                
        if self.prerequisites:
            import copy
            P = copy.copy(self.prerequisites)
            if self.parent:
                for pr in self.parent.prerequisites:
                    P.remove(pr)
            if P:
                file = self.getRootTitle()
                s.append( ' PRE='+','.join( map(lambda x: re.sub(re.escape(file+'|'),'',x),P)) )
        s.append( LINESEP )
        note = re.sub('(?m)^[ \t]*(?=\S)','          ', self.notes.strip()).rstrip()
        if note:
            s.append( note )
            s.append(LINESEP)        
        if includeCRC:
            parent = self.parent
            while parent:
                s.append( "          [%s]%s"%(parent.title,LINESEP) )
                parent = parent.parent
        return ''.join(s)

    def asProject(self):
        level = -1
        parent = self.parent
        while parent:
            level += 1
            parent = parent.parent
        if level<0:
            level = 0
        indent = '  '*level
        s = []
        if not self.parent and self.extradata:
            s.append(self.extradata)
            s.append(LINESEP)
        if self.parent:
            if self.type == 0:
                bullet = "*"
            else:
                bullet = "%d."%self.type
            s.append("%s%s %s"%(indent, bullet, self.title))
            s.append( LINESEP )
            indent += ' '*(len(bullet)+1)
            s.append( indent[:-1] )
            for key in ['C','I','U','T','D','S','R','L']:
                attribute, default, inherited, attrtype = PARAMS[key]
                value = self.__getattribute__(attribute)
                if inherited:
                    if value[1] == LOCAL:
                        value = value[0]
                    else:
                        continue
                if str(value):
                    s.append( ' %s=%s'%(key,str(value)) )
            s.append( ' CRC=%s'%self.calcCRC() )
            if self.prerequisites:
                import copy
                P = copy.copy(self.prerequisites)
                if self.parent:
                    for pr in self.parent.prerequisites:
                        P.remove(pr)
                if P:
                    file = self.getRootTitle()
                    s.append( ' PRE='+','.join( map(lambda x: re.sub(re.escape(file+'|'),'',x),P)) )
            s.append( ' ID=%d'%self.id )
            s.append( LINESEP )
            note = re.sub('(?m)^[ \t]*(?=\S)',indent, self.notes.strip()).rstrip()
            if note:
                s.append( note )
                s.append( LINESEP )
            s.append( LINESEP )
        for kid in self.kids:
            s.append( kid.asProject() ) #`kid`
        return ''.join(s)

    def __str__(self):
        return self.asToDo()

    def __repr__(self):
        return self.asProject()

def _normalizeFilename(file):
    return re.sub(r'\\+','/',file)

def _byPriority(task1, task2):
    return cmp(task2.priority(), task1.priority())

def _crc16(s):
    crcValue=0x0000
    crc16tab = (0x0000, 0xC0C1, 0xC181, 0x0140, 0xC301, 0x03C0, 0x0280,
                0xC241, 0xC601, 0x06C0, 0x0780, 0xC741, 0x0500, 0xC5C1, 0xC481,
                0x0440, 0xCC01, 0x0CC0, 0x0D80, 0xCD41, 0x0F00, 0xCFC1, 0xCE81,
                0x0E40, 0x0A00, 0xCAC1, 0xCB81, 0x0B40, 0xC901, 0x09C0, 0x0880,
                0xC841, 0xD801, 0x18C0, 0x1980, 0xD941, 0x1B00, 0xDBC1, 0xDA81,
                0x1A40, 0x1E00, 0xDEC1, 0xDF81, 0x1F40, 0xDD01, 0x1DC0, 0x1C80,
                0xDC41, 0x1400, 0xD4C1, 0xD581, 0x1540, 0xD701, 0x17C0, 0x1680,
                0xD641, 0xD201, 0x12C0, 0x1380, 0xD341, 0x1100, 0xD1C1, 0xD081,
                0x1040, 0xF001, 0x30C0, 0x3180, 0xF141, 0x3300, 0xF3C1, 0xF281,
                0x3240, 0x3600, 0xF6C1, 0xF781, 0x3740, 0xF501, 0x35C0, 0x3480,
                0xF441, 0x3C00, 0xFCC1, 0xFD81, 0x3D40, 0xFF01, 0x3FC0, 0x3E80,
                0xFE41, 0xFA01, 0x3AC0, 0x3B80, 0xFB41, 0x3900, 0xF9C1, 0xF881,
                0x3840, 0x2800, 0xE8C1, 0xE981, 0x2940, 0xEB01, 0x2BC0, 0x2A80,
                0xEA41, 0xEE01, 0x2EC0, 0x2F80, 0xEF41, 0x2D00, 0xEDC1, 0xEC81,
                0x2C40, 0xE401, 0x24C0, 0x2580, 0xE541, 0x2700, 0xE7C1, 0xE681,
                0x2640, 0x2200, 0xE2C1, 0xE381, 0x2340, 0xE101, 0x21C0, 0x2080,
                0xE041, 0xA001, 0x60C0, 0x6180, 0xA141, 0x6300, 0xA3C1, 0xA281,
                0x6240, 0x6600, 0xA6C1, 0xA781, 0x6740, 0xA501, 0x65C0, 0x6480,
                0xA441, 0x6C00, 0xACC1, 0xAD81, 0x6D40, 0xAF01, 0x6FC0, 0x6E80,
                0xAE41, 0xAA01, 0x6AC0, 0x6B80, 0xAB41, 0x6900, 0xA9C1, 0xA881,
                0x6840, 0x7800, 0xB8C1, 0xB981, 0x7940, 0xBB01, 0x7BC0, 0x7A80,
                0xBA41, 0xBE01, 0x7EC0, 0x7F80, 0xBF41, 0x7D00, 0xBDC1, 0xBC81,
                0x7C40, 0xB401, 0x74C0, 0x7580, 0xB541, 0x7700, 0xB7C1, 0xB681,
                0x7640, 0x7200, 0xB2C1, 0xB381, 0x7340, 0xB101, 0x71C0, 0x7080,
                0xB041, 0x5000, 0x90C1, 0x9181, 0x5140, 0x9301, 0x53C0, 0x5280,
                0x9241, 0x9601, 0x56C0, 0x5780, 0x9741, 0x5500, 0x95C1, 0x9481,
                0x5440, 0x9C01, 0x5CC0, 0x5D80, 0x9D41, 0x5F00, 0x9FC1, 0x9E81,
                0x5E40, 0x5A00, 0x9AC1, 0x9B81, 0x5B40, 0x9901, 0x59C0, 0x5880,
                0x9841, 0x8801, 0x48C0, 0x4980, 0x8941, 0x4B00, 0x8BC1, 0x8A81,
                0x4A40, 0x4E00, 0x8EC1, 0x8F81, 0x4F40, 0x8D01, 0x4DC0, 0x4C80,
                0x8C41, 0x4400, 0x84C1, 0x8581, 0x4540, 0x8701, 0x47C0, 0x4680,
                0x8641, 0x8201, 0x42C0, 0x4380, 0x8341, 0x4100, 0x81C1, 0x8081,
                0x4040)
    for ch in s:
        tmp=crcValue^(ord(ch))
        crcValue=(crcValue>> 8)^crc16tab[(tmp & 0xff)]
    return crcValue

def _isParamLine(line):
    return not not paramRegexps[0].search(line)

def _getParamsFromLine(line):
    results = []
    for reObj in paramRegexps:
        results += reObj.findall(line)
    return results

def readGTDProject( data, title='', root=None, maxID=0 ):
    if not root:
        root = Task(title)
        root.id = 0
    ancestorChain = []
    currentItem = root
    depthStack = [-1]
    root.extradata = data
    for all,leadin,num,task in re.findall(r'(?ms)^(([ \t]*)(?:\*|(\d+)\.) (.+?))(?=\s*\Z|$\s*(?:\*|\d+\.) )', data ):
        root.extradata = re.sub(re.escape(all),'',root.extradata)
        depth = len(leadin)
        if depth != depthStack[-1]:
            if depth>depthStack[-1]:
                ancestorChain.append(currentItem)
                depthStack.append(depth)
            while depth<depthStack[-1]:
                ancestorChain.pop(-1)
                depthStack.pop(-1)
                
        currentItem = Task(task, num, parent=ancestorChain[-1])
        if VERBOSE:
            if currentItem.crc != currentItem.calcCRC():
                print title, '/', currentItem.title, "changed in project file"
        if currentItem.complete == 100.0 and currentItem.recurrence:
            currentItem.clearComplete()
            import datetime
            try:
                start, interval = re.match('(\d{4}-\d{2}-\d{2})\+(\d+[DWMY])',
                                           currentItem.recurrence).groups()
            except:
                interval = currentItem.recurrence
                start = None
            due = _dateDelta( interval, start )
            if due == str(datetime.date.today()):
                due = _dateDelta( interval, due)
            currentItem.due = (due ,LOCAL)
    root.assignIDs( max(maxID,root.maxSubtaskID()) )
    root.extradata = re.sub('\A\n','', re.sub('\n+\Z','\n',root.extradata))
    return root

def _dateDelta( interval, start=None, sign=1):
    import datetime
    if re.match('\d{4}-\d{2}-\d{2}',interval):
        return interval
    if not start:
        start = datetime.date.today()
    else:
        start = datetime.date(*map(int,start.split('-')))
    interval,type = re.match('(\d+)([DWMY])', interval).groups()
    interval = int(interval)*sign
    today = datetime.date.today()
    if type == 'Y':
        first = True
        while first or (interval>0 and start<=today):
            first = False
            start = start.replace(year=start.year+interval)
    elif type in 'WDM':
        first=True
        delta = {'W':datetime.timedelta(weeks=interval),
                 'D':datetime.timedelta(days=interval),
                 'M':datetime.timedelta(days=365./12*interval)}[type]
        while first or interval>0 and start<=today:
            first = False
            start += delta
    return str(start)

def contextMatches( context, contexts ):
    import re
    if not context:
        if '' in contexts:
            return True
    else:
        for c in contexts:
            if c and re.search(r'(?i)\b%s\b'%c,context):
                return True
    return False

def todo(inputFileList, todofiles=(TODOFILE,[]), donefile=DONEFILE):
    import os
    root = Task()
    tasks = []
    donefile = _normalizeFilename(donefile)    
    # read all the data files
    titlemap = {}
    specialfiles = [donefile]
    for file, contexts in todofiles:
        specialfiles.append( _normalizeFilename(file))
    for file in inputFileList:
        file = _normalizeFilename(file)
        if file not in specialfiles:
            r = readGTDProject( open(file).read(), file )
            root.kids.append(r)
            titlemap[file.lower()] = r
    # read old todo file, if it exists
    for todofile,contexts in todofiles:
        todofile = _normalizeFilename(todofile)
        if os.path.exists(todofile):
            for task,file in re.findall(r'(?ms)^[\d\.]+\s+[\d:]+H?\s+(.+?\n)(?:^\s*\[[^\]\n]+\]'
                                        r'[ \t]*\n)*^\s*\[([^\]\n]+)\][ \t]*\n', open(todofile).read() ):
                if not titlemap.has_key( file.lower() ):
                    print file, "is not in current list of project files"
                    print task
                    print
                    continue
                
                currentItem = Task( task )
                if currentItem.crc == currentItem.calcCRC():
                    # This item has not changed...skip ahead
                    continue
                if VERBOSE:
                    print file,'/',currentItem.title,'changed in',todofile
                currentroot = titlemap[file.lower()]
                target = currentroot.findSubtaskWithID( currentItem.id )                
                if not target:
                    print "Could not find id %d in %s" % (currentItem.id, file)
                    continue
                if target.crc != target.calcCRC():
                    print "Task has changed in project file...keeping that version"
                    print target.asToDo()
                    print
                    continue
                target.initializeParams()
                target.attachToParent(target.parent)
                target.updateFromString(task)
                # This is an exisiting todo, check to see if there are new subtasks
                readGTDProject( target.notes, root=target, maxID=currentroot.maxSubtaskID())
                target.notes = target.extradata
                    
                if target.complete == 100:
                    import time
                    # write out to complete list
                    open(donefile,'a').write( time.asctime(time.localtime(time.time()))+LINESEP+target.asToDo()+LINESEP )

    for r in root.kids:
        olddata = open(r.title).read()
        tasks = tasks+r.tasks()
        newdata = r.asProject() #`r`
        if olddata != newdata:
            if MAKEBACKUPS:
                open(r.title+'.bak','w').write(olddata)
            open(r.title,'w').write(newdata)
    tasks.sort(_byPriority)
    for todofile,contexts in todofiles:
        todofile = _normalizeFilename(todofile)
        f = open(todofile,'w')
        for task in tasks:
            if (not contexts or contextMatches(task.context[0], contexts)):
                allok = True
                for prereq in task.prerequisites:
                    (file, id) = prereq.split('|')
                    if titlemap.has_key( file.lower() ):
                        t = titlemap[ file.lower() ].findSubtaskWithID( int(id) )
                        if t and t.complete < 100:
                            allok = False
                            break
                if allok:
                    f.write( task.asToDo()+LINESEP )
        f.close()

if __name__ == '__main__':
     #  parse arguments
     import string, glob, os
     try: import optparse
     except ImportError: import optik as optparse
     parser = optparse.OptionParser(version = string.split(revision)[1])
     parser.add_option('-d', '--datadir', default = DATADIR, dest = 'dataDir',
             type = 'string',
             help = 'Directory where the input data files exist.')
     parser.add_option('-i', '--input', default = [], action = 'append',
             dest = 'inputFileList', help = 'Add the specified file to the list '
             'of files which are loaded.  May be specified multiple times.  If '
             'used, "--datadir" option is ignored.' )
     parser.add_option('-I', '--input-files-from', default = None,
             dest = 'inputFilesFrom', help = 'Specifies a file to read the '
             'list of input files from.  This list is appended to any specified '
             'with the "--input" option.')
     parser.add_option('--todo', default = TODOFILE,
             dest = 'todoFileName', help = 'Overrides the name of the '
             '"todo.gtd" file.')
     parser.add_option('--done', default = DONEFILE,
             dest = 'doneFileName', help = 'Overrides the name of the '
             '"done.gtd" file.')
     parser.add_option('-c','--context', default = None,
             dest = 'contextNames', help = 'Specifies which contexts to include. If '
                       'omitted, includes all. Multiple contexts may be included, separated '
                       'by commas.')
     options, args = parser.parse_args()
     #  create the list of input files
     inputFileList = options.inputFileList
     if options.inputFilesFrom:
         fp = open(options.inputFilesFrom, 'r')
         for line in fp.xreadlines():
             inputFileList.append(_normalizeFilename(string.rstrip(line)))
         fp.close()
     if not inputFileList:
         for dir, dirs, files in os.walk(options.dataDir):
             for file in files:
                 if os.path.splitext(file)[1].lower() == '.gtd':
                     inputFileList.append(_normalizeFilename(os.path.join(dir,file)))  
     if options.contextNames == None:
         contexts = ['']
     else:
         contexts = options.contextNames.split(',')
     todo(inputFileList, [(options.todoFileName,contexts)], options.doneFileName)
