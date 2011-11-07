#! /usr/bin/env bash

#echo "updating codes ..."

#echo 
#echo "generate tags ..."

# general commands 
myrtags .  # generate tags
ftags.sh . # generate ftags


# following codes works well for ruby files, but not general enough for other langs, need to improve
## following command add named_scope to tags file
#myrtags app lib test
##ctags -R --languages=Ruby --regex-Ruby='/^[ \t]*named_scope[ \t]+:([a-zA-Z0-9_]+),/\1/' app lib test

#echo
#echo "fixing ruby namespace issue in tags file ..."
#~/mytools/fix_tags_for_ruby.rb

#DIR_LIST="app test lib db config public"
#echo
#echo "generating file_tags for $DIR_LIST ..."
#~/mytools/ftags.sh $DIR_LIST

#echo
#echo "Done"
