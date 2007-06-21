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

/*
// EXAMPLE
var func = function () {
	var f = function (tempOpts) {
		var opts = f.temp(tempOpts);
		// do stuff using opts...
		alert(opts.ding + " " + opts.ring);
	};
	return f.makeOpts({
		ding: "dong", 
		ring: "wrong"
	});
}();
**What about doing this??
	var f = function (tempOpts) {
		var opts = f.temp(tempOpts);
		// do stuff using opts...
		alert(opts.ding + " " + opts.ring);
	};
	f.makeOpts({
		ding: "dong", 
		ring: "wrong"
	});
//Options for func can now be used in three ways:
	//1) Use default options: 
		func(); //alerts "dong wrong"
	//2) Non-destructively use one or more different options until func.options.reset() is called:
		func.set({ding: "bling"});
		func(); // now alerts "bling wrong"
		func.reset(); 
		func(); // alerts "dong wrong"
	//3) Use options for one call only:
		func({ding: "bling"}); // alerts "bling wrong"
		func(); // alerts "dong wrong"		
*/

// Call an annonymous function right now and assign the result to Function.prototype.options
// Calling options creates a new options object
Function.prototype.makeOpts = function () {
	// Create prototype for augmenting functions with options and funtions for options.
	var optsProto = {
		defaultOpts: {},
		opts: {},
		temp: function (tempOpts) {
			var opts = deepCopy(this.opts);
			return deepExtend(opts, tempOpts || {});			
		},
		set: function (opts) {
			deepExtend(this.opts, opts);
		},
		reset: function () {		
			clear(this.opts);
		},
	};	
	// f.options({...}) creates options for a function and returns f.
	// Adds temp, set, and reset methods
	return function (defaultOpts) {
		extend(this, optsProto); 
		this.defaultOpts = defaultOpts;
		this.currentOpts = deepProto(defaultOpts);
		return this;
	}
}();
// proto() is an exact copy of Douglass Crockford's object() function (Mochikit's clone() function is very similar)
// Create a new object and set its prototype property to o.
function proto(o) {
	var F = function F() {};
	F.prototype = o;
	return new F();
}
// Extends an o
function extend(o, obj) {
	for (var i in o) {
		o[i] = obj[i];
	}
	return o;
}
function copy(o) {
	return extend({}, o);
}
function clear(o) {
	for (var i in o) {
		delete o[i];
	}
	return o;
}
// Create a new object who's prototype property at every leaf is set to the cooresponding leaf of o.
// Why? So you can change any leaf of the resulting object without affecting the original object, o.
function deepProto(o) {
    var obj = proto(o);
    for (var i in o) {
		// what about functions? Function can have properties too. 
		// I think functions would have to be handled differently.
		// The function itself should not be proto'ed...
		// ... but its attributes should be? I'm not sure this can work.
		// Why? Because functoins don't have prototypes like objects.
        if (typeof o[i] === 'object') { 
            obj[i] = deepProto(o[i]);
        }
    }
    return obj;
}
// go out to every leaf of o and add a cooresponding leaf in obj
// You can change any leaf of obj without affecting o and vise-versa. 
function deepExtend(o, obj) {
	for (var i in obj) {
		if (typeof obj[i] === 'object') {
			deepExtend(o[i], obj[i]);	
		}
		o[i] = obj[i];				
	}
	return o;
}
function deepCopy(o) {
	return deepExtend({}, o);	
}