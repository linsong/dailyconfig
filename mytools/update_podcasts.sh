#! /usr/bin/env bash
podcatcher --dir ~/Music/podcasts -v -p -S all 'http://rss.conversationsnetwork.org/series/stackoverflow.xml' 'http://feeds.feedburner.com/EnglishAsASecondLanguagePodcast?format=xml'
growlnotify -s -n "ShellNotification" -m "Podcasts updated!" "Podcatcher" 2>/dev/null;
