/* *************************************************************************** *
*					DIME DYNAMIC DOCUMENTATION TRAINING						   *												   
*																 			   *
*  PURPOSE:  			Export tables and images							   *		  
*  WRITEN BY:  			Luiza Andrade [lcardosodeandrad@worldbank.org]		   *
*  Last time modified:  June 2017											   *
*																			   *
********************************************************************************

	** OUTLINE:		Load data
					Part 5, task 1: Tabulate categorical variable
					Part 5, task 2: Balance table
					Part 5, task 3: Regression table
					Part 6, task 1: Manually create graph and then export it
					Part 6, task 2: Use iegraph to create figure
					Part 7: Using a do-file to edit a .tex file after exporting it
				
	** CREATES:		$raw_output\categorical.tex
					$raw_output\regression_table.tex
					$raw_output\regular_graph.png
					$raw_output\iegraph.png
					$raw_output\samplesizes.tex
						
	** NOTES:		This do-file requires ietoolkit and estout command to run



*******************************************************************************
*						Set your own path directories 
********************************************************************************/	

	* Change these file paths to match yours
	global main_folder 	"<<<ENTER YOUR FOLDER PATH HERE>>>"
	global raw_output	"$main_folder/Output/Raw"
	

/*******************************************************************************
*							Load and prepare data
*
*			There is no need to make any changes in this section until
*			you are ask to do so in the handout.
*
********************************************************************************/

	* Install ietoolkit - includes ieboilstart, iebaltab and iegraph used in this code
	* -----------------
	ssc install ietoolkit, replace
	
	* Install estout - includes commands for export results and estimates
	* -----------------	
	ssc install estout, replace

	* Standardizes settings and sets version number (important for randomization)
	ieboilstart, v(11.0)
	`r(version)'
	
	* Use life expectancy stata data
	sysuse 	lifeexp, clear
	
	*Settings important for reproducible randomization
	set 	seed 215320		
	sort 	region country
	
	*Randomly assign one half of the observations to treatment and the other to control
	gen 	random 		= uniform()
	gen 	treatment 	= random >=.5
	drop 	random
	lab def	tmt 		1 "Treatment" 0 "Control"
	lab var treatment	"Treatment group"
	lab val treatment 	tmt
	order	treatment 	,after(country)
	
	* Add variable labels to variables missing them
	lab var safewater	"Safe water index"
	lab var popgrowth	"Average annual population growth"
	
	*Rename the labels for the region variable
	lab def 	region	1 "Europe and Asia" ///
						2 "North America" 	///
						3 "South America", replace
	lab val		region	region
	

********************************************************************************
*			Part 5, task 1: Tabulate categorical variable
********************************************************************************
	
	* Clear any results already in memory
	estimates 	clear
	
	* Tabulate the region variable
	estpost 	tabulate region
	
	* Use esttab to export the tabulation above to tex
	esttab 		using 	"$raw_output/categorical.tex", replace 					/// 
				cells   ("b(label(Frequency)) pct(fmt(%9.2f)label(Share))")	///
				varlabels(`e(labels)') 										///		// Uses the value labels as row names. Alternatively, you could manually specify the labels using lab def and call it here
				nomtitle nonumbers 											///		// Prevents model names and numbers to be printed. Use if you're tabulating more then one variable, for example.
				noobs				
	
	
********************************************************************************
*			Part 5, task 2: Balance table
********************************************************************************

	iebaltab	popgrowth lexp gnppc, ///
				grpvar(treatment) ///
				vce(cluster region) ///
				rowvarlabels pftest ///
				savetex("$raw_output/balance_test") replace
				
	
********************************************************************************
*			Part 5, task 3: Regression table
********************************************************************************
	
	* Clear any results already in memory
	estimates 	clear
	
	* Run regression without fixed effects
	eststo : regress 	lexp treatment gnppc, vce(cluster region)
	estadd	 local fe 	"No"
	
	* Run regression with fixed effects
	eststo : regress 	lexp treatment gnppc i.region, vce(cluster region)
	estadd	 local fe 	"Yes"
			
	* Export regression results to tex using esttab 
	esttab 	using "$raw_output/regression_table.tex", 	///
			replace label r2 nomtitles b(%9.3f) 		///
			se(%9.3f) 									///
			keep(treatment gnppc _cons) 				///
			scalars("fe Region fixed-effects") 			///						// Adds a line specifying which regressions used fixed effects. This line was created by "estadd local fe"
			addnotes(Standard errors clustered at region level are in parentheses. \sym{*} \(p<0.05\), \sym{**} \(p<0.01\), \sym{***} \(p<0.001\)) nonotes
																				// Adds manual notes. Alternatively, you could use automatic notes by dropping the previous line
																				

																				
									
********************************************************************************
*			Part 6, task 1: Manually create graph and then export it
********************************************************************************
	
	* Generate graph
	twoway  (kdensity lexp if treatment == 1, lcolor(emidblue)) || 	///
			(kdensity lexp if treatment == 0, lcolor(gs12)), 		///
			legend(order(1 "Treatment" 2 "Control")) 				///
			title(Life expectancy distribution by treatment group) 	///
			ytitle(Density) xtitle(Years)
	
	* Export graph in file format suitable for tex
	graph export "$raw_output/regular_graph.png", width(5000) replace
	
	

********************************************************************************
*			Part 6, task 2: Use iegraph to create figure
********************************************************************************	
	
	* Clear any results already in memory
	estimates 	clear
	
	* Run a simple regression
	reg 	lexp treatment
	
	* Use iegraph to make it into a graph
	iegraph treatment, noconfbars 			///
			title	("Treatment effect")  	///
			save	("$raw_output/iegraph.png") ///
			yzero  grey 
																					
											
********************************************************************************
*			Part 7: Using a do-file to edit a .tex file after exporting it
********************************************************************************
	
	* Clear any results alreday in memory
	estimates 	clear
	
	* Tabulate treatment first for all observations, then for each region separately
	eststo : estpost 	tab treatment 
	eststo : estpost	tab treatment	if region == 1
	eststo : estpost	tab treatment 	if region == 2
	eststo : estpost	tab treatment 	if region == 3		
	
	* Use estab to export the tabulation to tex
	esttab 	using	"$raw_output/samplesizes.tex", replace ///
			mtitles ("Total" "Europe and Asia" "North America" "South America") ///	// Create column names
			noobs nonotes compress nonumbers										// noobs prevents an additional line with number of observations to be added, nonotes prevents notes to be added
	
	*Generate the table without this code first. The exercise will ask you 
	*to use this code to format the tex file after it has been exported
	/*
	filefilter 	"$raw_output/samplesizes.tex" "$raw_output/sample_sizes.tex", 	///				// Remove extra spacing
				from("\n[1em]") to("") 	replace
				
	filefilter 	"$raw_output/sample_sizes.tex" "$raw_output/samplesizes.tex", 	///				// Remove extra spacing
				from("          &                  &                  &                  &                  \BS\BS") to ("") ///
				replace	
	*/
