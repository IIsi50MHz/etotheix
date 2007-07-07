var jObject;
(function () {
	/////
	// helper functions	
	/////
	
	function isObject(x) {
		return x !== null && typeof x === "object";
	}
	function isFunction(x) {
		return typeof x === "function";
	}
	function isBasic(x) {
		return typeof x === "string" || typeof x === "number" || typeof x === "boolean" || typeof x === "undefined" || typeof x === null || typeof x !== typeof x;
	}
	// Function for iterating over objects
	function each(obj, f) {		
		var thisObj = obj;		
		for (var i in thisObj) {
			if (isObject(thisObj)) {
				if (Array.prototype[i] === undefined && Object.prototype[i] === undefined) {
					f(i, thisObj[i]);
				}				
			} else if (isFunction(thisObj)) {
				if (Function.prototype[i] === undefined) {
					f(i, thisObj[i]);
				}
			}						
		}
		return this;
	}
	// Functions extending objects
	function extend(o, obj) {		
		each (obj, function (key, val) {
			o[key] = val;
		})
		return o;
	}
	function deepExtend(o, obj) {
		for (var i in obj) {
			if (isObject(obj[i])) {	
				if (!isObject(o[i])) {				
					o[i] = {};
				}
				deepExtend(o[i], obj[i]);	
			} else {
				o[i] = obj[i];
			}
		}
		return o;
	}
	// Functions creating new objects
	function proto(obj) {
		var F = function F() {};
		F.prototype = obj;
		return new F();
	}
	function deepProto(obj) {
	    var o = proto(obj);
	    for (var i in obj) {
			if (isObject(obj[i])) { 
	            o[i] = deepProto(obj[i]);
	        }
	    }
	    return o;
	}
	// The jObject function returns a function that wraps extra functionality around obj
	jObject = function (obj) {
		// create a new jObject		
		var new_jObject = function (obj) {
			obj = obj || {};
			extend(new_jObject.obj, obj);
			return new_jObject.obj;
		};
		// add add wrapped object to new jObject
		new_jObject.obj = obj;		
		// add jObject functionality ot new jObject
		extend(new_jObject, jObject.augment);		
		return new_jObject;			
	};	
	
	jObject.each = each;
	jObject.extend = extend;
	
	// This function allows you to add functionality to all subsequently created jObjects
	jObject.augment = function (obj) {				
		extend(jObject.augment, obj);					
	};
	
	// add basic functionality to jObject
	jObject.augment({
		// shallow functions
		proto: function () {
			var F = function F() {};
			F.prototype = this.obj;
			return jObject(new F());
		},
		extend: function (obj) {		
			extend(this.obj, obj)
			return this;
		},
		copy: function (obj) {
			var copy = extend({}, this.obj);
			return jObject(extend(copy, obj));
		},
		clear: function (obj) {
			var thisObj = this.obj;
			for (var i in thisObj) {
				delete thisObj[i];
			}
			return this.extend(obj || {});
		}, 			
		each: function (f) {
			each(this.obj, f);
			return this;
		},
		//deep functions
		deepProto: function () {			
			return jObject(deepProto(this.obj));
		},
		deepExtend: function (obj) {
			deepExtend(this.obj, obj);
			return this;
		},
		deepCopy: function (obj) {
			var copy = deepExtend({}, this.obj);					
			return jObject(deepExtend(copy, obj));			
		},
		deepClear: function () {
			var thisObj = this.obj;
			for (var i in thisObj) {
				if (typeof thisObj[i] === 'object') { 
					obj[i] = this.deepClear(thisObj[i]);
				}
				delete thisObj[i];
			}
			return this.deepExtend(obj || {});
		},
		deepEach: function (f) {
			var thisObj = this.obj;
			each(thisObj, function (key, val) {
				if (typeof val === 'object') {
					deepEach(val, f);	
				}
			})			
		}
	});
})();

