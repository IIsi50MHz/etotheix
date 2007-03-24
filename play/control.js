// Setup jQuery so it's $ function doesn't conflict with Mochikit's
jQuery.noConflict();
// Use jQ instead
var jQ = jQuery;

function proto(o) {
	var F = function F() {};
	F.prototype = o;
	return new F();
}
// The protoControl object
// With the help of this object, you can add simple html markup defining the behavior of a control or a whole class of controls.
//	If you define controls (or a class of controls) on elements created dynamically, don't worry, they'll still work fine. 
//	This is because the event handlers are not normally bound to the control element; instead, they are bound to the parent 
//	element of the control definition markup.
/*
How to create a control:
	javascript code: 
		// Call on page load.
		protoControl.init();
	markup:
		<!-- Use markup like this to define the behavior for a control or a class of controls. -->
			<!-- NOTE: -->
			<!-- If the definition markup is for a class of controls, they must be contained within the parent element of the definition -->
			<!-- If the parent element of a control definition is destroyed, you're screwed... -->
			<!-- ...You can, however, create and destroy the control elements themselves at will. -->
			
		<!-- EXAMPLE 1: Setting up behavior for a class of controls -->		
		<div id="controlContainerBlah">
			<!-- this span cotains a control definition -->
			<span control=".ding">  <!-- the control attribute refers to the control elements -->
				<!-- these anchors define how the control affects other elements -->
				<!-- the hook attribute refers an element affected by the control -->
				<!-- the event and action attributes define when and how the elements are affected  -->				
				<a hook=".ding" event="click" action="select"></a> <!-- when a class ding control is clicked, select it... -->
				<a hook="#dong" event="click" action="toggleShow"></a> <!-- when a class ding control is clicked, show or hide the element with id="dong" -->
			</span>			
			<ul id="classDingControls"> 				
				<li class="ding">do</li>
				<li class="ding">re</li>
				<li class="ding">mi</li>
				<li class="ding">fa</li>
				<li class="ding">so</li>
				<!-- if you dynamically add more class ding controls here -- say, "la" and "ti" -- they will just work -->
			</ul>
		</div>
		<h1 id="dong">DONG!</h1>
			
		<!-- EXAMPLE 2: Setting up behavior for a stand-alone control -->
		<h1 id="boo">BOO!
			<!-- when the "boo" control is clicked, select it and show or hide the element with id="dong" -->
			<span control="#boo"> 
				<a hook="#boo" event="click" action="select"></a>
				<a hook="#eek" event="click" action="toggleShow"></a>
			</span>						
		</h1>
		<p id="eek">EEK!</p>

How to create custom actions that override default actions:
	javascript code:
		protoControl.extend({
			// overrides default select action for class "ding" elements only
			".ding select": function () {
				alert("Don't do default select for .ding controls. Pop up this alert instead.")
			},
			// creates a new default select action for all elements
			select: function () {
				alert("Pop up this alert instead for all ")
			}
		});
	markup:
		<!-- markup is same as before, but now clicking on a ding element sends up an alert -->
		<span control=".ding">
			<a hook=".ding" event="click" action="select"></a>
			<a hook="#dong" event="click" action="toggleShow"></a>
		</span>	
*/

var protoControl = {
	// jQuery object holding the delegator element. Events are bound to the delegator element.
	_delegator: "",
	// jQuery expression that identifies the control element(s),
	_control: "", 
	
	// holds the moset recent event - updated by event()
	e: "",	// **Should this be private -- provide an acces function?
	// holds the target of the most recent event - updated by event()
	eventTarget: "",
	
	// holds the most recent target control (jQuery object) - updated by event()
	targetControl: null, // **Should this be private -- provide a function to access?
	// holds other controls other controls that are similar to target control (jQuery object) - updated by event()
	otherControls: null, // **Should this be private -- provide a function to access?	
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
	// initializes all delegator controls that are within the context node (default is document)
	init: function (context) {
		// gather all control definitions
		var controlDefs = jQ("span[@control]", context || document);
		// set up event handlers for each control
		controlDefs.each(function () {
			var controlDef = jQ(this);
			var delegatorObj = protoControl.make(controlDef.parent(), controlDef.attr("control"));
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
		return this;
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
	extend: function (obj) {
		for (var i in obj) {
			this[i] = obj[i];
		}
		return this;
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
	selectOne: function () { //** Should accept and arument... Should be able to use on a group of elements other than the control.
		// select new element
		this.select(this.targetControl);
		// deselect old elements
		this.deselect(this.otherControls.filter(".selected"));
		return this;
	},
	// Select the target control and deselect the other controls. Selecting the same control twice in a row toggles the
	toggleSelectOne: function () {
		// toggle target control
		this.toggleSelect(this.targetControl);
		// deselect other controls
		this.deselect(this.otherControls.filter(".selected"));
		return this;
	},
	show: function (expr) {
		jQ(expr).show();
	},
	hide: function () {
		jQ(expr).hide();
	},
	toggleShow: function (expr) {
		jQ(expr).toggle();
	}
}

protoControl.extend({
	//".thing selectOne": function () {this.selectOne(); alert('hello');},
	//"#ding select": function (expr) {this.select(expr); alert("ding!");},
	//"#ding show": function () {}
});

jQ(function () {
	protoControl.init();
})