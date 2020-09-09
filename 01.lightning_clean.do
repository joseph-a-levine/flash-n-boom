clear all
set more off

global datapath1 "https://www1.ncdc.noaa.gov/pub/data/swdi/reports/county/byName/"
global datapath2 "~/Dropbox/Research/Weather/flashboom/Data"
global temppath "~/Dropbox/Research/Weather/flashboom/Analysis/temp"
global resultspath1 "~/Dropbox/Research/Weather/flashboom/Analysis"


* Sep 2020
* Last updated by: JL
* Goal: Get lightning data into Stata

********
* start with importing the master data from NOAA
********

import delimited "$datapath2\county_files.txt", varnames(1)

keep if substr(name, 12, 2) == "VT"
drop if name == "swdireport-VT-BETA.csv"

levelsof name, local(files)

clear

foreach file in `files' {
	import delimited "$datapath1/`file'", clear
	local outfile = substr("`file'",15,(strrpos("`file'","-")-15))
	syntax [varlist]
	foreach var of local varlist {
		rename `var' `var'_`outfile'
	}
	*save "`outfile'", replace
	save "$temppath/`outfile'.dta", replace
}





/******
*Next steps:
1) append dta files
2) find out how to import delimited direct from web. note line 19 works!!!
		did this!! Looks great
3) get time periods constant
*******/


