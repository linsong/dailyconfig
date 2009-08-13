#! /usr/bin/env bash

echo '!_TAG_FILE_FORMAT	2	/extended format; --format=1 will not append ;" to lines/' > file_tags
echo '!_TAG_FILE_SORTED	1	/0=unsorted, 1=sorted, 2=foldcase/' >> file_tags
echo '!_TAG_PROGRAM_AUTHOR	Darren Hiebert  /dhiebert@users.sourceforge.net/' >> file_tags
echo '!_TAG_PROGRAM_NAME	Exuberant Ctags //' >> file_tags
echo '!_TAG_PROGRAM_URL	http://ctags.sourceforge.net	/official site/' >> file_tags
echo '!_TAG_PROGRAM_VERSION	5.7	//' >> file_tags

find app test lib db config public \( -name '*.jpg' -or -name '*.png' -or -name '*.swf' -or -name '*.gif' -or -name '*.ico' -or -name '*.swp' -or -name '*.swo' \) -prune -or -path '*/.svn*' -prune -or -path '*/migrate/*' -prune -or -type f -print | ruby -nle 'result = []; result << File.basename($_); result << $_; result << %q{/^/;"} << "c"; puts result.join("\t")' | sort >> file_tags
