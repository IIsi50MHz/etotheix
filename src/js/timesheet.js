var hoursId = "TG_TOTALHOURS_";
var earningsCodeId = "txtTG_PAYCODEID_";
var departmentId = "txtTG_DEPARTMENTID_";
var jobId = "txtTG_WORKEDJOBID_";
		
for (var i = 4; i <= 12; i += 2) {
	var hours = document.getElementById(hoursId+i);	
	var earningsCode = document.getElementById(departmentId+i);
	var department = document.getElementById(jobId+i);
	
	hours.value = "8.00";
	earningsCode.value = "100011";
	department.value = "AIS-ENG-1422";	
	
	hours.onchange();
	earningsCode.onchange();
	department.onchange();
}	