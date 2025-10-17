libname hw3 "/home/u64140125/805/HW/HW3";
run;

proc print data=hw3.lead_f2025;
run;

data ds1;
set hw3.lead_f2025;

/*setting informat for date formatting later*/
informat date_a date_b date_c mmddyy10.;

/*arrays*/
array day{3} Daybld_a Daybld_b Daybld_c;
array month{3} Mthbld_a Mthbld_b Mthbld_c;
array date{3} date_a date_b date_c;

/*missing data recodes*/
do i= 1 to 3;
if day{i} in (-1 32) then day{i}= 15;
if month{i} in (-1 32) then month{i}= 6;

/*date variable creation*/
date{i}= mdy(month{i}, day{i}, 1990);
end;
drop i;
run;

proc print data=ds1;
 format dob date_a date_b date_c mmddyy10.;
run;

/*variable for max blood lead levels in each child*/
 data ds2;
 set ds1;
 highest_bldlead = max(of pblev_a pblev_b pblev_c);
 run;
 proc print data=ds2;
  format dob date_a date_b date_c mmddyy10.;
 run;
 
/*date highest level was obtained*/
data ds3;
set ds2;
informat highest_bldlead_date mmddyy10.;

array bldlead{3} pblev_a pblev_b pblev_c;
array date{3} date_a date_b date_c;
do i= 1 to 3;

if bldlead{i} = highest_bldlead then highest_bldlead_date = date{i};
end;
drop i;
run;

proc print data=ds3;
format highest_bldlead_date dob date_a date_b date_c mmddyy10.;
run;

/*creating var for child's age in years rounded to 2 decimal points*/
data ds4;
set ds3;
age_at_highest_bldlead = round((highest_bldlead_date-dob)/365, 0.01);
run;

/*creating var for agecats*/
data ds5;
set ds4;
if age_at_highest_bldlead = . then agecat=.;
else if age_at_highest_bldlead <4 then agecat=1;
else if 4<= age_at_highest_bldlead <8 then agecat=2;
else if age_at_highest_bldlead >= 8 then agecat=3;
run;


/*printing temp ds*/
proc print data=ds5;
format highest_bldlead_date dob mmddyy10.;
var id dob highest_bldlead_date age_at_highest_bldlead agecat sex highest_bldlead;
run;

/*means procedure for mean and std of age in each sex group*/
proc means data=ds5 mean std;
class sex;
var agecat;
run;

proc sort data=ds5;
by sex;
run;
/*percentages in each age cat for each sex*/
proc freq data=ds5;
by sex;
table agecat;
run;

data hw3.lead_final;
set ds5;
run;

/*anova + interaction term*/
	proc glm data=hw3.lead_final; 
	title 'Analysis of Blood Lead Levels'; 
	class agecat sex; 
	model highest_bldlead=agecat|sex; 
	means agecat|sex; 
	lsmeans agecat|sex;
run;

/*anova w/out interaction term + posthoc*/

proc glm data=hw3.lead_final; 
	title 'Analysis of Blood Lead Levels'; 
	class agecat sex; 
	model highest_bldlead=agecat sex; 
	means agecat sex; 
	lsmeans agecat sex / stderr pdiff adjust=tukey;
run;



