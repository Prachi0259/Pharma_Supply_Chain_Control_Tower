USE pharma_supply_chain;

-- ABC-XYZ segmentation.
WITH daily_demand AS (
    SELECT drug_id, date, SUM(demand_qty) AS daily_demand
    FROM fact_sales
    GROUP BY drug_id,date
), demand_stats AS (
    SELECT drug_id,
           AVG(daily_demand) AS avg_daily_demand,
           STDDEV_POP(daily_demand) AS demand_stddev
    FROM daily_demand
    GROUP BY drug_id
), annual_value AS (
    SELECT d.drug_id,
           d.drug_name,
           d.category,
           d.criticality,
           d.unit_cost,
           SUM(s.demand_qty) AS annual_demand,
           SUM(s.demand_qty)*d.unit_cost AS annual_demand_value
    FROM fact_sales s
    JOIN dim_drug d ON d.drug_id=s.drug_id
    GROUP BY d.drug_id,d.drug_name,d.category,d.criticality,d.unit_cost
)
SELECT
    a.*,
    ROUND(ds.demand_stddev/NULLIF(ds.avg_daily_demand,0),3) AS cv,
    CASE
      WHEN PERCENT_RANK() OVER (ORDER BY annual_demand_value DESC) <= 0.40 THEN 'A'
      WHEN PERCENT_RANK() OVER (ORDER BY annual_demand_value DESC) <= 0.68 THEN 'B'
      ELSE 'C'
    END AS abc_class,
    CASE
      WHEN ds.demand_stddev/NULLIF(ds.avg_daily_demand,0) < 0.50 THEN 'X'
      WHEN ds.demand_stddev/NULLIF(ds.avg_daily_demand,0) < 1.00 THEN 'Y'
      ELSE 'Z'
    END AS xyz_class
FROM annual_value a
JOIN demand_stats ds ON ds.drug_id=a.drug_id
ORDER BY annual_demand_value DESC;

-- Baseline ROP using average demand and actual lead time.
WITH demand AS (
    SELECT drug_id, AVG(demand_qty) AS avg_daily_demand
    FROM fact_sales
    GROUP BY drug_id
), lead_time AS (
    SELECT drug_id, AVG(actual_lead_time) AS avg_actual_lead_time
    FROM fact_purchase_orders
    GROUP BY drug_id
)
SELECT
    d.drug_id,
    d.drug_name,
    ROUND(dm.avg_daily_demand,0) AS avg_daily_demand,
    ROUND(lt.avg_actual_lead_time,1) AS avg_lead_time_days,
    d.safety_stock,
    ROUND(dm.avg_daily_demand*lt.avg_actual_lead_time+d.safety_stock,0) AS baseline_rop
FROM dim_drug d
JOIN demand dm ON dm.drug_id=d.drug_id
JOIN lead_time lt ON lt.drug_id=d.drug_id
ORDER BY baseline_rop DESC;

-- 95% scenario ROP: demand + lead-time variability buffer.
WITH daily_demand AS (
    SELECT drug_id,date,SUM(demand_qty) AS daily_demand
    FROM fact_sales
    GROUP BY drug_id,date
), demand_stats AS (
    SELECT drug_id,AVG(daily_demand) AS avg_daily_demand,STDDEV_POP(daily_demand) AS demand_stddev
    FROM daily_demand GROUP BY drug_id
), lead_stats AS (
    SELECT drug_id,AVG(actual_lead_time) AS avg_lead_time,STDDEV_POP(actual_lead_time) AS lead_time_stddev
    FROM fact_purchase_orders GROUP BY drug_id
), calc AS (
    SELECT d.drug_id,d.drug_name,d.category,d.criticality,d.safety_stock,
           ds.avg_daily_demand,ds.demand_stddev,ls.avg_lead_time,ls.lead_time_stddev,
           SQRT(ls.avg_lead_time*POWER(ds.demand_stddev,2)+POWER(ds.avg_daily_demand,2)*POWER(ls.lead_time_stddev,2)) AS combined_stddev
    FROM dim_drug d
    JOIN demand_stats ds ON ds.drug_id=d.drug_id
    JOIN lead_stats ls ON ls.drug_id=d.drug_id
)
SELECT
    drug_id,drug_name,category,criticality,
    ROUND(avg_daily_demand,0) AS avg_daily_demand,
    ROUND(avg_lead_time,1) AS avg_lead_time_days,
    ROUND(lead_time_stddev,2) AS lead_time_stddev,
    safety_stock,
    ROUND(avg_daily_demand*avg_lead_time,0) AS lead_time_demand,
    ROUND(combined_stddev,0) AS demand_lead_time_variability,
    ROUND(avg_daily_demand*avg_lead_time+safety_stock,0) AS baseline_rop,
    ROUND(avg_daily_demand*avg_lead_time+1.65*combined_stddev,0) AS scenario_rop_95,
    ROUND(avg_daily_demand*avg_lead_time+1.65*combined_stddev-safety_stock,0) AS incremental_inventory_vs_safety_stock
FROM calc
ORDER BY scenario_rop_95 DESC;
