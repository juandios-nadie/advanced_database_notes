-- ============================================================
-- EXERCISE 5: Discussion (Answers in SQL comments)
-- ============================================================

-- Q1:
-- Inside the transaction:
--   a) Reserve the time slot
--   b) Create the appointment record
-- Outside the transaction:
--   c) Send confirmation notification
-- Reason:
--   The first two must be atomic to maintain database consistency.
--   The notification is external and should not affect the transaction if it fails.

-- Q2:
-- Problem:
--   A COMMIT inside the procedure finalizes changes immediately.
--   If the procedure is called within a larger transaction,
--   the caller cannot ROLLBACK those changes anymore.
--   This breaks transaction control and can cause inconsistent states.

-- Q3:
-- calculate_copay():
--   Yes, it can be used in a SELECT because it is a function
--   that returns a value and does not modify data.
-- post_payment():
--   No, it cannot be used in a SELECT because it is a procedure
--   that performs actions (like INSERT/UPDATE) and may use COMMIT/ROLLBACK.

SELECT * FROM accounts;

UPDATE accounts SET balance = balance - 50 WHERE account_id = 3;
UPDATE accounts SET balance = balance + 50 WHERE account_id = 1;

COMMIT;

SELECT * FROM accounts;


UPDATE accounts SET balance = balance - 10000 WHERE account_id = 2;
UPDATE accounts SET balance = balance + 10000 WHERE account_id = 3;

SELECT * FROM accounts;

ROLLBACK;

SELECT * FROM accounts;


UPDATE accounts SET balance = balance + 25 WHERE account_id = 1;

SAVEPOINT sp1;

UPDATE accounts SET balance = balance - 25 WHERE account_id = 3;

ROLLBACK TO sp1;

UPDATE accounts SET balance = balance - 25 WHERE account_id = 2;

COMMIT;

SELECT * FROM accounts;

CREATE OR REPLACE PROCEDURE deposit_funds(
    p_account_id IN NUMBER,
    p_amount     IN NUMBER
) AS
BEGIN
    IF p_amount <= 0 THEN
        RAISE_APPLICATION_ERROR(-20002, 'Amount must be greater than 0');
    END IF;

    UPDATE accounts
    SET balance = balance + p_amount
    WHERE account_id = p_account_id;

    COMMIT;

EXCEPTION
    WHEN OTHERS THEN
        ROLLBACK;
        RAISE;
END;
/

EXEC deposit_funds(3, 75);