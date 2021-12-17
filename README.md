### Atomicity Tests
a1.txt: abort pre-exisiting account

a2.txt: abort newly created account

a3.txt: ignore commands outside transactions

### Consistency Tests
c1.txt: transaction involving multiple servers

c2.txt: negative balance during transaction but eventually resolved

c3.txt: commit with negative balance
