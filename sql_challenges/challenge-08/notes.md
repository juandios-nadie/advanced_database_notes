# Session – 2026-04-14

## Topics covered
- Indexes in Oracle and when they help performance
- Cardinality and why high-cardinality columns are better candidates for indexing
- Execution plans and how to check whether Oracle uses an index or a full table scan
- Range queries on `visit_date`
- Composite indexes such as `(patient_id, visit_date)`
- How functions on indexed columns can prevent index usage
- Real-world indexing decisions in reporting and OLTP systems

## What I understood
- An index helps when Oracle needs to find a small part of a table quickly
- `patient_id` is a better column for indexing because it has many possible values
- `site_id` and `status` have few possible values, so indexes on them may not help much
- For small date ranges, Oracle may use an index, but for large ranges it may prefer a full table scan
- In a composite index, column order matters
- An index on `(patient_id, visit_date)` works well when the query starts with `patient_id`
- Using a function like `TO_CHAR(patient_id)` can stop Oracle from using a normal index
- Gathering statistics helps the optimizer choose a better execution plan

## What is still confusing
- How Oracle decides between an index scan and a full table scan
- How big a range query can be before the index is no longer useful
- When two separate indexes are enough and when a composite index is better
- When to use a function-based index instead of rewriting the query

## Questions
- What execution plan names should I recognize first when checking index usage?
- Why are low-cardinality columns usually poor choices for indexing?
- Can Oracle ever use an index on a low-cardinality column effectively?
- When should I create a composite index instead of separate indexes?
- How can I rewrite queries to avoid breaking index usage?
