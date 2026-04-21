# Transactions & Stored Procedures — Quick Notes

- Transaction = group of queries that act as one  
- COMMIT = save changes  
- ROLLBACK = undo changes  
- SAVEPOINT = partial undo  

- Use transactions for important operations (like money transfer)  
- All steps must succeed or none  

- Procedure = does actions (INSERT, UPDATE, DELETE)  
- Function = returns a value (can use in SELECT)  

- Procedures can COMMIT/ROLLBACK  
- Functions cannot  

- Always:
  - validate inputs  
  - handle errors  
  - rollback on failure  

- Do NOT put external actions (emails, APIs) inside transactions  