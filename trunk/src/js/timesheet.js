// laad jQuery
setTimeout(function () {
	jQuery.noConflict();
	(function ($) {
		var hoursId = "#TG_TOTALHOURS_";
		var earningsCodeId = "#txtTG_PAYCODEID_";
		var departmentId = "#txtTG_DEPARTMENTID_";
		var jobId = "#txtTG_WORKEDJOBID_";
		
		for (var i = 2; i <= 6; i++) {
			$(hoursId+i).val(8.00);			
			$(jobId+i).val("AIS-ENG-1422");
		}	
	})(jQuery);
}, 4000)

