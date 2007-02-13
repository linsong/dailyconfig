#!/bin/sh
#TIME_LENGTH=1 # in minute
TIME_LENGTH=31 # in minute
FILE_PREFIX=$(date +%Y-%m-%d-%M-%S)
BUFFER_FILE=/tmp/studio_classroom_buffer_${FILE_PREFIX}
DEST_FILE=/home/vincent/download/mp3/studio_classroom/studio_classroom_${FILE_PREFIX}.mp3

mkfifo $BUFFER_FILE
# echo "Start to connecting to broadcaster ..."
mplayer -nolirc mms://211.89.225.101/live2 -ao pcm:file=$BUFFER_FILE -vc dummy -vo null &

# stop recording after some minutes
echo "kill $!" | at now + $TIME_LENGTH minutes

lame -h $BUFFER_FILE  $DEST_FILE 
rm $BUFFER_FILE

