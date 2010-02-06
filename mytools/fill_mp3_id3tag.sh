#! /usr/bin/env bash

#echo "Delete all id tags ..."
#for i in *.mp3 ; do id3v2 -D "$i" ; done

echo "Copy file name to id3 v1 tags"
for i in *.mp3 ; do id3v2 -1 -t "$(basename "$i" .mp3)" "$i"; done

echo "Done!"
