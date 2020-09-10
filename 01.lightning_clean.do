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


*get rid of this line to do all states; replace VT with two letter code for other states
keep if substr(name, 12, 2) == "VT"

*need to drop all the state-wide beta files, this will be not so simple
drop if name == "swdireport-VT-BETA.csv"

levelsof name, local(files)

*local with just the first file name
local first_file: word 1 of `files''"
*local with all *but* the first file name
local files: list files - first_file 


*first file - to set up the merge
*it's annoying that you can't merge into a blank file, or set up an \\
*"if" statement for the empty dataset
*I didn't think it was true, but implied to be the best way here:
*https://www.statalist.org/forums/forum/general-stata-discussion/general/1484575-how-to-merge-10-datasets-and-loop-through-them
import delimited "$datapath1/`first_file'", clear
local outfile = substr("`first_file'",15,(strrpos("`first_file'","-")-15))
syntax [varlist]
foreach var of local varlist {
		rename `var' `var'_`outfile'
	}
rename seqday_`outfile' seqday
save "$temppath/`outfile'.dta", replace
save "$datapath2/VT.dta", replace

clear



*now working off the rest of the file names, from local files
foreach file in `files' {
	import delimited "$datapath1/`file'", clear
	local outfile = substr("`file'",15,(strrpos("`file'","-")-15))
	syntax [varlist]
	foreach var of local varlist {
		rename `var' `var'_`outfile'
	}
	rename seqday_`outfile' seqday
	*save "`outfile'", replace
	save "$temppath/`outfile'.dta", replace
	merge 1:1 seqday using "$datapath2/VT.dta"
	drop _merge
	save "$datapath2/VT.dta", replace
}





/******
*Next steps:
1) try with some other states
2) annotate what needs to be down differently for other states
*******/


