# Empirical Analysis of District-Level Child Poverty and Educational Outcomes
## Project Overview
This repository contains the workflow of our project, which includes data cleaning, data merging, 
and econometric modeling code, done in Stata for our "Empirical Data Analysis" class at Texas State University.

We used national school district-level data from 2024 from the Stanford Education Archive (SEDA 4.1) and Small 
Area Income and Poverty Estimates (SAIPE) to investigate the non-linear relationship between child poverty (ages 5-17)
and academic achievement across school districts. This was possible through merging SEDA and SAIPE datasets along with
district demographic covariates, and analyzing how economic scarcity impacts mean student test scores within each state.

## Authors and Contributors (Team 5)
Abi Mangual (PowerPoint presentation and organizer)

William Schriever (Research and Writing)

Anthony Castano (Primary Data Analyst)

Michael Carter (Research and Writing)

## Primary Research Question
What is the relationship between poverty and student achievement on a district level?

## Methodology
Our independent variables were as follows:

Poverty Rate (SAIPE)

SESAVG (Socioeconomic Status average 2005-09, 2010-14 & 2015)

SESAVGALL (to account for the lack of inputs in 2024)


Control Variables:

Locale (suburban, town, & rural)

State Fixed Effects (absorb(fips) vce(cluster fips)

Enrollment (totenrl)

## Strategy
1. Merge SEDA with Covariate, Crosswalk, and SAIPE (overall sample size is 97,977 observations)
2. Square poverty to caputre diminishing marginal harm
3. Use poverty to capture current economic stress while SESAVGALL captures long-term structural support
4. Use state-fixed effects to isolate state variation and varying educational standards
5. Run a non-linear adjusted regression model to evaluate test scores

## Key Findings:
1. Test scores decline sharply at low to moderate levels of poverty, and flatten as poverty reaches extreme levels.
2. Child poverty exerts a strong negative effect on test scores, but long-term structural socioeconomic status (sesavgall)
is the largest predictor of academic performance.
3. Controlling for state fixed effects accounts for baseline differences in state funding and 
standardized test scaling. Holding Poverty and SES constant, suburban and town school districts show small
performance advantages relative to urban baselines

## Regression Models Summary
<img width="688" height="37" alt="Screenshot 2026-04-23 200706" src="https://github.com/user-attachments/assets/2f3872a5-0474-45f6-a896-6344bbba4903" />
Overall Model Fit (R^2): 0.4866
Key Coefficients:
Child Poverty Rate (Beta 1): -2.392  (p < 0.001)
Child Poverty Squared (Beta_2): +3.908 (p < 0.001)
Socioeconomic Index (Beta 3): +0.294 (p < 0.001)
Total Enrollment (Beta 4): -8.51 * 10^-7 (p = 0.021)

## Data Sources:
1. Stanford Education Data Archive (SEDA v2024.3):
   seda_admindist_long_cs_2024.3.dta (Standardized mean test scores)
   seda_cov_admindist_annual_2024.3.dta (District covariates & SES variables)
   seda_crosswalk_2024.3.dta (NCES leaid mapping file)

2. U.S. Census Bureau:
   districts_saipe (Small Area Income and Poverty Estimates for ages 5–17)

## Academic References
Gamoran, A., & An, B. P. (2016). Effects of School Segregation and School Resources in a Changing Policy Context. Educational Evaluation and Policy Analysis, 38(1), 43–64.
Hegedus, A., & Nwea, E. (2018). Evaluating the Relationships Between Poverty and School Performance. NWEA Research Whitepaper.
Reardon, S. F., et al. (2026). Stanford Education Data Archive (Version SEDA 2024.3). Stanford University.
U.S. Census Bureau (2026). Small Area Income and Poverty Estimates (SAIPE) Program. Project No. P-7502872.

