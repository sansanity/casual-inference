import delimited "PDGES-GHGRP-GHGEmissionsGES-2004-Present-edited.csv", clear

********** GENERATING THE REQUIRED VARIABLES **********

* Alberta is the treatment group
generate alberta = 1 if facility_prov == "Alberta" 
replace alberta = 0 if alberta == .
* The treatment starts after 2016
generate post_treatment = 1 if year >= 2016
replace post_treatment = 0 if post_treatment == .
* The interaction term
generate albxpost = alberta*post_treatment

* Converting the string variable into numbers for future use of fixed effects
encode facility_prov, gen(province_code)

* province x t
generate provxt = province*year

// ********** BASIC DD **********
// reg total_emissions alberta post_treatment albxpost, vce(robust)
// est store basic
//
// ********** FIXED EFFECTS DD CONTROLLING FOR PROVINCE AND TIME FIXED EFFECTS **********
// * i.facility_prov for provincial fixed effects and i.year for time fixed effects, method 1
// reg total_emissions alberta post_treatment albxpost i.province_code i.year, vce(robust)
// est store fixedeff1
//
// * method 2
// ** xtreg total_emissions alberta post albxpost, fe i(province_code)
//
// ********** FIXED EFFECTS DD CONTROLLING FOR PROVINCE AND TIME FIXED EFFECTS + PROVINCE SPECIFIC TRENDS **********
// reg total_emissions alberta post_treatment albxpost i.province_code i.year provxt, vce(robust)
// est store fixedeff2
// // outreg2 total_emissions alberta post1 albxpost i.province_code i.year provxt [basic fixedeff1 fixedeff2] using dd_results.xls, replace dec(4) 
//
// outreg2 total_emissions alberta post1 albxpost i.province_code i.year provxt [basic fixedeff1 fixedeff2] using dd_robust_results.doc, replace dec(4) 





********** BASIC DD **********
generate ln_total_emissions = ln(total_emissions)
reg ln_total_emissions alberta post_treatment albxpost, vce(robust)
est store basic

********** FIXED EFFECTS DD CONTROLLING FOR PROVINCE AND TIME FIXED EFFECTS **********
* i.facility_prov for provincial fixed effects and i.year for time fixed effects, method 1
reg ln_total_emissions alberta post_treatment albxpost i.province_code i.year, vce(robust)
est store fixedeff1

* method 2
** xtreg total_emissions alberta post albxpost, fe i(province_code)

********** FIXED EFFECTS DD CONTROLLING FOR PROVINCE AND TIME FIXED EFFECTS + PROVINCE SPECIFIC TRENDS **********
reg ln_total_emissions alberta post_treatment albxpost i.province_code i.year provxt, vce(robust)
est store fixedeff2


outreg2 ln_total_emissions alberta post1 albxpost i.province_code i.year provxt [basic fixedeff1 fixedeff2] using dd_ln_results2.doc, replace dec(4) 

********** GRAPHING **********
collapse (mean) ln_total_emissions, by(year alberta)
twoway (line ln_total_emissions year if alberta == 1) (line ln_total_emissions year if alberta == 0), tline(2016) xlabel(2004 2010 2016 2020, labsize(small)) ylabel(,format(%2.1e) labsize(small)) ytitle("ln(Total Emissions) per Facility") legend(label(1 Treated) label(2 Control))
graph export "dd_ln_emissions.png", replace