
import json

'''import argparse

parser = argparse.ArgumentParser()
parser.add_argument("-wav_file")
parser.add_argument("-txt_file")
args = parser.parse_args()

# this code section simply takes wave file ( ) and txt file (txt_file) and gentle json(json_file)
  and returns starting and ending times
'''

def filter_json(json_dict):
	last_word_index=-1
	for id,word in enumerate(json_dict["words"]):
		if "end" in word:
			last_word_index=id
	return json_dict["words"][0:last_word_index]


def get_sentence_boundary(json_file,txt_file):
    with open(json_file, 'r') as f:
        array = json.load(f)

        # print(array["words"])
        array=filter_json(array)

        text = ""


        sentence_ended = False
        sentence_started = False

        starting_time=0
        ending_time=0

        sentences=[]


        for word in array:
            if "end" in word:
                sentence_ended=False        
                ending_time=word["end"]
                if  sentence_started == False:
                    sentence_started = True
                    starting_time=word["start"]
                #if sentence_ended == False:
                text = text + " " + word["alignedWord"]
                #elif sentence_ended == True:
                    #text = word["alignedWord"]
            else :
                if len(text) != 0:
                    sentences.append([starting_time,ending_time,text])
                    
                text=""
                sentence_started=False
                starting_time=0
                ending_time=0
                #sentence_ended = True

        #print(" text : "  + text )
        #print(" starting time : "  + str(starting_time) )
        #print(" ending time : "  + str(ending_time) )


        # overwrite text file
        data=0
        with open(txt_file, 'w+') as out:
            #data = out.read()
            #if len(data) == 0:
            print(text)
                
            out.write(text)

        #if text=="" or len(data) == 0:
        if text=="":

            return [0,0]
            
        else:
            return [starting_time,ending_time]



'''
start of another code segment
will document this later

'''

def istxtfileempty(path):
    import os
    return os.stat(path).st_size == 0

def getaudiolen(path):
    import soundfile as sf
    f = sf.SoundFile(path)
    #print('samples = {}'.format(len(f)))
    #print('sample rate = {}'.format(f.samplerate))
    return len(f) / f.samplerate

def trim_audio(wavfilename,starting_time,ending_time):
    import subprocess
    subprocess.call(["ffmpeg", "-i",wavfilename,"-ss",starting_time,"-to",ending_time,"-y" , "-c" , "copy" , wavfilename ])

def sendgentlerequest(wavfilepath,txtfilepath,outputjsonpath):
    '''
        this function calls gentle forced aligner docker container passes txt file, wave file
        it expects output json which it stores to output json path

    '''
    import requests
    #payload = {'audio=@': wavfilepath, 'transcript=<': txt_file_path}
    #r = requests.post('http://localhost:8765/transcriptions?async=false',data=payload)

    #import requests
    with open(txtfilepath, 'r') as file:
        txt_data = file.read().replace('\n', '')
    params = (
        ('async', 'false'),
    )

    files = {
        'audio': ( wavfilepath, open(wavfilepath, 'rb')),
        'transcript': (None, txt_data),
    }

    r = requests.post('http://localhost:8765/transcriptions', params=params, files=files)


    import json
    print(r.json())
    with open(outputjsonpath, 'w', encoding='utf-8') as f:
        json.dump(r.json(), f, ensure_ascii=False, indent=4)

    

# iterate over all subdirectories in wav folder
import os
rootdir = 'filter_dir/wav/'

import glob,os
from pathlib import Path 

for folder in glob.iglob('./filter_dir/wav/*'):
    print(folder)
    base_folder_path=Path(folder).name
    for file in glob.iglob(folder + "/*.wav"):
        #print(file)
        base_file_name=Path(file).name


        # get audio length
        audio_len=getaudiolen(file)
        txt_file_path="./filter_dir/txt/" + base_folder_path + "/" + base_file_name.replace("wav","txt")
        output_json_path="./filter_dir/txt/" + base_folder_path + "/" + base_file_name.replace("wav","json")
        print(txt_file_path)
        #print(audio_len)
        if audio_len!=0 and istxtfileempty(txt_file_path) ==False:
            print("calling gentle")
            # call gentle
            sendgentlerequest(file,txt_file_path,output_json_path)

            # get sentence boundaries
            boundaries=get_sentence_boundary(output_json_path,txt_file_path)
            starting_time=boundaries[0]
            ending_time=boundaries[1]

            #trim audio
            print("starting time : ",starting_time)
            print("ending time : ",ending_time)
            trim_audio(file,str(starting_time),str(ending_time))

            
