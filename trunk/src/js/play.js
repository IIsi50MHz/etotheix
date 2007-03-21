// A wrapper for extending javascript objects' functionality (kind of like how jQuery extends the functionality of the DOM)
var jObject = function () {
	var objProto = {
		o: {},
		type: "jObject",
		proto: function () {
			function F();
			F.prototype = this.o;
			return new F();
		},
		protoTree: function () {},
		extend: function (obj) {
			if (obj.type === "jObject") {
				obj = obj.o;
			}
						
		},
		extendTree: function (obj) {}
	}	
	
	// perminent adaptor
	return function (o) {
		if (o.type === "jObject") {
			return o;
		} else {
			// Create adaptor for an object
			var obj = objProto.proto(objProto);			
			// Adapt the object and return it
			obj.o = o || {};
			return obj;
		}
	}	
}();

var jObject = function () {
	var o;
	var objProto = {
		proto: function () {
			function F();
			F.prototype = o;
			return new F();
		},
		protoTree: function () {},
		extend: function (obj) {},
		extendTree: function (obj) {}
	}	
	
	// temporary adaptor. Chainability is gone.
	return function (obj) {		
		o = obj;
		return jObject;
	}
}();


Function.createPattern = function once() {	
	// Function for creating pattern functions
	var createPattern = function (funcs) {
		// make sure funcs exists before trying to access any attributes
		var before = funcs && funcs.before; 
		var after = funcs && funcs.after;

		// This new function, f(), is returned whenever Function.createPattern() is called
		// f() is bound to the before() and after() functions that are passed ot Function.createPattern() 
		var f = function () {
			if (before) {
				// a fuction to always execute before everything else
				before.apply(f, arguments);
			}
			// Execute each function only if the corresponding pattern function returns true (or truthy)
			for (var i in f.patt) {
				if (f.patt[i].apply(f, arguments)) {
					f.func[i].apply(f, arguments);				
				}
			}
			if (after) {
				// a fuction to always execute after everything else
				after.apply(f, arguments);
			}
		};
		// bind f.pattern() to the local function pattern() 
		// function for adding patterns and their corresponding functions
		f.pattern = pattern;
		// create array for holding pattern functions
		f.patt = [];
		// create coorsponding array for holding functions to execute
		f.func = [];
		
		return f;
	};
	
	// function for adding patterns and their corresponding functions
	// This is created only once.
	var pattern = function (patt, func) {
		this.patt.push(patt);
		this.func.push(func);	
	};	
	
	return createPattern;
}();
// Expample
var f = Function.createPattern();
f.pattern(
	function (x) {
		return x >= 3;
	}, 
	function (x) {
		alert("x >= 3!");
	}
);
f.pattern(
	function (x) {
		return x <= 3;
	}, 
	function (x) {
		alert("x <= 3!");
	}
);
f.pattern(
	function (x) {
		return x === 3;
	}, 
	function (x) {
		alert("x = 3!");
	}
);

var $ = {};
$.o = jObject;

var obj = $.o({}).proto();
$.o(obj).extend({})

obj.o

var am = [
	"concat",
	"join",
	"pop",
	"push",
	"reverse",
	"shift",
	"slice",
	"sort",
	"splice",
	"unshift"
]


var o = {};
o.length = 0;
for (var i in am) {
	o[am[i]] = function () {return [][am[i]].apply(this, arguments);};
}