#!/bin/bash
trap "exit" INT

target_dir=$1
filter_dir=$2

declare -a arr=("boy meets world" "two" )


# get length of an array
arraylength=${#arr[@]}

# use for loop to read all values and indexes
for (( i=1; i<${arraylength}+1; i++ ));
do
          echo $i " / " ${arraylength} " : " ${arr[$i-1]}
          youtube-dl --download-archive ./en-downloaded.txt --no-overwrites -f mp4 --restrict-filenames --youtube-skip-dash-manifest --prefer-ffmpeg --socket-timeout 20  -iwc --write-info-json -k --write-srt --sub-format ttml --sub-lang en --convert-subs vtt  "https://www.youtube.com/results?sp=EgQIBCgB&q="${arr[$i-1]}"&p="$i -o "$target_dir/%(id)s%(title)s.%(ext)s" --exec "python ./crawler/process.py {} '$filter_dir'"
done


