/* *************************************************************************** *
*					DIME DYNAMIC DOCUMENTATION TRAINING						   *												   
*																 			   *
*  PURPOSE:  			Export tables and images							   *		  
*  WRITEN BY:  			Luiza Andrade [lcardosodeandrad@worldbank.org]		   *
*  Last time modified:  Apr 2017											   *
*																			   *
********************************************************************************


	** OUTLINE:		PART 0: Load data
					PART 1: Descriptives statistics
					PART 2: Balance tables
					PART 3: Regression tables
					PART 4: Images
				
	** REQUIRES:	"Data/sample_dataset.dta"
	
	** CREATES:		"Outputs/Raw files/sample_sizes.tex"
					"Outputs/Raw files/stats.tex"
					"Outputs/Raw files/twoway"
					"Outputs/Raw files/categorical.tex"
					"Outputs/Raw files/balance_table"
					"Outputs/Raw files/regression_table.tex"
					"Outputs/Raw files/regular_graph.png"
					"Outputs/Raw files/iegraph.png"
						
	** NOTES:		This do-file requires ietoolkit to run


********************************************************************************
*							PART 0: Load data
********************************************************************************/
	
	* Set directories
	* ---------------
	
	* Luiza's folders															// Add path to dynamic documentation folder
	if "`c(username)'" == "wb501238" {
		global main_folder 	"C:\Users\wb501238\Box Sync\DIME dynamic documentation"
	}
	
	capture confirm file 	"$main_folder\Raw\nul"
	di _rc
	if _rc 	mkdir 		 	"$main_folder\Raw"
	
	global	output		 	"$main_folder\Raw"
	
	* Load and process data
	* ---------------------
	
	* Use life expectantcy stata data
	sysuse 	lifeexp, clear
	
	* Create treatment variable
	gen 	random = uniform()
	gen 	treatment = random >.5
	
	* Label values
	lab def	tmt 		1 "Treatment" ///
						0 "Control"
	lab val treatment 	tmt
	
	* Label variables
	lab var treatment	"Treatment group"
	lab var popgrowth	"Average annual population growth"
	
	*Rename the labels for region
	lab def 	region	1 "Europe and Asia" ///
						2 "North America" ///
						3 "South America", replace
	lab val		region	region
	
	
	* Install ietoolkit
	* -----------------
	*ssc install ietoolkit
	
	
********************************************************************************
*						Exercise 1, taks 1: Descriptives statistics
********************************************************************************
	
	* Sample sizes
	* ------------
	
	estimates 	clear 
	qui estpost tab treatment 
	eststo		
	qui estpost	tab treatment	if region == 1
	eststo		
	qui estpost	tab treatment 	if region == 2
	eststo		
	qui estpost	tab treatment 	if region == 3
	eststo			
	esttab 		using	"$output\samplesizes.tex", replace ///
				mtitles ("Total" "Europe and Asia" "North America" "South America") ///	// Create column names
				noobs nonotes compress nonumbers										// noobs prevents an additional line with number of observations to be added, nonotes prevents notes to be added
				
	filefilter 	"$output\samplesizes.tex" "$output\sample_sizes.tex", ///				// Remove extra spacing
				from("\n[1em]") to("") ///
				replace
				
	filefilter 	"$output\sample_sizes.tex" "$output\samplesizes.tex", ///				// Remove extra spacing
				from("          &                  &                  &                  &                  \BS\BS") to ("") ///
				replace
					
	
	* Descriptive stats
	* -----------------
	estimates 	clear 
	qui estpost sum popgrowth lexp gnppc safewater
	eststo		
	
	esttab 		using	"$output\stats.tex", replace ///
				cells   ("count(label(N)) mean(fmt(%9.2f)label(Mean)) sd(fmt(%9.3f)label(Std. Dev.)) min(label(Min)) max(label(Max))")  ///	// Select statistics to be displayed and labels them
				label noobs nonumbers												// label uses the variable labels as row names

	filefilter 	"$output\stats.tex" "$output\stats_final.tex", ///				// Remove extra spacing
				from("&\BSmulticolumn{5}{c}{}                                            \BS\BS") to ("") ///
				replace			

	
	* Tabulate categorical vars
	* -------------------------

	estimates 	clear
	estpost 	tab region
	esttab 		using 	"$output\categorical.tex", replace /// 
				cells   ("b(label(Frequency)) pct(fmt(%9.2f)label(Share))")  ///
				varlabels(`e(labels)') ///										// Uses the value labels as row names. Alternatively, you could manually specify the labels using lab def and call it here
				nomtitle nonumbers ///												// Prevents model names and numbers to be printed. Use if you're tabulating more then one variable, for example.
				noobs				
	
	
********************************************************************************
*							PART 2: Balance tables
********************************************************************************
	
	* iebaltab: for continuous variables
	* ----------------------------------
	iebaltab 	popgrowth lexp gnppc safewater, ///								// Variables to be tested
				grpvar(treatment) ///											// Treatment variable
				fixedeffect(region) ///											// Fixed effects variable -- could also add controls using cov()
				vce(cluster region) ///											// Cluster variable
				rowvarlabels ////												// Use variable labels as row names
				savetex("$output\balance_table") replace ///			
				texcaption(Balance table) 										// Table title
				 
	
	
********************************************************************************
*							PART 3: Regression tables
********************************************************************************

	estimates 	clear
	qui reg 	lexp treatment gnppc safewater, vce(cluster region)
	eststo
	estadd		local fe "No"	
	qui reg 	lexp treatment gnppc safewater i.region, vce(cluster region)
	eststo
	estadd		local fe "Yes"
	qui reg 	lexp treatment gnppc safewater popgrowth, vce(cluster region)
	eststo
	estadd		local fe "No"
	qui reg 	lexp treatment gnppc safewater popgrowth i.region, vce(cluster region)
	eststo
	estadd		local fe "Yes"	
			
	esttab using 	"$output\regression_table.tex", ///
					replace label r2 nomtitles b(%9.3f) ///
					se(%9.3f) ///
					keep(treatment gnppc safewater popgrowth _cons) ///
					scalars("fe Region fixed-effects") ///						// Adds a line specifying which regressions used fixed effects. This line was created by "estadd local fe"
					addnotes(Standard errors clustered at region level are in parentheses. \sym{*} \(p<0.05\), \sym{**} \(p<0.01\), \sym{***} \(p<0.001\)) nonotes
																				// Adds manual notes. Alternatively, you could use automatic notes by dropping the previous line

	
********************************************************************************
*								PART 4: Images
********************************************************************************
	
	* Graphs																	// Manually create graph and then export it
	* ------
	
	twoway  (kdensity lexp if treatment == 1, lcolor(emidblue)) || ///
			(kdensity lexp if treatment == 0, lcolor(gs12)), ///
			legend(order(1 "Treatment" 2 "Control")) ///
			title(Life expectancy distribution by treatment group) ///
			ytitle(Density) xtitle(Years)
			
	gr export "$output\regular_graph.png", width(5000) replace
	
	* iegraph																	// Creates and saves graph automatically
	* -------
	
	qui reg 	lexp treatment
	iegraph 	treatment, noconfbars ///
				title	("Treatment effect")  ///
				save	("$output\iegraph.png") ///
				yzero  grey 
	
