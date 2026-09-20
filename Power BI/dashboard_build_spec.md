# Power BI Dashboard Build Specification

## Page 1 — Executive Control Tower

### KPI cards
- Fill Rate %
- Stockout Rate %
- Unfulfilled Units
- Closing Inventory Value
- Expiry Value

### Visuals
- Fill Rate by Region
- Stockout Rate by Region
- Top 10 Drugs by Unfulfilled Units
- Supplier Late Rate vs PO Fill Rate

## Page 2 — Stockout Root Cause

- Drug-location heatmap: stockout rate
- Top drug-location pairs by unfulfilled units
- Average closing stock vs safety stock
- Late-rate drilldown by drug/location

## Page 3 — Inventory & Expiry

- Inventory vs safety stock
- Expiry value by drug/location
- Earliest expiry date
- Inventory imbalance opportunities
- ABC-XYZ matrix

## Page 4 — Action Center

Prioritize drug-location combinations using:

- stockout rate
- unfulfilled units
- safety-stock gap
- days below safety stock
- PO late rate
- lead-time variance
- expiry exposure

### Design principle
The dashboard should answer: **Where is the problem? Why is it happening? What should operations investigate next?**
