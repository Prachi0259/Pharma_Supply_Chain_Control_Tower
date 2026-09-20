# Analytical Methodology

## 1. Service level

Fill rate is calculated as:

`Fulfilled units / Demand units`

Stockout rate is calculated from the stockout flag at the daily drug-location record level.

## 2. Root-cause dimensions

Stockout patterns are investigated across:

- drug
- distribution center / region
- average inventory vs safety stock
- supplier PO fill rate
- PO late rate
- actual vs planned lead time
- expiry exposure

This prevents a low fill rate from being attributed to suppliers without checking inventory positioning and delivery timing first.

## 3. ABC-XYZ

ABC uses annual demand value (`annual demand × unit cost`). XYZ uses the coefficient of variation of aggregated daily drug demand. The supplied dataset produces X-class demand for all 25 drugs under the project thresholds.

## 4. Reorder-point scenario

Baseline ROP:

`Average daily demand × Average actual lead time + Safety stock`

Scenario ROP:

`Average daily demand × Average actual lead time + 1.65 × Combined demand/lead-time variability`

The combined variability term is:

`SQRT(L × σd² + d² × σL²)`

where `d` is average daily demand, `σd` is demand standard deviation, `L` is average lead time, and `σL` is lead-time standard deviation.

The 1.65 factor is used as a 95% planning-service scenario. It is not presented as a statistically validated optimal policy.

## 5. Interpretation rule

Recommendations are framed as decision-support opportunities. They are not treated as confirmed operational fixes unless implementation data demonstrates an outcome.
