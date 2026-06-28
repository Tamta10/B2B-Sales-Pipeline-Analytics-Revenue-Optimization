-- Objective 1: Pipeline Metrics
-- Your first objective is to assess the overall sales pipeline by looking at opportunities by month, time to close, win rate, and product data .

-- TASK 1: Calculate the number of sales opportunities created each month using "engage_date", and identify the month with the most opportunities.
-- TASK 2:Find the average time deals stayed open (from "engage_date" to "close_date"), and compare closed deals versus won deals.
-- TASK 3:Calculate the percentage of deals in each stage, and determine what share were lost.
-- TASK 4:Compute the win rate for each product, and identify which one had the highest win rate.
 
 

-- Task 1: Monthly Trends & Peak Opportunity Month
-- -Calculate the number of sales opportunities created each month using "engage_date", and identify the month with the most opportunities

SELECT MONTH(engage_date_new),count(*)
FROM sales_pipeline
GROUP BY MONTH(engage_date_new)
ORDER BY COUNT(*) desc

-- Task 2: Deal Velocity (Closed vs. Won Deals)
-- Goal: Find the average time deals stayed open (from engage_date to close_date), and compare closed deals versus won deals.

 SELECT 
    deal_stage,
    COUNT(opportunity_id) AS total_deals,
    -- MySQL DATEDIFF takes (end_date, start_date)
    ROUND(AVG(DATEDIFF(close_date, engage_date)), 1) AS avg_days_to_close
FROM sales_pipeline
WHERE 
    engage_date IS NOT NULL 
    AND close_date IS NOT NULL
    AND deal_stage IN ('Won', 'Lost')
GROUP BY deal_stage;


-- Task 3: Funnel Share & Lost Percentage
-- Goal: Calculate the percentage of deals in each stage, and determine what share were lost.

SELECT 
    deal_stage,
    COUNT(opportunity_id) AS deal_count,
    ROUND(
        (COUNT(opportunity_id) * 100.0) / (SELECT COUNT(*) FROM sales_pipeline), 
        2
    ) AS funnel_percentage
FROM sales_pipeline
GROUP BY deal_stage
ORDER BY deal_count DESC;


-- Task 4: Product Win Rate
-- Goal: Compute the win rate for each product, and identify which one had the highest win rate.

SELECT 
    product,
    COUNT(opportunity_id) AS total_opportunities,
    SUM(CASE WHEN deal_stage = 'Won' THEN 1 ELSE 0 END) AS won_deals,
    ROUND(
        (SUM(CASE WHEN deal_stage = 'Won' THEN 1 ELSE 0 END) * 100.0) / 
        COUNT(opportunity_id), 
        2
    ) AS win_rate_percentage
FROM sales_pipeline
WHERE deal_stage IN ('Won', 'Lost') 
GROUP BY product
ORDER BY win_rate_percentage DESC; -- Top row shows the highest win rate




-- Objective 2 : Sales agent performance.
-- Your second objective is to assess the performance of sales agents, their managers, and regional offices.alter

-- TASK 1:Calculate the win rate for each sales agent, and find the top performer.
-- TASK 2:Calculate the total revenue by agent, and see who generated the most.
-- TASK 3:Calculate win rates by manager to determine which manager’s team performed best.
-- TASK 4:For the product GTX Plus Pro, find which regional office sold the most units.


-- TASK 1: Agent Win Rates &  TASK 2  :Revenue BY AGENT 
-- Goal: Group by sales_agent, count their win percentage, and sum their total close_value to expose performance styles.

SELECT 
    sales_agent,
    COUNT(opportunity_id) AS total_opportunities,
    SUM(CASE WHEN deal_stage = 'Won' THEN 1 ELSE 0 END) AS won_deals,
    ROUND(
        (SUM(CASE WHEN deal_stage = 'Won' THEN 1 ELSE 0 END) * 100.0) / 
        COUNT(CASE WHEN deal_stage IN ('Won', 'Lost') THEN 1 END), 
        2
    ) AS win_rate_percentage,
    ROUND(SUM(COALESCE(close_value, 0)), 2) AS total_revenue
FROM sales_pipeline
GROUP BY sales_agent
ORDER BY total_revenue DESC; 


-- TASK 2: Manager Performance
-- Goal: Join sales_pipeline with sales_teams on sales_agent. Group by manager and calculate overall team win rates.

SELECT 
    t.manager,
    COUNT(p.opportunity_id) AS team_opportunities,
    SUM(CASE WHEN p.deal_stage = 'Won' THEN 1 ELSE 0 END) AS team_won_deals,
    ROUND(
        (SUM(CASE WHEN p.deal_stage = 'Won' THEN 1 ELSE 0 END) * 100.0) / 
        COUNT(CASE WHEN p.deal_stage IN ('Won', 'Lost') THEN 1 END), 
        2
    ) AS team_win_rate_percentage
FROM sales_pipeline p
INNER JOIN sales_teams t 
    ON p.sales_agent = t.sales_agent
GROUP BY t.manager
ORDER BY team_win_rate_percentage DESC;  

-- TASK 3: Regional Volume for "GTX Plus Pro"
-- Goal: Filter specifically for GTX Plus Pro, join tables, and find out which regional office sold the most units.

SELECT 
    t.regional_office,
    COUNT(p.opportunity_id) AS units_sold 
FROM sales_pipeline p
INNER JOIN sales_teams t 
    ON p.sales_agent = t.sales_agent
WHERE p.product = 'GTX Plus Pro' 
  AND p.deal_stage = 'Won'
GROUP BY t.regional_office
ORDER BY units_sold DESC; 




-- Objective 3 : Product analysis
-- Your third objective is to analyze the sales performance and quantity sold of the company's product portfolio

-- TASK 1 :For March deals, identify the top product by revenue and compare it to the top by units sold
-- TASK 2 :Calculate the average difference between "sales_price" and "close_value" for each product, and note if the results suggest a data issue
-- TASK 3 :Calculate total revenue by product series and compare their performance

-- TASK 1: March Madness (Revenue vs. Volume)
-- Goal: Filter records where the deal was closed or engaged in March (using close_date for finalized revenue). Compare the top product by total revenue generated (SUM(close_value)) versus total deal count (COUNT(opportunity_id)).

SELECT 
    product,
    COUNT(opportunity_id) AS total_deals_closed,
    ROUND(SUM(COALESCE(close_value, 0)), 2) AS total_revenue
FROM sales_pipeline
WHERE MONTH(close_date) = 3 
  AND deal_stage = 'Won'
GROUP BY product
ORDER BY total_revenue DESC; 

-- TASK 2: The Pricing Discrepancy (Crucial Data Issue)
-- Goal: Join sales_pipeline with the products table on the product name. Calculate the difference between the standard retail market price (sales_price) and the actual finalized price (close_value) for won deals.

SELECT 
    p.product,
    r.series,
    r.sales_price AS standard_retail_price,
    ROUND(AVG(p.close_value), 2) AS avg_actual_close_value,
    ROUND(r.sales_price - AVG(p.close_value), 2) AS avg_price_difference,
    ROUND(((r.sales_price - AVG(p.close_value)) / r.sales_price) * 100, 2) AS avg_discount_percentage
FROM sales_pipeline p
INNER JOIN products r 
    ON REPLACE(p.product, 'GTXPro', 'GTX Pro') = r.product
WHERE p.deal_stage = 'Won'
GROUP BY p.product, r.series, r.sales_price
ORDER BY avg_price_difference DESC; 

-- TASK 3: Product Series Performance
-- Goal: Group by product series (GTX, MG, GTK) by joining the tables together, then aggregate the total actual revenue to identify the core financial pillars of the company.


SELECT 
    r.series,
    COUNT(p.opportunity_id) AS total_won_deals,
    ROUND(SUM(COALESCE(p.close_value, 0)), 2) AS total_series_revenue,
    ROUND(
        (SUM(COALESCE(p.close_value, 0)) * 100.0) / 
        (SELECT SUM(close_value) FROM sales_pipeline WHERE deal_stage = 'Won'), 
        2
    ) AS contribution_percentage
FROM sales_pipeline p
INNER JOIN products r 
    ON REPLACE(p.product, 'GTXPro', 'GTX Pro') = r.product
WHERE p.deal_stage = 'Won'
GROUP BY r.series
ORDER BY total_series_revenue DESC;




-- Objective 4: Account analysis
-- Your final objective is to analyze the company's accounts to get a better understanding of the team's customers.alter

-- TASK 1: Calculate revenue by office location, and identify the lowest performer
-- TASK 2: Find the gap in years between the oldest and newest customer, and name those companies
-- TASK 3: Which accounts that were subsidiaries had the most lost sales opportunities?
-- TASK 4: Join the companies to their subsidiaries. Which one had the highest total revenue?


-- TASK 1: Bottom Office LocationsGoal: Group by office_location from the accounts table and sum the revenue to highlight underperforming regions.  

SELECT 
    a.office_location,
    COUNT(p.opportunity_id) AS total_won_deals,
    ROUND(SUM(COALESCE(p.close_value, 0)), 2) AS total_revenue
FROM sales_pipeline p
INNER JOIN accounts a 
    ON p.account = a.account
WHERE p.deal_stage = 'Won'
GROUP BY a.office_location
ORDER BY total_revenue ASC;

-- TASK 2: Customer Longevity GapGoal: Find the year gap between your oldest established client enterprise and your newest client from the accounts table. 
 
 SELECT 
    MIN(year_established) AS oldest_client_establishment_year,
    MAX(year_established) AS newest_client_establishment_year,
    (MAX(year_established) - MIN(year_established)) AS customer_longevity_gap_years
FROM accounts;


-- Step 3: Subsidiary Failure RatesGoal: Identify which corporate parent companies have subsidiaries that consistently result in lost sales opportunities. 

 SELECT 
    a.subsidiary_of AS parent_company,
    COUNT(p.opportunity_id) AS lost_deals_count
FROM sales_pipeline p
INNER JOIN accounts a 
    ON p.account = a.account
WHERE a.subsidiary_of IS NOT NULL 
  AND p.deal_stage = 'Lost'
GROUP BY a.subsidiary_of
ORDER BY lost_deals_count DESC;












