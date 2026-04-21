# Session – 2026-04-21

## Topics covered
In this session, we covered the concept of transactions and how they ensure data consistency. We learned how COMMIT, ROLLBACK, and SAVEPOINT work to control changes in the database. We also explored manual transaction flow, stored procedures for automating logic, the differences between functions and procedures, and basic exception handling in SQL.

## What I understood
I understood that a transaction groups multiple operations into a single unit that must either fully succeed or fail. I learned that COMMIT saves changes permanently, while ROLLBACK undoes them if an error occurs. I also understood that SAVEPOINT allows partial rollback within a transaction, and that procedures are used for actions while functions are used to return values.

## What is still confusing
I am still unsure about when it is appropriate to include COMMIT inside a stored procedure. I also find it confusing how transactions behave when procedures are part of a larger process. Additionally, I do not fully understand how multiple users interacting with the database at the same time affect transactions.

## Questions
Why is using COMMIT inside a stored procedure sometimes considered bad practice? When should transaction control be handled in the application instead of the database? Can a function ever modify data, or should it always be limited to returning values?