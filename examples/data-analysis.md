# Data Analysis Examples

This document shows how to use `claude-task-plan` for various data analysis tasks with proper data source specification.

## Example 1: User Behavior Analysis

```bash
claude-task-plan "Analyze user behavior data in /data/user_logs/ directory containing CSV files with columns: user_id, timestamp, action, page_url. Generate comprehensive insights report with retention analysis, conversion funnel, and user segmentation. Output as PDF with visualizations using Python pandas and matplotlib."
```

**Expected Flow:**
1. **Clarification**: Claude asks about specific analysis goals, time periods, user segments
2. **Requirements**: Defines success criteria (retention metrics, funnel conversion rates, etc.)
3. **Solution**: Selects agents (data-scientist, python-pro, data-engineer)
4. **Risk Assessment**: Identifies data quality issues, missing values handling
5. **Execution**: Loads data, performs analysis, creates visualizations
6. **Verification**: Validates statistical significance and business insights

## Example 2: Sales Dashboard Creation

```bash
claude-task-plan "Create interactive sales dashboard from /data/sales.json with schema {date, region, product, revenue, quantity}. Build real-time KPI monitoring with revenue trends, regional performance comparison, and product analytics. Use Python, Plotly, and Streamlit for web interface."
```

**Key Agents Used:**
- `data-scientist`: Performs statistical analysis and trend identification
- `python-pro`: Implements data processing and calculation logic
- `frontend-developer`: Creates interactive dashboard interface
- `data-engineer`: Sets up data pipeline and real-time updates

## Example 3: Financial Risk Analysis

```bash
claude-task-plan "Analyze financial portfolio data in /data/portfolio.xlsx sheets: stocks, bonds, options. Calculate Value at Risk (VaR), portfolio optimization, correlation analysis. Generate risk assessment report with Monte Carlo simulations using Python scipy and numpy."
```

**Complex Workflow:**
- Data validation and cleaning from Excel sheets
- Statistical modeling and risk calculations
- Portfolio optimization algorithms
- Monte Carlo simulation implementation
- Professional financial report generation

## Example 4: Machine Learning Model Development

```bash
claude-task-plan "Build predictive model using customer data /data/customers.csv with features: age, income, purchase_history, demographics. Predict customer churn probability. Include feature engineering, model selection, hyperparameter tuning, and performance evaluation. Output model artifacts and evaluation report."
```

**Process Highlights:**
- Exploratory data analysis and feature engineering
- Model selection and cross-validation
- Hyperparameter optimization
- Model interpretability and business insights

## Example 5: Time Series Forecasting

```bash
claude-task-plan "Forecast website traffic using historical data /data/traffic_logs.csv with columns: timestamp, page_views, unique_visitors, bounce_rate. Create 30-day forecast with confidence intervals. Use ARIMA, Prophet, or LSTM models. Generate forecast report with model comparison and recommendations."
```

## Data Analysis Best Practices

### 1. Always Specify Data Sources
- **File paths**: `/data/filename.csv`, `/path/to/database.db`
- **Database connections**: Include connection details or config files
- **API endpoints**: Specify data source APIs with authentication

### 2. Define Data Schema
- **Column names**: List important columns and their meanings
- **Data types**: Specify numeric, categorical, datetime fields
- **Data quality**: Mention known issues or missing values

### 3. Specify Analysis Goals
- **Metrics**: What specific KPIs or insights to generate
- **Output format**: PDF reports, interactive dashboards, CSV results
- **Visualization**: Type of charts and graphs needed

### 4. Technology Preferences
- **Tools**: Python/R, pandas/dplyr, matplotlib/ggplot
- **Infrastructure**: Local processing, cloud platforms, databases
- **Performance**: Memory requirements, processing time constraints

## Common Success Criteria

- ✅ Data quality validation and cleaning completed
- ✅ Statistical significance of findings verified
- ✅ Visualizations are clear and informative
- ✅ Business insights are actionable
- ✅ Reproducible analysis pipeline created
- ✅ Documentation and code comments provided

## Error Prevention Tips

❌ **Don't do**: `"Analyze sales data"`
✅ **Do**: `"Analyze sales data in /data/sales.csv with revenue forecasting"`

❌ **Don't do**: `"Create dashboard"`
✅ **Do**: `"Create dashboard from /data/metrics.json with real-time updates"`

❌ **Don't do**: `"Build ML model"`
✅ **Do**: `"Build churn prediction model using /data/customers.csv with accuracy >85%"`