var jObject = (function () {
	// Why? So you can change any leaf of the resulting object without affecting the original object, o.
	function proto(o) {
	    var obj;
		var F = function F() {};
		F.prototype = o;
		obj = new F();
	    for (var i in o) {
			// what about functions? Function can have properties too. 
			// I think functions would have to be handled differently.
			// The function itself should not be proto'ed...
			// ... but its attributes should be? I'm not sure this can work.
			// Why? Because functoins don't have prototypes like objects.
	        if (typeof o[i] === 'object') { 
	            obj[i] = proto(o[i]);
	        }
	    }
	    return obj;
	}
	// go out to every leaf of o and add a cooresponding leaf in obj
	// You can change any leaf of obj without affecting o and vise-versa. 
	function extend(o, obj) {
		for (var i in obj) {
			if (typeof obj[i] === 'object') {
				extend(o[i], obj[i]);	
			}
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
	
	// holds properties for augmenting Object.prototype
	var augmentObj;
	// holds reference to current object
	var currentObj;
	// 
	var augmentIsOn = false;
	var origPrototype = copy(Object.prototype);	
	var jObject = function (x, isOn) 
		// If x is an object, update current object
		if (typeof x === "object") {
			currentObj = x;
			return jObject;
		// If x is a function...
		} else if (typeof x === "function") {
			// Use original Object.prototype
			if (isOn === false) {
				augmentIsOn = false;
				clear(Object.prototype);
				extend(Object.prototype, origPrototype);				
				x();				
				extend(Object.prototype, augmentObj);
			// Use augmented Object.prototype
			} else {
				augmentIsOn = true;
				extend(Object.prototype, augmentObj);
				x();
				clear(Object.prototype);
				extend(Object.prototype, origPrototype);				
			}
		// Turn on Object.prototype augmentation
		} else if (x === true) {
			augmentIsOn = true;
			extend(Object.prototype, augmentObj);				
		// Turn off Object.prototype augmentation
		} else if (x === false) {
			augmentIsOn = false;
			clear(Object.prototype);
			extend(Object.prototype, origPrototype);
		}
	};
	// add fuctionality to jObject and Object.prototypejObject
	jObject.augment = function (obj) {
		extend(augmentObj, obj);
		// update Object.prototype right away of aumentation is currently on.
		if (augmentIsOn) {			
			extend(Object.prototype, augmentObj);
		}
		for (i in obj) {
			if (typeof obj === "function") {			
				jObject[i] = function () {
					augmentObj[i].apply(currentObj, arguments);
				}
			}
		}
	};
	
	jObject.augment({
		proto: function () {return proto(this);},
		copy: function () {return copy(this);},
		extend: function (obj) {return extend(this, obj);},
		clear: function () {return clear(this);}
	});
	
	return jObject;
})();
////////////////////
// 2nd try...
// returns a jObject
var jObject = (function () {
	// Why? So you can change any leaf of the resulting object without affecting the original object, o.
	function proto(o) {
	    var obj;
		var F = function F() {};
		F.prototype = o;
		obj = new F();
	    for (var i in o) {
			// what about functions? Function can have properties too. 
			// I think functions would have to be handled differently.
			// The function itself should not be proto'ed...
			// ... but its attributes should be? I'm not sure this can work.
			// Why? Because functoins don't have prototypes like objects.
	        if (typeof o[i] === 'object') { 
	            obj[i] = proto(o[i]);
	        }
	    }
	    return obj;
	}
	// go out to every leaf of o and add a cooresponding leaf in obj
	// You can change any leaf of obj without affecting o and vise-versa. 
	function extend(o, obj) {
		for (var i in obj) {
			if (typeof obj[i] === 'object') {
				extend(o[i], obj[i]);	
			}
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
	
	
	
	/* Examples
		var king = {a: 1, b: 2, c: 3}
		var ding = jObject(king); // ding.obj == king
		ding("a"); // returns ding.obj.a 
		ding("a", "boo"); // ding.obj.a == "boo"; returns ding
		ding({a: "hello"}); // ding.obj.a == "hello"; returns ding
		var dong = ding(); // dong is a new jObject derived from ding. That is, dong.obj.prototype = ding.obj = king		
	*/
	var jObject = function (obj)  {
		// create a new jObject object
		var new_jObject = proto(jObject.prototype);		
		new_jObject.obj = typeof obj === "object" ? obj : {};
		var f = function (x, y) {		
			xIsObject = typeof x === "object";
			xIsString = typeof x === "string";						
			xIsDefined = !!x;
			yIsDefined = !!y;			
			// If x is an object, update new_jObject
			if (xIsObject) {				
				return extend(new_jObject.obj, x);
			// If x is a string, treat it as a key for the object
			} else if (xIsString) {
				if (yIsDefined) {
					// set the x property to y
					new_jObject.obj[x] = y;
					return new_jObject;
				} else {
					// just return the value of the x property 
					return new_jObject.obj[x];
				}
			// if no arguments are passed, return a new jObject with the current jObject.obj used as the prototype for a new jObject.obj
			} else if (!xIsDefined) {
				derived_jObject = jObject();
				derived_jObject.obj = proto(new_jObject.obj);
				return derived_jObject;
			} else {
				return new_jObject;
			}
		};
		f.obj = new_jObject.obj;		
		return f;
	};
	// add fuctionality to jObject and Object.prototypejObject
	jObject.augment = function (x) {
		for (i in x) {
			if (typeof x[i] === "function") {			
				// bind all functions to this.obj
				jObject.prototype[i] = function () {
					x[i].apply(this.obj, arguments);
				}
			} else {
				jObject.prototype[i] = x[i];
			}
		}
	};
	// add basic functionality to jObject...
	jObject.augment({
		obj: {},
		proto: function () {return proto(this);},
		copy: function () {return copy(this);},
		extend: function (obj) {return extend(this, obj);},
		clear: function () {return clear(this);}	
	});
	
	return function (obj) {
		if (typeof obj === "object") {
			return extend(this.obj, obj)
		} else if (typeof obj === "string") {
			
		}
	};
})();

////////// Another attempt
var ding = {};
var dong = {};
var blah = jObject(ding); // creates a new jObject; returns a function
blah(dong); // augments the ding object
blah()

var jObject = (function ()  {
	// helper function
	each(obj, f) {
		for (var i in obj) {
		for (var i in obj) {
			if (typeof obj === "function") {
				if (Function.prototype[i] === undefined) {
					f(obj[i]);
				}
			} else {
				if (Array.prototype[i] === undefined && Object.prototype[i] === undefined) {
					f(obj[i]);
				}
			}
		}
		return obj;
	}
	// helper function for extending objects
	var extend = function (o, obj) {
		return each(obj, function () {
			o[i] = obj[i];	
		})		
	};
	// public function for augmenting jObjects
	var jObject.augment = function (obj) {		
		for (var i in obj) {
			if (typeof obj[i] === "function") {				
				// bind all functions to this.obj
				augment_jObject[i] = function () {
					obj[i].apply(this.obj, arguments);
					return this;
				}
			} else {
				augment_jObject[i] = obj[i];				
			}
		}
		return jObject.augment;
	};	
	// function for extending a jObject's wrapped object
	var extend_jObject = function (jObj, obj) {
		extend(jObj.obj, obj);
		return jObj;
	};
	
	// return a function that creates the jObject
	return function (obj) {		
		// Create a new jObject
		// A jObject is a function returns the wrapped object
		var new_jObject = function (obj) {
			obj = obj || {};			
			extend_jObject(new_jObject, obj);
			return new_jObject.obj;
		}	
		// Add add wrapped object to new jObject
		new_jObject.obj = obj;
		// Add jObject functionality ot new jObject
		extend(new_jObject, jObject.augment);
		
		return new_jObject;	
	};	
})();

jObject.augment({
	proto: function () {
		var F = function F() {};
		F.prototype = this;
		var obj = new F();		
	},		
	extend: function (obj) {
		for (var i in obj) {
			this[i] = obj[i];
		}
		return this;
	},
	copy: function () {
		return extend({}, this);
	},
	clear: function () {
		for (var i in this) {
			delete this[i];
		}
		return this;
	}, 
	each: function (f) {
		for (var i in this) {
			if (typeof this === "object") {
				if (Array.prototype[i] === undefined && Object.prototype[i] === undefined) {
					f(this[i]);
				}				
			} else if (typeof this === "function") {
				if (Function.prototype[i] === undefined) {
					f(this[i]);
				}
			}
		}
		return this;
	}
});


