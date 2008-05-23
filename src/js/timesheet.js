// laad jQuery
var s=document.createElement('script');
s.setAttribute('src', 'http://jquery.com/src/jquery-latest.js');
document.getElementsByTagName('body')[0].appendChild(s);
jQuery.noConflict();
(function ($) {
	var hoursId = "#TG_TOTALHOURS_";
	var earningsCodeId = "#txtTG_PAYCODEID_";
	var departmentId = "#txtTG_DEPARTMENTID_";
	var jobId = "#txtTG_WORKEDJOBID_";
	
	for (var i = 4; i <= 12; i += 2) {
		$(hoursId+i).focus().val(8.00).keydown().keypress().change().blur();		
		$(departmentId+i).val(100011).focus().val(8.00).keydown().keypress().change().blur();
		$(jobId+i).val("AIS-ENG-1422").focus().val(8.00).keydown().keypress().change().blur();
	}	
})(jQuery);
