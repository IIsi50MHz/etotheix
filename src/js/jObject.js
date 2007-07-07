var jObject;
var OBJ;
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
	// The jObject function returns a function that wraps extra functionality around obj
	jObject = function (obj) {
		// create a new jObject		
		var new_jObject = proto(obj);
		// add add wrapped object to new jObject
		new_jObject.obj = obj;
		// add jObject functionality ot new jObject
		update(new_jObject, jObject.augment);		
		return new_jObject;			
	};	
	
	jObject.each = each;
	jObject.update = update;
	
	// This function allows you to add functionality to all subsequently created jObjects
	jObject.augment = function (obj) {				
		update(jObject.augment, obj);					
	};
	
	// add basic functionality to jObject
	jObject.augment({
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
			return update(this.obj, obj || {});
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
	OBJ = function (obj) {
		if (obj) {
			OBJ.obj = obj;
			return OBJ;
		}
		return OBJ.obj;
	}
	OBJ.obj = {};
	update(OBJ, {
		// shallow functions
		proto: function (obj) {
			var F = function F() {};
			F.prototype = this.obj;
			return OBJ(new F()).update(obj || {});
		},
		update: function (obj) {		
			update(this.obj, obj || {});
			return this;
		},
		copy: function (obj) {
			var copy = update({}, this.obj);
			return OBJ(copy).update(obj || {});
		},
		clear: function (obj) {
			clear(this.obj);
			return update(this.obj, obj || {});
		}, 			
		each: function (f) {
			each(this.obj, f);
			return this;
		},
		//deep functions
		deepProto: function (obj) {			
			return OBJ(deepProto(this.obj)).deepUpdate(obj);
		},
		deepUpdate: function (obj) {
			deepUpdate(this.obj, obj);
			return this;
		},
		deepCopy: function (obj) {
			var copy = deepUpdate({}, this.obj);					
			return OBJ(copy).deepUpdate(obj);		
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




