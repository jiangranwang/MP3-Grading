import sys
import os

num_client = int(sys.argv[1])
file_base = sys.argv[2]
intermediate_files = [file_base + '-' + str(i) + '.log' for i in range(num_client)]
final_file = file_base + '.log'
red = ['\033[93m', '\033[0m']
green = ['\033[92m', '\033[0m']

# check intermediate file outpus and how many files have aborted
total_aborted = 0
for fn in intermediate_files:
	assert os.path.isfile(fn), red[0] + fn + ' file is missing' + red[1]
	with open(fn, 'r') as f:
		lines = f.readlines()
		# check if aborted
		aborted = False
		for l in lines:
			if 'ABORT' in l:
				aborted = True
				total_aborted += 1
				break
		if aborted:
			continue
		
		# current transaction is committed
		assert len(lines) >= 6, red[0] + fn + ' file is incomplete' + red[1]
		assert lines[0] == 'OK\n'
		assert lines[1] == 'OK\n'
		val1 = int(lines[2].split()[2])
		assert lines[3] == 'OK\n'
		assert int(lines[4].split()[2]) == val1 + 10, red[0] + 'intermediate file balance inconsistent' + red[1]
		assert lines[5] == 'COMMIT OK\n'

# check if number of aborted transaction is less than num_client
assert total_aborted < num_client, red[0] + fn + ' too many client aborted' + red[1]

# check if final balance matches the number of aborted clients
assert os.path.isfile(final_file), red[0] + final_file + ' file is missing' + red[1]
with open(final_file, 'r') as f:
	lines = f.readlines()
	assert lines[0] == 'OK\n'
	assert int(lines[1].split()[2]) == 10 + (num_client - total_aborted) * 20, red[0] + 'inconsistent final balance' + red[1]
	assert lines[2] == 'COMMIT OK\n'

print(green[0] + 'isolation test 3 with ' + str(num_client) + ' clients check success' + green[1])