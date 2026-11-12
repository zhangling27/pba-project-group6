# Olist Delivery Analysis Codebook

## Unit of Observation

Each row represents one delivered single-item order. Single-item orders are
used because a multi-item order may contain different sellers and different
`shipping_limit_date` values, which makes an order-level seller delay ambiguous.

## Sample Construction

1. Start with 99,441 rows in `olist_orders_dataset.csv`.
2. Keep 96,478 orders with `order_status == "delivered"`.
3. Keep orders appearing exactly once in `olist_order_items_dataset.csv`,
   producing 86,843 orders.
4. Remove orders missing any timestamp required for the delay measures,
   producing 86,834 orders.

## Variables

| Variable | Type | Definition |
|---|---|---|
| `order_id` | Character | Unique Olist order identifier. |
| `seller_delay_days` | Numeric | `order_delivered_carrier_date - shipping_limit_date`, measured in 24-hour days using the full timestamps. |
| `seller_late` | Logical | `TRUE` when `seller_delay_days > 0`. |
| `final_delay_days` | Integer | Calendar date of actual customer delivery minus calendar date of estimated delivery. |
| `final_late` | Logical | `TRUE` when `final_delay_days > 0`. An order delivered on the estimated calendar date is on time. |
| `seller_late_final_on_time` | Logical | `seller_late & !final_late`. This describes the observed outcome only and does not establish that downstream logistics actively recovered a delay. |

## Interpretation

The data are observational. Differences between seller-late and seller-on-time
orders are interpreted as associations, not causal effects.

The calendar-date definition of `final_late` is used because every estimated
delivery timestamp in the analytical sample is recorded at `00:00:00`, while
the source documentation describes an estimated delivery date and does not
establish midnight as a customer-facing cutoff.
