
/* Write a query to find customer with at least one funded savings plan AND 
one funded investment plan, sorted by total deposits/*

select
 u.id AS owner_id,
    CONCAT(u.first_name, ' ', u.last_name) AS name,
    COUNT(DISTINCT CASE WHEN p.is_regular_savings = TRUE THEN s.plan_id END) AS savings_count,
    COUNT(DISTINCT CASE WHEN p.is_a_fund = TRUE THEN s.plan_id END) AS investment_count,
    ROUND(SUM(s.confirmed_amount) / 100.0, 2) AS total_deposits
FROM users_customuser u
JOIN savings_savingsaccount s ON u.id = s.owner_id
JOIN plans_plan p ON s.plan_id = p.id
WHERE s.confirmed_amount > 0
GROUP BY u.id, u.first_name, u.last_name
HAVING
    COUNT(DISTINCT CASE WHEN p.is_regular_savings = TRUE THEN s.plan_id END) >= 1
    AND COUNT(DISTINCT CASE WHEN p.is_a_fund = TRUE THEN s.plan_id END) >= 1
ORDER BY total_deposits DESC;