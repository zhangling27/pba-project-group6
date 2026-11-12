library(tidyverse)

orders_path <- "data/raw/olist_orders_dataset.csv"
items_path <- "data/raw/olist_order_items_dataset.csv"

if (!file.exists(orders_path) || !file.exists(items_path)) {
  stop(
    "Required raw files are missing. See data/raw/README.md for setup instructions."
  )
}

orders <- read_csv(orders_path, show_col_types = FALSE)
order_items <- read_csv(items_path, show_col_types = FALSE)

if (n_distinct(orders$order_id) != nrow(orders)) {
  stop("olist_orders_dataset.csv must contain one row per order_id.")
}

single_item_orders <- order_items |>
  add_count(order_id, name = "item_count") |>
  filter(item_count == 1) |>
  select(order_id, shipping_limit_date)

if (n_distinct(single_item_orders$order_id) != nrow(single_item_orders)) {
  stop("The single-item table must contain one row per order_id.")
}

delivered_orders <- orders |>
  filter(order_status == "delivered")

single_item_delivered <- delivered_orders |>
  inner_join(single_item_orders, by = "order_id")

analysis_data <- single_item_delivered |>
  filter(
    !is.na(shipping_limit_date),
    !is.na(order_delivered_carrier_date),
    !is.na(order_delivered_customer_date),
    !is.na(order_estimated_delivery_date)
  ) |>
  transmute(
    order_id,
    seller_delay_days = as.numeric(
      difftime(
        order_delivered_carrier_date,
        shipping_limit_date,
        units = "days"
      )
    ),
    seller_late = seller_delay_days > 0,
    final_delay_days = as.integer(
      as.Date(order_delivered_customer_date) -
        as.Date(order_estimated_delivery_date)
    ),
    final_late = final_delay_days > 0,
    seller_late_final_on_time = seller_late & !final_late
  )

sample_flow <- tibble(
  step = c(
    "Raw orders",
    "Delivered orders",
    "Delivered single-item orders",
    "Complete analytical sample"
  ),
  n_orders = c(
    nrow(orders),
    nrow(delivered_orders),
    nrow(single_item_delivered),
    nrow(analysis_data)
  )
)

expected_counts <- c(99441, 96478, 86843, 86834)

if (!all(sample_flow$n_orders == expected_counts)) {
  stop(
    "Sample counts differ from the validated counts. Review the raw data version and filters."
  )
}

if (n_distinct(analysis_data$order_id) != nrow(analysis_data)) {
  stop("The processed dataset must contain one row per order_id.")
}

if (!all(
  format(single_item_delivered$order_estimated_delivery_date, "%H:%M:%S") ==
    "00:00:00"
)) {
  stop("Not all estimated delivery timestamps are at midnight; review final_late.")
}

dir.create("data/processed", recursive = TRUE, showWarnings = FALSE)
write_csv(analysis_data, "data/processed/olist_delivery_analysis.csv")
write_csv(sample_flow, "data/processed/sample_flow.csv")

print(sample_flow)
cat("\nProcessed data written to data/processed/olist_delivery_analysis.csv\n")
