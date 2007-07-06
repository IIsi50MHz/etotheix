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


