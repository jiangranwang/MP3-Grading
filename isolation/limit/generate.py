num_write = 5
for i, ac in enumerate('abcdefghij'):
	with open('t'+str(i+1)+'.txt', 'w') as f:
		f.write('BEGIN\n')
		for j in range(num_write):
			f.write('DEPOSIT A.'+ac+' 10\n')
		f.write('COMMIT\n')
with open('t11.txt', 'w') as f:
	f.write('BEGIN\n')
	for c in 'abcdefghij':
		f.write('BALANCE A.'+c+'\n')

with open('t11-expected.txt', 'w') as f:
	f.write('OK\n')
	for c in 'abcdefghij':
		f.write('A.'+c+' = '+str(10*num_write)+'\n')