# -*- coding: utf-8 -*-
import urllib
import urllib2
import vim
import xml.dom.minidom
import xmlrpclib
import sys
import string
import re

#####################
#      Settings     #
#####################

enable_tags = 0
enable_markdown = 0
blog_username = ''
blog_password = ''
blog_url = 'http://blog.linsong.org/xmlrpc.php'

if vim.eval('g:Blog_Use_Markdown')=='1':
    enable_markdown = 1
    import html2text
    #import markdown
    import markdown2 as markdown

#####################
# Do not edit below #
#####################

handler = xmlrpclib.ServerProxy(blog_url).metaWeblog
edit = 1

def blog_edit_off():
  global edit
  if edit:
    edit = 0
    for i in ["i","a","s","o","I","A","S","O"]:
      vim.command('map '+i+' <nop>')

def blog_edit_on():
  global edit
  if not edit:
    edit = 1
    for i in ["i","a","s","o","I","A","S","O"]:
      vim.command('unmap '+i)

def blog_send_post():
  def get_line(what):
    start = 0
    while not vim.current.buffer[start].startswith('"'+what):
      start +=1
    return start
  def get_meta(what):
    start = get_line(what)
    end = start + 1
    while not vim.current.buffer[end][0] == '"':
      end +=1
    return " ".join(vim.current.buffer[start:end]).split(":")[1].strip()

  strid = get_meta("StrID")
  title = get_meta("Title")
  cats = [i.strip() for i in get_meta("Cats").split(",")]
  if enable_tags:
    tags = get_meta("Tags")

  text_start = 0
  while not vim.current.buffer[text_start] == "\"========== Content ==========":
    text_start +=1
  text_start +=1
  text = '\n'.join(vim.current.buffer[text_start:])

  if enable_markdown:
    content = markdown.markdown(text.decode('utf-8')).encode('utf-8')
  else:
    content = text

  if enable_tags:
    post = {
      'title': title,
      'description': content,
      'categories': cats,
      'mt_keywords': tags
    }
  else:
    post = {
      'title': title,
      'description': content,
      'categories': cats,
    }

  authenticate()
  if strid == '':
    strid = handler.newPost('', blog_username,
      blog_password, post, 1)

    vim.current.buffer[get_line("StrID")] = "\"StrID : "+strid
  else:
    handler.editPost(strid, blog_username,
      blog_password, post, 1)

  vim.command('set nomodified')


def blog_new_post():
  def blog_get_cats():
    authenticate()
    l = handler.getCategories('', blog_username, blog_password)
    s = ""
    for i in l:
      s = s + (i["description"].encode("utf-8"))+", "
    if s != "": 
      return s[:-2]
    else:
      return s
  del vim.current.buffer[:]
  blog_edit_on()
  vim.command("set syntax=blogsyntax")
  vim.current.buffer[0] =   "\"=========== Meta ============\n"
  vim.current.buffer.append("\"StrID : ")
  vim.current.buffer.append("\"Title : ")
  vim.current.buffer.append("\"Cats  : "+blog_get_cats())
  if enable_tags:
    vim.current.buffer.append("\"Tags  : ")
  vim.current.buffer.append("\"========== Content ==========\n")
  vim.current.buffer.append("\n")
  vim.current.window.cursor = (len(vim.current.buffer), 0)
  vim.command('set nomodified')
  vim.command('set textwidth=0')

def blog_open_post(id):
  try:
    authenticate()
    post = handler.getPost(id, blog_username, blog_password)
    blog_edit_on()
    vim.command("set syntax=blogsyntax")
    del vim.current.buffer[:]
    vim.current.buffer[0] =   "\"=========== Meta ============\n"
    vim.current.buffer.append("\"StrID : "+str(id))
    vim.current.buffer.append("\"Title : "+(post["title"]).encode("utf-8"))
    vim.current.buffer.append("\"Cats  : "+",".join(post["categories"]).encode("utf-8"))
    if enable_tags:
      vim.current.buffer.append("\"Tags  : "+(post["mt_keywords"]).encode("utf-8"))
    vim.current.buffer.append("\"========== Content ==========\n")
    if enable_markdown:
        content = html2text.html2text(post["description"]).encode("utf-8")
    else:
        content = (post["description"]).encode("utf-8")
    for line in content.split('\n'):
      vim.current.buffer.append(line)
    text_start = 0
    while not vim.current.buffer[text_start] == "\"========== Content ==========":
      text_start +=1
    text_start +=1
    vim.current.window.cursor = (text_start+1, 0)
    vim.command('set nomodified')
    vim.command('set textwidth=0')
  except:
    sys.stderr.write("An error has occured")

def blog_list_edit():
  try:
    row,col = vim.current.window.cursor
    id = vim.current.buffer[row-1].split()[0]
    blog_open_post(int(id))
  except:
    pass

def blog_list_posts():
  try:
    authenticate()
    lessthan = handler.getRecentPosts('',blog_username, blog_password,1)[0]["postid"]
    size = len(lessthan)
    allposts = handler.getRecentPosts('',blog_username, blog_password,int(lessthan))
    del vim.current.buffer[:]
    vim.command("set syntax=blogsyntax")
    vim.current.buffer[0] = "\"====== List of Posts ========="
    for p in allposts:
      vim.current.buffer.append(("".zfill(size-len(p["postid"])).replace("0", " ")+p["postid"])+"\t"+(p["title"]).encode("utf-8"))
      vim.command('set nomodified')
    blog_edit_off()
    vim.current.window.cursor = (2, 0)
    vim.command('map <enter> :py blog_list_edit()<cr>')
  except:
    sys.stderr.write("An error has occured")

def authenticate():
  global blog_username
  global blog_password
  try:
    blog_username = vim.eval("g:Blog_Account")
  except vim.error:
    print "Error: g:Blog_Account variable not set."

  # NOTE: it seems vim.eval will always return string
  try:
    has_password = vim.eval("exists('g:Blog_Password')") != '0'
    if has_password:
      blog_password = vim.eval("g:Blog_Password")
    else:
      vim.command('let g:Blog_Password = inputsecret("Blog Password: ")')
      blog_password = vim.eval('g:Blog_Password')

      #has_password = vim.eval("exists('s:Blog_Password')") != '0'
      #if has_password:
      #  blog_password = vim.eval("s:Blog_Password")
      #else:
      #  # store password into a script scope variable to make it a bit secure
      #  vim.command('let s:Blog_Password = inputsecret("Blog Password: ")')
      #  blog_password = vim.eval('s:Blog_Password')
  except vim.error, e:
    print "Error: exception(%s) happends when getting password." % str(e)
