USE pharma_supply_chain;

-- 1. Executive KPIs: aggregate each fact separately to avoid fan-out.
WITH sales_kpi AS (
    SELECT
        COUNT(DISTINCT date) AS analysis_days,
        COUNT(DISTINCT drug_id) AS drugs_analyzed,
        COUNT(DISTINCT location_id) AS locations_analyzed,
        SUM(demand_qty) AS total_demand,
        SUM(fulfilled_qty) AS total_fulfilled,
        SUM(stockout_flag) AS stockout_records
    FROM fact_sales
), inventory_kpi AS (
    SELECT
        SUM(i.closing_stock) AS closing_inventory_units,
        SUM(i.closing_stock * d.unit_cost) AS closing_inventory_value
    FROM fact_inventory i
    JOIN dim_drug d ON d.drug_id = i.drug_id
), po_kpi AS (
    SELECT
        COUNT(*) AS purchase_orders,
        SUM(ordered_qty) AS ordered_units,
        SUM(received_qty) AS received_units,
        SUM(late_flag) AS late_purchase_orders
    FROM fact_purchase_orders
), expiry_kpi AS (
    SELECT SUM(quantity) AS expiry_units, SUM(inventory_value) AS expiry_value
    FROM fact_expiry
)
SELECT
    s.*,
    ROUND(100 * s.total_fulfilled / NULLIF(s.total_demand,0),2) AS fill_rate_pct,
    ROUND(100 * s.stockout_records / NULLIF(s.analysis_days * s.drugs_analyzed * s.locations_analyzed,0),2) AS stockout_rate_pct,
    i.closing_inventory_units,
    ROUND(i.closing_inventory_value,2) AS closing_inventory_value,
    p.purchase_orders,
    p.ordered_units,
    p.received_units,
    ROUND(100 * p.received_units / NULLIF(p.ordered_units,0),2) AS supplier_fill_rate_pct,
    p.late_purchase_orders,
    ROUND(100 * p.late_purchase_orders / NULLIF(p.purchase_orders,0),2) AS supplier_late_rate_pct,
    e.expiry_units,
    ROUND(e.expiry_value,2) AS expiry_value
FROM sales_kpi s
CROSS JOIN inventory_kpi i
CROSS JOIN po_kpi p
CROSS JOIN expiry_kpi e;

-- 2. Drug-level service gap.
SELECT
    d.drug_id,
    d.drug_name,
    d.category,
    d.criticality,
    SUM(s.demand_qty) AS total_demand,
    SUM(s.fulfilled_qty) AS total_fulfilled,
    SUM(s.demand_qty - s.fulfilled_qty) AS unfulfilled_qty,
    ROUND(100 * SUM(s.fulfilled_qty) / NULLIF(SUM(s.demand_qty),0),2) AS fill_rate_pct,
    SUM(s.stockout_flag) AS stockout_records,
    ROUND(100 * SUM(s.stockout_flag) / COUNT(*),2) AS stockout_rate_pct
FROM fact_sales s
JOIN dim_drug d ON d.drug_id = s.drug_id
GROUP BY d.drug_id,d.drug_name,d.category,d.criticality
ORDER BY unfulfilled_qty DESC;

-- 3. Regional stockout hotspots.
SELECT
    l.location_name,
    l.region,
    SUM(s.demand_qty) AS total_demand,
    SUM(s.fulfilled_qty) AS total_fulfilled,
    SUM(s.demand_qty - s.fulfilled_qty) AS unfulfilled_qty,
    ROUND(100 * SUM(s.fulfilled_qty) / NULLIF(SUM(s.demand_qty),0),2) AS fill_rate_pct,
    SUM(s.stockout_flag) AS stockout_records,
    ROUND(100 * SUM(s.stockout_flag) / COUNT(*),2) AS stockout_rate_pct
FROM fact_sales s
JOIN dim_location l ON l.location_id = s.location_id
GROUP BY l.location_name,l.region
ORDER BY stockout_rate_pct DESC;

-- 4. Drug x location service matrix.
SELECT
    l.location_name,
    l.region,
    d.drug_id,
    d.drug_name,
    d.safety_stock,
    SUM(s.demand_qty) AS total_demand,
    SUM(s.fulfilled_qty) AS total_fulfilled,
    SUM(s.demand_qty - s.fulfilled_qty) AS unfulfilled_qty,
    ROUND(100 * SUM(s.fulfilled_qty) / NULLIF(SUM(s.demand_qty),0),2) AS fill_rate_pct,
    ROUND(100 * SUM(s.stockout_flag) / COUNT(*),2) AS stockout_rate_pct
FROM fact_sales s
JOIN dim_drug d ON d.drug_id=s.drug_id
JOIN dim_location l ON l.location_id=s.location_id
GROUP BY l.location_name,l.region,d.drug_id,d.drug_name,d.safety_stock
ORDER BY unfulfilled_qty DESC;
