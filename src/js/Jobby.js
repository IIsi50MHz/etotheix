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
	function deepUpdate(obj, up, level) { //**should change this to use new objects with prototypes of object instead of copying all members... ****done, but not tested.
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
					obj[i] = deepProto(up[i]);			
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
	function deepCopy (obj, up, level) { //** With changes made to deepUpdate, is this now the same as deepProto??? ****I think it's a little different... I think the copy has no prototype at the top level, so a shallowClear will result in an empty object.
	//**I think there's a problem here now. Changing <obj> will change the copy.... ****I think we need to bring back the old deepUpdate that doesn't use deepProto... we want to keep the new version to. How do we name them?
	//**For deep copy... first use new deepUpdate, then re-update the result with the old deepUpdate. Or maybe deepUpdate should do both of these always??? No... I don't think so...
		var copy = deepUpdate({}, obj);		
		return up?
			deepUpdate(copy, up, level):
			copy;
	}
	/*
	Function: deepClear
		clears and recreates <obj>
		If called with an object created using deepPrototype, deepClear will restore it to its original state.
		If called on an object that has one prototype level, the result will be an object with a deep prototype.
		If called on an object that has no prototype, results in an empty object with an empty prototype.
	Arguments:
		<obj> - object to clear
		<up> - object used to update <obj> after clear
		<level> - string specifying at what level of <obj> to apply the update (Example: ".ding.dong.blah" or "['ding']['dong']['blah']")
	Returns: Altered object <obj>
	*/
	function deepClear(obj, up, level) {  //** Change so to this uses prototypes of objects instead of trying to copy their members... **** Done, but need to test...
		shallowClear(obj);
		return deepProto(obj, up, level);		
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

/*

Kinds of copies
	1) Changing original doesn't affect copy. Changing copy doen't affect original // copy has no prototypes. all copies of original.
	2) Changing original affects copy for members not overridden by copy. Changing copy doesn't affect original // each object in copy has a prototype that references a corresponding object in the original.
	3) Changing original affects copy for members not overridden by copy. Changing copy affects original if you tell it to.
	4) Changing original doesn't affect copy. Changing copy doen't affect original unless you tell it to. // each object in copy has a prototype that references a corresponding object in the original, but are all overridden by copeies of the original

update.byValue // old deepUpdate. **update values... no objects created or destroyed... prototypes are untouched
update.byReference // shallowUpdate **objects get replaced... prototypes are untouched
update.byPrototype // new deepUpdate **objects... 

set.byValue // shallowUpdate
set.byReference // equals
set.byPrototype // deepProto


value.update // for every object in up, a new object will be constructed and the values from the original object will be copied to it. //** old deepUpdate (recursive)
reference.update // for every object in up, a reference to the object is created //** shallowUdpate (non-recursive)
prototype.update // for every object in up, a new object is created with the object from up as its prototype //** new deepUpdate (recursive)

value.copy // old deepCopy **direct changes never affect original
reference.copy // shallowCopy **direct below first level affect original
prototype.copy // new deepCopy **same as deepProto ****no... not the same. There's no prototype at the top level for the new deepCopy (maybe there should be). **direct changes never affect the original. Same a value.copy but with backup prototypes of originals added to each object

value.proto // shallowProto **direct changes below first level effect original
reference.proto // **similar to prototype.copy but without any updates ****there is no top level protoype... objects inside are shallowProto'ed **direct changes below second level affect original
prototype.proto // deepProto **direct changes never affect original

**************
** use prototype.copy for all copies... this would be a deepProto of an object followed by an old deepUpdate of the new object using the original object. **This is so changing original won't effect the copy. ****But why bother with the proto then? So struture is kept intact????
** use prototype.proto for all proto's
** have a bunch of versions of update..
**************

copy.byValue
copy.byReferences
copy.prototypes
copy **does by prototype then does and old deepUpdate

proto.shallow
proto.deep




*/