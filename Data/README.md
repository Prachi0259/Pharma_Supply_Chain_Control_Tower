# Data

The dataset is a synthetic portfolio dataset representing a pharmaceutical distribution network.

| Table | Rows | Purpose |
|---|---:|---|
| `dim_drug.csv` | 25 | Drug master data, unit cost, criticality and safety stock |
| `dim_location.csv` | 5 | Distribution centers and regions |
| `dim_supplier.csv` | 4 | Supplier lead-time and reliability attributes |
| `fact_sales.csv` | 45,625 | Daily demand, fulfillment and stockout flags |
| `fact_inventory.csv` | 45,625 | Daily opening, receipts, dispensing and closing stock |
| `fact_purchase_orders.csv` | 1,200 | Purchase orders, quantities and lead-time performance |
| `fact_expiry.csv` | 899 | Batch-level expiry quantity and inventory value |

The sales and inventory facts cover 365 days across 25 drugs and 5 locations.
