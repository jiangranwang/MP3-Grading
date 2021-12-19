import sys
import os

files = []
if int(sys.argv[1]) == 1:
	files.append(sys.argv[2] + '-4.log')
elif int(sys.argv[1]) == 2:
	files.append(sys.argv[2] + '-8.log')
	files.append(sys.argv[2] + '-9.log')
for file in files:
	if not os.path.isfile(file):
		print('\033[93m' + 'client '+file+' file does not exist' + '\033[0m')
		sys.exit()
	with open(file, 'r') as f:
		lines = f.readlines()
		invalid = False 
		if len(lines) == 2:
			if lines[0] != 'OK\n' or lines[1] != 'NOT FOUND, ABORTED\n':
				invalid = True
		elif len(lines) == 3:
			try:
				val = int(lines[1].split()[2])
				if lines[0] != 'OK\n' or lines[2] != 'COMMIT OK\n' or val % 10 != 0 or val > len(files) * 20:
					invalid = True
			except:
				invalid = True
		if invalid:
			print('\033[93m' + 'unexpected log: '+ str(lines) + '\033[0m')
			sys.exit()
print('\033[92m' + 'file check success' + '\033[0m')