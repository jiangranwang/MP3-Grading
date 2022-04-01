servers = ['A', 'B', 'C', 'D']
acs = ['dd', 'ee', 'ff', 'gg', 'hh', 'ii']
for r in range(3):
	for i, num_client in enumerate([2,5]):
		account1 = servers[r] + '.' + acs[i*2]
		account2 = servers[r+1] + '.' + acs[i*2+1]
		with open('i'+str(num_client)+'-1-'+str(r)+'.txt', 'w') as f:
			f.write('BEGIN\nDEPOSIT '+account1+' 10\nDEPOSIT '+account2+' 10\nCOMMIT\n')
		with open('i'+str(num_client)+'-21-'+str(r)+'.txt', 'w') as f:
			f.write('BEGIN\nDEPOSIT '+account1+' 10\nDEPOSIT '+account2+' 10\nCOMMIT\n')
		with open('i'+str(num_client)+'-22-'+str(r)+'.txt', 'w') as f:
			f.write('BEGIN\nDEPOSIT '+account2+' 10\nDEPOSIT '+account1+' 10\nCOMMIT\n')
		with open('i'+str(num_client)+'-3-'+str(r)+'.txt', 'w') as f:
			f.write('BEGIN\nBALANCE '+account1+'\nBALANCE '+account2+'\nCOMMIT\n')
		with open('i'+str(num_client)+'-3-expected-'+str(r)+'.txt', 'w') as f:
			f.write('OK\n'+account1+' = '+str(10*num_client+10)+'\n'+account2+' = '+str(10*num_client+10)+'\nCOMMIT OK\n')