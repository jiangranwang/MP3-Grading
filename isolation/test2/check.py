import sys
import os
from time import sleep
num_client = int(sys.argv[1])
file_base = sys.argv[2]
run_files = [file_base + '-' + str(i) + '.log' for i in range(num_client)]
for file in run_files:
	while not os.path.isfile(file):
		sleep(0.1)
for client in range(num_client):
	run_file = run_files[client]
	prev_val = None
	while True:
		if os.path.isfile(file):
			with open(run_file, 'r') as f:
				if len(f.readlines()) == 23:
					break
		sleep(0.1)
	with open(run_file, 'r') as f:
		lines = f.readlines()
		for l in lines:
			if l[2] != '.':
				continue
			curr_val = int(l.split()[2])
			if prev_val is None:
				prev_val = curr_val
			else:
				if curr_val - prev_val !=10:
					print('\033[93m' + 'client '+client+' has invalid value output' + '\033[0m')
					sys.exit()
				prev_val = curr_val
print('\033[92m' + 'value check success' + '\033[0m')