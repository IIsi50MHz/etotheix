// Selector (tabs or buttons are examples of selectors) (mongoose event list, mongoose target list, trainee tabs, etc.) ** would "Control" be a better name?
// 	A selector element can effect one (or more?) elements when an event happens
//	What sort of mark-up should we use to indicate what elements a selector element affects?
//		- use href = id of affected element. That means selector would have to be an anchor. Do we want that?
//		- have one or more hidden anchors inside selector element that refer to affected elements
//		- href value could be a jQuery expression? (css selector, xpath)
//	Use event delegation for potentially transient selectors, or where there are multiple selectors present that can use the same event handler.
/*
delegator = delegator
container = wrapper
control = control

*/

// Setup jQuery so it's $ function doesn't conflict with Mochikit's
jQuery.noConflict();
// Use jQ instead
var jQ = jQuery;

function proto(o) {
	var F = function F() {};
	F.prototype = o;
	return new F();
}
// DELEGATOR OBJECT **Not sure this is a very goode name. But may expand functionality of this object so it makes more sense.
// Wraps event delegating functionality around an element
// Use this when you have a bunch of selectable controls with internal structure and you want to delagate event handling to some higher level container.
// The element that does the event delegation should contain the selectable elements and nothing else. (**maybe, or maybe not)
// **Need to add some functionality to this object
//	way to bind one or more event types to delegator. Or maybe just one event type. Should create a new object for each event type event if delegator element is the same?
//	way to identify the lowest level container that contains the (potentially composite) elements to delegate to
//	way to identify the (potentially composite) elements that need to be delagated to
//	 function that handles event. Maybe an array of functions?
// Example:	
//	var ding = makeDelegator("#delegator").container("#container").control(".ding");
//	ding.bind("click", function(e) {
//		//do stuff
//		ding.selectOne();
//		alert(ding.e.target);
//		alert(e.target);
//	});
//	...
//
//	// by default control is same as delegator

//**change name to control or controlProto
var delegatorProto = {
	// jQuery expression that identifies delegator element
	_delegator: "",
	// jQuery expression that identifies control element(s),
	_control: "", 			
	// holds current event - set by event()
	_event: "",	
	
	// holds jQuery wrapped target element - set by event()
	// NOTE: The target element is calulated by event(). It will be an element that matches the expression held by _control 
	// and will be inside an element that matches the expression held by _container.
	// For example, if _control is set to ".ding", target will be an element of class "ding"
	target: "nothing", //**change name to targetControl?
	// sets event e and calculates target element
	event: function (e) {
		this._event = e;
		// calculate target element
		var targ = jQ(e.target);
		// make sure the event target is inside the container element (container element is parent of e.target)
		// **Why? Isn't the container element redunant? why do we need a container and a delegator?
		/*
		 // or this (short but really hard to read)
		 var elem = targ.is(this._control) ? targ[0] : targ.parents(this._control)[0];
		this.target = elem && jQ(elem);			 
		*/
		var targControl = targ.parents(this._control);	
		if (targ.is(this._control)) {
			this.target = jQ(targ[0])
		} else if (targControl.length > 0) {
			this.target = jQ(targControl[0])
		} else {
			this.target = false;
		}		
		return this;
	},
	// Set _control to expr		
	control: function (expr) {
		this._control = expr || "#" + jQ(this._delegator)[0].id;		
		return this;
	},	
	// bind a function to delegator element
	bind: function (type, data, fn) {
		var that = this;
		fn = fn || data;		
		// **need to add ability to use data parameter and make sure it works		
		jQ(this._delegator).bind(type, data, function (e) {
			that.event(e);
			if (that.target !== false) {
				fn();
			}
		});
		return this;
	},

	// initialize all delegators and controls
	init: function () {
		//gather all class controlHooks elements 
		var controlHooks = jQ("div.controlHooks");
		// set up event handlers
		controlHooks.each(function () {			
			var controlLink = jQ(this);						
			var delegator = controlLink.parent();
			var control = controlLink.attr("control") || "#" + delegator.attr("id");
			var delegatorObj = makeDelegator(delegator).control(control);
			// get all the links inside this controlLink
			var links = jQ("a", this);
			// for each link, hook up the appropriate event handler to the delegator element 
			links.each(function () {
				var link = jQ(this);				
				var href = link.attr("href") || delegatorObj._control;				
				var event = link.attr("event") || "click";	//**user should be able set default event and action for page to something else		
				var action = link.attr("action") || "select";
				var fnName = "";
				delegatorObj.bind(event, function() {
					// check for custom version of action
					if (!delegatorObj[href + " " + action]) {						
						fnName = action;
					} else {								
						fnName = href + " " + action;
					}
					// check if action should be applied to control element only
					if (delegatorObj.target.filter(href).length > 0) {
						delegatorObj[fnName](delegatorObj.target);
					} else {
						delegatorObj[fnName](href);
					}
				});
			});			
		});
	},
	// make a new delegator object
	// delegator can be an id, an element, or a jQuery wrapped element
	make: function function (delegator, control) {
		var obj = proto(this);
		obj._delegator = jQ(delegator);
		obj._control = control || "#" + jQ(delegator)[0].id;
		return obj;
	},
	extend: function (obj) {
		for (var i in obj) {
			this[i] = obj[i];
		}
	},
	/////
	// Default Actions
	/////
	// ** haven't tried this one out
	select: function (expr) {
		jQ(expr).addClass("selected");		
		return this;
	},
	// ** haven't tried this one out
	deselect: function (expr) {
		jQ(expr).removeClass("selected");
		return this;
	},
	// ** haven't tried this one out
	toggleSelect: function (expr) {
		jQ(expr).toggleClass("selected");
		return this;
	},
	// Select one element and deselect everything else. Selecting the same element twice in a row does nothing.
	selectOne: function () {
		newElem = this.target;
		// get currently selected elements (if any). Exclude the new element (in case already selected control was selected).
		oldElem = jQ(".selected", this._delegator).filter(this._control).filter(function () {
			return this !== newElem[0];
		});
		// select new element
		newElem.addClass("selected");
		// deselect old elements
		oldElem.removeClass("selected");
		return this;
	},
	toggleSelectOne: function () {},
	show: function () {},
	hide: function () {},
	toggleShow: function () {}
}
function makeDelegator(delegator, control) {
		var obj = proto(delegatorProto);
		obj._delegator = jQ(delegator);
		obj._control = control || "#" + jQ(delegator)[0].id;
		return obj;
}
/*
delegatorProto.extend({
	".target select": function () {},
	"#ding select": function () {},
	"#ding show": function () {},		
});
*/
/////////////////////// 
// "onload" 
//   **Seems like there's might be too much going on here. A lot of the code here could probably be used other places. 
//	Need write some general purpose functions/objects and use them instead.
jQ(function () {
	delegatorProto.init();
})