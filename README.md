### Atomicity Tests
a1.txt: abort pre-exisiting account

a2.txt: abort newly created account

a3.txt: ignore commands outside transactions

### Consistency Tests
c1.txt: transaction involving multiple servers

c2.txt: negative balance during transaction but eventually resolved

c3.txt: commit with negative balance

### Isolation Tests
Each test runs 5 times

#### 10 clients write to different accounts within time limit
i1.txt: first only 1 client write to 1 account 10 times and get how long it takes as T

i2.txt - i-11.txt: each client write to different accounts 10 times and limit execution time within 2T

i12.txt: check final balance of all accounts with i12-expected.txt

#### N clients write once to single account
iN-1.txt: initialize account x

iN-2.txt: deposit 10 x

iN-3.txt: display balance of account x

Compare the output of iN-3.txt with iN-3-expected.txt (final value should be 10N)

N={2,5,10}, run in the order of iN-1.txt -> NxiN-2.txt -> iN-3.txt

#### N clients read/write multiple times to single account
iN-4.txt: initialize account x

iN-5.txt: deposit 10 x, balance x, deposit 10 x, balance x, deposit 10 x, balance x (the output of three balance commands should each have a difference of 10, i.e. y, y+10, y+20)

Compare the output of iN-5.txt with iN-5-expected.txt

iN-6.txt: display balance of account x

Compare the output of iN-6.txt with iN-6-expected.txt (Final value should be 30N)

N={2,5,10}, run in the order of iN-4.txt -> NxiN-5.txt -> iN-6.txt

#### N clients abort test
half clients abort? the other half clients' operation should be unaffected. Not sure how to design the tests

### Deadlock Tests
Each test runs 5 times

2 clients: client 1 (deposit a, deposite b), client 2 (deposit b, deposite a)

5 clients: client 1 (deposit a, deposite b, deposit c, deposite d, deposit e), client 2 (deposit b, deposite c, deposit d, deposite e, deposit a), ...

10 clients: ...