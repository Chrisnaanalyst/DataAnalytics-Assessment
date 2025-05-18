      
/* Calculate the average number of transactions per customer per month and categorize them /*
SELECT 
    frequency_category,
    COUNT(*) AS customer_count,
    ROUND(AVG(avg_txn_per_month), 1) AS avg_transactions_per_month
FROM (
    SELECT 
        u.id AS user_id,
        CASE
            WHEN AVG(monthly_txn_count) >= 10 THEN 'High Frequency'
            WHEN AVG(monthly_txn_count) BETWEEN 3 AND 9 THEN 'Medium Frequency'
            ELSE 'Low Frequency'
        END AS frequency_category,
        AVG(monthly_txn_count) AS avg_txn_per_month
    FROM (
        SELECT 
            s.owner_id,
            DATE_FORMAT(s.transaction_date, '%Y-%m') AS txn_month,
            COUNT(*) AS monthly_txn_count
        FROM savings_savingsaccount s
        JOIN users_customuser u ON s.owner_id = u.id
        GROUP BY s.owner_id, txn_month
    ) AS monthly_txns
    JOIN users_customuser u ON monthly_txns.owner_id = u.id
    GROUP BY u.id
) AS categorized_users
GROUP BY frequency_category
ORDER BY FIELD(frequency_category, 'High Frequency', 'Medium Frequency', 'Low Frequency');


