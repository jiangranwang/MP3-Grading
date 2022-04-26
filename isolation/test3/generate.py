servers = ['B', 'C', 'D']
acs = ['jj', 'kk', 'll']
for r in range(3):
	for i, num_client in enumerate([2,5]):
		account = servers[r] + '.' + acs[i]
		with open('i'+str(num_client)+'-1-'+str(r)+'.txt', 'w') as f:
			f.write('BEGIN\nDEPOSIT '+account+' 10\nCOMMIT\n')
		with open('i'+str(num_client)+'-2-'+str(r)+'.txt', 'w') as f:
			commands = 'BEGIN\n'
			for _ in range(2):
				commands += 'DEPOSIT '+account+' 10\nBALANCE '+account+'\n'
			commands += 'COMMIT\n'
			f.write(commands)
		with open('i'+str(num_client)+'-3-'+str(r)+'.txt', 'w') as f:
			f.write('BEGIN\nBALANCE '+account+'\nCOMMIT\n')