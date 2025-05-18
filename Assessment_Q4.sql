/* 
   For each customer, assuming profit_per_transaction is 0.1% of the transaction value, calculate:
   - Account tenure (months since signup)
   - Total transactions
   - Estimated CLV 
     (Formula: CLV = (total_transactions / tenure_months) * 12 * avg_profit_per_transaction)
   Order by estimated CLV from highest to lowest.
*/
SELECT 
    u.id AS customer_id,
    NULLIF(COALESCE(u.name, CONCAT_WS(' ', u.first_name, u.last_name)), '') AS name,
    TIMESTAMPDIFF(MONTH, u.date_joined, CURDATE()) AS tenure_months,
    COUNT(sa.id) AS total_transactions,
    ROUND(
        (COUNT(sa.id) / NULLIF(TIMESTAMPDIFF(MONTH, u.date_joined, CURDATE()), 0)) * 12 *
        (AVG(sa.confirmed_amount) / 100.0) * 0.001,
        2
    ) AS estimated_clv
FROM users_customuser u
LEFT JOIN savings_savingsaccount sa ON sa.owner_id = u.id
GROUP BY u.id, name, tenure_months
HAVING tenure_months > 0
ORDER BY estimated_clv DESC;



