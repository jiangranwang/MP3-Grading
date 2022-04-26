servers = ['A', 'B', 'C']
acs = ['aa', 'bb', 'cc']
for r in range(3):
	for i, num_client in enumerate([2,5]):
		account = servers[r] + '.' + acs[i]
		with open('i'+str(num_client)+'-1-'+str(r)+'.txt', 'w') as f:
			f.write('BEGIN\nDEPOSIT '+account+' 10\nCOMMIT\n')
		with open('i'+str(num_client)+'-2-'+str(r)+'.txt', 'w') as f:
			f.write('BEGIN\nDEPOSIT '+account+' 10\nCOMMIT\n')
		with open('i'+str(num_client)+'-3-'+str(r)+'.txt', 'w') as f:
			f.write('BEGIN\nBALANCE '+account+'\nCOMMIT\n')