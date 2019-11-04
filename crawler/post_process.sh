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
    base_name_original_txt=${base_filename%.wav}.orig
    base_name_original_json=${base_filename%.wav}.json
    base_name_output_wav=${base_filename%.wav}.output.wav
    base_name_original_wav=${base_filename%.wav}.original.wav
    #echo "$base_filename"
    text_file="${dir}"/txt/
    #echo "$text_file"
    #text_file2= "${text_file}" echo ${base_filename}
    text_file2="${text_dir}/$dir_base_name/${base_name_changed}"
    text_file3="${text_dir}/$dir_base_name/${base_name_original_txt}"
    text_file4="${text_dir}/$dir_base_name/${base_name_original_json}"
    text_file5="${text_dir}/$dir_base_name/${base_name_output_wav}"
    text_file6="${text_dir}/$dir_base_name/${base_name_original_wav}"
    echo "${text_file2}"

       echo "length of audio : "
    wav_len=$(ffmpeg -i ${filename} 2>&1 | grep Duration | awk '{print $2}' | tr -d ,)
    echo $wav_len
      #if [[ ( ${myarray[1]} = 0 || -s ${text_file2} ) ]]; then
    if [ ${wav_len} = 'N/A'   ]; then
    
        echo "zero length wav file found  skipping" 
        rm ${filename}
        rm  ${text_file2}

    elif [ ! -s "$text_file2" ]; then
         echo " the zero length txt file found"
           rm ${filename}
        rm  ${text_file2}
       
    else
        touch ${text_file3}
        cp ${text_file2} ${text_file3}
    
        result=$(curl -o result.json -X POST -F "audio=@${filename}" -F "transcript=<${text_file2}" 'http://localhost:8765/transcriptions?async=false') 
        cp result.json ${text_file4}
        

            myarray=()
   while read line ; do
   myarray+=($line)
  done < <(python3 post_process_json.py -wav_file ${filename} -txt_file ${text_file2})
  echo ${myarray[@]}

  cp ${text_file2} ${text_file6}



    #if [[ ( ${myarray[1]} = 0 || -s ${text_file2} ) ]]; then
    if [ ${myarray[1]} = 0 ]; then
    
        echo "ending time is 0 bad aligned sentence ignoring" 
        rm ${filename}
        rm  ${text_file2}
       
    else
    
          # trim according to end time and save with same filename this is because we can use the webserver viewer code
      
          #ffmpeg -i $filename -ss ${myarray[0]} -to ${myarray[1]} -y -c copy $filename
          ffmpeg -i $filename -ss ${myarray[0]} -to ${myarray[1]} -y -c copy ${text_file5}
    fi
         
    fi
     

    # now send api request to local gentle server
    #curl -F "audio=${filename}" -F "transcript=@${text_file2}" "http://localhost:8765/transcriptions?async=false"
   
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


    
    #get the json result and trim audio based on last gentle word ending time
    #end_time="$(echo $result | jq .words | jq 'map(select(.end != null))[-1].end')"   
    #echo $end_time


   

done

done









