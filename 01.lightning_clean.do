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


*import delimited "$datapath1/swdireport-VT-Addison-BETA.csv", clear

local files : dir "$datapath2" files "swdireport-VT*.csv"

display `files'

cd "$datapath2"

*downloads each file and renames varialbes to include county name

foreach file in `files' {
    import delimited `file', clear
	local outfile = substr("`file'",15,(strrpos("`file'","-")-15))
	syntax [varlist]
	foreach var of local varlist {
		rename `var' `var'_`outfile'
	}
	save "`outfile'", replace
}


******
*Next steps:
*1) append dta files
*2) find out how to import delimited direct from web. note line 19 works!!!
*3) get time periods constant
*******


