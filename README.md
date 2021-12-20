## Atomicity Tests
a1.txt: abort pre-exisiting account (8 points)

a2.txt: abort newly created account (8 points)

a3.txt: ignore commands outside transactions (4 points)

## Consistency Tests
c1.txt: transaction involving multiple servers (8 points)

c2.txt: negative balance during transaction but eventually resolved (6 points)

c3.txt: commit with negative balance (6 points)

## Isolation Tests
Each test runs 5 times

### 10 clients write to different accounts within time limit (5 points)
i1.txt: first only 1 client write to 1 account 10 times and get how long it takes as T

i2.txt - i-11.txt: each client write to different accounts 10 times and limit execution time within 5T (10T being the absolute maximum. Partial credit for execution time >5T?)

i12.txt: check final balance of all accounts with i12-expected.txt

### N clients write twice to single account (2, 3, 5 points for N=2, 5, 10)
iN-1.txt: initialize account x 10

iN-2.txt: deposit 10 x, withdraw 5 x

iN-3.txt: display balance of account x

Compare the output of iN-3.txt with iN-3-expected.txt (final value should be 5N+10)

N={2,5,10}, run in the order of iN-1.txt -> NxiN-2.txt -> iN-3.txt

### N clients read/write multiple times to single account (2, 3, 5 points for N=2, 5, 10)
iN-4.txt: initialize account x 10

iN-5.txt: deposit 10 x, balance x, deposit 10 x, balance x... (repeat 10 times, the output of ten balance commands should each have a difference of 10, i.e. y, y+10, y+20...)

Compare the output of iN-5.txt with iN-5-expected.txt

iN-6.txt: display balance of account x

Compare the output of iN-6.txt with iN-6-expected.txt (Final value should be 100N+10)

N={2,5,10}, run in the order of iN-4.txt -> NxiN-5.txt -> iN-6.txt

### N clients abort test (2, 3, 5 points for N=2, 5, 10)
2 clients: two clients deposit to the same account, one aborts and the other one should be unaffected. Check balance of the account at last. (i2-7.txt/i2-8.txt -> i2-10.txt)

5 clients: two clients deposit to account x and abort, two clients deposit to account x and do not abort, one client read account x. Check balance of account x at last. The output of the read client could be either success or aborted. (i5-7.txt/i5-8.txt/i5-9.txt -> i5-10.txt)

10 clients: four clients deposit to account x and abort, four clients deposit to account x and do not abort, two clients read account x. Check balance of account x at last. The output of the read clients could be either success or aborted. (i10-7.txt/i10-8.txt/i10-9.txt -> i10-10.txt)

## Deadlock Tests
Each test runs 5 times

Each deposit operation is repeated 5 times to maximize possibiltiy of deadlock

2 clients: client 1 (deposit a, deposite b), client 2 (deposit b, deposite a) (2 points)

5 clients: client 1 (deposit a, deposite b, deposit c, deposite d, deposit e), client 2 (deposit b, deposite c, deposit d, deposite e, deposit a), ... (3 points)

10 clients: ... (5 points)