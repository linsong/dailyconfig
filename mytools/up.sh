#! /usr/bin/env bash

echo "updating codes ..."
#svn up 
#git pull --rebase

echo 
echo "generate tags ..."
# following command add named_scope to tags file
myrtags -R app lib test
#ctags -R --languages=Ruby --regex-Ruby='/^[ \t]*named_scope[ \t]+:([a-zA-Z0-9_]+),/\1/' app lib test

echo
echo "fixing ruby namespace issue in tags file ..."
~/mytools/fix_tags_for_ruby.rb

DIR_LIST="app test lib db config public"
echo
echo "generating file_tags for $DIR_LIST ..."
~/mytools/ftags.sh $DIR_LIST

echo
echo "Done"
