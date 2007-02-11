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
var func = function () {
	var defaultOpts = {ding: "dong", ring: "wrong"};
	var f = function (tempOpts) {
		var opts = f.options.temp(tempOpts);
		// do stuff using opts...
		alert(opts.ding + " " + opts.ring);
	};	
	return f.options(defaultOpts);
}();
Options for func can now be used in three ways:
	1) Use default options: 
		func(); //alerts "dong wrong"
	2) Non-destructively use one or more different options until func.options.reset() is called:
		func.options.set({ding: "bling"});
		func(); // now alerts "bling wrong"
		func.options.reset(); 
		func(); // alerts "dong wrong"
	3) Use options for one call only:
		func({ding: "bling"}); // alerts "bling wrong"
		func(); // alerts "dong wrong"		
*/
// Call executeOnce right now and assign the result to options
// Calling options creates a new options object
Function.prototype.options = function once() {
	// Create prototype for options objects
	var optsProto = {
		_defaultOpts: {},
		_currentOpts: {},
		temp: function (tempOpts) {
			var opts = deepCopy(this._currentOpts);
			return deepExtend(opts, tempOpts || {});			
		},
		set: function (opts) {
			deepExtend(this._currentOpts, opts);
		},
		reset: function () {		
			this._currentOpts = deepProto(this._defaultOpts);
		}	
	};
	
	// Return a function and assign it to options
	// (This gets executed only once)
	return function (defaultOpts) {
		this.options = deepProto(optsProto); 
		this.options._defaultOpts = defaultOpts; // Ideally, this would be hidden
		this.options._currentOpts = deepProto(defaultOpts);
		return this;
	}	
}();
// Example of use of options objects
var func = function () {
	var f = function (tempOpts) {
		var opts = f.options.temp(tempOpts);
		// do stuff using opts...
		alert(opts.ding + " " + opts.ring);
	};
	return f.options({
		ding: "dong", 
		ring: "wrong"
	});
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