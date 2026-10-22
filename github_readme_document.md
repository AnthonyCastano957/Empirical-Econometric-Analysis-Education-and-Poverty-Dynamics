# Empirical Analysis of District-Level Child Poverty and Educational Outcomes

[![Stata](https://img.shields.io/badge/Stata-SE%20%2F%20MP%2018%2B-blue.svg)](https://www.stata.com/)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](LICENSE)
[![Data: SEDA & SAIPE](https://img.shields.io/badge/Data-SEDA%20%7C%20SAIPE-green.svg)](#data-sources)

---

## 📌 Project Overview

This repository contains the data cleaning, data integration, and econometric modeling code for **Project 3: "Cinco de Children" Empirical Analysis**. 

Using national school district-level data from 2024, this project investigates the non-linear relationship between child poverty (ages 5–17) and academic achievement across U.S. school districts. By merging Stanford Education Data Archive (SEDA 4.1) test score estimates with Census Small Area Income and Poverty Estimates (SAIPE) and district demographic covariates, we analyze how economic scarcity impacts mean student test scores within states.

### Authors & Contributors (Team 5)
* Abi Mangual
* William Schriever
* Anthony Castano
* Michael Carter

---

## 🎯 Key Findings & Research Questions

**Primary Research Question:** *What is the relationship between district-level child poverty and student educational achievement?*

1. **Non-Linear Impact (Diminishing Marginal Harm):** Test scores decline most sharply as districts move from low to moderate levels of child poverty. At extreme poverty levels, the incremental marginal decline flattens out, exhibiting a quadratic (convex) relationship.
2. **Structural SES vs. Current Income:** While current child poverty exerts a strong negative drag on test scores, long-term structural Socioeconomic Status (`sesavgall`) remains the largest positive predictor of academic performance.
3. **Within-State Variation & Geographic Locales:** Controlling for State Fixed Effects (`absorb(fips)`) accounts for baseline differences in state funding and standardized test scaling. Holding poverty and SES constant, suburban and town school districts show small performance advantages relative to urban baselines.

---

## 📊 Summary of Regression Models

The econometric analysis evaluates test scores ($Y_{ids}$) using State Fixed Effects and cluster-robust standard errors at the state (FIPS) level:

$$Y_{ids} = \beta_0 + \beta_1 \text{Poverty}_{ds} + \beta_2 \text{Poverty}^2_{ds} + \beta_3 \text{SES}_{ds} + \beta_4 \text{Enrollment}_{ds} + \boldsymbol{\Gamma} \text{Locale}_{ds} + \alpha_s + \epsilon_{ids}$$

### Primary Specification Results (Model 5 - State Fixed Effects)
* **Sample Size ($N$):** 97,977 District-Year Observations across 43 state categories
* **Overall Model Fit ($R^2$):** 0.4866
* **Key Coefficients:**
  * **Child Poverty Rate ($\beta_1$):** $-2.302$ ($p < 0.001$)
  * **Child Poverty Squared ($\beta_2$):** $+3.908$ ($p < 0.001$)
  * **Socioeconomic Index ($\beta_3$):** $+0.294$ ($p < 0.001$)
  * **Total Enrollment ($\beta_4$):** $-8.51 \times 10^{-7}$ ($p = 0.021$)

---

## 📂 Repository Structure

```text
.
├── scripts/
│   └── Project_3_data_cleaning.do     # Complete Stata pipeline (cleaning, merging, regressions, plots)
├── output/
│   ├── Heatmapcorr.png                 # Correlation matrix heatmap
│   ├── Impact on Test Scores.png       # Coefficient plot (coefplot output)
│   ├── NonLPoverty_Scatter.png         # Quadratic scatter plot of poverty vs. scores
│   ├── Poverty Distribution.png        # Histogram of SAIPE child poverty rates
│   ├── Poverty_Scatter.png             # Linear fitted scatter plot
│   ├── ResidualsPlot.png               # Residuals vs. Fitted diagnostic plot
│   └── MyResults.rtf                   # Exported regression table (esttab)
├── docs/
│   └── Team 5 Empirical Presentation.pdf # Slides presentation
├── README.md                           # Repository documentation
└── LICENSE                             # Open source license
```

---

## 🗄️ Data Sources

To execute the pipeline, the following raw datasets must be placed in your Stata working directory:

1. **Stanford Education Data Archive (SEDA v2024.3):**
   * `seda_admindist_long_cs_2024.3.dta` (Standardized mean test scores)
   * `seda_cov_admindist_annual_2024.3.dta` (District covariates & SES variables)
   * `seda_crosswalk_2024.3.dta` (NCES `leaid` mapping file)
2. **U.S. Census Bureau:**
   * `districts_saipe` (Small Area Income and Poverty Estimates for ages 5–17)

---

## 🛠️ Instructions for Running the Analysis

### Requirements
* **Stata 16 or higher** (SE or MP recommended due to dataset size)
* User-written Stata packages: `estout`, `coefplot`, `heatplot`, `palettes`, `colrspace`

### Setup & Execution
1. Clone this repository:
   ```bash
   git clone https://github.com/your-username/poverty-education-outcomes.cmd
   ```
2. Open Stata and install required user packages:
   ```stata
   ssc install estout, replace
   ssc install coefplot, replace
   ssc install heatplot, replace
   ssc install palettes, replace
   ssc install colrspace, replace
   ```
3. Update the directory pathways at the top of `scripts/Project_3_data_cleaning.do`:
   ```stata
   cd "YOUR/LOCAL/DIRECTORY/PATH"
   ```
4. Execute the `.do` file. The script will sequentially process raw datasets, execute merges, run regression diagnostics, generate visualization figures, and export `MyResults.rtf`.

---

## 📜 Academic References

* **Gamoran, A., & An, B. P. (2016).** *Effects of School Segregation and School Resources in a Changing Policy Context.* Educational Evaluation and Policy Analysis, 38(1), 43–64.
* **Hegedus, A., & Nwea, E. (2018).** *Evaluating the Relationships Between Poverty and School Performance.* NWEA Research Whitepaper.
* **Reardon, S. F., et al. (2026).** *Stanford Education Data Archive (Version SEDA 2024.3).* Stanford University.
* **U.S. Census Bureau (2026).** *Small Area Income and Poverty Estimates (SAIPE) Program.* Project No. P-7502872.