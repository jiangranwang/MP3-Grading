servers = ['C', 'D']
acs = ['gg', 'hh', 'ii']
with open('i2-7-expected.txt', 'w') as f:
	f.write('OK\nOK\nABORTED\n')
with open('i2-8-expected.txt', 'w') as f:
	f.write('OK\nOK\nCOMMIT OK\n')
for r in range(2):
	# 2 clients
	account = servers[r] + '.' + acs[0]
	with open('i2-7-'+str(r)+'.txt', 'w') as f:
		f.write('BEGIN\nDEPOSIT '+account+' 10\nABORT\n')
	with open('i2-8-'+str(r)+'.txt', 'w') as f:
		f.write('BEGIN\nDEPOSIT '+account+' 10\nCOMMIT\n')
	with open('i2-10-'+str(r)+'.txt', 'w') as f:
		f.write('BEGIN\nBALANCE '+account+'\nCOMMIT\n')
	with open('i2-10-expected-'+str(r)+'.txt', 'w') as f:
		f.write('OK\n'+account+' = 10\nCOMMIT OK\n')

	# 5 clients
	account = servers[r] + '.' + acs[1]
	with open('i5-7-'+str(r)+'.txt', 'w') as f:
		f.write('BEGIN\nDEPOSIT '+account+' 10\nABORT\n')
	with open('i5-8-'+str(r)+'.txt', 'w') as f:
		f.write('BEGIN\nDEPOSIT '+account+' 10\nCOMMIT\n')
	with open('i5-9-'+str(r)+'.txt', 'w') as f:
		f.write('BEGIN\nBALANCE '+account+'\n')
	with open('i5-10-'+str(r)+'.txt', 'w') as f:
		f.write('BEGIN\nBALANCE '+account+'\nCOMMIT\n')
	with open('i5-10-expected-'+str(r)+'.txt', 'w') as f:
		f.write('OK\n'+account+' = 20\nCOMMIT OK\n')

	# 10 clients
	account = servers[r] + '.' + acs[2]
	with open('i10-7-'+str(r)+'.txt', 'w') as f:
		f.write('BEGIN\nDEPOSIT '+account+' 10\nABORT\n')
	with open('i10-8-'+str(r)+'.txt', 'w') as f:
		f.write('BEGIN\nDEPOSIT '+account+' 10\nCOMMIT\n')
	with open('i10-9-'+str(r)+'.txt', 'w') as f:
		f.write('BEGIN\nBALANCE '+account+'\n')
	with open('i10-10-'+str(r)+'.txt', 'w') as f:
		f.write('BEGIN\nBALANCE '+account+'\nCOMMIT\n')
	with open('i10-10-expected-'+str(r)+'.txt', 'w') as f:
		f.write('OK\n'+account+' = 40\nCOMMIT OK\n')
