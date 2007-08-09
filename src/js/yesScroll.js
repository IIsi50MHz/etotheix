// load jQuery
var s = document.createElement('script');
s.setAttribute('src', 'http://jquery.com/src/jquery-latest.js');
s.onload = function () {
	document.getElementsByTagName('body')[0].appendChild(s);
	console.debug(jQuery("a"));
}