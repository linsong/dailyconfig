#!/bin/bash
################################################################################
### my crontab for streamrecorder to record studio classroom 
# # Weird! cron treat '%' as new line character, unless escaped with backslash (\)
# # m h  dom mon dow   command
#   29 21  *   *   1-6  /home/vincent/mytools/streamrecorder.sh -t 31 /home/vincent/download/mp3/studio_classroom/studio_classroom_$(date +\%Y-\%m-\%d-\%H-\%M-\%S).mp3
#   29 21  *   *   7    /home/vincent/mytools/streamrecorder.sh -t 31 /home/vincent/download/mp3/studio_classroom/advance_english_$(date +\%Y-\%m-\%d-\%H-\%M-\%S).mp3
#   0  2   *   *   6     podget
#   0 22   *   *   *     sudo shutdown -P +15

set -x 
cmdname=$( echo $0 | sed s:.*/:: )
#TIME_LENGTH=1 # in minute
#TIME_LENGTH=31 # in minute
FILE_PREFIX=$(date +%Y-%m-%d-%M-%S)
BUFFER_FILE=/tmp/stream_recorder_buffer_${FILE_PREFIX}
#DEST_FILE=/home/vincent/download/mp3/studio_classroom/studio_classroom_${FILE_PREFIX}.mp3

case :$1: in
    :-t:)
        shift
        TIME_LENGTH=$1
        shift
        ;;
    :-h:)
        echo "USAGE: $cmdname [OPTIONS] download_file_name"
        echo "OPTIONS"
        echo ""
        echo "  -t TIMELENGTH_IN_MINUTE  download how long stream"
        echo "  -h                       print this help "
        echo ""
        exit 0 
        ;;
esac

DEST_FILE=${1:?'You must specify a name for the download file.'}
TIME_LENGTH=${TIME_LENGTH:-31} # default download 31 minutes

mkfifo $BUFFER_FILE
# echo "Start to connecting to broadcaster ..."
mplayer -nolirc mms://211.89.225.101/live2 -ao pcm:file=$BUFFER_FILE -vc dummy -vo null &

# stop recording after some minutes
echo "kill $!" | at now + $TIME_LENGTH minutes

lame -h $BUFFER_FILE  $DEST_FILE 
rm $BUFFER_FILE

