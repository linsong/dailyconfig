#! /usr/bin/python2.3
"""
  <+DOC STRING+>
"""

import sys
import httplib2
import re
import urlparse
import xml.dom.minidom as minidom

class Blogger:
    def __init__(self, blogURI):
        self.blog_uri = blogURI
        self.google_auth = None
        self.google_auth_uri = 'https://www.google.com/accounts/ClientLogin'
        self._blog_id = None
        self._http_conn = None
        self.posts = {}

    def _getHttpConn(self):
        if not self._http_conn:
            self._http_conn = httplib2.Http()
        return self._http_conn

    def _getBlogID(self):
        if not self._blog_id:
            conn = self._getHttpConn()
            response, content = conn.request(self.blog_uri, 'GET')
            match = re.search('blogID=(\d*)', content)
            if match:
                self._blog_id = match.group(1)
            else:
                raise Exception(
                    "Can not get BlogID, Google changed the interface?")
        return self._blog_id

    def _getPosts(self, query_uri):
        """
        return all posts dictionay

        edit_url is the key for every post
        every post is a dictionay
        """
        conn = self._getHttpConn()

        print "Retrieving posts..."
        if self.google_auth:
            headers = {'Content-Type': 'application/atom+xml', 'Authorization': 'GoogleLogin auth=%s' % self.google_auth.strip()}
            response, content = conn.request(query_uri, "GET", headers=headers)
        else:
            response, content = conn.request(query_uri, "GET")

        if response['status'] == '200':
            return self._extractPost(content)
        else:
            print "Error getting post feed."
            return None

    def _getTextDataFromNode(self, node):
        for n in node.childNodes:
            if n.nodeType == minidom.Node.TEXT_NODE:
                return n.data
        return None

    def _convertEncoding(self, text):
        """
        input text must be in Unicode encoding
        """
        return text.encode('utf-8')

    def _extractPost(self, xml_content):
        posts = {}
        doc = minidom.parseString(xml_content)
        for entryNode in doc.getElementsByTagName('entry'):
            post = {}
            for node in entryNode.getElementsByTagName('link'):
                attr = self._convertEncoding(node.getAttribute('rel')+"_url")
                post[attr] = self._convertEncoding(node.getAttribute('href'))

            for attr in ['title', 'content', 'id', 'updated']:
                node = entryNode.getElementsByTagName(attr)[0]
                post[attr] = self._convertEncoding(
                    self._getTextDataFromNode(node))

            categoryNodes = entryNode.getElementsByTagName('category')
            categories = []
            for node in categoryNodes:
                label = node.getAttribute('term').strip()
                if not label == '':
                    categories.append(self._convertEncoding(label))
            post['categories'] = categories
            if entryNode.getElementsByTagName('app:draft'):
                post['draft'] = True
            else:
                post['draft'] = False
            assert post.has_key('edit_url')
            key = post['edit_url']
            posts[key] = post
        return posts

    def _getCategoriesXML(self, post):
        cat_str = ''
        for category in post['categories']:
            if not category.strip() == '':
                cat_str = cat_str + '<category scheme="http://www.blogger.com/atom/ns#" term="%s"/>' % category
        return cat_str

    def _isNewPost(self, post):
        return post.has_key('id') and post['id']:

    def _draftToXML(self, post):
        if self._isNewPost(post):
            entry = """<?xml version="1.0"?>
                <entry xmlns="http://www.w3.org/2005/Atom">
                <app:control xmlns:app='http://purl.org/atom/app#'>
                    <app:draft>yes</app:draft>
                </app:control>
                  <title type="text">%s</title>
                  <content type="xhtml">%s</content>
                  %s
                </entry>""" % (post['title'],
                               post['content'],
                               self._getCategoriesXML(post))
        else:
            entry = """<?xml version="1.0"?>
                <entry xmlns="http://www.w3.org/2005/Atom">
                <app:control xmlns:app='http://purl.org/atom/app#'>
                    <app:draft>yes</app:draft>
                </app:control>
                  <id>%s</id>
                  <link rel='edit' href='%s'/>
                  <updated>%s</updated>
                  <title type="text">%s</title>
                  <content type="xhtml">%s</content>
                  %s
                </entry>""" % (post['id'],
                               post['edit_url'],
                               post['updated'],
                               post['title'],
                               post['content'],
                               self._getCategoriesXML(post))
        return entry

    def _postToXML(self, post):
        if self._isNewPost(post):
            entry = """<?xml version="1.0"?>
                <entry xmlns="http://www.w3.org/2005/Atom">
                  <title type="text">%s</title>
                  <content type="xhtml">%s</content>
                  %s
                </entry>""" % (post['title'],
                               post['content'],
                               self._getCategoriesXML(post))
        else:
            entry = """<?xml version="1.0"?>
                <entry xmlns="http://www.w3.org/2005/Atom">
                  <id>%s</id>
                  <link rel='edit' href='%s'/>
                  <updated>%s</updated>
                  <title type="text">%s</title>
                  <content type="xhtml">%s</content>
                  %s
                </entry>""" % (post['id'],
                               post['edit_url'],
                               post['updated'],
                               post['title'],
                               post['content'],
                               self._getCategoriesXML(post))

        return entry

    def _preparePost(self, post, draft):
        if draft:
            entry = self._draftToXML(post)
        else:
            entry = self._postToXML(post)
        return entry

    def _doRequest(self, uri, method, body, headers):
        conn = self._getHttpConn()
        response, content = conn.request(uri, method, body=body, headers=headers)

        # follow redirects
        while response['status'] == '302':
            response, content = conn.request(response['location'], method,
                                             body=body, headers=headers)

        if ((method=='POST' and response['status'] == '201') or
            (method=='PUT' and response['status'] == '200') or
            (method=='DELETE' and response['status'] == '200')):
            print "Method %s successful!" % method
            return content
        else:
            print "Method %s failed: %s %s" % (method, response['status'], content)
            return None

    def _updatePost(self, post_url, entry):
        conn = self._getHttpConn()
        headers = {'Content-Type': 'application/atom+xml',
                   'Authorization': 'GoogleLogin auth=%s' % self.google_auth.strip()}

        if self._doRequest(post_url, 'PUT', entry, headers):
            print "Entry successfully updated."
            return True
        else:
            print "Entry update failed."
            return False

    def login(self, username, password):
        if not username:
            print "username(%s) is not correct!"
        if not password:
            print "password(%s) is not correct!"

        headers = {'Content-Type': 'application/x-www-form-urlencoded'}
        # TODO: use "Blogger-0.1" instead of 'dcraven-Vim-Blogger-0.1'
        auth_request = ("Email=%s&Passwd=%s&service=blogger&service=dcraven-Vim-Blogger-0.1" % (username, password))
        conn = self._getHttpConn()
        response, content = conn.request(self.google_auth_uri, 'POST',
                                         body=auth_request, headers=headers)
        if response['status'] == '200':
            self.google_auth = re.search('Auth=(\S*)', content).group(1)
            return True
        else:
            print "response: %s; content: %s" % (response, content)
            # since the authorization failed, we should not remember the password
            return False

    def getPosts(self):
        """
        return all posts dictionay

        edit_url is the key for every post
        every post is a dictionay
        """
        blog_id = self._getBlogID()
        post_uri = 'http://www.blogger.com/feeds/%s/posts/full' % blog_id
        return self._getPosts(post_uri)

    def getPostsByLabel(self, labels):  #{{{
        """
        get posts by labels
        """
        #TODO: merge this function with getPost
        blog_id = self._getBlogID()
        if not len(labels):
            print "Please specify labels to query..."
            return None

        labellist = ''
        for label in labels:
            labellist += "/%s" % label.strip()

        labels_query_uri = 'http://beta.blogger.com/feeds/%s/posts/default/-%s' % (blog_id, labellist)
        return self._getPosts(labels_query_uri)


    def newPost(self, post, draft=False):
        if not self.google_auth:
            raise Exception("You have not log in")

        entry = self._preparePost(post, draft)

        blog_id = self._getBlogID()
        post_uri = 'http://www.blogger.com/feeds/%s/posts/full' % blog_id

        headers = {'Content-Type': 'application/atom+xml', 'Authorization': 'GoogleLogin auth=%s' % self.google_auth.strip()}

        content = self._doRequest(post_uri, 'POST', entry, headers):
        if content:
            return self._extractPost(content)
        else:
            return None

    def updatePost(self, post, draft=False):
        if not self.google_auth:
            raise Exception("You have not log in")

        entry = self._preparePost(post, draft)

        # it's an update
        return self._updatePost(post['edit_url'], entry)

    def Delete(self, post):
        if not self.google_auth:
            raise Exception("You have not log in")

        headers = {'Content-Type': 'application/atom+xml', 'Authorization': 'GoogleLogin auth=%s' % self.google_auth.strip()}

        if self._doRequest(post['edit_url'],
                           'DELETE',
                           body=None,
                           headers=headers):
            print "Entry successfully deleted."
            return True
        else:
            return False

if __name__ == '__main__':
    pass
