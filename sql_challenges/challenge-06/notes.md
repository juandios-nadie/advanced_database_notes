
- Creating `BEFORE INSERT`, `BEFORE UPDATE`, and `BEFORE DELETE` triggers in PL/SQL
- Using row-level triggers with `FOR EACH ROW`
- Automatically filling audit fields with `SYSDATE` and `USER`
- Validating permissions with `:NEW` and `:OLD`
- Handling trigger errors with `RAISE_APPLICATION_ERROR`
- Applying one general `EXCEPTION WHEN OTHERS` block in each trigger

- A `BEFORE INSERT` trigger can automatically save the current date and time in `LAST_UPDATE_DATETIME` and the current database user in `CREATED_BY_USER`.
- `SYSDATE` and `USER` are useful pseudocolumns for audit-related automation.
- A `BEFORE UPDATE` trigger can compare the current session user with `:OLD.CREATED_BY_USER` to decide whether the update should be allowed.
- The `:OLD` record stores the previous values of the row, while `:NEW` stores the values that will be written.
- A `BEFORE DELETE` trigger can restrict deletion rights by checking whether the current user matches a specific username such as `'JOEMANAGER'`.
- `RAISE_APPLICATION_ERROR` makes it possible to return custom error messages when a business rule is violated.
- A general `WHEN OTHERS` exception handler can catch unexpected errors and send a clearer message to the application.