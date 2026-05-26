-- ============================================================
-- Lesson 07: KPI Dashboards
-- Complete SQL Solution - Exercises 1 to 8
-- ============================================================


-- ============================================================
-- EXERCISE 1: Team Velocity
-- Definition:
-- Team velocity = completed tasks per active team member.
-- Only completed tasks with completed_at are counted.
-- ============================================================

WITH team_stats AS (
    SELECT
        t.id AS team_id,
        t.name AS team_name,
        COUNT(DISTINCT u.id) AS team_members,
        COUNT(CASE 
                  WHEN ts.status = 'completed'
                   AND ts.completed_at IS NOT NULL
                  THEN ts.id
              END) AS completed_tasks
    FROM teams t
    LEFT JOIN users u 
        ON u.team_id = t.id
    LEFT JOIN tasks ts 
        ON ts.assigned_to = u.id
    GROUP BY t.id, t.name
),
velocity AS (
    SELECT
        team_name,
        team_members,
        completed_tasks,
        ROUND(completed_tasks / NULLIF(team_members, 0), 2) AS team_velocity
    FROM team_stats
),
overall_avg AS (
    SELECT AVG(team_velocity) AS avg_velocity
    FROM velocity
)
SELECT
    v.team_name,
    v.team_members,
    v.completed_tasks,
    v.team_velocity,
    CASE
        WHEN v.team_velocity < o.avg_velocity THEN 'Below Average'
        ELSE 'At or Above Average'
    END AS velocity_flag
FROM velocity v
CROSS JOIN overall_avg o
ORDER BY v.team_velocity DESC;


-- ============================================================
-- EXERCISE 2: On-Time Delivery Rate
-- Definition:
-- On-time delivery rate = completed tasks finished on or before
-- the end of their due date.
-- ============================================================

SELECT
    priority,
    COUNT(*) AS completed_tasks,
    SUM(CASE
            WHEN completed_at < CAST(due_date + 1 AS TIMESTAMP)
            THEN 1 ELSE 0
        END) AS on_time_tasks,
    ROUND(
        SUM(CASE
                WHEN completed_at < CAST(due_date + 1 AS TIMESTAMP)
                THEN 1 ELSE 0
            END) * 100 / COUNT(*),
        2
    ) AS on_time_delivery_rate,
    ROUND(
        AVG(CASE
                WHEN completed_at >= CAST(due_date + 1 AS TIMESTAMP)
                THEN
                    EXTRACT(DAY FROM (completed_at - CAST(due_date + 1 AS TIMESTAMP))) * 24 +
                    EXTRACT(HOUR FROM (completed_at - CAST(due_date + 1 AS TIMESTAMP))) +
                    EXTRACT(MINUTE FROM (completed_at - CAST(due_date + 1 AS TIMESTAMP))) / 60
            END),
        2
    ) AS avg_lateness_hours
FROM tasks
WHERE status = 'completed'
  AND completed_at IS NOT NULL
  AND due_date IS NOT NULL
GROUP BY priority
ORDER BY
    CASE priority
        WHEN 'critical' THEN 1
        WHEN 'high' THEN 2
        WHEN 'medium' THEN 3
        WHEN 'low' THEN 4
    END;


-- ============================================================
-- EXERCISE 3: Improved Tasks per Team
-- ============================================================

SELECT
    t.name AS team_name,
    COUNT(ts.id) AS total_tasks,
    COUNT(CASE
              WHEN ts.status IN ('open', 'in_progress', 'blocked')
              THEN ts.id
          END) AS active_tasks,
    ROUND(
        COUNT(CASE WHEN ts.status = 'completed' THEN ts.id END) * 100
        / NULLIF(COUNT(CASE WHEN ts.status <> 'cancelled' THEN ts.id END), 0),
        2
    ) AS completion_rate,
    CASE
        WHEN COUNT(CASE WHEN ts.status IN ('open', 'in_progress', 'blocked') THEN ts.id END) > 10
            THEN 'Overloaded'
        WHEN COUNT(CASE WHEN ts.status IN ('open', 'in_progress', 'blocked') THEN ts.id END) BETWEEN 5 AND 10
            THEN 'Healthy'
        ELSE 'Underutilized'
    END AS health_score
FROM teams t
LEFT JOIN users u 
    ON u.team_id = t.id
LEFT JOIN tasks ts 
    ON ts.assigned_to = u.id
GROUP BY t.id, t.name
ORDER BY active_tasks DESC;


-- ============================================================
-- EXERCISE 4: Improved Average Resolution Time
-- Definition:
-- Resolution time = completed_at - created_at in hours.
-- SLA targets:
-- critical = 24h, high = 72h, medium = 168h, low = 336h.
-- ============================================================

WITH completed_tasks AS (
    SELECT
        priority,
        EXTRACT(DAY FROM (completed_at - created_at)) * 24 +
        EXTRACT(HOUR FROM (completed_at - created_at)) +
        EXTRACT(MINUTE FROM (completed_at - created_at)) / 60 AS resolution_hours
    FROM tasks
    WHERE status = 'completed'
      AND completed_at IS NOT NULL
)
SELECT
    priority,
    COUNT(*) AS completed_task_count,
    ROUND(AVG(resolution_hours), 2) AS avg_resolution_hours,
    ROUND(
        PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY resolution_hours),
        2
    ) AS median_resolution_hours,
    ROUND(MIN(resolution_hours), 2) AS fastest_resolution_hours,
    ROUND(MAX(resolution_hours), 2) AS slowest_resolution_hours,
    CASE
        WHEN priority = 'critical' AND AVG(resolution_hours) <= 24 THEN 'Target Met'
        WHEN priority = 'high'     AND AVG(resolution_hours) <= 72 THEN 'Target Met'
        WHEN priority = 'medium'   AND AVG(resolution_hours) <= 168 THEN 'Target Met'
        WHEN priority = 'low'      AND AVG(resolution_hours) <= 336 THEN 'Target Met'
        ELSE 'Target Missed'
    END AS target_met
FROM completed_tasks
GROUP BY priority
ORDER BY
    CASE priority
        WHEN 'critical' THEN 1
        WHEN 'high' THEN 2
        WHEN 'medium' THEN 3
        WHEN 'low' THEN 4
    END;


-- ============================================================
-- EXERCISE 5: Improved Overdue Tasks Report
-- Definition:
-- Overdue tasks = tasks with due_date before today,
-- not completed and not cancelled.
-- ============================================================

WITH overdue_tasks AS (
    SELECT
        ts.title,
        u.full_name AS assignee,
        t.name AS team_name,
        ts.priority,
        ts.due_date,
        TRUNC(SYSDATE) - ts.due_date AS days_overdue,
        CASE
            WHEN ts.priority = 'critical' AND TRUNC(SYSDATE) - ts.due_date > 0 THEN 'CRITICAL'
            WHEN ts.priority = 'high'     AND TRUNC(SYSDATE) - ts.due_date > 2 THEN 'HIGH'
            WHEN ts.priority = 'medium'   AND TRUNC(SYSDATE) - ts.due_date > 5 THEN 'MEDIUM'
            ELSE 'LOW'
        END AS severity
    FROM tasks ts
    LEFT JOIN users u 
        ON ts.assigned_to = u.id
    LEFT JOIN teams t 
        ON u.team_id = t.id
    WHERE ts.due_date < TRUNC(SYSDATE)
      AND ts.status NOT IN ('completed', 'cancelled')
      AND ts.due_date IS NOT NULL
)
SELECT
    title,
    assignee,
    team_name,
    priority,
    due_date,
    days_overdue,
    severity,
    NULL AS overdue_count,
    NULL AS avg_days_overdue
FROM overdue_tasks

UNION ALL

SELECT
    'SUMMARY' AS title,
    NULL AS assignee,
    NULL AS team_name,
    NULL AS priority,
    NULL AS due_date,
    NULL AS days_overdue,
    severity,
    COUNT(*) AS overdue_count,
    ROUND(AVG(days_overdue), 2) AS avg_days_overdue
FROM overdue_tasks
GROUP BY severity

ORDER BY
    CASE severity
        WHEN 'CRITICAL' THEN 1
        WHEN 'HIGH' THEN 2
        WHEN 'MEDIUM' THEN 3
        WHEN 'LOW' THEN 4
    END,
    days_overdue DESC NULLS LAST;


-- ============================================================
-- EXERCISE 6: Fix Productivity Score
-- Problem:
-- Counting all assigned tasks is not productivity because it includes
-- unfinished, blocked, and cancelled work.
-- Better KPI:
-- Weighted completed tasks per user.
-- Weight:
-- critical = 4, high = 3, medium = 2, low = 1.
-- ============================================================

SELECT
    u.full_name,
    COUNT(CASE 
              WHEN ts.status = 'completed' 
               AND ts.completed_at IS NOT NULL 
              THEN ts.id 
          END) AS completed_tasks,
    SUM(CASE
            WHEN ts.status = 'completed' AND ts.priority = 'critical' THEN 4
            WHEN ts.status = 'completed' AND ts.priority = 'high' THEN 3
            WHEN ts.status = 'completed' AND ts.priority = 'medium' THEN 2
            WHEN ts.status = 'completed' AND ts.priority = 'low' THEN 1
            ELSE 0
        END) AS weighted_productivity_score
FROM users u
LEFT JOIN tasks ts 
    ON ts.assigned_to = u.id
GROUP BY u.id, u.full_name
ORDER BY weighted_productivity_score DESC;


-- ============================================================
-- EXERCISE 7: Fix Team Efficiency
-- Problem:
-- Average task ID is meaningless because an ID is only an identifier,
-- not a performance metric.
-- Better KPI:
-- Team efficiency = completed tasks / total valid tasks,
-- excluding cancelled tasks.
-- ============================================================

SELECT
    t.name AS team_name,
    COUNT(CASE 
              WHEN ts.status <> 'cancelled' 
              THEN ts.id 
          END) AS valid_tasks,
    COUNT(CASE 
              WHEN ts.status = 'completed' 
              THEN ts.id 
          END) AS completed_tasks,
    ROUND(
        COUNT(CASE WHEN ts.status = 'completed' THEN ts.id END) * 100
        / NULLIF(COUNT(CASE WHEN ts.status <> 'cancelled' THEN ts.id END), 0),
        2
    ) AS team_efficiency_rate
FROM teams t
LEFT JOIN users u 
    ON u.team_id = t.id
LEFT JOIN tasks ts 
    ON ts.assigned_to = u.id
GROUP BY t.id, t.name
ORDER BY team_efficiency_rate DESC NULLS LAST;


-- ============================================================
-- EXERCISE 8: Fix Urgency Index
-- Problem:
-- priority is VARCHAR2, so it cannot be multiplied.
-- due_date is DATE, so it should not be added directly to a score.
-- Better KPI:
-- urgency_score = priority weight + overdue pressure.
-- Higher score = more urgent.
-- ============================================================

SELECT
    title,
    priority,
    due_date,
    status,
    CASE priority
        WHEN 'critical' THEN 4
        WHEN 'high' THEN 3
        WHEN 'medium' THEN 2
        WHEN 'low' THEN 1
    END AS priority_weight,
    due_date - TRUNC(SYSDATE) AS days_until_due,
    CASE
        WHEN due_date < TRUNC(SYSDATE) THEN ABS(due_date - TRUNC(SYSDATE))
        ELSE 0
    END AS overdue_days,
    (
        CASE priority
            WHEN 'critical' THEN 4
            WHEN 'high' THEN 3
            WHEN 'medium' THEN 2
            WHEN 'low' THEN 1
        END * 10
        +
        CASE
            WHEN due_date < TRUNC(SYSDATE) THEN ABS(due_date - TRUNC(SYSDATE))
            ELSE 0
        END
    ) AS urgency_score
FROM tasks
WHERE status NOT IN ('completed', 'cancelled')
  AND due_date IS NOT NULL
ORDER BY urgency_score DESC;