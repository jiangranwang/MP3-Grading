import sys
import os

file0 = '../outputs/d0.log'
file1 = '../outputs/d1.log'
red = ['\033[93m', '\033[0m']
green = ['\033[92m', '\033[0m']

assert os.path.isfile(file0), red[0] + 'file0 is missing' + red[1]
assert os.path.isfile(file0), red[0] + 'file1 is missing' + red[1]

abort0 = False
abort1 = False
with open(file0, 'r') as f:
	lines = f.readlines()
	for l in lines:
		if 'ABORT' in l:
			abort0 = True
			break
with open(file1, 'r') as f:
	lines = f.readlines()
	for l in lines:
		if 'ABORT' in l:
			abort1 = True
			break

if abort0 and abort1:
	print(red[0] + 'Both transactions are aborted. Test Failed.' + red[1])
elif abort0 or abort1:
	print(green[0] + 'One of the transactions are aborted. Test Passed.' + green[1])
else:
	print(red[0] + 'Deadlock not created. Inconclusive Test.' + red[1])
