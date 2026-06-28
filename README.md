📊 B2B-Sales-Pipeline-Analytics-Revenue-Optimization

Author:Rishabh Tamta  
Database Dialect: MySQL  
Project Context: B2B CRM Sales Pipeline Infrastructure  

---

 🎯 1. Project Overview & Problem Statement
In a competitive B2B landscape, sales tracking fragmentation can hide significant structural issues. The primary objective of this project is to parse raw CRM pipeline records, lookup product structures, analyze regional sales performance matrices, and trace client corporate hierarchies. 
This repository systematically walks through data verification benchmarks to optimize sales funnel efficiency, validate pricing execution, discover agent-level discounting behaviors, and compile consolidated parent-subsidiary enterprise values.

---

--- Data Source & Reference Link
The dataset utilized in this analysis is sourced directly from the official --Maven Analytics--- platform. You can access the project details, data dictionary parameters, and download files here:

 --[Official Maven Analytics Dataset & Project Brief](https://app.mavenanalytics.io/guided-projects/3a35f0ec-fc19-4e69-8377-b08534925844#dataset)

---

 📁 2. Dataset & Database Schema
The analysis integrates data from a standard enterprise CRM system consisting of the following relation objects:
1. sales_pipeline: Contains transaction lifespans, unique opportunity keys, assignees, products, deal conversion status, and absolute financial close values.
2. products: Baseline lookup array defining standard retail prices (MSRP) and product category series.
3. sales_teams: Roster records mapping every sales agent to their direct supervisor and primary geographic division.
4. accounts: Enterprise demographic attributes listing establishing years, headquarter jurisdictions, and child-to-parent corporate mappings.

---

🛠️ 3. Advanced SQL Techniques Showcased
To mirror real-world industry applications, this analysis avoids basic logic and relies heavily on enterprise-level SQL design patterns:
1.Window Functions (`LAG()`): Leveraged to compute historical period-over-period chronological revenue velocity.
2.Common Table Expressions (CTEs): Utilized to modularize multi-tier data queries for clean pipeline architecture.
3.Conditional Segmenting (`CASE WHEN`): Used to mathematically tier and bucket agent performance groups dynamically.
4.String Sanitization (`REPLACE()` / `LIKE`)**: Implemented to dynamically clean CRM nomenclature mismatches (e.g., resolving `GTXPro` to `GTX Pro` and aggregating variations of corporate entities).
5.Data Cleansing & Handling Nulls (`COALESCE()`): Applied across revenue arrays to prevent aggregation skewing from open, un-finalized leads.

---

 4. Step-by-Step Project Milestones & Core Insights

📊 Milestone 1: Pipeline Funnel Metrics
1.Monthly Activity Cycles:*Pinpointed peak historical lead onboarding spikes by isolating transactional initiation timestamps.
2.Deal Lifespan Velocity: Evaluated standard business sales cycles by calculating processing durations (`DATEDIFF`) between entry dates and ultimate resolutions, discovering that successful deal conversions consistently maintain a significantly faster conversion rate compared to stagnant, ultimately lost prospects.
3.Conversion Funnel Share: Quantified structural attrition ratios by calculating the percentage share of each pipeline stage to establish definitive attrition metrics.
4.Product Win Rate Benchmarks: Discovered core organic market preferences by calculating product-specific closing ratios.

 👥 Milestone 2: Sales Agent & Team Performance
1.The Volume vs. Revenue Paradox: Exposed distinct operational styles by mapping conversion rates directly alongside absolute revenue contributions. *(Insight: High win-rate agents often process high-volume, lower-tier items, while some lower win-rate agents yield higher value via whale enterprise deals).*
2.anagement Matrix Evaluation: Evaluated localized branch leadership impact by aggregating total converting success ratios sorted exclusively by direct Sales Managers.
3.Premium Spatial Density: Isolated regional office dominance for premium assets (specifically `GTX Plus Pro`) to identify geographical sweet spots for targeted marketing spend.

 📦 Milestone 3: Product Portfolio & Data Integrity
1.March Revenue Velocity: Evaluated standard monthly margins by isolating and highlighting discrepancies where maximum transaction counts did not scale linearly with absolute financial outputs.
2.The CRM Pricing Discrepancy (Crucial Finding):** Uncovered a structural tracking vulnerability or unauthorized discounting pattern by joining pipelines back to baseline retail lookups and computing the financial markdown gap.
3.Core Product Series Share:** Established macro contribution distributions across fundamental product family lines (GTX, MG, GTK).

  🏢 Milestone 4: Corporate Account Architecture
1.Underperforming Branches: Highlighted geographical market weaknesses by grouping realized contract revenue entirely by localized client headquarters.
2.Enterprise Demographic Span: Determined customer base longevity and market evolution dynamics by executing multi-decade span comparisons.
3.Subsidiary Failure Tracing: Isolated friction points by listing corporate parent clusters whose child entities continuously result in abandoned transactions.
4.Parent-Subsidiary Financial Consolidation:** Constructed complete parent-subsidiary rollup entities (such as aggregating all underlying revenue streams belonging to Acme Corporation and its associated sub-networks) using structural `COALESCE` matching to provide management with clean, complete client-group evaluations.

--

📊 Milestone 1: Pipeline Funnel Metrics
Key Finding: Won deals closed significantly faster (Average: 32 days) than Lost deals (Average: 68 days), highlighting a clear bottleneck threshold for stale leads.
Funnel Conversion: The data shows a 14.2% drop-off rate from the 'Prospecting' phase to the 'Engaging' phase.

📦 Milestone 3: Product Portfolio & Data Integrity
Pricing Leakage:Discovered a massive anomaly where the actual `close_value` for specific product variants was running up to 18% below the official company catalog price listing, pointing to aggressive rogue discounting.

----

 💻 5. How to Run the Script
1. Clone this repository to your local system or server.
2. Ensure your local relational system (MySQL Server Workbench or terminal instance) contains the imported target data sheets.
3. Execute the single, comprehensive script file containing all structured milestones:
   ```bash
   mysql -u your_username -p your_database_name < queries/sales_pipeline_analysis.sql
