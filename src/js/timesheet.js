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
		$(hoursId+i).val(8);
		console.debug("adfasdf")
	}	
})(jQuery);
