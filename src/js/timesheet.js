// laad jQuery
setTimeout(function () {
	jQuery.noConflict();
	(function ($) {
		var hoursId = "#TG_TOTALHOURS_";
		var earningsCodeId = "#txtTG_PAYCODEID_";
		var departmentId = "#txtTG_DEPARTMENTID_";
		var jobId = "#txtTG_WORKEDJOBID_";
		
		for (var i = 4; i <= 12; i += 2) {
			$(hoursId+i).val(8.00);
			$(departmentId+i).val(100011);
			$(jobId+i).val("AIS-ENG-1422");
		}	
	})(jQuery);
}, 4000)

