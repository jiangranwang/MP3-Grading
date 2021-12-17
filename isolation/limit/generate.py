for i, ac in enumerate('bcdefghijk'):
	with open('i'+str(i+2)+'.txt', 'w') as f:
		f.write('BEGIN\n')
		for j in range(100):
			f.write('DEPOSIT A.'+ac+' 10\n')
		f.write('COMMIT\n')

