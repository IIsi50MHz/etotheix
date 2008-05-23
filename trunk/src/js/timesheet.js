var hoursId = "TG_TOTALHOURS_";
var earningsCodeId = "txtTG_PAYCODEID_";
var departmentId = "txtTG_DEPARTMENTID_";
var jobId = "txtTG_WORKEDJOBID_";
		
for (var i = 4; i <= 12; i += 2) {
	hours = document.getElementById(hoursId+i).value = 8.00;		
	document.getElementById(departmentId+i).value = 100011;
	document.getElementById(jobId+i).value = "AIS-ENG-1422";			
}	