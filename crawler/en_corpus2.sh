#!/bin/bash
trap "exit" INT

target_dir=$1
filter_dir=$2



youtube-dl --download-archive ./en-downloaded.txt --no-overwrites -f mp4 --restrict-filenames --youtube-skip-dash-manifest --prefer-ffmpeg --socket-timeout 20  -iwc --write-info-json -k --write-auto-sub  --sub-format ttml --sub-lang en --convert-subs vtt "ytsearch:mr feeny boy meets world"  -o "$target_dir%(id)s%(title)s.%(ext)s" --exec "python3 ./crawler/process.py {} '$filter_dir'"


