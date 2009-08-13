echo "updating codes ..."
svn up 

echo 
echo "generate tags ..."
ctags -R app lib test 

echo
echo "fixing ruby namespace issue in tags file ..."
~/mytools/fix_tags_for_ruby.rb

DIR_LIST="app test lib db config public"
echo
echo "generating file_tags for $DIR_LIST ..."
~/tools/gen_rails_file_tags.sh $DIR_LIST

echo
echo "Done"
