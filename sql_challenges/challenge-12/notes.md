# Lesson 08 Notes — ETL + Data Warehouse

## Main Idea

This lesson shows how to move data from an OLTP system into a Data Warehouse using an ETL process.

The example uses a ticketing/task system where records can change over time, especially when a ticket or task gets reassigned to another person.

---

## OLTP

OLTP means **Online Transaction Processing**.

It is used for daily operations, like:

- Creating tickets
- Updating ticket status
- Assigning tickets to agents
- Reassigning tickets
- Resolving tickets

In this exercise, the OLTP tables are:

- `tickets`
- `ticket_assignments`

---

## tickets Table

The `tickets` table stores the current state of each ticket.

It includes:

- Ticket ID
- Title
- Status
- Priority
- Creation date
- Resolution date
- Current assigned agent

This table only shows who is assigned right now.

---

## ticket_assignments Table

The `ticket_assignments` table stores the history of ticket assignments.

It tracks:

- Which ticket was assigned
- Who it was assigned to
- When the assignment started
- When the assignment ended

This is important because a ticket can be created by one agent and resolved by another.

---

## Trigger

A trigger is used to automatically save assignment changes.

The trigger runs when:

- A new ticket is inserted
- The assigned agent changes

When a ticket is reassigned, the trigger:

1. Closes the previous assignment by setting `valid_to`
2. Inserts a new assignment record
3. Leaves the new assignment with `valid_to = NULL`

`valid_to = NULL` means that assignment is still current.

---

## Data Warehouse

A Data Warehouse is used for reporting and analysis.

Instead of focusing on daily operations, it focuses on questions like:

- How many tickets were created per day?
- How many tickets were resolved per day?
- Which agent handled the most tickets?
- How many tickets existed by status and priority?

---

## Star Schema

The Data Warehouse uses a star schema.

A star schema usually has:

- Dimension tables
- Fact tables

---

## dim_agent

The `dim_agent` table stores information about agents.

It includes:

- Agent key
- Agent name
- Team

This table helps make reports easier to read.

---

## fact_ticket_daily

The `fact_ticket_daily` table stores daily ticket metrics.

It includes:

- Date key
- Agent key
- Status
- Priority
- Tickets created
- Tickets resolved

This is the main table used for reporting.

---

## ETL

ETL means:

- **Extract**
- **Transform**
- **Load**

---

## Extract

Extract means getting data from the source tables.

In this exercise, the data comes from:

- `tickets`
- `ticket_assignments`

---

## Transform

Transform means cleaning or changing the data so it is useful for analysis.

In this exercise, the transformation finds:

- Who was assigned when the ticket was created
- Who was assigned when the ticket was resolved

This is done using:

```sql
valid_from <= date
AND (valid_to IS NULL OR valid_to > date)