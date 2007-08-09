// load jQuery
if (!jQuery) {
	var s = document.createElement('script');
	s.setAttribute('src', 'http://jquery.com/src/jquery-latest.js');
	document.getElementsByTagName('body')[0].appendChild(s);
}
// get rid of scroll bars
s.onload = function () {	
	jQuery("body").css("overflow", "hidden");
}