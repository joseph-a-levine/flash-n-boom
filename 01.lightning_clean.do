*------------------Header---------------------
* Load lightning data into Stata
* 01b.lightning_clean
* Last edited date: 2020-10-14
* Last edited by: Joseph Levine
* Note: This does not run from URLs. Requires a text file.
* 		Analysis code is in private repository, contact jablevine@gmail.com ///
*		for access. 
*---------------------------------------------




*-------------------Program set-up-------------------------------

version 15		  // Set version number for backward compatibility
set more off      // Disable partitioned output 
pause on		  // Enables pause, to assist with debugging	
clear all  		  // Start with a clean slate
set linesize 100  // Line size limit to make output/logs more readable
set mem 15m		  // Sets usable memory in the evironment /*\ MUST CHECK FILE SIZE \*/
macro drop _all   // Clear all macros 
cap log close     // Close any open log files

/*\ ATTENTION \*/


global datapath1 	"https://www1.ncdc.noaa.gov/pub/data/swdi/reports/county/byName/"
global datapath2 	"~/Dropbox/Research/Weather/flashboom/Data"
global temppath 	"~/Dropbox/Research/Weather/flashboom/Analysis/temp"
global resultspath1 "~/Dropbox/Research/Weather/flashboom/Analysis"

log using "$temppath/1_lightning_$S_DATE.txt", replace text
*----------------------------------------------------------------


clear




* grab a text file which has the names of county files
import delimited "$datapath2\county_files.txt", varnames(1)


* For this project, I am only interested in VT (see analysis with L. Beck)
* Get rid of the following line to pull data for all states
* or switch out VT with two letter fcode for another state to just do that state
keep if substr(name, 12, 2) == "VT"

* need to drop all the state-wide beta files
* Again, can switch two letter code here
drop if name == "swdireport-VT-BETA.csv"

levelsof name, local(files)

* local with just the first file name
local first_file: word 1 of `files''"
* local with all *but* the first file name
local files: list files - first_file 


* first file - to set up the merge
* it's annoying that you can't merge into a blank file, or set up an \\
* "if" statement for the empty dataset
* I didn't think it was true, but implied to be the best way here:
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












clear all
log close

exit
