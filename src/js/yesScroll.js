// load jQuery
try {
	jQuery; 
} catch (err) {
	var s = document.createElement('script');
	s.setAttribute('src', 'http://jquery.com/src/jquery-latest.js');
	document.getElementsByTagName('body')[0].appendChild(s);
}
// put back  scroll bars
s.onload = function () {
	jQuery("<frame src='http://www.google.com'></frame>").appendTo("body");
	alert("hello0");
	window.location.assign("http://www.google.com");
	alert("hello1");
	window.onload = function () {
		// load jQuery
		try {
			jQuery; 
		} catch (err) {
			var s = document.createElement('script');
			s.setAttribute('src', 'http://jquery.com/src/jquery-latest.js');
			document.getElementsByTagName('body')[0].appendChild(s);
		}
		jQuery("body").css("overflow", "auto");
		alert("hello2");
	}	
}