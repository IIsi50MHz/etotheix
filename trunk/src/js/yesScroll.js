// load jQuery
try {
	jQuery; 
} catch (err) {
	var s = document.createElement('script');
	s.setAttribute('src', 'http://jquery.com/src/jquery-latest.js');
	document.getElementsByTagName('body')[0].appendChild(s);
}
// get rid of scroll bars
s.onload = function () {	
	jQuery("body").css("overflow", "auto");
}