# Raw Olist Data

Download Version 2 of the
[Olist Brazilian E-Commerce Public Dataset](https://www.kaggle.com/datasets/olistbr/brazilian-ecommerce)
and place the CSV files in this directory.

Required for the current analysis:

- `olist_orders_dataset.csv`
- `olist_order_items_dataset.csv`

The complete download also contains:

- `olist_customers_dataset.csv`
- `olist_geolocation_dataset.csv`
- `olist_order_payments_dataset.csv`
- `olist_order_reviews_dataset.csv`
- `olist_products_dataset.csv`
- `olist_sellers_dataset.csv`
- `product_category_name_translation.csv`

Do not modify or commit the raw CSV files. Run `scripts/01_prepare_data.R` from
the repository root to create the processed analysis file.
