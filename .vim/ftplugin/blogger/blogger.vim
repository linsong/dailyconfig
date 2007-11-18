" Vim-BloggerBeta Preamble"{{{
" Make sure the Vim was compiled with +python before loading the script...
if !has("python")
    finish
endif

" Only load this plugin if it's not already loaded.
if exists('g:BloggerLoaded')
    finish
endif
let g:BloggerLoaded = 1

if ((exists('g:Blog_Use_Markdown')) && g:Blog_Use_Markdown == 1)
    let g:Blog_Use_Markdown = 1
else
    let g:Blog_Use_Markdown = 0
endif
"}}}

" Setup Vim-Blogger Custom Commands"{{{
:command! BlogPost :call BloggerPost()
:command! BlogDraft :call BloggerDraft()
:command! -nargs=? BlogIndex :call BloggerIndex("<args>")
:command! -nargs=? BlogQuery :call BloggerIndexLabel("<args>")
:command! -nargs=? BlogDelete :call BloggerDelete("<args>")
"}}}

" Vim Functions (These simply call their Python counterparts below)"{{{
function! BloggerDelete(args)
python << EOF
Delete()
EOF
endfunction

function! BloggerPost()
python << EOF
Post()
EOF
endfunction

function! BloggerDraft()
python << EOF
Post(True)
EOF
endfunction

function! BloggerIndex(args)
python << EOF
import vim
args = vim.eval('a:args').split()
try:
    args = [int(arg) for arg in args]
except (TypeError, ValueError), e:
    args = [5]
     
GetPosts(args)
EOF
endfunction

function! BloggerIndexLabel(args)
python << EOF
import vim
labels = vim.eval('a:args').split(",")
GetPostsByLabel(labels)
EOF
endfunction

"}}}

" Python Preamble {{{
python << EOF

import sys
import re
import vim

vim.command("let path = expand('<sfile>:p:h')")
PYPATH = vim.eval('path')
sys.path += [r'%s' % PYPATH]

import html2text
import markdown
import blogger

try:
    blogURI = vim.eval("g:Blog_URI")
except vim.error:
    print "Error: g:Blog_URI variable not set."

b = blogger.Blogger(blogURI)

BLOGGER_POSTS = None
#}}}

def getBloggerPost():
    global BLOGGER_POSTS
    if not BLOGGER_POSTS:
        BLOGGER_POSTS = b.getPosts()
    return BLOGGER_POSTS

def ChoosePost(num, start_index):
    posts = getBloggerPost()
    if int(start_index+num) > len(posts):
        num = len(posts)-start_index
    elif int(num) < 1:
        print "Invalid post number."
        return None

    keys = posts.keys()
    for i in range(num):
        key = keys[start_index+i]
        post = posts[key]
        if post['draft']:
            print str(i+1) + ':' + post['title'] + '        **DRAFT**'
        else:
            print str(i+1) + ':' + post['title']

    vim.command('let choice = input("Enter number or ENTER: ")')
    
    try:
        choice = int(vim.eval('choice'))
        key = keys[start_index+choice-1]
    except (TypeError, ValueError), e:
        key = None
    return key

def GetPostsByLabel(labels):  #{{{
    if not len(labels):
        print "No labels given for query, return now ..."
        return

    posts = b.getPostsByLabel(labels)
    if posts:
        post_key = ChoosePost(len(posts), 0)
        if post_key:
            EditPost(post_key)
        else:
            print "Nothing selected, return now ..."
    else:
        print "Don't find any post for labels: %s" % labels
# }}}

def GetPosts(args):  #{{{
    posts = getBloggerPost()

    if len(args)>=1:
        num = args[0]
    else:
        num = len(posts)

    if len(args)>=2:
        start_index = args[1]
    else:
        start_index = 0

    if not len(posts):
        print "You have no blog posts to index."
        return

    post_key = ChoosePost(num, start_index)
    if post_key:
        EditPost(post_key)
    else:
        print "Nothing selected, return now ..."
# }}}

def EditPost(post_key): # 
    # Don't overwrite any currently open buffer.. TODO:What's the best way?
    tmp_blog_file = vim.eval("tempname() . '.blogger'")
    if vim.current.buffer.name: # Does this buffer have a name? 
        if not vim.current.buffer.name.endswith(".blogger"):
            vim.command('e! %s' % tmp_blog_file)
    else: # buffer has no name, just open the tmp one for now...
        vim.command('e! %s' % tmp_blog_file)

    vim.command('set foldmethod=marker')
    vim.command('set nomodified')

    vim.current.buffer[:] = []
    vim.current.buffer[0] = '@@EDIT@@ %s' % post_key

    posts = getBloggerPost()
    post = posts[post_key]
    title = post['title']
    vim.current.buffer.append(str(title))
    vim.current.buffer.append('')

    if not (vim.eval("g:Blog_Use_Markdown") == '0'):
        use_markdown = True
    else:
        use_markdown = False
    if use_markdown:
        # FIXME: it seems html2text only accept Unicode string, but not UTF-8
        # to workaround this, I convert content to Unicode before passing
        # them to html2text and convert it back to UTF-8 when html2text is done
        content = post['content']
        content = html2text.html2text(content).encode('utf-8')
        #content = html2text.html2text(posts['content'])
    else:
        content = post['content']

    for line in str(content).split('\n'):
        vim.current.buffer.append(line)
    cat_str = '@@LABELS@@ ' + ', '.join(post['categories'])
    vim.current.buffer.append(str(cat_str))

    vim.command('set nomodified')
        
def Post(draft=False):  # {{{
    authenticate()

    categories = []
    has_labels = False
    numlines = len(vim.current.buffer)
    match = re.search('^@@LABELS@@ (.*)', vim.current.buffer[numlines-1])
    if match:
        categories = match.group(1).split(',')
        has_labels = True

    match = re.search('^@@EDIT@@ (.*)$', vim.current.buffer[0])
    if not (vim.eval("g:Blog_Use_Markdown") == '0'):
        use_markdown = True
    else:
        use_markdown = False

    if match:
        # it means this is old blog article, we will update it
        post_key = match.group(1).strip()
        subject = vim.current.buffer[1]
        if has_labels:
            if use_markdown:
                content = '\n'.join(vim.current.buffer[3:-1])
                body = markdown.markdown(content.decode('utf-8'))
                body = body.encode('utf-8')
            else:
                body = '\n'.join(vim.current.buffer[3:-1])
        else:
            if use_markdown:
                content = '\n'.join(vim.current.buffer[3:-1])
                body = markdown.markdown(content.decode('utf-8'))
                body = body.encode('utf-8')
            else:
                body = '\n'.join(vim.current.buffer[3:])
    else:
        # this is a new post
        post_key = None
        subject = vim.current.buffer[0]
        if has_labels:
            body = '\n'.join(vim.current.buffer[2:-1])
            if use_markdown:
                body = markdown.markdown(body.decode('utf-8'))
                body = body.encode('utf-8')
        else:
            body = '\n'.join(vim.current.buffer[2:])
            if use_markdown:
                body = markdown.markdown(body.decode('utf-8'))
                body = body.encode('utf-8')

    posts = getBloggerPost()
    # construct a post object for posting
    if post_key:
        # it's an update
        post = posts[post_key]
        post['title'] = subject
        post['content'] = body
        post['categories'] = categories
        b.updatePost(post, draft)
        post['draft'] = draft
    else:
        post = {}
        post['title'] = subject
        post['content'] = body
        post['categories'] = categories
        result = b.newPost(post, draft)
        posts.update(result)
        post_key = result.keys()[0]
        posts[post_key]['draft'] = draft
        vim.current.buffer[0:0] = ['@@EDIT@@ %s' % post_key]
    print "Post successful!"
# }}}

def Delete(): # {{{
    authenticate()

    posts = getBloggerPost()
    post_key = ChoosePost(len(posts), 0)
    if not post_key:
        print "Nothing specified, return now"
        return 

    post = posts[post_key]
    vim.command('let choice = input("Are you sure to delete `%s`?: ")' % post['title'])
    choice = vim.eval('choice')
    if choice.lower()=='yes' or choice.lower()=='y':
        b.Delete(post)
        del posts[post_key]
    else:
        return
# }}}

def authenticate():   #{{{
    if b.isLogin():
        return 

    try:
        account = vim.eval("g:Gmail_Account")
    except vim.error:
        print "Error: g:Gmail_Account variable not set."
        return None

    # NOTE: it seems vim.eval will always return string
    try:
        has_password = vim.eval("exists('g:Gmail_Password')") != '0'
        if has_password:
            password = vim.eval("g:Gmail_Password")
        else:
            has_password = vim.eval("exists('s:Gmail_Password')") != '0'
            if has_password:
                password = vim.eval("s:Gmail_Password")
            else:
                # store password into a script scope variable to make it a bit secure
                vim.command('let s:Gmail_Password = inputsecret("Gmail Password: ")')
                password = vim.eval('s:Gmail_Password')
    except vim.error, e:
        print "Error: exception(%s) happends when getting password." % str(e)
        return None

    try:
        b.login(account, password)
    except Exception, e:
        # since the authorization failed, we should not remember the password
        vim.command("unlet s:Gmail_Password")
        raise

EOF
