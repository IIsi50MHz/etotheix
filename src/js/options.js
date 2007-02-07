// Created Fall 2006
// Updated 2007.01.31
// Pruned 2007.02.06

/**
 * For creating functions with options.
 * @function options
 * @param {Object} defaultOpts >>> Typically an object literal 
 * @param {Function} f >>> Typically an annonymous function 
 * @return{Function} >>> Returns f with added options object 
 */
// EXAMPLE
/*
var func = options(
	{
		ding: "dong",
		ring: "wrong"
	}, 
	function f(args, tempOpts) {
		var opts = f.options.use(tempOpts);
		// do stuff using opts...
		alert(opts.ding + " " + opts.ring);
	}
);
Options for func can now be used in three ways:
	1) Use default options: 
		f(args); //alerts "dong wrong"
	2) Non-destructively use one or more different options until f.options.reset() is called:
		f.options.set({ding: "bling"})
		f(args); // now alerts "bling wrong"
		f.options.reset(); 
		f(args); // alerts "dong wrong"
	3) Use options for one call only:
		f(args, {ding: "bling"}); // alerts "bling wrong"
		f(args); // alerts "dong wrong"		
*/
var options = function () {
	var optsObj = {
		defaultOpts: {},
		currentOpts: {},
		use: function (tempOpts) {
			var opts = deepCopy(this.currentOpts);
			return deepExtend(opts, tempOpts || {});			
		},
		set: function (opts) {
			deepExtend(this.currentOpts, opts);
		},
		reset: function () {		
			this.currentOpts = deepProto(this.currentOpts);
		}	
	};
	return function (defaultOpts, f) {
		f.options = deepProto(optsObj);
		f.options.defaultOpts = defaultOpts;
		f.options.currentOpts = deepProto(defaultOpts);
		return f;
	}
}();


// proto() is an exact copy of Douglass Crockford's object() function (Mochit's clone() function is very similar)
// Create a new object and set its prototype property to o.
function proto(o) {
	var F = function F() {};
	F.prototype = o;
	return new F();
}
function extend(obj, o) {
	for (var i in o) {
		obj[i] = o[i];
	}
	return obj;
}
function copy(o) {
	return extend({}, o);
}

// Create a new object who's prototype property at every leaf is set to the cooresponding leaf of o.
// Why? So you can change any leaf of the resulting object withoug affecting the original object, o.
function deepProto(o) {
    var obj = proto(o);
    for (var i in o) {
        if (typeof o[i] === 'object') {
            obj[i] = deepProto(o[i]);
        }
    }
    return obj;
}
// go out to every leaf of o and create a cooresponding leaf in obj
// You can change any leaf of obj without affecting o.
function deepExtend(obj, o) {
	for (var i in o) {
		if (typeof o[i] === 'object') {
			deepExtend(obj[i], o[i]);	
		}
		obj[i] = o[i];				
	}
	return obj;
}
function deepCopy(o) {
	return deepExtend({}, o);	
}