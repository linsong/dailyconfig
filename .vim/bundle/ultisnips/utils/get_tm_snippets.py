#!/usr/bin/env python
# encoding: utf-8

import urllib
import re
import glob
from xml.etree import ElementTree
from xml.parsers.expat import ExpatError
import htmlentitydefs

_UNESCAPE = re.compile(ur'&\w+?;', re.UNICODE)
def unescape(s):
    if s is None:
        return ""
    def fixup(m):
        ent = m.group(0)[1:-1]
        print ent
        return unichr(htmlentitydefs.name2codepoint[ent])
    try:
        return _UNESCAPE.sub(fixup,s.decode("utf-8")).encode("utf-8")
    except:
        try:
            print s.decode("utf-8")
        except:
            return ""

def parse_content(c):
    try:
        data = ElementTree.fromstring(c)[0]

        rv = {}
        for k,v in zip(data[::2], data[1::2]):
            rv[k.text] = unescape(v.text)

        return rv
    except ExpatError:
        print "   Syntax Error"
        return None

def fetch_snippets(name):
    base_url = "http://svn.textmate.org/trunk/Bundles/" + name + ".tmbundle/"
    snippet_idx = base_url + "Snippets/"

    idx_list = urllib.urlopen(snippet_idx).read()


    rv = []
    for link in re.findall("<li>(.*?)</li>", idx_list):
        m = re.match(r'<a\s*href="(.*)"\s*>(.*)</a>', link)
        link, name = m.groups()
        if name == "..":
            continue

        name = unescape(name.rsplit('.', 1)[0]) # remove Extension
        print "Fetching data for Snippet '%s'" % name
        content = urllib.urlopen(snippet_idx + link).read()

        cont = parse_content(content)
        if cont:
            rv.append((name, cont))

    return rv


def write_snippets(snip_descr, f):

    for name, d in snip_descr:
        if "tabTrigger" not in d:
            continue

        f.write('snippet %s "%s"\n' % (d["tabTrigger"], name))
        f.write(d["content"].encode("utf-8") + "\n")
        f.write("endsnippet\n\n")

def get_bundle(bundle):
    print "Getting bundle for '%s'" % bundle
    if bundle.endswith('/'):
      rv = fetch_snippets_from_folder(bundle)
      write_snippets(rv, open("tm_cucumber.snippets","w"))
    else:
      rv = fetch_snippets(bundle)
      write_snippets(rv, open("tm_" + bundle.lower() + ".snippets","w"))

def get_all_bundles():
    url = "http://svn.textmate.org/trunk/Bundles/"
    content = urllib.urlopen(url).read()
    names = []
    for link in re.findall("<li>(.*?)</li>", content):
        m = re.match(r'<a\s*href="(.*)\.tmbundle/"\s*>(.*).tmbundle/</a>', link)
        if not m:
          continue

        link, name = m.groups()
        names.append(name)
    for name in names:
      get_bundle(name)

def fetch_snippets_from_folder(bundle):
  import pdb, readline; pdb.set_trace();
  rv = []
  for fname in glob.glob(bundle + "*.tmSnippet"):
    name = unescape(fname.rsplit('.', 1)[0].split('/')[-1]) # remove Extension
    print "Fetching data for Snippet '%s'" % name
    content = file(fname).read()
    cont = parse_content(content)
    if cont:
        rv.append((name, cont))
  return rv

if __name__ == '__main__':
    import sys

    bundle = sys.argv[1]
    if bundle == 'all':
      get_all_bundles()
    else:
      get_bundle(bundle)




