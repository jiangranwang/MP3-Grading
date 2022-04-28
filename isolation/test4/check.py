import sys
import os

num_client = int(sys.argv[1])
file_base = sys.argv[2]
intermediate_files = [file_base + '-' + str(i) + '.log' for i in range(num_client)]
final_file = file_base + '.log'
red = ['\033[93m', '\033[0m']
green = ['\033[92m', '\033[0m']

# check how many files have aborted
total_aborted = 0
for fn in intermediate_files:
	assert os.path.isfile(fn), red[0] + fn + ' file is missing' + red[1]
	with open(fn, 'r') as f:
		lines = f.readlines()
		for l in lines:
			if 'ABORT' in l:
				total_aborted += 1
				break

# check if number of aborted transaction is greater than num_client / 2
assert total_aborted >= num_client // 2, red[0] + fn + ' not enough client aborted' + red[1]

# check if final balance matches the number of aborted clients
assert os.path.isfile(final_file), red[0] + final_file + ' file is missing' + red[1]
with open(final_file, 'r') as f:
	lines = f.readlines()
	assert lines[0] == 'OK\n'
	if 'ABORT' not in lines[1].split()[2]:
		assert int(lines[1].split()[2]) == (num_client - total_aborted) * 10, red[0] + 'inconsistent final balance' + red[1]
		assert lines[2] == 'COMMIT OK\n'
	else:
		assert total_aborted == num_client, red[0] + 'expect all clients to abort' + red[1]

print(green[0] + 'isolation test 1 with ' + str(num_client) + ' clients check success' + green[1])