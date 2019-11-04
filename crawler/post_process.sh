#!/bin/bash

filter_dir="filter_dir"
text_dir="filter_dir/txt"

# start gentle docker
sudo docker run -d -p 8765:8765 -P lowerquality/gentle 

# post processing
# iterate over all data <wav,text> pairs and pass through gentle

for dir in $filter_dir/wav/*/     # list directories in the form "/tmp/dirname/"
do
    dir=${dir%*/}      # remove the trailing "/"
    echo ${dir##*/}    # print everything after the final "/"
    dir_base_name="$(basename $dir)"
    # now for each subdirectory iterate over all wav files

    for filename in $dir/*.wav; do
    [ -e "$filename" ] || continue

    # also get corresponding transcription / text having same name
    echo $filename
    base_filename="$(basename $filename)"
    base_name_changed=${base_filename%.wav}.txt
    #echo "$base_filename"
    text_file="${dir}"/txt/
    #echo "$text_file"
    #text_file2= "${text_file}" echo ${base_filename}
    text_file2="${text_dir}/$dir_base_name/${base_name_changed}"
    echo "${text_file2}"

    # now send api request to local gentle server
    #curl -F "audio=${filename}" -F "transcript=@${text_file2}" "http://localhost:8765/transcriptions?async=false"
    result=$(curl -o result.json -X POST -F "audio=@${filename}" -F "transcript=<${text_file2}" 'http://localhost:8765/transcriptions?async=false') 
    #result=$(curl  -X POST -F "audio=@${filename}" -F "transcript=<${text_file2}" 'http://localhost:8765/transcriptions?async=false') 
    #echo $result

    # process using python script
    #python3 post_process_json.py -wav_file ${filename} -txt_file ${text_file2}

    #mapfile -t myarray <<"python3 post_process_json.py -wav_file ${filename} -txt_file ${text_file2}"

    #python_results=$(python3 post_process_json.py -wav_file ${filename} -txt_file ${text_file2})
    #echo ${python_results}
    #echo ${python_results[1]}
    #echo ${python_results[2]}

    #python3 post_process_json.py -wav_file ${filename} -txt_file ${text_file2} | while read line ; do
    #echo $line
    
    #done

    myarray=()
   while read line ; do
   myarray+=($line)
  done < <(python3 post_process_json.py -wav_file ${filename} -txt_file ${text_file2})
  #echo ${myarray[0]}

    if [ ${myarray[0]} = 0 ]; then
    
        echo "bad aligned sentence ignoring" 
        rm ${filename}
        rm  ${text_file2}
       
    else
    
          # trim according to end time and save with same filename this is because we can use the webserver viewer code
      
          ffmpeg -i $filename -ss ${myarray[0]} -to ${myarray[1]} -y -c copy $filename
    fi
    
    #get the json result and trim audio based on last gentle word ending time
    #end_time="$(echo $result | jq .words | jq 'map(select(.end != null))[-1].end')"   
    #echo $end_time


   

done

done









