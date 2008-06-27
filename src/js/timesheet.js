(function () {
	var hoursId = "TG_TOTALHOURS_";
	var earningsCodeId = "txtTG_PAYCODEID_";
	var departmentId = "txtTG_DEPARTMENTID_";
	var jobId = "txtTG_WORKEDJOBID_";
	
	for (var i = 2; i <= 6; i++) {
		document.getElementById(hoursId+i).value = "8.11";			
		document.getElementById(jobId+i).value = "AIS-ENG-1422";
	}	
})();

