USE pharma_supply_chain;

-- 1. Supplier performance: quantity fill vs delivery timeliness.
SELECT
    sp.supplier_id,
    sp.supplier_name,
    COUNT(*) AS orders,
    SUM(po.ordered_qty) AS ordered_units,
    SUM(po.received_qty) AS received_units,
    ROUND(100 * SUM(po.received_qty) / NULLIF(SUM(po.ordered_qty),0),2) AS po_fill_rate_pct,
    ROUND(AVG(po.planned_lead_time),1) AS planned_lead_time_days,
    ROUND(AVG(po.actual_lead_time),1) AS actual_lead_time_days,
    ROUND(AVG(po.actual_lead_time - po.planned_lead_time),1) AS lead_time_variance_days,
    SUM(po.late_flag) AS late_orders,
    ROUND(100 * AVG(po.late_flag),2) AS late_rate_pct
FROM fact_purchase_orders po
JOIN dim_supplier sp ON sp.supplier_id=po.supplier_id
GROUP BY sp.supplier_id,sp.supplier_name
ORDER BY late_rate_pct DESC;

-- 2. Inventory against safety stock.
SELECT
    l.location_name,
    l.region,
    d.drug_id,
    d.drug_name,
    d.safety_stock,
    ROUND(AVG(i.closing_stock),0) AS avg_closing_stock,
    MIN(i.closing_stock) AS min_closing_stock,
    ROUND(AVG(i.closing_stock)-d.safety_stock,0) AS avg_gap,
    SUM(i.closing_stock < d.safety_stock) AS days_below_safety,
    ROUND(100 * SUM(i.closing_stock < d.safety_stock) / COUNT(*),2) AS pct_days_below_safety_stock,
    SUM(i.stockout_flag) AS stockout_days,
    ROUND(100 * AVG(i.stockout_flag),2) AS stockout_rate_pct
FROM fact_inventory i
JOIN dim_drug d ON d.drug_id=i.drug_id
JOIN dim_location l ON l.location_id=i.location_id
GROUP BY l.location_name,l.region,d.drug_id,d.drug_name,d.safety_stock
ORDER BY stockout_rate_pct DESC, avg_gap ASC;

-- 3. Drug/location replenishment execution.
SELECT
    l.location_name,
    l.region,
    d.drug_id,
    d.drug_name,
    COUNT(*) AS total_orders,
    SUM(po.ordered_qty) AS ordered_units,
    SUM(po.received_qty) AS received_units,
    ROUND(100 * SUM(po.received_qty)/NULLIF(SUM(po.ordered_qty),0),2) AS po_fill_rate_pct,
    SUM(po.late_flag) AS late_orders,
    ROUND(100 * AVG(po.late_flag),2) AS late_rate_pct,
    ROUND(AVG(po.actual_lead_time-po.planned_lead_time),1) AS avg_lead_time_variance
FROM fact_purchase_orders po
JOIN dim_drug d ON d.drug_id=po.drug_id
JOIN dim_location l ON l.location_id=po.location_id
GROUP BY l.location_name,l.region,d.drug_id,d.drug_name
ORDER BY late_rate_pct DESC;

-- 4. Inventory imbalance: one location above safety stock while another is below.
WITH avg_inventory AS (
    SELECT drug_id, location_id, AVG(closing_stock) AS avg_closing_stock
    FROM fact_inventory
    GROUP BY drug_id, location_id
)
SELECT
    d.drug_id,
    d.drug_name,
    l.location_name,
    l.region,
    d.safety_stock,
    ROUND(ai.avg_closing_stock,0) AS avg_closing_stock,
    ROUND(ai.avg_closing_stock-d.safety_stock,0) AS stock_vs_safety_stock
FROM avg_inventory ai
JOIN dim_drug d ON d.drug_id=ai.drug_id
JOIN dim_location l ON l.location_id=ai.location_id
WHERE ABS(ai.avg_closing_stock-d.safety_stock) >= 15
ORDER BY d.drug_id, stock_vs_safety_stock DESC;

-- 5. Expiry exposure by drug/location.
SELECT
    l.location_name,
    l.region,
    d.drug_id,
    d.drug_name,
    d.category,
    SUM(e.quantity) AS expiry_units,
    ROUND(SUM(e.inventory_value),2) AS expiry_value,
    COUNT(*) AS batches,
    MIN(e.expiry_date) AS earliest_expiry
FROM fact_expiry e
JOIN dim_drug d ON d.drug_id=e.drug_id
JOIN dim_location l ON l.location_id=e.location_id
GROUP BY l.location_name,l.region,d.drug_id,d.drug_name,d.category
ORDER BY expiry_value DESC;
