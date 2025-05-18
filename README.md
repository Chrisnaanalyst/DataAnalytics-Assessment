# DataAnalytics-Assessment

### Question 1: Identify customers with both funded savings and investment plans

**Approach:**
- Joined `users_customuser`, `savings_savingsaccount`, and `plans_plan` via `owner_id` and `plan_id`.
- A **savings plan** is defined by `is_regular_savings = TRUE`.
- An **investment plan** is defined by `is_a_fund = TRUE`.
- Only included rows where `confirmed_amount > 0` (i.e., funded).
- Used `CASE WHEN` statements to count distinct plan IDs by type.
- Converted the total confirmed amount from kobo to naira by dividing by 100 and rounding to 2 decimal places.

**Challenges:**
- Ensured clear separation between plan types using logical filters.
- Verified proper relationships between users, plans, and savings accounts.
- Carefully handled unit conversion and ensured accurate grouping and filtering.
---

# Assessment Question 2: Transaction Frequency Analysis
**Objective:**
This SQL query analyzes the frequency of customer transactions to classify users into three categories:
- **High Frequency** (≥10 transactions/month)
- **Medium Frequency** (3–9 transactions/month)
- **Low Frequency** (≤2 transactions/month)

## Tables Used
- `users_customuser`: Contains user profile information, including `id` as the primary key.
- `savings_savingsaccount`: Contains savings transactions for users, with `owner_id` linking to `users_customuser.id`.

## Approach
1. **Join both tables** using `owner_id = id` to ensure valid user transactions are included.
2. **Aggregate transactions** per user per month using `DATE_FORMAT`.
3. **Calculate average monthly transactions** per user.
4. **Classify users** into frequency categories based on their average.
5. **Summarize** the number of users and average transaction rate in each category.

## Output Columns
- `frequency_category`: The transaction frequency class.
- `customer_count`: Number of users in each category.
- `avg_transactions_per_month`: Average monthly transactions for users in each category.

---

# Assessment Question 3:Inactive Savings or Investment Plans Detection
 **Scenario**
- You want to identify active savings or investment plans that have not received any confirmed inflow transactions in the last 365 days.

- This is helpful for tracking dormant plans and designing strategies to improve customer engagement.

**Objective :**
- Find all active savings or investment plans where:

* The most recent confirmed inflow is older than 365 days Or, there has been no recent transaction activity
---
## Tables Used
- plans_plan: Contains information about all available plans, including:

* id

* is_regular_savings

* is_a_fund

* savings_savingsaccount: Contains transaction records for each plan:

* plan_id

* confirmed_amount

* transaction_date

* owner_id

## How the Query Works
- Step 1: Filter Active Plans
```sql
SELECT DISTINCT id 
FROM plans_plan 
WHERE is_regular_savings = TRUE OR is_a_fund = TRUE
```

**Returns only plans that are either savings or investment funds Used as a subquery named active_plans**

- Step 2: Get Most Recent Confirmed Inflow
```sql
SELECT plan_id, MAX(transaction_date) AS last_trans
FROM savings_savingsaccount
WHERE confirmed_amount > 0
GROUP BY plan_id
```
**Retrieves the last confirmed inflow date per plan Used as a subquery named recent_trans**

- Step 3: Main Query Logic
**Join plans_plan, savings_savingsaccount, active_plans, and recent_trans Filter where DATEDIFF(CURDATE(), last_trans) > 365**
---
## Output Columns
**Column Name	Description:**
* plan_id	Unique identifier of the plan
* owner_id	ID of the user who owns the plan
* type	Either "Savings" or "Investment" based on plan attributes
* last_transaction_date	Date of last confirmed inflow transaction
* inactivity_days	Number of days since last inflow

## Challenges Faced
- Column Reference Error
- Initially tried accessing owner_id from plans_plan (doesn’t exist).
- Fix: Retrieved owner_id from savings_savingsaccount.

## Ambiguous Logic on No Transactions
- Uncertainty whether to include plans with no transactions at all.
- Fix: Included only plans with at least one confirmed inflow (confirmed_amount > 0).

## Subquery Complexity
- JOINing derived tables was confusing at first.
- Fix: Broke subqueries into independent components and tested separately.
  
---

#  Assessment Question 4:Customer Lifetime Value (CLV) Estimation

**Scenario:**

- The marketing team wants to estimate the **Customer Lifetime Value (CLV)** for all customers using a simplified model based on account tenure and confirmed inflow transactions.

---

##  Objective

* Estimate the CLV for each customer using the formula:
* Assumption: Each transaction contributes a profit of **0.1% (i.e., 0.001)**.

---

##  Tables Used

### `users_customuser`
- Contains customer details.
- **Key Fields:**
  - `id`: Primary key
  - `name`, `first_name`, `last_name`: Customer's name fields
  - `date_joined`: When the customer created the account

### `savings_savingsaccount`
- Contains savings transaction data.
- **Key Fields:**
  - `owner_id`: FK to `users_customuser.id`
  - `confirmed_amount`: Verified inflow value (in kobo)
  - `transaction_date`: Date of transaction

---

| Column               | Description                             |
| -------------------- | --------------------------------------- |
| `customer_id`        | ID of the customer                      |
| `name`               | Customer’s full name (fallback applied) |
| `tenure_months`      | Number of months since account creation |
| `total_transactions` | Count of confirmed inflow transactions  |
| `estimated_clv`      | Computed lifetime value estimate        |

## Challenges Faced
1. Choosing the Right Date for Tenure
Initially considered using transaction_date (first transaction).

- Chose date_joined because:

* It always exists.

* Reflects the true start of the customer’s lifecycle.

2. Handling Null Names
- Some customers had null name, first_name, and last_name.

**Used:**

```sql
COALESCE(u.name, CONCAT_WS(' ', u.first_name, u.last_name))
```
**CONCAT_WS smartly skips nulls and extra spaces.**

3. Division by Zero Risk
- Customers with tenure_months = 0 would trigger errors.

**Solution:**

```sql
NULLIF(TIMESTAMPDIFF(MONTH, u.date_joined, CURDATE()), 0)
```
**Converts 0 to NULL and avoids the divide-by-zero error.**

4. Identifying the Correct Transaction Field
- Chose confirmed_amount because it represents actual inflow.

**Confirmed by provided business logic:**

* confirmed_amount = inflow

* amount_withdrawn = outflow


