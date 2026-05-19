-- ============================================================
-- EXERCISE 8: Fix the "Urgency Index"
-- ============================================================

-- PROBLEM:
-- The bad query tries to multiply priority, which is a VARCHAR2, by 10.
-- It also tries to add a date to a numeric expression.
-- That does not create a meaningful urgency metric.
--
-- REWRITE KPI CONTRACT:
-- Business question: Which active tasks should be handled first?
-- Definition: Urgency score combines priority weight and deadline pressure.
-- Priority weight:
-- - critical = 4
-- - high = 3
-- - medium = 2
-- - low = 1
-- Deadline pressure:
-- - overdue tasks receive a higher score.
-- - tasks due soon receive a moderate score.
-- - tasks due later receive a lower score.
-- Formula:
-- urgency_score = priority_weight * 10 + overdue_or_due_soon_score
-- Scope: Active tasks only.
-- Unit: Numeric score where higher = more urgent.
-- Edge cases:
-- - Tasks without due_date receive only priority score.
-- - Completed and cancelled tasks are excluded.
-- Misleading if:
-- - Priority is outdated.
-- - Due dates are not realistic.

WITH active_tasks AS (
    SELECT
        title,
        status,
        priority,
        due_date,
        CASE priority
            WHEN 'critical' THEN 4
            WHEN 'high' THEN 3
            WHEN 'medium' THEN 2
            WHEN 'low' THEN 1
        END AS priority_weight,
        CASE
            WHEN due_date IS NULL THEN 0
            WHEN due_date < TRUNC(SYSDATE) THEN 20 + (TRUNC(SYSDATE) - due_date)
            WHEN due_date = TRUNC(SYSDATE) THEN 15
            WHEN due_date <= TRUNC(SYSDATE) + 2 THEN 10
            WHEN due_date <= TRUNC(SYSDATE) + 7 THEN 5
            ELSE 0
        END AS due_date_pressure
    FROM tasks
    WHERE status NOT IN ('completed', 'cancelled')
)
SELECT
    title,
    status,
    priority,
    due_date,
    priority_weight,
    due_date_pressure,
    priority_weight * 10 + due_date_pressure AS urgency_score
FROM active_tasks
ORDER BY urgency_score DESC, due_date ASC NULLS LAST;