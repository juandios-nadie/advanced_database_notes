# Session – 2026-04-21

## Topics covered
- Transactions (COMMIT, ROLLBACK, SAVEPOINT)
- Manual transaction control
- Stored procedures
- Functions vs procedures
- Error handling in SQL

## What I understood
- Transactions group operations and must be all-or-nothing
- COMMIT saves changes, ROLLBACK undoes them
- SAVEPOINT allows partial undo
- Procedures are used for actions, functions for returning values
- Error handling prevents partial or broken data

## What is still confusing
- When exactly to use COMMIT inside procedures
- Difference between procedure design vs application logic
- How transactions behave in multi-user environments

## Questions
- Should procedures always avoid COMMIT?
- When is it better to handle transactions in the app instead of SQL?
- How does isolation work when multiple users update the same data?