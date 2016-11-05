/* Importing data files*/
PROC IMPORT DATAFILE="/home/dulaykj0/sasuser.v94/PROJECT/FAA1.xls" OUT=faa1 
		replace dbms=xls;
	GETNAMES=yes;
RUN;

PROC IMPORT DATAFILE="/home/dulaykj0/sasuser.v94/PROJECT/FAA2.xls" OUT=faa2 
		replace dbms=xls;
	GETNAMES=yes;
RUN;

/*Merging the two datasets*/
data combined_data;
	set faa1 faa2;
run;

proc print data=combined_data;
run;

/*Removing duplicates from the dataset*/
proc sort data=combined_data nodupkey;
     by aircraft no_pasg speed_ground speed_air height pitch distance;
run;

proc print data=combined_data;
run;

/*Removing the empty 50 rows sorting & sorting the data */
data combined_data_1;
	set combined_data;

	if aircraft='' then
		delete;
run;

proc print data=combined_data_1;
run;

/*Finding the basic statistics for each aircraft type */
proc means data=combined_data_1 n nmiss min max std skewness;
	by aircraft;
run;

data abnormal_duration_values;
set combined_data_1;
if duration > 40 or duration =. then abnormal = 'false';
else abnormal = 'true';
if abnormal = 'false' then delete;
title Outliers in duration variable;
run;

data abnormal_speedground_values;
set combined_data_1;
if (speed_ground > 30) and (speed_ground < 140)then abnormal = 'false';
else abnormal = 'true';
if abnormal = 'false' then delete;
drop abnormal;
title outliers in speed_ground;
run;
proc print data = abnormal_speedground_values;
run;

data abnormal_speedair_values;
set combined_data;
if (speed_air>30 and speed_air<140)or speed_air =. then abnormal = 'false';
else abnormal = 'true';
if abnormal = 'false' then delete;
drop abnormal;
title outliers in speed_air;
run;

data abnormal_height_values;
set combined_data_1;
if height > 6 then abnormal = 'false';
else abnormal = 'true';
if abnormal = 'false' then delete;
drop abnormal;
title outliers in height_variable;
run;

data abnormal_distance_values;
set combined_data_1;
if distance < 6000 then abnormal = 'false';
else abnormal = 'true';
if abnormal = 'false' then delete;
drop abnormal;
title outliers in distance;
run;

/*Filtering the data out*/
data combined_data_1;
	set combined_data_1;

	if duration < 40 and duration ~=. then
		delete;

	if speed_ground<30 or speed_ground>140 then
		delete;

	if (speed_air<30 or speed_air>140) and speed_air ~=. then
		delete;

	if height<6 then
		delete;

	if distance >6000 then
		delete;
run;

proc print data=combined_data_1;
run;
proc corr data = combined_data_1;
var speed_air speed_ground;
run;
proc plot data = combined_data_1;
plot speed_air*speed_ground;
run;
/*Finding the statistics of the filtered data */
proc means data=combined_data_1 n nmiss min max std skewness;
	by aircraft;
run;

/*Plotting the histogram and testing for normality for each variable*/
proc univariate data=combined_data_1 normal;
	by aircraft;
	histogram;
run;