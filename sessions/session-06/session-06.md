## Topics covered
- PL/SQL triggers (`BEFORE INSERT`, `BEFORE UPDATE`, `BEFORE DELETE`)
- Per-row trigger behavior (`FOR EACH ROW`)
- Pseudocolumns and session/environment values (`SYSDATE`, `USER`)
- Applying `:NEW` and `:OLD` pseudorecords for validation and automatic field updates
- Trigger exception management with `RAISE_APPLICATION_ERROR` and `WHEN OTHERS`

## What I understood
- Triggers are useful not only for audit trails, but also for enforcing security rules directly in the database. For instance, they can block `UPDATE` and `DELETE` actions depending on the current `USER`.
- The `:NEW` pseudorecord can be used to fill audit fields such as `UPDATE_DATE` and `UPDATED_BY_USER` automatically before the row is saved, which helps protect those values from manual manipulation.
- The `:OLD` pseudorecord is important for validation because it lets the trigger inspect previous row values, such as checking whether the current session user matches the original creator before allowing changes.
- Unexpected database errors inside a trigger can be caught with `EXCEPTION WHEN OTHERS` and then returned in a controlled way through `RAISE_APPLICATION_ERROR`.
- This kind of row-level control and auditing is especially useful for improving Oracle trigger logic in OctoTask, since it protects data integrity independently of the frontend.

## What is still confusing
- How much performance impact several row-level triggers could have on a table that handles many inserts or updates in bulk.
- The best way to create efficient unit tests for trigger exception cases, especially to verify that `RAISE_APPLICATION_ERROR` behaves correctly for different session users.

## Questions
- From a long-term architecture perspective, is it better to keep role-based authorization checks, such as a hardcoded `'JOEMANAGER'`, in the application layer rather than inside the database?
- If the `PET_CARE_LOG` table has more than one trigger of the same type, such as two `BEFORE INSERT` triggers, how can the execution order be controlled reliably?
