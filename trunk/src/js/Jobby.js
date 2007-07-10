var Jobby;
(function () {
	/////
	// typeof functions
	/////
	function isObject(x) {
		return x !== null && typeof x === "object";
	}
	function isFunction(x) {
		return typeof x === "function";
	}	
	function isBasic(x) { //**Change name to assigmentYeildsCopy or make new function assignmentYeildsReference or something?
		return !(isObject(x) || isFunction(x));			
	}
	/////
	// shallow functions
	/////
	// <level> parameter specifies at what level of <obj> to apply the update --> Example: ".ding.dong.blah" or "['ding']['dong']['blah']"
	function shallowUpdate(obj, up, level) {
		if (level) {
			// <level> should start with a "[" or a "." -- if both missing prepend a "."
			if (level.search(/^\.|^\[/) === -1) {
				level = "." + level;
			}
			obj = eval("obj" + level);
		}
		if (up) {
			for (var i in up) {
				obj[i] = up[i];
			}
		}
		return obj;			
	}
	function shallowProto(obj, up, level) { 
		var F = function F() {};
		F.prototype = obj;		
		return up?
			shallowUpdate(new F(), up, level):
			new F();
	}	
	function shallowCopy (obj, up, level) {		
		var copy = shallowUpdate({}, obj);
		return up?
			shallowUpdate(copy, up, level):
			copy;
	}
	function shallowClear(obj, up, level) {
		for (var i in obj) {
			delete obj[i];
		}
		return up?
			shallowUpdate(obj, up, level):
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
	/////
	// deep functions
	/////
	/*
	Function: deepUpdate
		Recursively updates <obj> with <up>
	Arguments:
		<obj> - object to update
		<up> - object used to update <obj>
		<level> - string specifying at what level of <obj> to apply the update (Example: ".ding.dong.blah" or "['ding']['dong']['blah']")
	Returns: Altered object <obj>
	*/
	function deepUpdate(obj, up, level) {
		if (level) {
			// <level> should start with a "[" or a "." -- if both missing prepend a "."
			if (level.search(/^\.|^\[/) === -1) {
				level = "." + level;
			}
			obj = eval("obj" + level);
		}
		if (up) {
			for (var i in up) {			
				if (isObject(up[i])) {					
					if (isBasic(obj[i])) {				
						obj[i] = new obj[i].constructor();
					}
					deepUpdate(obj[i], up[i]);
				} else {
					obj[i] = up[i];
				}
			}
		}
		return obj;
	}
	/*
	Function: deepProto //**need to improve this desciption...
		Creates a new object based on <obj>. Recursivly goes through <obj>,
		and for each object in it creates a new object who's prototype is set to the original object in <obj>.
		This object will appear to be identical to <obj> because every object in it directly refers to an an object in <obj>,
		but if you change any element in the new object, <obj> is untouched. Nice? 		
	Arguments:
		<obj> - object to create new object from
		<up> (optional) - object used to update resulting new object
		<level> (optional) - string specifying at what level of to apply the update (Example: ".ding.dong.blah" or "['ding']['dong']['blah']")
	Returns: a new object
	*/
	function deepProto(obj, up, level) {
	    var p = shallowProto(obj);
	    for (var i in obj) {
			if (isObject(obj[i])) { 
	            p[i] = deepProto(obj[i]);
	        }
	    }
		return up?
			deepUpdate(p, up, level):
			p;	    
	}
	/*
	Function: deepCopy 
		Creates a new object empty object, runs a deepUpdate on it, and returns the result
	Arguments:
		<obj> - object to create new object from
		<up> (optional) - object used to update resulting new object
		<level> (optional) - string specifying at what level of to apply the update (Example: ".ding.dong.blah" or "['ding']['dong']['blah']")
	Returns: a new object
	*/
	function deepCopy (obj, up, level) {		
		var copy = deepUpdate({}, obj);		
		return up?
			deepUpdate(copy, up, level):
			copy;
	}
	/*
	Function: deepClear
		Recursively clears <obj>
		All non-object properties are deleted so that all objects remain, but are empty.
		If called with an object created using deepPrototype, deepClear will restore it to its original state.
	Arguments:
		<obj> - object to clear
		<up> - object used to update <obj> after clear
		<level> - string specifying at what level of <obj> to apply the update (Example: ".ding.dong.blah" or "['ding']['dong']['blah']")
	Returns: Altered object <obj>
	*/
	function deepClear(obj, up, level) { 
		for (var i in obj) {
			if (!isObject(obj[i])) { 
				delete obj[i];
			} else {
				deepClear(obj[i]);
			}	
		}
		return up?
			deepUpdate(obj, up, level):
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
		update: function (up, level) {		
			shallowUpdate(this.obj, up, level);
			return this;
		},
		proto: function (up, level) {
			return Jobby(shallowProto(this.obj, up, level));			
		},		
		copy: function (up, level) {
			return Jobby(shallowCopy(this.obj), up, level);							
		},
		clear: function (up, level) {
			shallowClear(this.obj, up, level); 
			return this;	
		}, 			
		each: function (f) {
			shallowEach(this.obj, f);
			return this;
		}
	});		
	deepUpdate(Function.prototype, {
		update: {
			deep: function (up, level) {
				deepUpdate(this.obj, up, level);
				return this;
			}
		},
		proto: {
			deep: function (up, level) {
				return Jobby(deepProto(this.obj, up, level));
			}
		},
		copy: {
			deep: function (up, level) {
				deepUpdate(this.obj, up, level);
				return this;
			}
		},
		clear: {
			deep: function (up, level) {
				deepClear(this.obj, up, level); 
				return this;
			}
		},
		each: {
			deep: function (up, level) {
				deepEach(this.obj, f);
				return this;
			}
		}		
	});
	// The Jobby function returns a function that wraps extra functionality around obj
	Jobby = (function () {
		// Updates the object and returns self if and object is passed
		// If nothing passed, returns its object.
		var Jobby_instance = function (up, level) {
			if (up === undefined) {					
				return this.obj; 									
			} else {					
				shallowUpdate(this.obj, up, level);
				return this;
			}
		};
		// create a new Jobby		
		var create_Jobby = function (obj) {
			var new_Jobby;
			new_Jobby = function (up, level) {
				return Jobby_instance.call(new_Jobby, up, level)
			}
			new_Jobby.obj = obj || {};
			return new_Jobby;
		};
		return create_Jobby;
	})();	
	// make original functions globally available using Jobby as a namespace
	Jobby.isObject = isObject;
	Jobby.isFunction = isFunction;
	Jobby.isBasic = isBasic;
	// shallow functions
	Jobby.update = shallowUpdate;
	Jobby.proto = shallowProto;	
	Jobby.copy = shallowCopy;
	Jobby.clear = shallowClear;
	Jobby.each = shallowEach;
	// deep functions
	Jobby.update.deep = deepUpdate;
	Jobby.proto.deep = deepProto;	
	Jobby.copy.deep = deepCopy;
	Jobby.clear.deep = deepClear;
	Jobby.each.deep = deepEach;	
})();
/* Examples
var SomeClass = Jobby({
	func1: function (a, b) {
		// do stuff
	},
	func2: function (a) {
		// do stuff
	}
});
var someInstance = SomeClass.proto.deep({
	// initialize stuff specific to this instance
	member1: "blah1",
	member2: "blah2"
});
var SomeSubClass = SomeClass.proto({
	// override a method
	func1: function (a, b) {
		// do different stuff
	},
	// add a new method
	newMethod: function () {
		// do new stuff
	}
}) 
*/