// Setup jQuery so it's $ function doesn't conflict with Mochikit's
jQuery.noConflict();
// Use jQ instead
var jQ = jQuery;

function proto(o) {
	var F = function F() {};
	F.prototype = o;
	return new F();
}

/*
** Need to explain how the use the protoDelegator better. Below are some comments I wrote while trying to figure out what I was doing.
control.html might have some useful comments and expamples.
	Need to include
		- Purpose of protoDelegator
		- Primary uses
			create controls
			link elements to controls in html
		- Examples of use
*/

/*
Selector (tabs or buttons are examples of selectors) (mongoose event list, mongoose target list, trainee tabs, etc.) ** would "Control" be a better name?
	A selector element can effect one (or more?) elements when an event happens
	What sort of mark-up should we use to indicate what elements a selector element affects?
		- use href = id of affected element. That means selector would have to be an anchor. Do we want that?
		- have one or more hidden anchors inside selector element that refer to affected elements
		- href value could be a jQuery expression? (css selector, xpath)
	Use event delegation for potentially transient selectors, or where there are multiple selectors present that can use the same event handler.
*/

/*
DELEGATOR OBJECT **Not sure this is a very goode name. But may expand functionality of this object so it makes more sense.
Wraps event delegating functionality around an element
Use this when you have a bunch of selectable controls with internal structure and you want to delagate event handling to some higher level container.
The element that does the event delegation should contain the selectable elements and nothing else. (**maybe, or maybe not)
**Need to add some functionality to this object
	way to bind one or more event types to delegator. Or maybe just one event type. Should create a new object for each event type event if delegator element is the same?
	way to identify the lowest level container that contains the (potentially composite) elements to delegate to
	way to identify the (potentially composite) elements that need to be delagated to function that handles event. Maybe an array of functions?
Example:	
	var ding = makeDelegator("#delegator").container("#container").control(".ding");
	ding.bind("click", function(e) {
		//do stuff
		ding.selectOne();
		alert(ding.e.target);
		alert(e.target);
	});
	...
	// by default control is same as delegator
*/

var protoDelegator = {
	// jQuery object holding the delegator element. Events are bound to the delegator element.
	_delegator: "",
	// jQuery expression that identifies the control element(s),
	_control: "", 
	
	// holds the moset recent event - updated by event()
	e: "",	// Should this be private -- provide an acces function?
	// holds the target of the most recent event - updated by event()
	eventTarget: "",
	
	// holds the most recent target control (jQuery object) - updated by event()
	targetControl: null, //**Should this be private -- provide a function to access?
	// holds other controls other controls that are similar to target control (jQuery object) - updated by event()
	otherControls: null, //**Should this be private -- provide a function to access?
	
	// sets event e and calculates targetControl element
	event: function (e) {
		// don't bother doing anything unless we've got a new event		
		if (e !== this.e) {			
			this.e = e;
			this.eventTarget = e.target;
			// calculate targetControl element
			var eventTarget = jQ(e.target);
			var targetControl = eventTarget.parents(this._control);			
			if (eventTarget.is(this._control)) {
				this.targetControl = jQ(eventTarget[0]);
				this.otherControls = jQ(this._control, this._delegator).not(this.targetControl[0]);
			} else if (targetControl.length > 0) {
				this.targetControl = jQ(targetControl[0]);
				this.otherControls = jQ(this._control, this._delegator).not(this.targetControl[0]);
			} else {
				this.targetControl = false;
				this.otherControls = false;			
			}
		}
		return this;
	},	
	// binds a function to the delegator element
	bind: function (type, data, func) {
		var that = this;
		func = func || data;		
		// **need to add ability to use data parameter and make sure it works		
		jQ(this._delegator).bind(type, data, function (e) {
			that.event(e);
			if (that.targetControl !== false) {
				func();
			}
		});
		return this;
	},

	// initializes all delegator elements inside context node (default is document)
	init: function (context) {
		//gather all control elements 
		var controls = jQ("div[@control]", context || document);
		// set up event handlers for each control
		controls.each(function () {			
			var control = jQ(this);
			var delegatorObj = protoDelegator.make(control.parent(), control.attr("control"));
			// get all the control anchors inside this control
			var controlAnchors = jQ("a", this);
			// for each control anchor, hook up the appropriate event handler to the delegator element 
			controlAnchors.each(function () {
				var controlAnchor = jQ(this);				
				var hook = controlAnchor.attr("hook") || delegatorObj._control;				
				var event = controlAnchor.attr("event") || "click";	//**user should be able set default event and action for page to something else		
				var action = controlAnchor.attr("action") || "select";
				var funcName;
				delegatorObj.bind(event, function() {
					// check for custom version of action
					if (!delegatorObj[hook + " " + action]) {						
						funcName = action;
					} else {								
						funcName = hook + " " + action;
					}
					// check if action should be applied to control element only
					if (delegatorObj.targetControl.filter(hook).length > 0) {
						delegatorObj[funcName](delegatorObj.targetControl);
					} else {
						delegatorObj[funcName](hook);
					}
				});
			});			
		});
	},
	// makes a new delegator object
	// the delegator argument can be an id selector (example: "#ding"), an element, or a jQuery wrapped element
	// the control argument should be a class or id selector (examples: "#dong", ".thingy")
	make: function function (delegator, control) {
		var obj = proto(this);
		obj._delegator = jQ(delegator);
		obj._control = control;
		return obj;
	},
	// extends delegator with custom actions
	// These custom functions can overwrite the default actions...
	// ...or they can override the default actions for specific controls or elements
	/*
	// EXAMPLE:
		protoDelegtor.extend({
			// selecting the element with id="ding" now sends up an alert after it is selected
			"#ding select": function (expr) {
				this.select(expr);
				alert("Ding!");
			},
			// default deselect doesn't deleselet anything any more--alerts "blah" insead.
			deselect: function () {
				alert("blah");
			}				
		})
	*/
	extend: function (obj) {
		for (var i in obj) {
			this[i] = obj[i];
		}
	},
	/////
	// Default Actions
	/////
	// select elements
	select: function (expr) {
		jQ(expr).addClass("selected");		
		return this;
	},
	// deselect elements
	deselect: function (expr) {
		jQ(expr).removeClass("selected");
		return this;
	},
	// toggle element selection
	toggleSelect: function (expr) {
		jQ(expr).toggleClass("selected");
		return this;
	},
	// Select the target control and deselect the other controls. Selecting the same control twice in a row does nothing.
	selectOne: function () {
		// select new element
		this.select(this.targetControl);
		// deselect old elements
		this.deselect(this.otherControls.filter(".selected"));
		return this;
	},
	// Select the target control and deselect the other controls. Selecting the same control twice in a row toggles the control.
	toggleSelectOne: function () {
		// toggle target control
		this.toggleSelect(this.targetControl);
		// deselect other controls
		this.deselect(this.otherControls.filter(".selected"));
		return this;
	},
	show: function () {},
	hide: function () {},
	toggleShow: function () {}
}

protoDelegator.extend({
	//".thing selectOne": function () {this.selectOne(); alert('hello');},
	//"#ding select": function (expr) {this.select(expr); alert("ding!");},
	//"#ding show": function () {}
});

/////////////////////// 
// "onload" 
//   **Seems like there's might be too much going on here. A lot of the code here could probably be used other places. 
//	Need write some general purpose functions/objects and use them instead.
jQ(function () {
	protoDelegator.init();
})