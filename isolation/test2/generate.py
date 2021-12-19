servers = ['A', 'B', 'C', 'D', 'E']
acs = ['dd', 'ee', 'ff']
for r in range(5):
	for i, num_client in enumerate([2,5,10]):
		account = servers[r] + '.' + acs[i]
		with open('i'+str(num_client)+'-4-'+str(r)+'.txt', 'w') as f:
			f.write('BEGIN\nDEPOSIT '+account+' 0\nCOMMIT')
		with open('i'+str(num_client)+'-5-'+str(r)+'.txt', 'w') as f:
			commands = 'BEGIN\n'
			for _ in range(10):
				commands += 'DEPOSIT '+account+' 10\nBALANCE '+account+'\n'
			commands += 'COMMIT'
			f.write(commands)
		with open('i'+str(num_client)+'-6-'+str(r)+'.txt', 'w') as f:
			f.write('BEGIN\nBALANCE '+account+'\nCOMMIT')
		with open('i'+str(num_client)+'-6-expected-'+str(r)+'.txt', 'w') as f:
			f.write('OK\n'+account+' = '+str(100*num_client)+'\nCOMMIT OK\n')