-- Advanced Insights 

-- 1. Discount / Slippage Analysis per Sales AgentGoal: Calculate the average discount percentage given by each sales agent to pinpoint who might be relying too heavily on price drops to close deals. 
 SELECT 
    p.sales_agent,
    COUNT(p.opportunity_id) AS won_deals,
    ROUND(AVG(pr.sales_price), 2) AS avg_retail_price,
    ROUND(AVG(p.close_value), 2) AS avg_close_value,
    ROUND(
        AVG(((pr.sales_price - p.close_value) / pr.sales_price) * 100), 
        2
    ) AS avg_discount_percentage
FROM sales_pipeline p
INNER JOIN products pr 
    ON REPLACE(p.product, 'GTXPro', 'GTX Pro') = pr.product
WHERE p.deal_stage = 'Won'
GROUP BY p.sales_agent
ORDER BY avg_discount_percentage DESC;

-- 2. Quarter-over-Quarter (QoQ) Revenue GrowthGoal: Use the window function LAG() to look at revenue progression across chronological quarters. 
 
 WITH QuarterlyRevenue AS (
    SELECT 
        YEAR(close_date) AS deal_year,
        QUARTER(close_date) AS deal_quarter,
        SUM(close_value) AS revenue
    FROM sales_pipeline
    WHERE deal_stage = 'Won' AND close_date IS NOT NULL
    GROUP BY YEAR(close_date), QUARTER(close_date)
)
SELECT 
    deal_year,
    deal_quarter,
    ROUND(revenue, 2) AS current_quarter_revenue,
    ROUND(
        LAG(revenue, 1) OVER (ORDER BY deal_year, deal_quarter), 
        2
    ) AS previous_quarter_revenue,
    ROUND(
        ((revenue - LAG(revenue, 1) OVER (ORDER BY deal_year, deal_quarter)) / 
        LAG(revenue, 1) OVER (ORDER BY deal_year, deal_quarter)) * 100, 
        2
    ) AS qoq_growth_percentage
FROM QuarterlyRevenue;

-- 3. Sales Agent Revenue TieringGoal: Use a CASE WHEN conditional distribution statement to tier sales agents based on total revenue generation, giving management a clear team health overview.  

WITH AgentRevenue AS (
    SELECT 
        sales_agent,
        SUM(COALESCE(close_value, 0)) AS total_revenue
    FROM sales_pipeline
    WHERE deal_stage = 'Won'
    GROUP BY sales_agent
)
SELECT 
    sales_agent,
    ROUND(total_revenue, 2) AS total_revenue,
    CASE 
        WHEN total_revenue >= 1000000 THEN 'Elite'
        WHEN total_revenue >= 500000 AND total_revenue < 1000000 THEN 'Mid-Tier'
        ELSE 'Underperforming'
    END AS performance_tier
FROM AgentRevenue
ORDER BY total_revenue DESC;


-- total revenue of Acme Corp and all of its subsidiaries.

SELECT 
    COALESCE(a.subsidiary_of, p.account) AS parent_company,
    ROUND(SUM(COALESCE(p.close_value, 0)), 2) AS total_combined_revenue
FROM sales_pipeline p
INNER JOIN accounts a 
    ON p.account = a.account
WHERE p.deal_stage = 'Won'
  AND (a.subsidiary_of = 'Acme Corp' OR p.account = 'Acme Corp')
GROUP BY parent_company;