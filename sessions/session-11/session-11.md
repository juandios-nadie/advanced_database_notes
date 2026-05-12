# Session – 2026-05-12

## Topics covered
- SQL schema design (teams, users, tasks)
- Relationships (1-to-many, foreign keys)
- SQLAlchemy ORM basics
- Alembic migrations (upgrade / downgrade)
- Adding a new model (`Comment`)
- CRUD operations with ORM
- Migration rollback

## What I understood
- Tables are connected through foreign keys (teams → users → tasks)
- ORM allows working with objects instead of raw SQL
- Relationships simplify navigation between models
- `upgrade()` applies schema changes, `downgrade()` reverts them
- `add()` stages changes, `commit()` persists them
- Cascade delete ensures dependent records (comments) are removed automatically

## What is still confusing
- When to prefer ORM vs raw SQL in real systems
- How Alembic detects changes automatically
- Best practices for handling data loss during migrations
- How cascade options impact performance and integrity

## Questions
- How do you handle migrations safely in production?
- When should cascade delete NOT be used?
- What is the best way to version large schema changes?
- How do relationships scale in very large databases?

## Related concepts
- [ORM vs SQL](../concepts/orm-vs-sql.md)
- [Database migrations](../concepts/migrations.md)
- [Foreign keys](../concepts/foreign-keys.md)
- [Cascade delete](../concepts/cascade-delete.md)

## Resources used
- See `resources/`