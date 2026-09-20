# Pharma Supply Chain Control Tower

**SQL | Inventory Analytics | Supply Chain Analytics | Root-Cause Analysis | Decision Support**

## Business problem

Which medicines are at risk of stockout, where are service gaps concentrated, and what replenishment or inventory actions can improve availability without creating unnecessary excess stock?

## What I investigated

This project uses a 365-day synthetic pharma distribution dataset to diagnose service and inventory issues across **25 drugs, 5 distribution centers, and 1,200 purchase orders**.

The analysis moves from KPI diagnosis to root-cause analysis and planning scenarios:

1. Service-level and stockout analysis
2. Regional hotspot identification
3. Drug × location root-cause analysis
4. Supplier fill-rate and delivery-timeliness analysis
5. Inventory vs safety-stock analysis
6. Replenishment execution analysis
7. Expiry exposure analysis
8. Inventory imbalance / redistribution opportunities
9. ABC-XYZ segmentation
10. Reorder-point scenario analysis using demand and lead-time variability

## Key findings

- **93.84% fill rate** across **5.19M demand units**, leaving **319,395 units unfulfilled**.
- **7.70% stockout rate**, with **3,511 stockout records**.
- **Central DC** is the main service hotspot at **91.75% fill rate** and **10.60% stockout rate**, representing **104,875 unfulfilled units**.
- Supplier quantity fulfillment remains high at **99.48%**, while **42.00% of purchase orders were late**. This separates delivery-timing risk from supplier quantity shortfall.
- Total recorded expiry exposure is **432,799 units worth ₹7.63 Cr** in the supplied expiry dataset.
- Several drug-location combinations remain below safety stock for a large share of the analysis period, while a small number show above-safety inventory in one DC and below-safety inventory in another.
- All 25 drugs fall into the **X demand-variability class** under the project's ABC-XYZ thresholds, indicating relatively stable demand in this dataset.
- The 95% reorder-point scenario incorporates both demand variability and lead-time variability and is intended as a **planning scenario**, not a claim of statistically optimal inventory policy.

## Business impact

The analysis converts raw transaction, inventory, purchasing and expiry data into an actionable control-tower view. It helps an operations team prioritize **where service is breaking down, which drug-location pairs need attention, whether the issue is inventory positioning or replenishment execution, and where expiry exposure should constrain additional inventory**.

The project deliberately does **not** claim that stockouts were reduced because the recommendations were not implemented. The measurable impact is the identification and prioritization of intervention opportunities.

## Project structure

```text
Pharma_Supply_Chain_Control_Tower/
├── data/
│   ├── dim_drug.csv
│   ├── dim_location.csv
│   ├── dim_supplier.csv
│   ├── fact_sales.csv
│   ├── fact_inventory.csv
│   ├── fact_purchase_orders.csv
│   └── fact_expiry.csv
├── sql/
│   ├── 00_schema.sql
│   ├── 01_core_analysis.sql
│   ├── 02_root_cause_analysis.sql
│   └── 03_segmentation_and_rop.sql
├── results/
│   ├── executive_kpis.csv
│   ├── drug_stockout_analysis.csv
│   ├── regional_stockout_analysis.csv
│   ├── drug_location_analysis.csv
│   ├── supplier_performance.csv
│   ├── inventory_vs_safety_stock.csv
│   ├── replenishment_by_drug_location.csv
│   ├── expiry_exposure.csv
│   ├── drug_abc_xyz.csv
│   └── reorder_point_scenario.csv
├── powerbi/
│   └── dashboard_build_spec.md
├── docs/
│   ├── analytical_methodology.md
│   └── project_story.md
├── .gitignore
└── README.md
```

## Tools

- MySQL Workbench 8.0
- SQL
- Power BI (dashboard layer planned from the completed analysis)
- Excel/CSV for source data preparation

## Dashboard plan

The Power BI control tower is designed around four pages:

1. **Executive Control Tower** — service, stockout, inventory, expiry and supplier KPIs
2. **Stockout Root Cause** — drug, region and drug-location hotspots
3. **Inventory & Expiry** — safety-stock gaps, inventory value, expiry exposure and imbalance
4. **Action Center** — prioritized replenishment, timing and inventory actions

The `.pbix` file is intentionally excluded until the dashboard build is completed; the SQL and result layer are already reproducible from the supplied data.

## Data note

The dataset is used for portfolio/learning purposes. It is not a representation of any real pharmaceutical company's operations. The analysis should be interpreted as a decision-analytics case rather than a production inventory policy.
