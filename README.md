## Atomicity Tests
a1.txt: deposit/withdraw from two accounts on two branches and read balance (3 points)

a2.txt: (single branch) deposit is aborted and check account doesn't exist (3 points)

a3.txt: (two branches) deposit is aborted and check account doesn't exist (4 points)

a4.txt: deposit and withdraw from nonexist account and check deposit is reverted (5 points)

## Consistency Tests
c1.txt: withdraw from nonexist account (5 points)

c2.txt: deposit/withdraw from single account and check balance consistency (5 points)

c3.txt: deposit/withdraw from two accounts and check balance consistency (5 points)

## Isolation Tests
Each test runs 3 times

### N clients write to single account (3, 4 points for N=2, 5)
iN-1.txt: initialize account x 10

iN-2.txt: deposit 10 x

iN-3.txt: read balance of account x

N={2,5}, run in the order of iN-1.txt -> NxiN-2.txt -> iN-3.txt

The number of aborted transaction is at most N-1, and the final balance of the account is num_sucess_transaction * 10 + 10

### N clients write to two accounts on two branches (3, 3 points for N=2, 5)
iN-1.txt: initialize account x/y 10

iN-2.txt: deposit 10 x/y

iN-3.txt: read balance of account x/y

N={2,5}, run in the order of iN-1.txt -> NxiN-2.txt -> iN-3.txt

The number of aborted transaction is at most N-1, and the final balance of each account is num_sucess_transaction * 10 + 10

### N clients read/write multiple times to single account (3, 3 points for N=2, 5)
iN-1.txt: initialize account x 10

iN-2.txt: deposit 10 x, balance x, deposit 10 x, balance x (the output of the two balance command should have a difference of 10)

iN-3.txt: read balance of account x

N={2,5}, run in the order of iN-1.txt -> NxiN-2.txt -> iN-3.txt

The number of aborted transaction is at most N-1, and the final balance of each account is num_sucess_transaction * 20 + 10

### N clients abort test (3, 3 points for N=2, 5)
2 clients: 2 clients deposit to the same account, one aborts and the other one should be unaffected. Check balance of the account at last. (i2-1.txt/i2-2.txt -> i2-3.txt)

5 clients: 5 clients deposit to account x and abort, two clients deposit to account x and do not abort but the other three clients are aborted. Check balance of account x at last. (i5-1.txt/i5-2.txt -> i5-3.txt)

For this test, it's possible that all transactions are aborted if using timestamped concurrency.

## Deadlock Tests (5 points)
client 1 contains: deposit a, deposit a, deposit a, deposit a, deposit a, deposite b
client 2 contains: deposit b, deposit b, deposit b, deposit b, deposit b, deposite a

If the none of the client is aborted, that means a deadlock is not created. We can either rerun the same test multiple times until an abort is emitted, or manually spin up two clients and create the deadlock. One of the transactions should be successful.