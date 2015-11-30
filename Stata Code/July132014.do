//This is the stata file containing all the old stata files
//After this one, I deleted all the old ones
//(1) mup; (2) 2 plans, no hdr; (3) exception; the strategy is to merge then clean

cd "/Users/sunnieshang/Dropbox/Research/KN_1/Stata Code"
cd "/Users/sunnie/Desktop/Dropbox/Research/KN_1/Stata Code"
cd "D:\Dropbox\Research\KN_1\Stata Code"
set memory 8g
set maxvar 32767
set emptycells drop
set matsize 11000


insheet using c2k_mup_stati.csv, delimiter(";") clear
destring subtype, replace
destring weight, replace ignore(,)	
rename type status_type
gen effective_ts=clock(effective_timestamp, "DMYhms")	
format effective_ts %tc
drop *timestamp
compress
save mup.dta, replace //370,140 mbl

clear
insheet using c2k_rm_hdr2.csv, delimiter(";") clear
save rm_hdr2.dta, replace
clear
insheet using c2k_route_map1.csv, delimiter(";")
save route_map1, replace
clear
insheet using c2k_exception.csv, delimiter(";")
save exception, replace
clear
insheet using c2k_exception_codes.csv, delimiter(";") clear
save exception_codes, replace 

clear
use route_map1.dta, clear
append using rm_hdr2.dta
rename c2k_route_map_hdr_id hdr_id
drop if status_type==9999 | status_type==1281
replace v11=from_location_id if status_type<=1280
replace v12=v11 if status_type<=1280
replace v11=to_location_id if status_type>=1410
replace v12=v11 if status_type>=1410 
gen plan_ts=clock(plan_timestamp, "DMYhms")	
gen effective_ts=clock(effective_timestamp, "DMYhms")	
drop if effective_ts>=.	
drop if plan_ts>=. 
format effective_ts %tc
format plan_ts %tc
destring weight, replace ignore(,) 
drop *timestamp
bysort hdr_id status_type v11 flight_no (milestone_sn): drop if _n<_N 
save plan.dta, replace //160,973 shipments; 548,118 plans; 3.4 plans per shipment; 7 lines per plan
//%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
clear
use mup.dta
gen RMP_time=effective_ts-msofhours(0.9) if status_type==1280
bysort mbl (RMP_time): replace RMP_time=RMP_time[1]
bysort mbl: keep if _n==1
keep mbl RMP_time
format RMP_time %tc
merge 1:m mbl using plan.dta
keep if _merge==3
drop _merge
format mbl %11.0f
compress
bysort mbl hdr_id: gen rmp_num=1 if _n==1
by mbl: replace rmp_num=sum(rmp_num)
by mbl: replace rmp_num=rmp_num[_N]
gen a=1 if effective_ts<RMP_time+msofhours(0.1) & RMP_time<.
bysort mbl: egen double hdr_lowhigh=max(hdr_id) if a==1
bysort mbl: egen double hdr_highlow=min(hdr_id) if a!=1
keep if hdr_id==hdr_lowhigh | hdr_id==hdr_highlow
bysort mbl: egen double hdr=min(hdr_id)
keep if hdr_id==hdr
drop a hdr hdr_lowhigh hdr_highlow effective_ts
save plan_inuse.dta, replace //156,398 matched

clear
use mup.dta
keep location location_id
bysort location location_id: keep if _n==1
bysort location: gen a=1 if _N>1
drop a
drop if location_id>=.
save location_code.dta, replace

clear
use location_code.dta
rename location_id v11
rename location v11_name
merge m:m v11 using plan_inuse.dta
keep if _merge==3
drop _merge v11
rename v11_name v11
save plan_inuse.dta, replace
clear
use location_code.dta
rename location_id v12
rename location v12_name
merge m:m v12 using plan_inuse.dta
keep if _merge==3
drop _merge v12
rename v12_name v12
save plan_inuse.dta, replace
clear
use location_code.dta
rename location_id from_location_id
rename location plan_from_location
merge m:m from_location_id using plan_inuse.dta
keep if _merge==3
drop _merge from_location_id
save plan_inuse.dta, replace
clear
use location_code.dta
rename location_id to_location_id
rename location plan_to_location
merge m:m to_location_id using plan_inuse.dta
keep if _merge==3
drop _merge to_location_id
save plan_inuse.dta, replace

clear
use plan_inuse.dta
//in plan, the v11 and v12 is different, A-B for 1300 1400 and 1405
//also in the plan there is to and from location
replace flight_no=trim(flight_no) //(2324 real changes made)
replace flight_no="" if flight_no=="#"
replace weight=0 if weight>=.
bysort mbl (weight): replace weight=weight[_N]
rename weight expected_weight
replace expected_pcs=0 if expected_pcs>=.
bysort mbl (expected_pcs): replace expected_pcs=expected_pcs[_N]

foreach i in 1280 1410 1415 1700{
	bysort mbl status_type (milestone_sn): drop if _n<_N & status_type==`i'
	gen plan_time_`i'=plan_ts if status_type==`i'
	bysort mbl (plan_time_`i'): replace plan_time_`i'=plan_time_`i'[1]
}
bysort mbl (status_type): drop if status_type<=1280 & status_type[_N]>1280
bysort mbl (status_type): drop if status_type>=1410 & status_type[1]<1410
//first flight related time: 1300 1400 1405
bysort mbl status_type v11 (milestone_sn): keep if _n==_N & status_type>=1300 & status_type<=1405
bysort mbl status_type (milestone_sn): gen plan_time_1300_1=plan_ts ///
	if status_type==1300 & v11==plan_from_location
bysort mbl (plan_time_1300_1): replace plan_time_1300_1=plan_time_1300_1[1]
bysort mbl status_type (milestone_sn): gen plan_time_1400_1=plan_ts ///
	if status_type==1400 & v11==plan_from_location
bysort mbl (plan_time_1400_1): replace plan_time_1400_1=plan_time_1400_1[1]
bysort mbl status_type (milestone_sn): gen plan_time_1405_1=plan_ts ///
	if status_type==1405 & v11==plan_from_location
bysort mbl (plan_time_1405_1): replace plan_time_1405_1=plan_time_1405_1[1]
//first flight
bysort mbl status_type (milestone_sn): gen plan_flight_1=flight_no ///
	if status_type==1300 & v11==plan_from_location
bysort mbl (plan_flight_1): replace plan_flight_1=plan_flight_1[_N]
bysort mbl status_type (milestone_sn): replace plan_flight_1=flight_no ///
	if (status_type==1405|status_type==1400) & v11==plan_from_location & plan_flight_1==""
bysort mbl (plan_flight_1): replace plan_flight_1=plan_flight_1[_N]
//first connection
bysort mbl status_type (milestone_sn): gen plan_connect_1=v12 ///
	if v12!=plan_to_location & v11==plan_from_location & status_type==1300
bysort mbl (plan_connect_1): replace plan_connect_1=plan_connect_1[_N]
bysort mbl status_type (milestone_sn): replace plan_connect_1=v12 ///
	if v12!=plan_to_location & v11==plan_from_location & ///
	(status_type==1400|status_type==1405) & plan_connect_1==""
bysort mbl (plan_connect_1): replace plan_connect_1=plan_connect_1[_N]
//second flight related time: 1300 1400 1405
bysort mbl status_type (milestone_sn): gen plan_time_1300_2=plan_ts ///
	if status_type==1300 & v11==plan_connect_1
bysort mbl (plan_time_1300_2): replace plan_time_1300_2=plan_time_1300_2[1]
bysort mbl status_type (milestone_sn): gen plan_time_1400_2=plan_ts ///
	if status_type==1400 & v11==plan_connect_1
bysort mbl (plan_time_1400_2): replace plan_time_1400_2=plan_time_1400_2[1]
bysort mbl status_type (milestone_sn): gen plan_time_1405_2=plan_ts ///
	if status_type==1405 & v11==plan_connect_1
bysort mbl (plan_time_1405_2): replace plan_time_1405_2=plan_time_1405_2[1]
//second flight
bysort mbl status_type (milestone_sn): gen plan_flight_2=flight_no ///
	if status_type==1300 & v11==plan_connect_1
bysort mbl (plan_flight_2): replace plan_flight_2=plan_flight_2[_N]
bysort mbl status_type (milestone_sn): replace plan_flight_2=flight_no ///
	if (status_type==1405|status_type==1400) & v11==plan_connect_1 & plan_flight_2==""
bysort mbl (plan_flight_2): replace plan_flight_2=plan_flight_2[_N]
//second connection
bysort mbl status_type (milestone_sn): gen plan_connect_2=v12 ///
	if v12!=plan_to_location & v11==plan_connect_1 & ///
	status_type==1300 & v12!=plan_from_location
bysort mbl (plan_connect_2): replace plan_connect_2=plan_connect_2[_N]
bysort mbl status_type (milestone_sn): replace plan_connect_2=v12 ///
	if v12!=plan_to_location & v11==plan_connect_1 & ///
	(status_type==1400|status_type==1405) & plan_connect_2=="" & v12!=plan_from_location
bysort mbl (plan_connect_2): replace plan_connect_2=plan_connect_2[_N]
//third flight related time: 1300 1400 1405
bysort mbl status_type (milestone_sn): gen plan_time_1300_3=plan_ts ///
	if status_type==1300 & v11==plan_connect_2
bysort mbl (plan_time_1300_3): replace plan_time_1300_3=plan_time_1300_3[1]
bysort mbl status_type (milestone_sn): gen plan_time_1400_3=plan_ts ///
	if status_type==1400 & v11==plan_connect_2
bysort mbl (plan_time_1400_3): replace plan_time_1400_3=plan_time_1400_3[1]
bysort mbl status_type (milestone_sn): gen plan_time_1405_3=plan_ts ///
	if status_type==1405 & v11==plan_connect_2
bysort mbl (plan_time_1405_3): replace plan_time_1405_3=plan_time_1405_3[1]
//third flight
bysort mbl status_type (milestone_sn): gen plan_flight_3=flight_no ///
	if status_type==1300 & v11==plan_connect_2
bysort mbl (plan_flight_3): replace plan_flight_3=plan_flight_3[_N]
bysort mbl status_type (milestone_sn): replace plan_flight_3=flight_no ///
	if (status_type==1405|status_type==1400) & v11==plan_connect_2 & plan_flight_3==""
bysort mbl (plan_flight_3): replace plan_flight_3=plan_flight_3[_N]
//drop shipments with more than 2 flights
bysort mbl status_type (milestone_sn): gen plan_connect_3=v12 ///
	if v12!=plan_to_location & v11==plan_connect_2 & status_type==1300
bysort mbl (plan_connect_3): replace plan_connect_3=plan_connect_3[_N]
bysort mbl status_type (milestone_sn): replace plan_connect_3=v12 ///
	if v12!=plan_to_location & v11==plan_connect_2 & ///
	(status_type==1400|status_type==1405) & plan_connect_3==""
bysort mbl (plan_connect_3): replace plan_connect_3=plan_connect_3[_N]
drop if plan_connect_3!=""

format plan_time* %tc
bysort mbl: keep if _n==1
drop status_type v11 v12 plan_ts flight_no milestone_sn plan_connect_3
compress
order mbl hdr_id plan_from_location plan_flight_1 plan_connect_1 plan_flight_2 plan_connect_2 ///
	plan_flight_3 plan_to_location expected_weight expected_pcs
save plan_map.dta, replace
//%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
//all the change status in the plan data is C
clear
use mup.dta
bysort mbl status_type effective: keep if _n==1 
replace location_2=location if status_type<=1280 & location_2==""
replace location_1=location if status_type>=1400 & location_1==""
format mbl %11.0f
foreach i in 1280 1410 1415 1700{
	bysort mbl status_type (effective_ts): drop if _n<_N & status_type==`i'
	gen time_`i'=effective_ts if status_type==`i'
	bysort mbl (time_`i'): replace time_`i'=time_`i'[1]
}
format time* %tc

bysort mbl (status_type): drop if status_type<=1280 & status_type[_N]>1280
bysort mbl (status_type): drop if status_type>=1410 & status_type[1]<1410
merge m:1 mbl using plan_map.dta
keep if _merge==3
drop _merge
save mup_map.dta, replace 

clear
use mup_map.dta
replace weight=0 if weight>=.
replace number_of_pieces=0 if number_of_pieces>=.
bysort mbl (weight): replace weight=weight[_N]
bysort mbl (number_of_pieces): replace number_of_pieces=number_of_pieces[_N]
bysort mbl status_type location (effective): drop if _n<_N
gen num_connect=0 if plan_connect_1==""
replace num_connect=1 if plan_connect_1!="" & plan_connect_2=="" & num_connect>=.
replace num_connect=2 if plan_connect_2!="" & num_connect>=.
//only 1300 has differences A-B; for 1400 and 1405, A,A,A
gen time_1300_1=effective if location==plan_from_location & status_type==1300
bysort mbl (time_1300_1): replace time_1300_1=time_1300_1[1]
gen time_1400_1=effective if ///
	((location==plan_connect_1 & num_connect>=1)|(location==plan_to_location & num_connect==0)) & status_type==1400
bysort mbl (time_1400_1): replace time_1400_1=time_1400_1[1]
gen time_1405_1=effective if ///
	((location==plan_connect_1 & num_connect>=1)|(location==plan_to_location & num_connect==0)) & status_type==1405
bysort mbl (time_1405_1): replace time_1405_1=time_1405_1[1]

gen time_1300_2=effective if location==plan_connect_1 & status_type==1300
bysort mbl (time_1300_2): replace time_1300_2=time_1300_2[1]
gen time_1400_2=effective if ///
	((location==plan_connect_2 & num_connect>=2)|(location==plan_to_location & num_connect==1)) & status_type==1400
bysort mbl (time_1400_2): replace time_1400_2=time_1400_2[1]
gen time_1405_2=effective if ///
	((location==plan_connect_2 & num_connect>=2)|(location==plan_to_location & num_connect==1)) & status_type==1405
bysort mbl (time_1405_2): replace time_1405_2=time_1405_2[1]

gen time_1300_3=effective if location==plan_connect_2 & status_type==1300
bysort mbl (time_1300_3): replace time_1300_3=time_1300_3[1]
gen time_1400_3=effective if ///
	location==plan_to_location & num_connect==2 & status_type==1400
bysort mbl (time_1400_3): replace time_1400_3=time_1400_3[1]
gen time_1405_3=effective if ///
	location==plan_to_location & num_connect==2 & status_type==1405
bysort mbl (time_1405_3): replace time_1405_3=time_1405_3[1]
format time* %tc
//generate change_route
gen change_route=1 if status==1300 & location==plan_from_location & ///
	((location_2!=plan_connect_1 & num_connect>0) | (location_2!=plan_to_location & num_connect==0))
gen connect_1=location_2 if status==1300 & location==plan_from_location & ///
	((location_2!=plan_connect_1 & num_connect>0) | (location_2!=plan_to_location & num_connect==0))
bysort mbl (connect_1): replace connect_1=connect_1[_N]

replace change_route=1 if status==1300 & location==plan_connect_1 & ///
	((location_2!=plan_connect_2 & num_connect==2) | (location_2!=plan_to_location & num_connect==1))
gen connect_2=location_2 if status==1300 & location_1==plan_connect_1 & ///
	((location_2!=plan_connect_2 & num_connect==2) | (location_2!=plan_to_location & num_connect==1))
bysort mbl (change_route): replace change_route=change_route[1]
bysort mbl (connect_2): replace connect_2=connect_2[_N]

replace change_route=1 if status==1300 & location==plan_connect_2 & location_2!=plan_to_location & num_connect==2
gen connect_3=location_2 if status==1300 & location_1==plan_connect_2 & location_2!=plan_to_location & num_connect==2
replace change_route=0 if change_route>=.
bysort mbl (change_route): replace change_route=change_route[_N]

bysort mbl: keep if _n==1
drop status_type location_1 location_2 subtype location location_id effective_ts
compress
order mbl hdr_id change_route plan_from_location plan_flight_1 connect_1 plan_connect_1 plan_flight_2 ///
 connect_2 plan_connect_2 plan_flight_3 connect_3 plan_to_location num_connect number_of_pieces expected_pcs ///
 weight expected_weight rmp_num route_map_sn change_status RMP_time time_1280 ///
 time_1300_1 plan_time_1300_1 time_1400_1 plan_time_1400_1 time_1405_1 plan_time_1405_1 ///
 time_1300_2 plan_time_1300_2 time_1400_2 plan_time_1400_2 time_1405_2 plan_time_1405_2 ///
 time_1300_3 plan_time_1300_3 time_1300_3 time_1400_3 plan_time_1400_3 time_1405_3 plan_time_1405_3 ///
 time_1410 plan_time_1410 time_1415 plan_time_1415 time_1700 plan_time_1700
foreach i in 1280 1410 1415 1700{
	gen delay_`i'=hours(time_`i'-plan_time_`i')/24
	drop plan_time_`i'
}
foreach j in 1300 1400 1405{
	foreach i in 1 2 3{
		gen delay_`j'_`i'=hours(time_`j'_`i'-plan_time_`j'_`i')/24                                                              
		drop plan_time_`j'_`i'
	}
}
save map.dta, replace //155,780

use exception, clear //19107 mbls; 48155 observations
format mbl %11.0f
gen exception_ts=clock(exception_dt, "DMYhms")	
gen transmit_ts=clock(transmit_dt, "DMYhms")	
drop exception_dt transmit_dt
format exception_ts %tc
format transmit_ts %tc
bysort mbl status_type location (transmit_ts): drop if _n<_N //19107; 42564; 2.22
merge m:1 mbl using plan_map
keep if _merge==3
drop _merge //14850 mbl
drop plan_time* location_id expected* change_status route_map rmp RMP_time
replace voyage=trim(voyage)
foreach i in 1249 1280 1410 1415{
	gen exception_time_`i'=exception_ts if status==`i' & ((location==plan_from_location & status<=1280) | ///
		(location==plan_to_location & status>=1410))
	gen exception_code_`i'=c2k_exception_code if status==`i' & ((location==plan_from_location & status<=1280) | ///
		(location==plan_to_location & status>=1410))
}
gen exception_time_1300_1=exception_ts if status==1300 & location==plan_from_location 
gen exception_code_1300_1=c2k_exception_code if status==1300 & location==plan_from_location
gen exception_flight_1300_1=voyage if status==1300 & location==plan_from_location
gen exception_time_1300_2=exception_ts if status==1300 & location==plan_connect_1 
gen exception_code_1300_2=c2k_exception_code if status==1300 & location==plan_connect_1
gen exception_flight_1300_2=voyage if status==1300 & location==plan_connect_1
gen exception_time_1300_3=exception_ts if status==1300 & location==plan_connect_2
gen exception_code_1300_3=c2k_exception_code if status==1300 & location==plan_connect_2
gen exception_flight_1300_3=voyage if status==1300 & location==plan_connect_2

gen exception_time_1400_1=exception_ts if status==1400 & ((location==plan_connect_1 & ///
	plan_connect_1!="")|(location==plan_to_location & plan_connect_1==""))
gen exception_code_1400_1=c2k_exception_code if status==1400 & ((location==plan_connect_1 & ///
	plan_connect_1!="")|(location==plan_to_location & plan_connect_1==""))
gen exception_flight_1400_1=voyage if status==1400 & ((location==plan_connect_1 & ///
	plan_connect_1!="")|(location==plan_to_location & plan_connect_1==""))

gen exception_time_1400_2=exception_ts if status==1400 & ((location==plan_connect_2 & ///
	plan_connect_2!="")|(location==plan_to_location & plan_connect_2==""))	
gen exception_code_1400_2=c2k_exception_code if status==1400 & ((location==plan_connect_2 & ///
	plan_connect_2!="")|(location==plan_to_location & plan_connect_2==""))
gen exception_flight_1400_2=voyage if status==1400 & ((location==plan_connect_2 & ///
	plan_connect_2!="")|(location==plan_to_location & plan_connect_2==""))
	
gen exception_time_1400_3=exception_ts if status==1400 & location==plan_to_location & plan_connect_2!=""
gen exception_code_1400_3=c2k_exception_code if status==1400 & location==plan_to_location & plan_connect_2!=""
gen exception_flight_1400_3=voyage if status==1400& location==plan_to_location & plan_connect_2!=""

gen exception_time_1405_1=exception_ts if status==1405 & ((location==plan_connect_1 & ///
	plan_connect_1!="")|(location==plan_to_location & plan_connect_1==""))
gen exception_code_1405_1=c2k_exception_code if status==1405 & ((location==plan_connect_1 & ///
	plan_connect_1!="")|(location==plan_to_location & plan_connect_1==""))
gen exception_flight_1405_1=voyage if status==1405 & ((location==plan_connect_1 & ///
	plan_connect_1!="")|(location==plan_to_location & plan_connect_1==""))

gen exception_time_1405_2=exception_ts if status==1405 & ((location==plan_connect_2 & ///
	plan_connect_2!="")|(location==plan_to_location & plan_connect_2==""))	
gen exception_code_1405_2=c2k_exception_code if status==1405 & ((location==plan_connect_2 & ///
	plan_connect_2!="")|(location==plan_to_location & plan_connect_2==""))
gen exception_flight_1405_2=voyage if status==1405 & ((location==plan_connect_2 & ///
	plan_connect_2!="")|(location==plan_to_location & plan_connect_2==""))
	
gen exception_time_1405_3=exception_ts if status==1405 & location==plan_to_location & plan_connect_2!=""
gen exception_code_1405_3=c2k_exception_code if status==1405 & location==plan_to_location & plan_connect_2!=""
gen exception_flight_1405_3=voyage if status==1405 & location==plan_to_location & plan_connect_2!=""

foreach j in 1249 1280 1410 1415 1300_1 1300_2 1300_3 1400_1 1400_2 1400_3 1405_1 1405_2 1405_3{
	bysort mbl (exception_time_`j'): replace exception_time_`j'=exception_time_`j'[1] 
	bysort mbl (exception_code_`j'): replace exception_code_`j'=exception_code_`j'[_N]
}
foreach j in 1300_1 1300_2 1300_3 1400_1 1400_2 1400_3 1405_1 1405_2 1405_3{
	bysort mbl (exception_flight_`j'): replace exception_flight_`j'=exception_flight_`j'[_N]
}
format exception_time* %tc
keep exception_time* exception_code* exception_flight* mbl
bysort mbl: keep if _n==1
merge 1:1 mbl using map
drop _merge
order mbl hdr_id change_route plan_from_location plan_flight_1 connect_1 plan_connect_1 plan_flight_2 ///
 connect_2 plan_connect_2 plan_flight_3 connect_3 plan_to_location num_connect number_of_pieces expected_pcs ///
 weight expected_weight rmp_num route_map_sn change_status RMP_time time_1280 delay_1280 ///
 time_1300_1 delay_1300_1 time_1400_1 delay_1400_1 time_1405_1 delay_1405_1 ///
 time_1300_2 delay_1300_2 time_1400_2 delay_1400_2 time_1405_2 delay_1405_2 ///
 time_1300_3 delay_1300_3 time_1300_3 time_1400_3 delay_1400_3 time_1405_3 delay_1405_3 ///
 time_1410 delay_1410 time_1415 delay_1415 time_1700 delay_1700
save map_exception.dta, replace

//%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

use map_exception.dta, clear //155,780 mbl
/*
_pctile delay_1410, nq(1000)
ret li //99%, -3, 66
_pctile delay_1700, nq(100)
ret li //99%, -4, 56
_pctile delay_1415, nq(100)
ret li //99%, -6.9, 85.1
_pctile delay_1280, nq(1000)
ret li //99%, -4, 69
_pctile delay_1300_1, nq(1000)
ret li //99%, -3, 63
_pctile delay_1300_2, nq(1000)
ret li //99%, -3, 54
_pctile delay_1300_3, nq(1000)
ret li //99%, -3, 21
_pctile delay_1405_1, nq(1000)
ret li //99%, -2.9, 47
_pctile delay_1405_2, nq(1000)
ret li //99%, -3, 11 
_pctile delay_1405_3, nq(1000)
ret li //99%, -3, 11
*/
//%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Data cleaning; may change rules %%%%%%%%%%%%%%%%%%%%%%%
use map_exception.dta, clear //155,780 mbl
gen plan_dur=hours(time_1410-time_1280)/24 + delay_1280-delay_1410
gen act_dur=hours(time_1410-time_1280)/24
drop if plan_dur<=1/24 | act_dur<=1/24
drop if delay_1410>=.
foreach i in 1280 1410 1415 1700{
	drop if delay_`i'<. & (delay_`i'>=25 | delay_`i'<=-10)  
}

foreach j in 1300 1400 1405{
	foreach i in 1 2 3{
		drop if delay_`j'_`i'<. & (delay_`j'_`i'>=25 | delay_`j'_`i'<=-10)                                                              
	}
}  //142,255
drop if delay_1280>=. & delay_1410>=. & delay_1300_1>=. 
sum expected_weight if weight==0, d
replace weight=expected_weight if weight==0
drop if weight<1 | weight>20000
gen log_weight = log(weight)
drop if number_of_pieces<1 | number_of_pieces>1000
gen log_pieces = log(number_of_pieces)
gen carrier=word(plan_flight_1,1)
drop if carrier=="" 
gen month = month(dofc(time_1300_1))
replace month = month(dofc(time_1405_1)) if month>=.
replace month = month(dofc(time_1300_2)) if month>=.
drop if month>=.
replace carrier="KL" if carrier=="2X" | carrier=="XC" | carrier=="XB"
replace carrier="SK" if carrier=="XD" | carrier=="KF"
replace carrier="CX" if carrier=="XH"
replace carrier="CV" if carrier=="C8"
replace carrier="AC" if carrier=="QK"
replace carrier="AA" if carrier=="5X"

drop if delay_1410>12 | delay_1410<-4.06 //99.5%
drop if delay_1280> 8.5 | delay_1280<-5  //99.5%
drop if plan_dur>12.2 | plan_dur<0.175

/*
bysort plan_from_location plan_to_location: gen route=1 if _n==1
replace route=sum(route) //132,402 obs; 10,986 routes
*/

bysort plan_from_location plan_to_location carrier: gen route_carrier_size=_N
drop if route_carrier_size<10
drop route_carrier_size
bysort plan_from_location plan_to_location: gen route_size=_N
drop if route_size<20
drop route_size   //86,198 (65%) shipments on 20 carrier 1333 (12.1%) routes
bysort plan_from_location plan_to_location: gen route=1 if _n==1
replace route=sum(route)
tab carrier, sort
bysort route carrier: gen route_carrier_size=_N
gsort route -route_carrier_size
by route: gen large_carrier=1 if carrier==carrier[1]
replace large_carrier=0 if large_carrier>=.
bysort route (carrier): gen one_carrier=1 if carrier[1]==carrier[_N]
replace one_carrier=0 if one_carrier>=.
replace large_carrier=0 if one_carrier==1
save clean_map.dta, replace

//%%%%%%%%%%%%%%%%%%%%% Exploratory Analysis %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
/*bysort route: gen route_size=_N
bysort route carrier: gen route_carrier_size=_N
bysort route carrier: keep if _n==1
sum route_carrier_size, d
bysort route: gen carrier_num=_N
bysort route: keep if _n==1
summ carrier_num, d
summ route_size, d
count if carrier_num==1
egen car1_size=sum(route_size) if carrier_num==1
sum route_size if carrier_num==1, d
sum route_size if carrier_num>1, d */


/*bysort plan_from_location plan_to_location carrier: gen size=_N
by plan_from_location plan_to_location carrier: keep if _n==1
by plan_from_location plan_to_location: egen route_size=sum(size)
by plan_from_location plan_to_location: gen carrier_num=_N
by plan_from_location plan_to_location: gen route=1 if _n==1
replace route=sum(route)
bysort route: keep if _n==1


bysort plan_from_location plan_to_location: gen size=_N
egen totol1=sum(size) if size<5
bysort plan_from_location plan_to_location: gen route=1 if _n==1
replace route=sum(route)
egen total=sum(size)

*/
/*
twoway scatter delay_1300_1 delay_1280 if delay_1280<4 & delay_1280>=-4 ///
	& delay_1300_1<4 & delay_1300_1>=-4
twoway scatter delay_1405_1 delay_1300_1 if delay_1300_1<4 & delay_1300_1>=-4 ///
	& delay_1405_1<4 & delay_1405_1>=-4
twoway scatter delay_1300_2 delay_1405_1 if delay_1405_1<4 & delay_1405_1>=-4 ///
	& delay_1300_2<4 & delay_1300_2>=-4	
twoway scatter delay_1405_2 delay_1300_2 if delay_1300_2<4 & delay_1300_2>=-4 ///
	& delay_1405_2<4 & delay_1405_2>=-4	

twoway scatter delay_1300_3 delay_1405_2 if delay_1405_2<4 & delay_1405_2>=-4 ///
	& delay_1300_3<4 & delay_1300_3>=-4	
	
twoway scatter delay_1410 last_1405 if last_1405<4 & last_1405>=-4 ///
	& delay_1410<4 & delay_1410>=-4	
	
gen last_1405=delay_1405_1 if num_connect==0
replace last_1405=delay_1405_2 if num_connect==1
replace last_1405=delay_1405_3 if num_connect==2
sum last_dep, d //91,320
sum last_dep if last_dep>=-3 & last_dep<=3 //113,780
hist last_dep if last_dep>=-2.8 & last_dep<=2.8, bin(200)
hist delay_1410 if delay_1410<=4 & delay_1410>=-2, bin(200)
count if delay_1300_1>0 & delay_1300_1<. & delay_1280<=-0.5 //20,354
count if delay_1300_1>0 & delay_1300_1<. & delay_1280<=0 //20,354
count if delay_1300_1>0 & delay_1300_1<. & delay_1280>0 & delay_1280<. //7,473
count if delay_1300_1<=0 & delay_1280>0 & delay_1280<. //10,029
count if delay_1300_1<=0 & delay_1280<=0 //73,743
corr delay_1280 delay_1300_1 if delay_1280<=0 //0.2785
corr delay_1280 delay_1300_1 if delay_1280>0 //0.2785
corr delay_1280 delay_1300_1 if delay_1300_1>0 //0.8607


pwcorr po_1300_0 ne_1300_0 po_1280 ne_1280

corr delay_1300_1 delay_1405_1 if delay_1300_1<=0 //0.1208
corr delay_1300_1 delay_1405_1 if delay_1300_1>0 //0.1208
count if delay_1405_1>0 & delay_1405_1<. & delay_1300_1<=0 //10024
count if delay_1405_1>0 & delay_1405_1<. & delay_1300_1>0 & delay_1300_1<. //13442

count if delay_1300_2>0 & delay_1300_2<. & delay_1300_1<=0 //12,519
count if delay_1300_2>0 & delay_1300_2<. & delay_1300_1>0 & delay_1300_1<. //7,719

count if delay_1300_2<=0 & delay_1300_1>0 & delay_1300_1<. //6,732
count if delay_1300_2<=0 & delay_1300_1<=0 //32,220
corr delay_1405_1 delay_1300_2 if delay_1405_1<=0 //0.1208
corr delay_1405_1 delay_1300_2 if delay_1405_1>0 //0.7791

corr delay_1300_2 delay_1405_2 if delay_1300_2<=0 //0.1208
corr delay_1300_2 delay_1405_2 if delay_1300_2>0 //0.1208
count if delay_1405_2>0 & delay_1405_2<. & delay_1300_2<=0 //3242
count if delay_1405_2>0 & delay_1405_2<. & delay_1300_2>0 & delay_1300_2<. //10728

count if delay_1300_3>0 & delay_1300_3<. & delay_1300_2<=0 //874
count if delay_1300_3>0 & delay_1300_3<. & delay_1300_2>0 & delay_1300_2<. //799
count if delay_1300_3<=0 & delay_1300_2>0 & delay_1300_2<. //738
count if delay_1300_3<=0 & delay_1300_2<=0 //2,428
corr delay_1405_2 delay_1300_3 if delay_1405_2<=0 //0.1191
corr delay_1405_2 delay_1300_3 if delay_1405_2>0 //0.7067

corr delay_1300_3 delay_1405_3 if delay_1300_3<=0 //0.1208
corr delay_1300_3 delay_1405_3 if delay_1300_3>0 //0.1208
count if delay_1405_3>0 & delay_1405_3<. & delay_1300_3<=0 //289
count if delay_1405_3>0 & delay_1405_3<. & delay_1300_3>0 & delay_1300_3<. //1174

count if delay_1410>0 & delay_1410<. & last_1405<=0 //1806
count if delay_1410>0 & delay_1410<. & last_1405>0 & last_1405<. //17940
count if delay_1410<=0 & last1405>0 & last_1405<. //17,980
count if delay_1410<=0 & last_1405<=0 //71,862
corr last_1405 delay_1410 if last_1405<=0 //0.4450
corr last_1405 delay_1410 if last_1405>0 //0.9135

hist delay_1280 if delay_1300_1>0 & delay_1300_1<. & ///
	delay_1280<=3 & delay_1280>=-3, bin(100)
graph save Graph "D:\Dropbox\Research\KN_1\Stata Code\delay_1280_dep1_late.gph"

hist delay_1300_1 if delay_1300_1>0 & delay_1300_1<. & ///
	delay_1280<=3 & delay_1280>=-3 & delay_1300_1<=4, bin(100)
graph save Graph "D:\Dropbox\Research\KN_1\Stata Code\delay_1300_dep1_late.gph"	
	
hist delay_1405_1 if delay_1300_1>0 & delay_1300_1<. & ///
	delay_1280<=3 & delay_1280>=-3 & delay_1405_1<=4 & delay_1405_1>-2, bin(100)
graph save Graph "D:\Dropbox\Research\KN_1\Stata Code\delay_1410_dep1_late.gph"	

hist delay_1300_1 if delay_1300_2>=0 & delay_1300_2<. & ///
	delay_1300_1<=3 & delay_1300_1>=-2, bin(100)	
hist last_1405 if delay_1410>0 & delay_1410<. & ///
	last_1405<=5 & last_1405>=-0.5, bin(100)	
hist delay_1410 if delay_1410>0 & delay_1410<. & ///
	delay_1410<=5 & delay_1410>=-2, bin(100)	
graph combine "D:\Dropbox\Research\KN_1\Stata Code\delay_1410_NFD_late.gph" ///
"D:\Dropbox\Research\KN_1\Stata Code\delay_last1405_NFD_late.gph" 
graph save Graph "D:\Dropbox\Research\KN_1\Stata Code\delay_propagate2.gph"

hist last_1405 if last_1405<=4 & last_1405>=-2, bin(100)	
graph save Graph "D:\Dropbox\Research\KN_1\Stata Code\delay_last1405.gph"
hist delay_1410 if delay_1410<=4 & delay_1410>=-2, bin(100)
graph save Graph "D:\Dropbox\Research\KN_1\Stata Code\delay_1410.gph"
graph combine "D:\Dropbox\Research\KN_1\Stata Code\delay_last1405.gph" ///
	"D:\Dropbox\Research\KN_1\Stata Code\delay_1410.gph"
*/	
/*
rename plan_from_location iata_place
merge m:1 iata_place using airport
keep if _merge==3
rename country plan_from_country
rename iata_place plan_from_location
rename continent plan_from_continent
drop  id name city icao latitude longitude altitude timezone ///
	DST code _merge
rename plan_to_location iata_place
merge m:1 iata_place using airport
keep if _merge==3
rename country plan_to_country
rename iata_place plan_to_location
rename continent plan_to_continent
drop  id name city icao latitude longitude altitude timezone ///
	DST code _merge
replace plan_from_country="China" if plan_from_country=="Hong Kong"
replace plan_to_country="China" if plan_to_country=="Hong Kong"
distinct plan_from_country
tab plan_from_country, sort 
distinct plan_to_country
tab plan_to_country, sort
replace plan_from_continent="AS" if plan_from_continent=="ASEU"
replace plan_to_continent="AS" if plan_to_continent=="ASEU"
drop if plan_from_continent=="OC" | plan_to_continent=="OC"
tab plan_from_continent plan_to_continent
bysort plan_from_continent plan_to_continent: gen continent_pair=_N/91310
bysort plan_from_continent plan_to_continent: keep if _n==1
gsort -continent_pair plan_from_continent plan_to_continent
*/
/*tab carrier, sort freq
bysort plan_from_location plan_to_location: gen size=_N
bysort plan_from_location plan_to_location: keep if _n==1
gsort -size plan_from_location plan_to_location */


//exploratory analysis of exception code
/*
count if delay_1280>=0 & delay_1280<. & exception_code_1280!="" //2,501
count if delay_1280>=0 & delay_1280<. & exception_code_1280=="" //22,866
count if delay_1280>=0 & delay_1280<. //25,367

count if delay_1300_1>=0 & delay_1300_1<. & ///
	(exception_code_1300_1!=""|exception_code_1280!="") //2,197
count if delay_1300_1>=0 & delay_1300_1<. //39,666

count if delay_1300_2>=0 & delay_1300_2<. & ///
	(exception_code_1300_2!=""|exception_code_1300_1!=""|exception_code_1280!="" ///
	|exception_code_1400_1!="" | exception_code_1405_1!="")  //2,809
count if delay_1300_2>=0 & delay_1300_2<. //31,935

count if delay_1300_3>=0 & delay_1300_3<. & ///
	(exception_code_1300_3!=""|exception_code_1300_1!=""|exception_code_1280!="" ///
	|exception_code_1400_1!="" | exception_code_1405_1!=""|exception_code_1300_2!="" ///
	| exception_code_1400_2!=""| exception_code_1405_2!="")  //2,809
count if delay_1300_3>=0 & delay_1300_3<. //3?774
gen exception=exception_code_1300_1+exception_code_1300_2+exception_code_1300_3 ///
 	+exception_code_1400_1+exception_code_1400_2+exception_code_1400_3+exception_code_1405_1 ///
 	+exception_code_1405_2+exception_code_1405_3 
count if delay_1410>=0 & delay_1410<. & exception!=""  //3120
count if delay_1410>=0 & delay_1410<.  //28,027

count if delay_1300_1>=1 & delay_1300_1<. & ///
	(exception_code_1300_1!=""|exception_code_1280!="") //491
count if delay_1300_1>=1 & delay_1300_1<. //4769

count if delay_1300_2>=1 & delay_1300_2<. & ///
	(exception_code_1300_2!=""|exception_code_1300_1!=""|exception_code_1280!="" ///
	|exception_code_1400_1!="" | exception_code_1405_1!="")  //1026
count if delay_1300_2>=1 & delay_1300_2<. //7718

count if delay_1300_3>=0 & delay_1300_3<. & ///
	(exception_code_1300_3!=""|exception_code_1300_1!=""|exception_code_1280!="" ///
	|exception_code_1400_1!="" | exception_code_1405_1!=""|exception_code_1300_2!="" /??
	| exception_code_1400_2!=""| exception_code_1405_2!="")  //2,809
count if delay_1300_3>=0 & delay_1300_3<. //3?774

gen exception=exception_code_1300_1+exception_code_1300_2+exception_code_1300_3 ///
 	+exception_code_1400_1+exception_code_1400_2+exception_code_1400_3+exception_code_1405_1 ///
 	+exception_code_1405_2+exception_code_1405_3 
count if delay_1410>=1 & delay_1410<. & exception!=""  //1191
count if delay_1410>=1 & delay_1410<.  //9999

gen excep_1=exception_code_1280
replace excep_1=exception_code_1300_1 if excep_1==""
replace excep_1=exception_code_1400_1 if excep_1==""
replace excep_1=exception_code_1405_1 if excep_1==""
replace excep_1=exception_code_1300_2 if excep_1==""
replace excep_1=exception_code_1400_2 if excep_1==""
replace excep_1=exception_code_1405_2 if excep_1==""
replace excep_1=exception_code_1300_3 if excep_1==""
replace excep_1=exception_code_1400_3 if excep_1==""
replace excep_1=exception_code_1405_3 if excep_1==""
replace excep_1=exception_code_1410 if excep_1==""
tab excep_1, sort
*/
/*sum time*
sum delay*
foreach i in 1280 1410 1415 1700{
	sum delay_`i' if delay_`i'>=-5 & delay_`i'<=5 
}
foreach j in 1300 1400 1405{
	foreach i in 1 2 3{
		sum delay_`j'_`i' if delay_`j'_`i' >=-5 & delay_`j'_`i' <=5                                                              
	}
} */
/*
hist delay_1410 if delay_1410<=100 & delay_1410>=-75 & ///
	((from_conti=="EU" & to_conti=="AS") | (from_conti=="AS" & to_conti=="EU")), bin(100) freq ///
	xlabel(-75(25)100, grid) xtitle("Last Step's Delay (hours)") ///
	subtitle("Route EU-AS: All Airlines") 
graph export EUAS_1410.png, replace
*/


//%%%%%%%%%%%%%%%%%%%%%%%%%% Matlab Data %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
use clean_map.dta, clear  //2,456 routes; 112,211 shipments 
drop  plan_con* time_* delay_1300_3 delay_1300_1 delay_1300_2 delay_1400_3 ///
	delay_1400_1 delay_1405_3 delay_1405_1 delay_1405_2 plan_flight_1 ///
	plan_flight_2 plan_flight_3 delay_1400_2 exception* delay_1415 ///
	delay_1700 route_map_sn expected* connect* change_route mbl hdr_id ///
	RMP_time change_status rmp_num number_of_pieces weight
gen num_leg=num_connect+1
replace month=month-5 if month>=10 //10,11,12 ---> 5, 6, 7
/* 
         al |      Freq.     Percent        Cum.
------------+-----------------------------------
  1      AA |      4,405        3.93        3.93
  2      AC |      3,988        3.55        7.48
  3      AF |      7,544        6.72       14.20
  4      AY |      1,405        1.25       15.45
  5      BA |      9,535        8.50       23.95
  6      CV |      8,095        7.21       31.17
  7      CX |      5,591        4.98       36.15
  8      DL |      3,624        3.23       39.38
  9      EY |      1,047        0.93       40.31
 10      KA |        946        0.84       41.15
 11      KE |      1,459        1.30       42.45
 12      KL |     11,303       10.07       52.53
 13      LH |     26,494       23.61       76.14
 14      LX |      6,754        6.02       82.16
 15      MP |        946        0.84       83.00
 16      OS |      1,329        1.18       84.19
 17      QR |      1,682        1.50       85.68
 18      SK |      3,761        3.35       89.04
 19      SQ |      6,695        5.97       95.00
 20      UA |      5,608        5.00      100.00
------------+-----------------------------------
      Total |    112,211      100.00
*/

//CDG-SIN; FRA-ATL; HKG-BUD; LHR-MAD; NBO-AMS
/* random sample route
bysort route: gen route_size=_N
bysort route (carrier): gen mul_route=1 if carrier[1]!=carrier[_N]
gen index=runiform() if mul_route==1
sort index
keep if route==1040|route==995|route==125|route==203|route==427
keep if route==584|route==996|route==828|route==384|route==273 ///
|route==782|route==855|route==451|route==21|route==630|route==437|route==411
460 - 557 - 387 - 467 - 371
*/
drop route
bysort plan_from_location plan_to_location: gen route=1 if _n==1
replace route=sum(route)
egen carrier_id=group(carrier)
egen group_id = group(carrier route)
bysort route (carrier_id): gen notfirst=1 if carrier_id!=carrier_id[1]
bysort carrier notfirst (route): replace notfirst=0 if route==route[1] & notfirst==1
bysort route carrier_id: gen route_carrier_id=1 if _n==1 & notfirst==1
replace route_carrier_id=sum(route_carrier_id) if notfirst==1
replace route_carrier_id=0 if route_carrier_id>=.
replace route_carrier_id = route_carrier_id+1

/*bysort carrier_id route (num_leg): gen notfirstleg=1 if num_leg!=num_leg[1]
bysort carrier_id num_leg (notfirstleg): replace notfirstleg=notfirstleg[1] if notfirstleg[1]==1
bysort carrier_id num_leg: gen carrier_leg2=1 if _n==1  & notfirstleg==1 & num_leg==2
bysort carrier_id num_leg: gen carrier_leg3=1 if _n==1  & notfirstleg==1 & num_leg==3

replace carrier_leg2=sum(carrier_leg2) if notfirstleg==1 & num_leg==2
replace carrier_leg2=0 if carrier_leg2>=.
replace carrier_leg2=carrier_leg2+1

replace carrier_leg3=sum(carrier_leg3) if notfirstleg==1 & num_leg==3
replace carrier_leg3=0 if carrier_leg3>=.
replace carrier_leg3=carrier_leg3+1*/

replace delay_1410=delay_1410*24
/*replace log_weight=log_weight/10
replace log_pieces=log_pieces/7
replace plan_dur = plan_dur/12.2 */

gen range1_1280 = delay_1280    if delay_1280<-0.5
gen range2_1280 = delay_1280    if delay_1280>=-0.5 & delay_1280<0
gen range3_1280 = delay_1280    if delay_1280>=0 & delay_1280<0.5
gen range4_1280 = delay_1280    if delay_1280>=0.5 & delay_1280<1
gen range5_1280 = delay_1280    if delay_1280>=1 & delay_1280<2
gen range6_1280 = delay_1280    if delay_1280>=2

gen range1_dur = plan_dur	if plan_dur<1
gen range2_dur = plan_dur   if plan_dur>=1 & plan_dur<2
gen range3_dur = plan_dur   if plan_dur>=2

gen range1_weight = log_weight if log_weight<2  
gen range2_weight = log_weight if log_weight>=2 & log_weight<4
gen range3_weight = log_weight if log_weight>=4 & log_weight<6
gen range4_weight = log_weight if log_weight>=6 & log_weight<8
gen range5_weight = log_weight if log_weight>=8

gen range1_pcs = log_pieces if log_pieces<1  
gen range2_pcs = log_pieces if log_pieces>=1 & log_pieces<2
gen range3_pcs = log_pieces if log_pieces>=2


foreach i in range1_1280 range2_1280 range3_1280 range4_1280 ///
	range5_1280 range6_1280 range1_dur range2_dur range3_dur range1_weight ///
	range2_weight range3_weight range4_weight range5_weight range1_pcs ///
	range2_pcs range3_pcs {
	replace `i'=0 if `i'>=.
}

drop plan_from_location plan_to_location carrier notfirst  ///
	num_connect  one_carrier large carrier route_carrier_size ///
	delay_1280 act_dur plan_dur log*
order delay_1410 carrier_id route route_carrier_id month num_leg group_id


/*drop plan_from_location plan_to_location carrier notfirst delay_1280 ///
	num_connect notfirstleg num_leg one_carrier large carrier route_carrier_size
order delay_1410 carrier_id route route_carrier_id month carrier_leg2 carrier_leg3 ///
	pos_1280 neg_1280 plan_dur log_weight log_pieces
drop plan_from_location plan_to_location carrier notfirst  ///
	num_connect  one_carrier large carrier route_carrier_size act_dur
order delay_1410 carrier_id route route_carrier_id month num_leg ///
	delay_1280 plan_dur log_weight log_pieces*/
/*
log using "/Users/sunnieshang/Dropbox/Research/KN_1/Stata Code/log_09252014.log"
log using "log_09252014.log", append
xi: reg delay_1410 carrier_id##route i.num_leg log_weight log_pieces range*
predict p_delay_1410
predict st_delay_1410, stdp
outsheet using "predict2.csv", comma replace
log close 
*/
outsheet using "PSBP_Whole3.csv", comma replace	
//outsheet using "PSBP_12_Sample_Routes.csv", comma replace
//outsheet using "PSBP_Whole.csv", comma replace
/*{'HKG-BUD-CV',6-584-1-(1,11),   'HKG-BUD-QR',17-584-298-30,	
   'NBO-AMS-KL',6-995-1-1,  'NBO-AMS-MP',15-995-494-1,
   'NBO-AMS-SQ',19-995-496-1,'LHR-MAD-BA',5-827-1-1,
   'LHR-MAD-LH',13-827-423-23, 'LHR-MAD-LX',14-827-424-25,
   'FRA-ATL-CV',6-384-155-11,   'FRA-ATL-DL',8-384-156-1(15),
   'FRA-ATL-LH',13-384-158-1(23), 'CDG-SIN-AF',3-272-1-1, 
   'CDG-SIN-SQ',19-272-109-1(34) } */
