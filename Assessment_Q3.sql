/* Find all active accounts (savings or investments) with no transactions in the last 1 year (365 days) /*.
select *
        from
        users_customuser;
        
SELECT 
    p.id AS plan_id,
    sa.owner_id,
    CASE 
        WHEN p.is_regular_savings = TRUE THEN 'Savings'
        WHEN p.is_a_fund = TRUE THEN 'Investment'
        ELSE 'Other'
    END AS type,
    MAX(sa.transaction_date) AS last_transaction_date,
    DATEDIFF(CURDATE(), MAX(sa.transaction_date)) AS inactivity_days
FROM plans_plan p
JOIN savings_savingsaccount sa ON sa.plan_id = p.id
JOIN (
    SELECT DISTINCT id FROM plans_plan 
    WHERE is_regular_savings = TRUE OR is_a_fund = TRUE
) active_plans ON active_plans.id = p.id
JOIN (
    SELECT plan_id, MAX(transaction_date) AS last_txn
    FROM savings_savingsaccount
    WHERE confirmed_amount > 0
    GROUP BY plan_id
) recent_txns ON recent_txns.plan_id = p.id
WHERE recent_txns.last_txn < CURDATE() - INTERVAL 365 DAY
GROUP BY p.id, sa.owner_id, type;
