servers = ['A', 'B', 'C', 'D', 'E']
acs = ['j', 'k', 'l']
for r in range(5):
	for j, num_client in enumerate([2, 5, 10]):
		accounts = [''.join([acs[j] for _ in range(1, i+2)]) for i in range(num_client)]
		for c in range(num_client):
			with open('d'+str(num_client)+'-'+str(c)+'-'+str(r)+'.txt', 'w') as f:
				f.write('BEGIN\n')
				for add in range(num_client):
					curr = (c + add) % num_client
					for _ in range(5):
						f.write('DEPOSIT '+servers[r]+'.'+accounts[curr]+' 1\n')
				f.write('COMMIT')
