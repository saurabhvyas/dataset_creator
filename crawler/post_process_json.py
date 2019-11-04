import json

import argparse

parser = argparse.ArgumentParser()
parser.add_argument("-wav_file")
parser.add_argument("-txt_file")
args = parser.parse_args()

# to do;
# fix ffmpeg bug
# add exception handling



def filter_json(json_dict):
	last_word_index=-1
	for id,word in enumerate(array["words"]):
		if "end" in word:
			last_word_index=id
	return json_dict["words"][0:last_word_index]




with open('./result.json', 'r') as f:
  array = json.load(f)

# print(array["words"])
array=filter_json(array)

text = ""


sentence_ended = False
sentence_started = False

starting_time=0
ending_time=0

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
with open(args.txt_file, 'r+') as out:
    data = out.read()
    #if len(data) == 0:
    
        
    out.write(text)

if text=="" or len(data) == 0:

	print(0)
	print(0)
else:
	print(starting_time)
	print(ending_time)
# trim audio
#import ffmpeg

#print(args.wav_file)
#print(args.txt_file)

#in_file = ffmpeg.input(args.wav_file)


#audio=ffmpeg.input(args.wav_file).trim(start=starting_time, end=ending_time)
#ffmpeg.output(audio,"./output.wav").overwrite_output().run()
    
