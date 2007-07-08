var Jobby;
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
	function shallowUpdate(obj, up) {
		if (up) {
			for (var i in up) {						
				obj[i] = up[i];
			}
		}
		return obj;			
	}
	function shallowProto(obj, up) { 
		var F = function F() {};
		F.prototype = obj;		
		return up?
			shallowUpdate(new F(), up):
			new F();
	}	
	function shallowCopy (obj, up) {		
		var copy = shallowUpdate({}, obj);
		return up?
			shallowUpdate(copy, up):
			copy;
	}
	function shallowClear(obj, up) {
		for (var i in obj) {
			delete obj[i];
		}
		return up?
			shallowUpdate(obj, up):
			obj;
	}
	function shallowEach(obj, f) {		
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
	function deepUpdate(obj, up) {
		console.debug("deepUpdate --", "obj:", obj, "up:", up || "NO! UP!");
		if (up) {
			for (var i in up) {			
				if (isObject(up[i])) {					
					if (isBasic(obj[i])) {				
						obj[i] = {};
					}
					deepUpdate(obj[i], up[i]);
				} else {
					obj[i] = up[i];
				}
			}
		}
		return obj;
	}
	function deepProto(obj, up) {
	    var p = shallowProto(obj);
	    for (var i in obj) {
			if (isObject(obj[i])) { 
	            p[i] = deepProto(obj[i]);
	        }
	    }
		return up?
			deepUpdate(p, up):
			p;	    
	}	
	function deepCopy (obj, up) {		
		var copy = deepUpdate({}, obj);		
		return up?
			deepUpdate(copy, up):
			copy;
	}
	function deepClear(obj, up) { 
		for (var i in obj) {
			if (!isObject(obj[i])) { 
				delete obj[i];
			} else {
				deepClear(obj[i]);
			}	
		}
		return up?
			deepUpdate(obj, up):
			obj;
	}	
	function deepEach(obj, f) {
		shallowEach(obj, function (key, val) {
			if (!isBasic(val)) {
				deepEach(val, f);	
			} 
		});
		return obj;
	}	
	// The Jobby function returns a function that wraps extra functionality around obj
	Jobby = (function () {
		// Updates the object and returns self if and object is passed
		// If nothing passed, returns its object.
		var Jobby_instance = function (up) {
			if (up === undefined) {					
				return this.obj; 									
			} else {					
				deepUpdate(this.obj, up)
				return this;
			}
		};
		// create a new Jobby		
		var create_Jobby = function (obj) {
			var new_Jobby;
			new_Jobby = function (up) {
				return Jobby_instance.call(new_Jobby, up)
			}
			new_Jobby.obj = obj || {};
			return new_Jobby;
		};
		return create_Jobby;
	})();	
	
	// add basic functionality to Function.protype	
	shallowUpdate(Function.prototype, {
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
		shallowUpdate: function (up) {		
			shallowUpdate(this.obj, up);
			return this;
		},
		shallowProto: function (up) {
			return Jobby(shallowProto(this.obj, up));			
		},		
		shallowCopy: function (up) {
			return Jobby(shallowCopy(this.obj), up);							
		},
		shallowClear: function (up) {
			shallowClear(this.obj, up); 
			return this;	
		}, 			
		each: function (f) {
			shallowEach(this.obj, f);
			return this;
		},
		//deep functions
		update: function (up) {
			deepUpdate(this.obj, up);
			return this;
		},
		proto: function (up) {	
			return Jobby(deepProto(this.obj, up));
		},		
		copy: function (up) {
			return Jobby(deepCopy(this.obj, up));			
		},
		clear: function (up) {
			deepClear(this.obj, up); 
			return this;
		},
		deepEach: function (f) {
			deepEach(this.obj, f);
			return this;
		}
	});	
	// make original functions globally available using Jobby as a namespace
	Jobby.isObject = isObject;
	Jobby.isFunction = isFunction;
	Jobby.isBasic = isBasic;
	// shallow functions
	Jobby.shallowUpdate = shallowUpdate;
	Jobby.shallowProto = shallowProto;	
	Jobby.shallowCopy = shallowCopy;
	Jobby.shallowClear = shallowClear;
	Jobby.each = shallowEach;
	// deep functions
	Jobby.update = deepUpdate;
	Jobby.proto = deepProto;	
	Jobby.copy = deepCopy;
	Jobby.clear = deepClear;
	Jobby.deepEach = deepEach;	
})();





