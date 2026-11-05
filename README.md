# Pizza Sales Analytics — SQL & Excel

Analysis of one year of orders from a pizza restaurant (2015): **$817.9K in revenue from 21,350 orders**. The project answers three questions a store owner would ask — *how is the business performing, when do customers order, and what sells* — and adds a **basket analysis** to find which pizzas are bought together and which combos are worth promoting.

**Tools:** MySQL 8.0 · Excel (Power Query, Power Pivot / Data Model, DAX measures, PivotCharts, slicers, timeline)

General Dashboard: 
![General analysis dashboard](Dashboard%20Analysis/Scrrenshots/General%20Analysis%20Dashboard.png)
![Basket analysis dashboard](Dashboard%20Analysis/Scrrenshots/Basket%20Analysis%20Dashboard.png)
---

## Key findings

| Area | Finding |
|---|---|
| **Order value** | Average order value is **$38.31**, with **2.32 pizzas** per order. |
| **Peak hours** | Orders peak at **12–2 pm** and **5–7 pm**; these four hours take **45%** of all orders. |
| **Busiest day** | **Friday** is the busiest day (3,538 orders) and **Sunday** the quietest (2,624). |
| **Revenue by size** | **Large** pizzas bring in **45.9%** of revenue; Large and Medium together **76.4%**. |
| **Revenue by category** | Revenue is evenly spread: Classic 26.9%, Supreme 25.5%, Chicken 24.0%, Veggie 23.7%. |
| **Best sellers** | The Classic Deluxe (2,453 sold), Barbecue Chicken (2,432) and Hawaiian (2,422) lead. |
| **Weakest seller** | The Brie Carre (490 sold) — but it is only offered in Small, so availability limits it as much as demand. |
| **Multi-item orders** | **61.6%** of orders contain 2 or more items (61.0% contain 2 or more *different* pizzas). |

### Basket analysis
- Of the **452 pizza pairs** ordered together at least 50 times, lift ranges from **0.83 to 1.50**, and about half fall between 0.9 and 1.1 — customers' pairing habits are mostly weak.
- **Italian Vegetables + Pepperoni, Mushroom, and Peppers** have the highest lift (**1.50**): they are bought together 50% more often than chance would predict.
- **Hawaiian + Thai Chicken** is the most frequent pair (**270 orders**), but its lift is only 1.14 — it is common mainly because both pizzas are popular.
- **Italian Vegetables** appears in 3 of the 5 highest-lift pairs, yet is in only 952 of 21,350 orders (4.5%). It works better as an **add-on or upsell** than as a pizza to promote on its own.

### Recommendations
1. **Trial a Four Cheese + Italian Vegetables combo.** The pair was ordered together 111 times with a lift of 1.38 — a balance of volume and genuine affinity.
2. **Staff up for 12–2 pm and 5–7 pm, especially on Fridays.**
3. **Review the Brie Carre** (lowest seller, Small only): offer more sizes or consider replacing it.

---

## Repository structure

```
├── sql/
│   ├── 01_create_table.sql      # database and table definition
│   ├── 02_load_data.sql         # CSV import with date conversion
│   └── 03_Data_analytics.sql    # KPIs, breakdowns and basket analysis
├── excel/
│   └── Data_analytics_and_dashboard_version_1.xlsx
├── images/                      # dashboard screenshots
└── README.md
```

## Dataset

- **48,620 rows**, one per pizza line in an order (an order with three different pizzas has three rows)
- **21,350 orders**, 32 pizzas, 4 categories, 5 sizes, 1 January – 31 December 2015 (358 trading days)
- Columns: `pizza_id`, `order_id`, `pizza_name_id`, `quantity`, `order_date`, `order_time`, `unit_price`, `total_price`, `pizza_size`, `pizza_category`, `pizza_ingredients`, `pizza_name`
- Source: https://www.kaggle.com/datasets/nextmillionaire/pizza-sales-dataset

---

## Approach

### 1. Loading the data (MySQL)
Two problems surfaced while loading the CSV and were fixed in `02_load_data.sql`:

- **Rows silently merging.** The file uses Windows (CRLF) line endings. With the default `\n` terminator, the 1,342 rows for *The Pepperoni, Mushroom, and Peppers Pizza* — whose quoted name contains commas — each swallowed the next line, so **1,307 order lines went missing** without any rows being reported as skipped. Setting `LINES TERMINATED BY '\r\n'` fixed it.
- **Date format.** Dates are stored as `DD-MM-YYYY`; they are converted on load with `STR_TO_DATE`.

The load was validated against the source file:

| Check | Expected | Loaded |
|---|---|---|
| Rows | 48,620 | ✅ |
| Distinct orders | 21,350 | ✅ |
| Distinct pizzas | 32 | ✅ |
| Total revenue | 817,860.05 | ✅ |

### 2. Analysis (SQL)
Because each row is a pizza line rather than an order:
- **Orders** are counted with `COUNT(DISTINCT order_id)` — a plain `COUNT(*)` would count lines.
- **Pizzas sold** use `SUM(quantity)`, since one line can hold several of the same pizza.
- **Average order value** is total revenue ÷ total orders, not `AVG(total_price)`, which would average lines ($16.82).
- **Revenue shares** divide each group's revenue by the overall total, so shares add up to 100%.

### 3. Basket analysis (SQL)
Built in `03_Data_analytics.sql` as a chain of CTEs and saved as the table `pizza_combinations`:

1. **One row per pizza per order** (`DISTINCT order_id, pizza_name`), so an order with the same pizza in two sizes counts it once.
2. **Self-join on `order_id`** with `p1.pizza_name < p2.pizza_name`, which keeps each pair once and excludes a pizza paired with itself.
3. **Support** = orders containing the pair ÷ total orders.
4. **Lift** = support of the pair ÷ (support of pizza A × support of pizza B). Lift above 1 means the pizzas are bought together more often than chance; around 1 means no real link.
5. Only pairs ordered together **at least 50 times** are kept, so rare pairs can't produce misleadingly high lift.

Raw pair counts mostly reflect how popular each pizza is; lift corrects for that, which is why both are shown.

### 4. Dashboards (Excel)
- **Data Model + DAX measures** for the KPIs (Total Revenue, Total Orders, Average Order Value, Total Pizzas, Average Pizzas per Order, Multi-Pizza Order %), so every card responds to the filters.
- **Slicers** for pizza category and size, and a **timeline** for order date, connected to all PivotTables.
- KPI cards are linked to the pivot through `GETPIVOTDATA`.
- **General Analysis** — KPIs, monthly and hourly trends, category and size mix, top and bottom 5 pizzas.
- **Basket Analysis** — multi-item order share, top pairs by order count and by lift, and a support-vs-lift scatter of all 452 pairs.

---

## Limitations
- **One year of data (2015)** — seasonality can't be confirmed across years.
- **No cost data**, so profitability can't be measured; revenue is used instead.
- **Pairs only** — the basket analysis doesn't look at combinations of three or more pizzas.
- **358 of 365 days** have orders; the 7 missing days (likely closures) are not filled in.

## Future scope

### Staff requirement analysis
- Build a **day-of-week × hour heatmap** of orders and pizzas to pinpoint the busiest windows (for example, Friday 12–2 pm and 5–7 pm).
- Convert demand into **staff needed per shift**, using an assumed kitchen capacity (pizzas per staff member per hour), and propose a weekly rota.
- Compare quiet periods (Sunday, before 11 am and after 10 pm) to find hours where staffing could be reduced.

### Inventory management
- Split `pizza_ingredients` into **one row per ingredient** and weight it by quantity sold, to measure demand for each ingredient by month, weekday and hour.
- **Forecast weekly ingredient needs** from the daily sales pattern to reduce waste and stock-outs.
- Flag ingredients used only by low-selling pizzas (for example, those in The Brie Carre) as candidates for **menu simplification**.
- *Needs:* recipe quantities (grams per pizza and size) and supplier lead times, which are not in this dataset; without them, demand can be measured in pizza counts only.

## How to reproduce
1. Install **MySQL 8.0** and enable `local_infile` on the server and in your client connection.
2. In `02_load_data.sql`, update the CSV path to where you saved the dataset.
3. Run the scripts in order: `01_create_table.sql` → `02_load_data.sql` → `03_Data_analytics.sql`.
4. Open the Excel workbook to explore the dashboards.

---
