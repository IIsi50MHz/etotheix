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
	function shallowUpdate(o, obj) {
		shallowEach (obj, function (key, val) {
			o[key] = val;
		});		
		return o;
	}
	function shallowProto(obj) {
		var F = function F() {};
		F.prototype = obj;
		return new F();
	}	
	function shallowCopy (obj) {
		return shallowUpdate({}, obj);		
	}
	function shallowClear(obj) {
		for (var i in obj) {
			delete obj[i];
		}
		return obj;
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
	function deepProto(obj) {
	    var o = shallowProto(obj);
	    for (var i in obj) {
			if (isObject(obj[i])) { 
	            o[i] = deepProto(obj[i]);
	        }
	    }
	    return o;
	}	
	function deepCopy (obj) {
		var deepCopy = deepUpdate({}, this.obj);					
		return deepUpdate(deepCopy, obj);	
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
		shallowEach(obj, function (key, val) {
			if (!isBasic(val)) {
				deepEach(val, f);	
			} 
		});
		return obj;
	}
	// make above functions above globally using Jobby as a namespace
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
	// The Jobby function returns a function that wraps extra functionality around obj
	Jobby = (function () {
		// Updates the object and returns self if and object is passed
		// If nothing passed, returns its object.
		var Jobby_instance = function (o) {
			if (o === undefined) {					
				return this.obj; 									
			} else {					
				deepUpdate(this.obj, o)
				return this;
			}
		};
		// create a new Jobby		
		var create_Jobby = function (obj) {
			var new_Jobby;
			new_Jobby = function (o) {
				return Jobby_instance.call(new_Jobby, o)
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
		shallowUpdate: function (obj) {		
			shallowUpdate(this.obj, obj || {});
			return this;
		},
		shallowProto: function (obj) {
			var o = shallowProto(this.obj);
			return obj? 
				Jobby(shallowUpdate(o, obj)): 
				Jobby(o);	
		},		
		shallowCopy: function (obj) {
			var o = shallowCopy(this.obj);
			return obj? 
				Jobby(shallowUpdate(o, obj)): 
				Jobby(o);	
		},
		shallowClear: function (obj) {
			shallowClear(this.obj); 
			return obj? 
				shallowUpdate(o, obj): 
				this;	
		}, 			
		each: function (f) {
			shallowEach(this.obj, f);
			return this;
		},
		//deep functions
		update: function (obj) {
			deepUpdate(this.obj, obj);
			return this;
		},
		proto: function (obj) {	
			var o = deepProto(this.obj);
			return obj? 
				Jobby(deepUpdate(o, obj)): 
				Jobby(o);						
		},		
		copy: function (obj) {
			var o = deepCopy(this.obj);
			return obj? 
				Jobby(deepUpdate(o, obj)): 
				Jobby(o);			
		},
		clear: function (obj) {
			deepClear(this.obj); 
			return obj? 
				deepUpdate(o, obj): 
				this;	
		},
		deepEach: function (f) {
			deepEach(this.obj, f);
			return this;
		}
	});	
})();





