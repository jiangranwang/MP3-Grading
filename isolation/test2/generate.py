servers = ['B', 'C']
acs = ['dd', 'ee', 'ff']
for r in range(2):
	for i, num_client in enumerate([2,5,10]):
		account = servers[r] + '.' + acs[i]
		with open('i'+str(num_client)+'-4-'+str(r)+'.txt', 'w') as f:
			f.write('BEGIN\nDEPOSIT '+account+' 10\nCOMMIT\n')
		with open('i'+str(num_client)+'-5-'+str(r)+'.txt', 'w') as f:
			commands = 'BEGIN\n'
			for _ in range(2):
				commands += 'DEPOSIT '+account+' 10\nBALANCE '+account+'\n'
			commands += 'COMMIT\n'
			f.write(commands)
		with open('i'+str(num_client)+'-6-'+str(r)+'.txt', 'w') as f:
			f.write('BEGIN\nBALANCE '+account+'\n')
		with open('i'+str(num_client)+'-6-expected-'+str(r)+'.txt', 'w') as f:
			f.write('OK\n'+account+' = '+str(20*num_client+10)+'\n')