library(tidyverse)

processed_path <- "data/processed/olist_delivery_analysis.csv"

if (!file.exists(processed_path)) {
  stop("Run scripts/01_prepare_data.R before running this script.")
}

analysis_data <- read_csv(processed_path, show_col_types = FALSE)

if (nrow(analysis_data) != 86834 ||
    n_distinct(analysis_data$order_id) != nrow(analysis_data)) {
  stop("Processed data must contain 86,834 unique orders.")
}

overall_summary <- analysis_data |>
  summarize(
    n_orders = n(),
    median_seller_delay_days = median(seller_delay_days),
    seller_late_n = sum(seller_late),
    seller_late_rate = mean(seller_late),
    final_late_n = sum(final_late),
    final_late_rate = mean(final_late),
    seller_late_final_on_time_n = sum(seller_late_final_on_time)
  )

summary_by_seller <- analysis_data |>
  mutate(
    seller_status = if_else(seller_late, "Seller late", "Seller on time")
  ) |>
  group_by(seller_status) |>
  summarize(
    n_orders = n(),
    final_late_n = sum(final_late),
    final_late_rate = mean(final_late),
    .groups = "drop"
  ) |>
  mutate(
    seller_status = factor(
      seller_status,
      levels = c("Seller on time", "Seller late")
    ),
    rate_label = paste0(sprintf("%.1f", 100 * final_late_rate), "%"),
    n_label = paste0("n = ", format(n_orders, big.mark = ",", trim = TRUE)),
    bar_label = paste0(rate_label, "\n(", n_label, ")")
  ) |>
  arrange(seller_status)

display_lower <- -15
display_upper <- 15
display_share <- mean(
  analysis_data$seller_delay_days >= display_lower &
    analysis_data$seller_delay_days <= display_upper
)

figure_1 <- ggplot(
  analysis_data,
  aes(x = seller_delay_days)
) +
  geom_histogram(
    binwidth = 1,
    boundary = 0,
    fill = "#2C7FB8",
    color = "white",
    linewidth = 0.25
  ) +
  geom_vline(
    xintercept = 0,
    color = "#D95F0E",
    linewidth = 0.9,
    linetype = "dashed"
  ) +
  coord_cartesian(xlim = c(display_lower, display_upper)) +
  labs(
    title = "Most sellers hand orders to carriers before the deadline",
    subtitle = "Negative values indicate early handoff; positive values indicate seller delay",
    x = "Seller handoff timing relative to shipping deadline (days)",
    y = "Number of orders",
    caption = paste0(
      "Dashed line marks the shipping deadline. Displayed range contains ",
      sprintf("%.1f", 100 * display_share),
      "% of orders; all observations remain in the analysis."
    )
  ) +
  theme_minimal(base_size = 11) +
  theme(
    plot.title.position = "plot",
    panel.grid.minor = element_blank()
  )

figure_2 <- ggplot(
  summary_by_seller,
  aes(x = seller_status, y = final_late_rate, fill = seller_status)
) +
  geom_col(width = 0.62, show.legend = FALSE) +
  geom_text(
    aes(label = bar_label),
    vjust = -0.45,
    fontface = "bold",
    lineheight = 1.1,
    size = 3.8
  ) +
  scale_fill_manual(values = c("#2C7FB8", "#D95F0E")) +
  scale_y_continuous(
    limits = c(0, 0.26),
    breaks = seq(0, 0.25, by = 0.05),
    labels = function(x) paste0(round(100 * x), "%"),
    expand = expansion(mult = c(0, 0))
  ) +
  labs(
    title = "Final late delivery is more common among seller-late orders",
    subtitle = "Late means delivery after the estimated calendar date",
    x = NULL,
    y = "Final late-delivery rate",
    caption = "Descriptive comparison; the difference should not be interpreted as a causal effect."
  ) +
  theme_minimal(base_size = 11) +
  theme(
    plot.title.position = "plot",
    panel.grid.major.x = element_blank(),
    panel.grid.minor = element_blank()
  )

dir.create("figures", recursive = TRUE, showWarnings = FALSE)

ggsave(
  "figures/figure1_seller_delay_distribution.png",
  figure_1,
  width = 8,
  height = 4.8,
  dpi = 300
)

ggsave(
  "figures/figure2_final_late_by_seller_status.png",
  figure_2,
  width = 8,
  height = 4.8,
  dpi = 300
)

write_csv(overall_summary, "data/processed/milestone3_overall_summary.csv")
write_csv(summary_by_seller, "data/processed/milestone3_by_seller_status.csv")

print(overall_summary)
print(summary_by_seller)
cat("\nMilestone 3 figures written to figures/.\n")
