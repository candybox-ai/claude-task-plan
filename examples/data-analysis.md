# Data Analysis Examples

This document shows realistic examples of using `claude-agent-dispatch` for data analysis tasks.

## Example 1: E-commerce User Behavior Analysis

### Task Description
```bash
claude-agent-dispatch "Analyze user behavior data from /data/ecommerce_logs.csv containing columns: user_id, session_id, timestamp, page_url, action_type, product_id, duration_seconds. Generate insights on user journey patterns, conversion funnel analysis, and session abandonment points. Create visualizations and export findings as PDF report with actionable recommendations."
```

### What Claude Might Ask (Clarification Phase)
- "What time period does this data cover?"
- "Are you looking for any specific user segments (new vs returning users)?"
- "What constitutes a 'conversion' in your funnel analysis?"
- "Do you need real-time dashboard or static report?"
- "What's your preferred visualization tool - Python matplotlib, Plotly, or R ggplot?"

### Expected Success Criteria
- ✅ User journey map showing common paths from landing to purchase
- ✅ Conversion funnel with drop-off rates at each stage
- ✅ Session abandonment analysis with timing insights
- ✅ Top performing and underperforming pages identified
- ✅ 3-5 actionable recommendations for UX improvements
- ✅ Professional PDF report with clear visualizations

### Likely Agents Used
- `data-scientist`: Statistical analysis and pattern recognition
- `python-pro`: Data processing with pandas and numpy
- `data-engineer`: Data cleaning and validation
- `business-analyst`: Business insights and recommendations

## Example 2: Sales Performance Dashboard

### Task Description
```bash
claude-agent-dispatch "Create interactive sales dashboard using /data/sales_2024.json with fields: {date, region, salesperson, product_category, revenue, units_sold, customer_segment}. Build real-time metrics showing YTD performance, regional comparisons, top performers, and trending analysis. Deploy as web dashboard accessible to sales team with filters and drill-down capabilities."
```

### What You'll Get
**Phase 1: Data Exploration**
- Data quality assessment
- Missing value analysis
- Outlier detection and handling

**Phase 2: Dashboard Development**
- Interactive Plotly/Dash or Streamlit dashboard
- Key metrics: YTD revenue, growth rates, regional performance
- Filtering by date range, region, product category
- Drill-down from regional to individual salesperson level

**Phase 3: Deployment**
- Web-accessible dashboard with authentication
- Mobile-responsive design
- Automated data refresh capabilities

### Business Value
- Real-time visibility into sales performance
- Faster identification of trends and opportunities
- Data-driven sales territory and strategy decisions

## Example 3: Customer Churn Prediction

### Task Description
```bash
claude-agent-dispatch "Build machine learning model to predict customer churn using /data/customer_data.csv with features: subscription_date, last_login, feature_usage_counts, support_tickets, payment_history, demographics. Achieve >85% accuracy with model interpretability. Include feature importance analysis, risk scoring system, and recommendations for retention strategies."
```

### Detailed Workflow
**1. Requirements Clarification**
- Define churn (30 days inactive? subscription cancellation?)
- Training data time period and prediction horizon
- Model performance requirements and constraints

**2. Data Science Process**
- Exploratory data analysis with correlation matrix
- Feature engineering (recency, frequency, monetary analysis)
- Train/validation/test split with temporal considerations
- Model selection: Logistic Regression, Random Forest, XGBoost comparison

**3. Model Development**
- Hyperparameter tuning with cross-validation
- Feature importance analysis and selection
- Model interpretability with SHAP values
- Threshold optimization for business metrics

**4. Deployment Strategy**
- Batch scoring system for monthly risk assessment
- API endpoint for real-time churn probability
- Integration with CRM for proactive retention campaigns

## Best Practices for Data Analysis Tasks

### 📊 Task Description Guidelines

**❌ Too Vague:**
```bash
claude-agent-dispatch "Analyze my sales data"
```

**✅ Specific and Actionable:**
```bash
claude-agent-dispatch "Analyze Q4 2024 sales data in /data/sales_q4.xlsx to identify top-performing product categories by region, calculate month-over-month growth rates, and predict Q1 2025 revenue using time series forecasting. Output Excel dashboard with pivot tables and Python script for monthly updates."
```

### 🎯 Include These Details

1. **Data Location**: Exact file paths, database connections, or API endpoints
2. **Data Schema**: Key columns and their meanings
3. **Analysis Goals**: Specific questions to answer or insights to find
4. **Output Format**: Reports, dashboards, models, or code deliverables
5. **Technical Preferences**: Python/R, specific libraries, visualization tools
6. **Business Context**: How results will be used, who the audience is

### 🚀 Success Indicators

- Data quality issues identified and resolved
- Statistical significance of findings verified
- Visualizations are publication-ready
- Code is documented and reproducible
- Business recommendations are actionable
- Results validated against known benchmarks

## Common Pitfalls to Avoid

❌ **Not specifying data location**: "Analyze user data"
✅ **Specific path**: "Analyze /data/users.csv"

❌ **Unclear success metrics**: "Make it accurate"
✅ **Measurable goals**: "Achieve >90% precision and >85% recall"

❌ **Missing business context**: "Find patterns"
✅ **Clear purpose**: "Identify churn risk factors to reduce customer loss by 15%"