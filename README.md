# PBA Final Project - Group 6

## Seller Fulfillment Delays and Final Delivery Performance in E-Commerce

This project examines how seller handoff delays are associated with final
delivery performance among delivered single-item orders in the Olist Brazilian
E-Commerce Public Dataset. The analysis is descriptive and associational, not
causal.

## Team Members

- Zhang Jia Ling
- Tneoh Song Xian
- Wu Yi Cing

## Data

Download the nine CSV files from the
[Olist Brazilian E-Commerce Public Dataset](https://www.kaggle.com/datasets/olistbr/brazilian-ecommerce)
and place them in `data/raw/`. Raw CSV files are intentionally excluded from
Git. See `data/raw/README.md` for the required file names.

The Milestone 3 analysis uses:

- `olist_orders_dataset.csv`
- `olist_order_items_dataset.csv`

## Reproduce Milestone 3

Run these commands from the repository root:

```bash
Rscript scripts/01_prepare_data.R
Rscript scripts/02_milestone3_eda.R
quarto render milestone3.qmd --output-dir output/pdf
```

The first script creates the one-row-per-order processed dataset. The second
script creates the descriptive summaries and figures. The Quarto file produces
the submission PDF.

## Project Structure

```text
data/raw/                 Local source CSV files (ignored by Git)
data/processed/           Reproducible analysis data and codebook
scripts/01_prepare_data.R Sample construction and variable definitions
scripts/02_milestone3_eda.R Descriptive summaries and figures
figures/                  Milestone 3 figures
output/pdf/               Rendered submission PDF
milestone3.qmd            Milestone 3 report source
```
