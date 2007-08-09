// load jQuery
var s = document.createElement('script');
s.setAttribute('src', 'http://jquery.com/src/jquery-latest.js');
document.getElementsByTagName('body')[0].appendChild(s);
s.onload = function () {	
	console.debug(jQuery("a"));
	alert("blah")
}