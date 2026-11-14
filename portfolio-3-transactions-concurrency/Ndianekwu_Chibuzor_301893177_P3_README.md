# Portfolio 3: Transactions and Concurrency

All tests use real ticketing operations on the Portfolio 1 tables.

| File | Content |
| --- | --- |
| [Transactions](Ndianekwu_Chibuzor_301893177_P3_Transactions.sql) | COMMIT, ROLLBACK and SAVEPOINT in one session |
| [Commit and rollback output](evidence/Ndianekwu_Chibuzor_301893177_P3_CommitRollbackOutput.txt) | psql output |
| [Buy last ticket, no lock](Ndianekwu_Chibuzor_301893177_P3_BuyLastTicket_NoLock.sql) | one buyer: count, then insert |
| [Buy last ticket, row lock](Ndianekwu_Chibuzor_301893177_P3_BuyLastTicket_RowLock.sql) | one buyer: lock the event row, count, then insert |
| [Runner](Ndianekwu_Chibuzor_301893177_P3_RunConcurrency.sh) | starts two buyers one second apart, three ways |
| [Concurrency output](evidence/Ndianekwu_Chibuzor_301893177_P3_ConcurrencyOutput.txt) | output of both sessions for each test |

## Part 1: commit, rollback, savepoint

| Test | What happens | Result |
| --- | --- | --- |
| COMMIT | Order 350 and seats B1, B2 are inserted in one transaction | order and both tickets are stored |
| ROLLBACK | Order 351 asks for seat B5 and seat A1; A1 is already sold | error 23505 on ticket_seat_unique; after ROLLBACK the order and seat B5 are gone too |
| SAVEPOINT | Order 352: same failure, but only the failed seat is undone and B6 is taken instead | order stored with B5 and B6 |

After the 23505 error PostgreSQL answered the next statement with 25P02 (transaction is aborted). Nothing more can run in that transaction until it is rolled back. This is atomicity: an order is never left half saved.

## Part 2: two buyers, one place left

Event 204 (Acoustic Rooftop Session) has capacity 3 and 2 tickets sold. Sessions A and B each try to buy one ticket. A starts first and waits 3 seconds before committing. B starts 1 second after A.

| Test | Isolation and method | What B saw | Final tickets | Outcome |
| --- | --- | --- | --- | --- |
| 1 | READ COMMITTED, count then insert | sold = 2 | 4 of 3 | **oversold** |
| 2 | READ COMMITTED, SELECT ... FOR UPDATE on the event row first | waited 1.99 s, then sold = 3 | 3 of 3 | B bought nothing |
| 3 | SERIALIZABLE, count then insert | sold = 2 | 3 of 3 | A's COMMIT failed with 40001 |

### Test 1: why the event was oversold

When B counted, A had inserted its ticket but had not committed. Under READ COMMITTED a session never sees another session's uncommitted rows, so B also counted 2 and also inserted. Each transaction was correct alone. Together they broke the capacity rule. No constraint caught it because the rule spans many rows.

### Test 2: row lock

Both buyers first run `SELECT capacity FROM event WHERE event_id = 204 FOR UPDATE`. Only one session can hold that row lock. B asked at 05:06:07.305 and got it at 05:06:09.295, the moment A committed. B then counted 3, found the event full and rolled back. Buyers of other events lock other rows and are not delayed.

### Test 3: serializable

No lock was requested. PostgreSQL tracked that each transaction read the rows the other one changed, and cancelled one of them at commit with SQLSTATE 40001 ("could not serialize access"). The capacity rule held, but the application must catch 40001 and retry the purchase.

### Comparison

| | Row lock (pessimistic) | SERIALIZABLE (optimistic) |
| --- | --- | --- |
| When the conflict is handled | before the work, by waiting | at commit, by failing one transaction |
| Cost when buyers collide | second buyer waits | one buyer's work is thrown away and retried |
| Application code | must remember to lock | must retry on 40001 |
| Fits | on-sale rush for a popular event | mostly quiet sales with rare collisions |

## Run

```bash
psql -d ticketing -f Ndianekwu_Chibuzor_301893177_P3_Transactions.sql
./Ndianekwu_Chibuzor_301893177_P3_RunConcurrency.sh "-d ticketing"
```

The runner needs bash and psql. It removes the test orders after each test, so it can be repeated.

## References

- PostgreSQL Global Development Group. *Transaction Isolation.* https://www.postgresql.org/docs/16/transaction-iso.html
- PostgreSQL Global Development Group. *Explicit Locking.* https://www.postgresql.org/docs/16/explicit-locking.html
