var jObject;
(function () {	
	// typeof functions
	function isObject(x) {
		return x !== null && typeof x === "object";
	}
	function isFunction(x) {
		return typeof x === "function";
	}
	function isBasic(x) {
		return !(isObject(x) || isFunction(x));			
	}
	// shallow functions	
	function proto(obj) {
		var F = function F() {};
		F.prototype = obj;
		return new F();
	}
	function update(o, obj) {
		each (obj, function (key, val) {
			o[key] = val;
		});		
		return o;
	}
	function clear(obj) {
		for (var i in obj) {
			delete obj[i];
		}
		return update(this.obj, obj || {});
	}
	function each(obj, f) {		
		for (var i in obj) {
			if (!isBasic(obj)) {
				if (Array.prototype[i] === undefined && Function.prototype[i] === undefined) {
					f(i, obj[i]);
				}				
			}					
		}
		return obj;
	}
	// deep functions
	function deepProto(obj) {
	    var o = proto(obj);
	    for (var i in obj) {
			if (isObject(obj[i])) { 
	            o[i] = deepProto(obj[i]);
	        }
	    }
	    return o;
	}
	function deepUpdate(o, obj) {		
		for (var i in obj) {
			//console.debug("obj is object?", obj[i], isObject(obj[i]))
			if (isObject(obj[i])) {	
				//console.debug("obj is !basic?", o[i], !isBasic(o[i]));
				if (isBasic(o[i])) {				
					o[i] = {};
				}
				deepUpdate(o[i], obj[i]);
			} else {
				o[i] = obj[i];
			}
		}
		return o;
	}
	function deepClear(obj) {
		for (var i in obj) {
			if (!isObject(obj[i])) { 
				delete obj[i];
			} else {
				deepClear(obj[i]);
			}	
		}
		return obj;
	}
	
	function deepEach(obj, f) {
		each(obj, function (key, val) {
			if (!isBasic(val)) {
				deepEach(val, f);	
			} 
		});
		return obj;
	}
	// make above functions above globally using Object as a namespace
	Object.isObject = isObject;
	Object.isFunction = isFunction;
	Object.isBasic = isBasic;
	// shallow functions
	Object.proto = proto;
	Object.update = update;
	Object.copy = copy;
	Object.clear = clear;
	Object.each = each;
	// deep functions
	Object.deepProto = deepProto;
	Object.deepUpdate = deepUpdate;
	Object.deepCopy = deepCopy;
	Object.deepClear = deepClear;
	Object.deepEach = deepEach;
	// The jObject function returns a function that wraps extra functionality around obj
	jObject = (function () {
		// Updates the object and returns self if and object is passed
		// If nothing passed, returns its object.
		var jObject_instance = function (o) {
			if (o === undefined) {					
				return this.obj; 									
			} else {					
				deepUpdate(this.obj, o)
				return this;
			}
		};
		// create a new jObject		
		var create_jObject = function (obj) {
			var new_jObject;
			new_jObject = function (o) {
				return jObject_instance.call(new_jObject, o)
			}
			new_jObject.obj = obj || {};
			return new_jObject;
		};
		return create_jObject;
	})();	
	
	// add basic functionality to Function.protype	
	update(Function.prototype, {
		obj: {},
		isObject: function () {
			return isObject(this.obj);
		},
		isFunction: function () {
			return isFunction(this.obj);
		},
		isBasic: function () {
			return isBasic(this.obj);
		},
		// shallow functions		
		proto: function (obj) {
			var F = function F() {};
			F.prototype = this.obj;
			return jObject(new F()).update(obj || {});
		},
		update: function (obj) {		
			update(this.obj, obj || {});
			return this;
		},
		copy: function (obj) {
			var copy = update({}, this.obj);
			return jObject(copy).update(obj || {});
		},
		clear: function (obj) {
			clear(this.obj);
			return this.update(obj || {});
		}, 			
		each: function (f) {
			each(this.obj, f);
			return this;
		},
		//deep functions
		deepProto: function (obj) {			
			return jObject(deepProto(this.obj)).deepUpdate(obj);
		},
		deepUpdate: function (obj) {
			deepUpdate(this.obj, obj);
			return this;
		},
		deepCopy: function (obj) {
			var copy = deepUpdate({}, this.obj);					
			return jObject(copy).deepUpdate(obj);		
		},
		deepClear: function (obj) {
			deepClear(this.obj);
			return this.deepUpdate(obj || {});
		},
		deepEach: function (f) {
			deepEach(this.obj, f);
			return this;
		}
	});	
})();





