cd "C:\Users\aspir\Documents\Stata Work\Project 3"
log using "C:\Users\aspir\Documents\Stata Work\Project 3\Project_3_data_cleaning.txt", text replace

use seda_admindist_long_cs_2024.3.dta, clear
tostring sedaadmin, replace usedisplayformat
*Tostringing sedaadmin in all datasets for isid.
codebook, compact


save "C:\Users\aspir\Documents\Stata Work\Project 3\seda_use.dta", replace 

*======================Import and Organize Covariate===========================*

use seda_cov_admindist_annual_2024.3.dta, clear
tostring sedaadmin, replace usedisplayformat
isid sedaadmin year

save "C:\Users\aspir\Documents\Stata Work\Project 3\Seda_Cov_Org.dta", replace

*======================Merge Test and Covariate================================*
use seda_use.dta, clear	
merge m:1 sedaadmin year using Seda_Cov_Org.dta
tab _merge
keep if _merge == 3
drop _merge

rename sedaadmin leaid
save "C:\Users\aspir\Documents\Stata Work\Project 3", replace
	
*=====================Import and Organize Crosswalk============================*

use seda_crosswalk_2024.3.dta, clear
codebook, compact
rename id leaid
keep if year == 2024

keep if geo == "sedaadmin"
*Geo kept sedaschool and had duplicates within leaid. Filtered out. 

tostring leaid, replace format(%07.0f) force
isid leaid year
list leaid name geo in 1/20
describe leaid

save "C:\Users\aspir\Documents\Stata Work\Project 3", replace	


*=======================Merge with Crosswalk_Clean=============================*

use Test_Cov_Merge.dta, clear	
merge m:1 leaid year using Crosswalk_Clean.dta
tab _merge
keep if _merge == 1| _merge ==3
drop _merge
save "C:\Users\aspir\Documents\Stata Work\Project 3\Test_Cov_Cross_Merge.dta", replace


*========================Import and Clean SAIPE data===========================*
clear
import excel "C:\Users\aspir\Documents\Stata Work\Project 3\districts_saipe", sheet ("districts_saipe") firstrow
codebook, compact

tostring leaid, replace format(%07.0f) 
isid leaid year

save "C:\Users\aspir\Documents\Stata Work\Project 3", replace 

use saipe_use.dta, clear
describe est_population_5_17_poverty_pct
*Ensuring data is clean
*========================Final Merge with SAIPE dataset========================*


use Test_Cov_Cross_Merge.dta, clear
merge m:1 leaid year using saipe_use.dta
tab _merge
keep if _merge == 1| _merge ==3
drop _merge	
keep if year == 2024

save "C:\Users\aspir\Documents\Stata Work\Project 3\Final_Merge2.dta", replace
use Final_Merge2, clear
*================Gen dummy variable for high_poverty==============================

gen high_poverty = 1 if perfrl >= 0.75 & perfrl != .
replace high_poverty = 0 if perfrl < 0.75


reg cs_mn_all est_population_5_17 high_poverty
*Isn't used in final model due to different scaling and affects on the outcome.
*Still helpful for viewing relationship with test scores. 
*==========================Summary stats=======================================

summarize perfrl sesall totenrl est_population_5_17_pct high_poverty cs_mn_all urban suburb town rural

*============================Regressions=======================================*

reg cs_mn_all est_population_5_17_poverty_pct
estimates store Model_1
reg cs_mn_all est_population_5_17_poverty_pct sesavgall
estimates store Model_2
reg cs_mn_all est_population_5_17_poverty_pct sesavgall totenrl
estimates store Model_3
reg cs_mn_all est_population_5_17_poverty_pct sesavgall totenrl suburb town rural
estimates store Model_4
gen poverty_sq = est_population_5_17_poverty_pct^2
areg cs_mn_all est_population_5_17_poverty_pct poverty_sq sesavgall totenrl suburb town rural, absorb(fips) vce(cluster fips) 
estimates store Model_5
*Final Model.
*===========================Diagnostics=========================================
* Check for Multicollinearity
reg cs_mn_all est_population_5_17_poverty_pct poverty_sq sesavgall totenrl suburb town rural
estat vif

*Residual vs. Fitted Plot
reg cs_mn_all est_population_5_17_poverty_pct poverty_sq sesavgall totenrl suburb town rural
rvfplot, yline(0)
graph export "C:\Users\aspir\Documents\Stata Work\Project 3\ResidualsPlot.png", replace

* Check for Heteroskedasticity (constant variance of errors)
estat hettest

*Final Model already uses vce(cluster fips), making it more robust to heteroskedasticity.

*===========================Coefficient Plot=====================================
*Note, you must run areg first before you create the plot!
ssc install coefplot
areg cs_mn_all est_population_5_17_poverty_pct poverty_sq sesavgall totenrl suburb town rural, absorb(fips) vce(cluster fips) 
coefplot, keep(est_population_5_17_poverty_pct sesavgall suburb town rural) ///
    rename(est_population_5_17_poverty_pct = "Child Poverty (SAIPE)" ///
           sesavgall = "Socioeconomic Status" ///
           suburb 
		   = "Suburban" ///
           town = "Town" ///
           rural = "Rural") ///
    xline(0, lp(dash) lc(gs10)) ///
    title("Predictors of Test Scores (2024)") ///
    xtitle("Effect Size (Grade Levels)") ///
    graphregion(color(white))
	
graph export "C:\Users\aspir\Documents\Stata Work\Project 3\Impact on Test Scores.png", replace 
*Interpretations:
*Poverty (est_populati~y_pct): The coefficient is now -0.157. Interpretation: Within any given state, 
*a 1 percentage point increase in child poverty is associated with a 0.157 unit decrease in test scores.

*Note: This effect is smaller than your previous model (-0.41). This suggests that a lot of that "poverty effect" 
*you saw earlier was actually just "state differences" that have now been filtered out.

*The Rural Effect (rural): This is now statistically significant ($p=0.002$).
*Interpretation: Holding poverty and SES constant, rural districts perform 0.04 units lower than urban districts.

*In your previous model, rural areas looked the same as urban; now that you are comparing rural areas within 
*their own states, a "rural penalty" has emerged.

*=================Estimates Table==============================================
estimates table Model_1 Model_2 Model_3 Model_4 Model_5, b(%9.3f) star(.05 .01 .001) keep(est_population_5_17_poverty_pct poverty_sq sesavgall totenrl suburb town rural)
ssc install estout
esttab Model_1 Model_2 Model_3 Model_4 Model_5 using "MyResults.rtf", ///
    replace ///
    b(3) se(3) ///              // 3 decimal places for beta and standard errors
    star(* 0.05 ** 0.01 *** 0.001) ///
    label ///                   // Uses variable labels instead of names
    title("Determinants of SEDA Test Scores 2024") ///
    keep(est_population_5_17_poverty_pct poverty_sq sesavgall totenrl suburb town rural) ///
    addnotes("Note: Model 3 includes State Fixed Effects.") 
*Note for groupmates: In word change the font size to 14 and change the height margins to 0.01, 
*and the width to 1.4
*=======================Correlation Matrix=====================================*
pwcorr cs_mn_all est_population_5_17_poverty_pct sesavgall totenrl urban rural town suburb,  sig star(.05)
ssc install heatplot, replace
ssc install palettes, replace
ssc install colrspace, replace

quietly correlate cs_mn_all est_population_5_17_poverty_pct sesavgall totenrl urban rural town suburb
matrix C = r(C)
heatplot C, ///
    values(format(%3.2f)) ///
    aspect(1) ///
    ylabel(1 "Scores" 2 "Pov." 3 "sesavgall" 4 "totenrl" 5 "Urban" 6 "Rural" 7 "Town" 8 "Suburb") ///
    xlabel(1 "Scores" 2 "Pov." 3 "sesavgall" 4 "totenrl" 5 "Urban" 6 "Rural" 7 "Town" 8 "Suburb")  ///
    lower nodiag
graph export "C:\Users\aspir\Documents\Stata Work\Project 3\Heatmapcorr.png", replace 

	histogram est_population_5_17_poverty_pct, percent ///
    title("Distribution of Child Poverty Rates") ///
	xtitle("SAIPE Poverty rate ages 5-17")
graph export "C:\Users\aspir\Documents\Stata Work\Project 3\Poverty Distribution.png", replace

*============================Scatter Plots======================================*
predict predicted_score, xb
twoway (scatter cs_mn_all predicted_score, msize(tiny) mcolor(gs12%20)) ///
       (lfit cs_mn_all predicted_score, lcolor(red)), ///
       title("Model Performance: Actual vs. Predicted Test Scores") ///
       xtitle("Predicted Score (All Variables)") ///
       ytitle("Actual SEDA Score") ///
       legend(order(1 "Districts" 2 "Perfect Prediction"))

graph export "C:\Users\aspir\Documents\Stata Work\Project 3\improved scatter.png", replace

twoway (scatter cs_mn_all est_population_5_17_poverty_pct, mcolor(blue%5) msize(tiny)) ///
       (lfit cs_mn_all est_population_5_17_poverty_pct, lcolor(red) lwidth(medthick)), ///
       xtitle("Percentage of Children (5-17) in Poverty") ///
       ytitle("Mean Test Scores (SEDA)") ///
       title("Impact of District Poverty on Student Achievement") ///
       legend(label(1 "District Data") label(2 "Linear Trend"))
	   
graph export "C:\Users\aspir\Documents\Stata Work\Project 3\Poverty_Scatter.png", replace

twoway (scatter cs_mn_all est_population_5_17_poverty_pct, mcolor(blue%5) msize(tiny)) ///
       (qfit cs_mn_all est_population_5_17_poverty_pct, lcolor(red) lwidth(medthick)), ///
       title("Nonlinear Relationship: Poverty vs. Test Scores")
graph export "C:\Users\aspir\Documents\Stata Work\Project 3\NonLPoverty_Scatter.png", replace


*noticed that poverty is nonlinear and made adjustments under the regression section!
log close

