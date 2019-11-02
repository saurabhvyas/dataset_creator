import json

with open('./result.json', 'r') as f:
  array = json.load(f)

# print(array["words"])

text = ""


sentence_ended = False

starting_time=0
ending_time=0

for word in array["words"]:
  if "end" in word and sentence_ended == False:
  	text = text + " " + word["alignedWord"]
  elif "end" in word and sentence_ended == True:
  	text = word["alignedWord"]
  else :
  	sentence_ended = True

print(text)
