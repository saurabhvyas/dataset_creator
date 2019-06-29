#!/bin/bash
trap "exit" INT

target_dir=$1
filter_dir=$2

declare -a arr=("boy meets world" "kim possible" )

# num of videos to download per keyword
num=3

# get length of an array
arraylength=${#arr[@]}

# use for loop to read all values and indexes
for (( i=1; i<${arraylength}+1; i++ ));
do

  for j in `seq 1 2`;
  do
          echo "PAGE="$j

          echo $i " / " ${arraylength} " : " ${arr[$i-1]}
          
          #youtube-dl -o "$target_dir/%(id)s%(title)s.%(ext)s" "https://www.youtube.com/results?sp=EgQIBCgB&q="${arr[$i-1]}"&p="$j --download-archive ./en-downloaded.txt --no-overwrites --restrict-filenames --youtube-skip-dash-manifest --max-downloads 3 --socket-timeout 20 -iwc --write-info-json -k --write-auto-sub --skip-download  --sub-format vtt --sub-lang en    --extract-audio --audio-format "wav"  --exec "python ./crawler/process.py {} '$filter_dir'"
          youtube-dl -o "$target_dir/%(id)s%(title)s.%(ext)s" "ytsearch${num}:${arr[$i-1]}" --download-archive ./en-downloaded.txt --no-overwrites --restrict-filenames --youtube-skip-dash-manifest --max-downloads 20 --socket-timeout 20 -iwc --write-info-json -k --write-auto-sub   --sub-format vtt --sub-lang en    --extract-audio --audio-format "wav"  --exec "python ./crawler/process.py {} '$filter_dir'"
  done
done

