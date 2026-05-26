-- ============================================================
-- Lesson 08 Exercise Solution
-- Assignment History + Data Warehouse
-- Full SQL Solution
-- Run on FreeSQL / Oracle
-- ============================================================


BEGIN EXECUTE IMMEDIATE 'DROP TABLE fact_ticket_daily'; EXCEPTION WHEN OTHERS THEN NULL; END;
/
BEGIN EXECUTE IMMEDIATE 'DROP TABLE ticket_assignments'; EXCEPTION WHEN OTHERS THEN NULL; END;
/
BEGIN EXECUTE IMMEDIATE 'DROP TABLE tickets'; EXCEPTION WHEN OTHERS THEN NULL; END;
/
BEGIN EXECUTE IMMEDIATE 'DROP TABLE dim_agent'; EXCEPTION WHEN OTHERS THEN NULL; END;
/

-- ============================================================
-- STEP 1: SOURCE TABLES OLTP
-- ============================================================

CREATE TABLE tickets (
    ticket_id    NUMBER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    title        VARCHAR2(200) NOT NULL,
    status       VARCHAR2(20)  DEFAULT 'open' NOT NULL,
    priority     VARCHAR2(10)  DEFAULT 'medium' NOT NULL,
    created_at   TIMESTAMP     DEFAULT SYSTIMESTAMP NOT NULL,
    resolved_at  TIMESTAMP,
    assigned_to  NUMBER        NOT NULL,

    CONSTRAINT chk_ticket_status CHECK (
        status IN ('open', 'in_progress', 'blocked', 'resolved', 'cancelled')
    ),

    CONSTRAINT chk_ticket_priority CHECK (
        priority IN ('low', 'medium', 'high', 'critical')
    )
);

CREATE TABLE ticket_assignments (
    assignment_id NUMBER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    ticket_id     NUMBER    NOT NULL REFERENCES tickets(ticket_id),
    assigned_to   NUMBER    NOT NULL,
    assigned_by   NUMBER,
    valid_from    TIMESTAMP NOT NULL,
    valid_to      TIMESTAMP
);

CREATE INDEX idx_ticket_assignments_lookup
ON ticket_assignments (ticket_id, valid_from, valid_to);

-- ============================================================
-- STEP 2: TRIGGER
-- ============================================================

CREATE OR REPLACE TRIGGER trg_ticket_assignment_log
    AFTER INSERT OR UPDATE OF assigned_to ON tickets
    FOR EACH ROW
BEGIN
    IF INSERTING THEN
        INSERT INTO ticket_assignments (
            ticket_id,
            assigned_to,
            assigned_by,
            valid_from,
            valid_to
        )
        VALUES (
            :NEW.ticket_id,
            :NEW.assigned_to,
            NULL,
            :NEW.created_at,
            NULL
        );

    ELSIF UPDATING THEN
        UPDATE ticket_assignments
           SET valid_to = :NEW.resolved_at
         WHERE ticket_id = :OLD.ticket_id
           AND valid_to IS NULL;

        INSERT INTO ticket_assignments (
            ticket_id,
            assigned_to,
            assigned_by,
            valid_from,
            valid_to
        )
        VALUES (
            :NEW.ticket_id,
            :NEW.assigned_to,
            NULL,
            SYSTIMESTAMP,
            NULL
        );
    END IF;
END;
/

-- ============================================================
-- STEP 3: SAMPLE DATA
-- ============================================================

INSERT INTO tickets (
    title,
    status,
    priority,
    created_at,
    resolved_at,
    assigned_to
)
VALUES (
    'Login issue',
    'resolved',
    'high',
    TIMESTAMP '2026-04-01 09:00:00',
    TIMESTAMP '2026-04-02 14:00:00',
    1
);

INSERT INTO tickets (
    title,
    status,
    priority,
    created_at,
    resolved_at,
    assigned_to
)
VALUES (
    'Payment page error',
    'resolved',
    'critical',
    TIMESTAMP '2026-04-02 10:00:00',
    TIMESTAMP '2026-04-04 16:00:00',
    2
);

INSERT INTO tickets (
    title,
    status,
    priority,
    created_at,
    resolved_at,
    assigned_to
)
VALUES (
    'Cannot download invoice',
    'in_progress',
    'medium',
    TIMESTAMP '2026-04-03 11:00:00',
    NULL,
    3
);

INSERT INTO tickets (
    title,
    status,
    priority,
    created_at,
    resolved_at,
    assigned_to
)
VALUES (
    'Account locked',
    'resolved',
    'high',
    TIMESTAMP '2026-04-04 08:30:00',
    TIMESTAMP '2026-04-05 13:00:00',
    2
);

INSERT INTO tickets (
    title,
    status,
    priority,
    created_at,
    resolved_at,
    assigned_to
)
VALUES (
    'Mobile app crash',
    'open',
    'medium',
    TIMESTAMP '2026-04-05 12:00:00',
    NULL,
    4
);

COMMIT;

-- ============================================================
-- STEP 4: REASSIGN ONE TICKET
-- Ticket 2 was created assigned to agent 2.
-- Now it is reassigned to agent 3.
-- ============================================================

UPDATE tickets
SET assigned_to = 3,
    resolved_at = TIMESTAMP '2026-04-04 16:00:00'
WHERE ticket_id = 2;

COMMIT;

-- ============================================================
-- STEP 5: DATA WAREHOUSE TABLES
-- ============================================================

CREATE TABLE dim_agent (
    agent_key   NUMBER PRIMARY KEY,
    agent_name  VARCHAR2(100) NOT NULL,
    team        VARCHAR2(50)  NOT NULL
);

CREATE TABLE fact_ticket_daily (
    date_key          NUMBER       NOT NULL,
    agent_key         NUMBER       NOT NULL REFERENCES dim_agent(agent_key),
    status            VARCHAR2(20) NOT NULL,
    priority          VARCHAR2(10) NOT NULL,
    tickets_created   NUMBER       DEFAULT 0,
    tickets_resolved  NUMBER       DEFAULT 0,

    CONSTRAINT pk_fact_ticket_daily PRIMARY KEY (
        date_key,
        agent_key,
        status,
        priority
    )
);

-- ============================================================
-- STEP 6: POPULATE DIM_AGENT
-- ============================================================

INSERT INTO dim_agent (agent_key, agent_name, team)
VALUES (1, 'Alice Chen', 'Support');

INSERT INTO dim_agent (agent_key, agent_name, team)
VALUES (2, 'Bob Martinez', 'Support');

INSERT INTO dim_agent (agent_key, agent_name, team)
VALUES (3, 'Carol Smith', 'Technical Support');

INSERT INTO dim_agent (agent_key, agent_name, team)
VALUES (4, 'Dave Kim', 'Technical Support');

COMMIT;

-- ============================================================
-- STEP 7: ETL LOGIC IN SQL
-- This replaces the pandas logic using pure SQL.
-- It finds the assigned agent at created_at and resolved_at.
-- ============================================================

-- Clear fact table before loading
DELETE FROM fact_ticket_daily;

-- Insert created ticket counts
INSERT INTO fact_ticket_daily (
    date_key,
    agent_key,
    status,
    priority,
    tickets_created,
    tickets_resolved
)
SELECT
    TO_NUMBER(TO_CHAR(CAST(t.created_at AS DATE), 'YYYYMMDD')) AS date_key,
    ta.assigned_to AS agent_key,
    t.status,
    t.priority,
    COUNT(*) AS tickets_created,
    0 AS tickets_resolved
FROM tickets t
JOIN ticket_assignments ta
    ON ta.ticket_id = t.ticket_id
   AND ta.valid_from <= t.created_at
   AND (
        ta.valid_to IS NULL
        OR ta.valid_to > t.created_at
   )
GROUP BY
    TO_NUMBER(TO_CHAR(CAST(t.created_at AS DATE), 'YYYYMMDD')),
    ta.assigned_to,
    t.status,
    t.priority;

-- Insert resolved ticket counts
MERGE INTO fact_ticket_daily f
USING (
    SELECT
        TO_NUMBER(TO_CHAR(CAST(t.resolved_at AS DATE), 'YYYYMMDD')) AS date_key,
        ta.assigned_to AS agent_key,
        t.status,
        t.priority,
        0 AS tickets_created,
        COUNT(*) AS tickets_resolved
    FROM tickets t
    JOIN ticket_assignments ta
        ON ta.ticket_id = t.ticket_id
       AND ta.valid_from <= t.resolved_at
       AND (
            ta.valid_to IS NULL
            OR ta.valid_to > t.resolved_at
       )
    WHERE t.resolved_at IS NOT NULL
    GROUP BY
        TO_NUMBER(TO_CHAR(CAST(t.resolved_at AS DATE), 'YYYYMMDD')),
        ta.assigned_to,
        t.status,
        t.priority
) r
ON (
    f.date_key = r.date_key
    AND f.agent_key = r.agent_key
    AND f.status = r.status
    AND f.priority = r.priority
)
WHEN MATCHED THEN
    UPDATE SET
        f.tickets_resolved = f.tickets_resolved + r.tickets_resolved
WHEN NOT MATCHED THEN
    INSERT (
        date_key,
        agent_key,
        status,
        priority,
        tickets_created,
        tickets_resolved
    )
    VALUES (
        r.date_key,
        r.agent_key,
        r.status,
        r.priority,
        r.tickets_created,
        r.tickets_resolved
    );

COMMIT;

-- ============================================================
-- STEP 8: VERIFY ASSIGNMENT HISTORY
-- ============================================================

SELECT
    t.ticket_id,
    t.title,
    ta.assigned_to,
    ta.valid_from,
    ta.valid_to,
    CASE
        WHEN ta.valid_to IS NULL THEN 'current'
        ELSE 'historical'
    END AS assignment_status
FROM tickets t
JOIN ticket_assignments ta
    ON t.ticket_id = ta.ticket_id
WHERE t.ticket_id = 2
ORDER BY ta.valid_from;

-- ============================================================
-- STEP 9: VERIFY FACT TABLE
-- Shows tickets created and resolved per agent per day
-- ============================================================

SELECT
    f.date_key,
    a.agent_name,
    a.team,
    f.status,
    f.priority,
    f.tickets_created,
    f.tickets_resolved
FROM fact_ticket_daily f
JOIN dim_agent a
    ON f.agent_key = a.agent_key
ORDER BY
    f.date_key,
    a.agent_name,
    f.status,
    f.priority;

-- ============================================================
-- STEP 10: FINAL COUNTS
-- ============================================================

SELECT 'tickets: ' || COUNT(*) AS count_result FROM tickets
UNION ALL
SELECT 'ticket_assignments: ' || COUNT(*) FROM ticket_assignments
UNION ALL
SELECT 'dim_agent: ' || COUNT(*) FROM dim_agent
UNION ALL
SELECT 'fact_ticket_daily: ' || COUNT(*) FROM fact_ticket_daily;