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
			var containerObj = protoControl.make(controlDef.parent(), controlDef.attr("control"));
			// get all the control anchors inside this control
			var controlAnchors = jQ("a", this);
			// for each control anchor, hook the appropriate event handler to the delegator element
			controlAnchors.each(function () {
				var controlAnchor = jQ(this);				
				var container;
				var targetContainer;
				// Check if container id was inclued as part of the hook
				var hook = controlAnchor.attr("hook") || containerObj._control;
				hook = hook.split(/\s+/);
				if (hook.length === 2) {
					container = targetContainer = hook[0];
					hook = hook[1];
				} else {
					targetContainer = containerObj._delegator;
					container = document;
					hook = hook[0];
				}
				var event = controlAnchor.attr("event") || "click";	//**user should be able set default event and action for page to something else		
				var action = controlAnchor.attr("action") || "select";
				var toggle = controlAnchor.attr("toggle") === "true";
				var exclusive = controlAnchor.attr("exclusive") === "true";	
				
				var funcName;						
				// check for custom version of action 
				// **not sure this is the best way to do custom actions
				// **WHY? because it depends on hook being simple class or id selector. Might want more complex hooks at some point.
				if (!containerObj[hook + " " + action]) {						
					funcName = action;
				} else {								
					funcName = hook + " " + action;
				}
				
				// toggle action? exclusive action? both?
				var modFunc;								
				if (exclusive && toggle) {
					modFunc = containerObj.exclusiveToggle(funcName); 
				} else if (toggle) {
					modFunc = containerObj.toggle(funcName);				
				} else if (exclusive) {						
					modFunc = containerObj.exclusive(funcName); 				
				} 			
				
				containerObj.bind(event, function() {
					// find any control anchors inside the target control
					var innerAnchors = jQ("a[@hook]", containerObj.targetControl);
					// get elements hooked to by inner anchors
					var hooks = [];
					innerAnchors.each(function(i) {
						// get hook values
						hooks[i] = jQ(this).attr("hook");
					})
					// get the actual elements associated with each hook... 
					// ...keep only elements that match the control anchor's hook
					hooks = hooks.join();
					var hookedElems = hooks ? jQ(hooks).filter(hook) : [];	
								
					// **We need to be able to apply the action to one element only...
					// ** ...This could be a control, or it could be some other element that is part of a group of elements.
					// All cases beleow use a modified function (modFunc) if available. 
					// case 1: action applies to target control itself					
					if (containerObj.targetControl.filter(hook).length > 0) {						
						(modFunc || containerObj[funcName])(containerObj.targetControl, hook, container);											
					// case 2: action applies to an element refered to by an anchor inside the target control
					} else if (hookedElems.length > 0) {				
						(modFunc || containerObj[funcName])(hookedElems, hook, container);
					// case 3: action applies directly to hook element(s)
					} else {						
						(modFunc || containerObj[funcName])(hook);
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
	// select elements -- expr is a jQuery expression
	select: function (expr) {		
		jQ(expr).addClass("selected");		
		return this;
	},
	// deselect elements
	deselect: function (expr) {		
		jQ(expr).removeClass("selected");
		return this;
	},
	// show elements
	show: function (expr) {
		jQ(expr).show();
	},
	// hide elements
	hide: function (expr) {
		jQ(expr).hide();
	},
	// undo relates actions to their opposites (selecte/deselect, hide/show, etc.)
	// It's is used by exclusive() and toggle().
	// **not sure undo is a good name
	undo: {
		"select": 	{
			inv: "deselect", 
			flag: ".selected"
		},
		"show": {
			inv: "hide", 
			flag: ":visible"	
		}
	},
	// exclusive() -- takes an action makes it exclusive (by exlusive, I mean exclusive like XOR is exclusive)
	// For example, passing the select function returns a function that selects one element and delselects all
	// similar elements.
	exclusive: function (f) {
		var that = this;		
		var fInv = this.undo[f].inv;
		var flag = this.undo[f].flag;
		return function (elem, hook, container) {		
			that[f](elem);			
			that[fInv](jQ(hook, container).filter(flag).not(elem));
			return that;
		}		
	},
	// returns function that toggles an action for elements
	toggle: function (f) {				
		var that = this;
		var fInv = this.undo[f].inv;
		var flag = this.undo[f].flag;		
		return function (elem, hook, container) {					
			jQ(elem).is(flag) ? that[fInv](elem, hook) : that[f](elem, hook);
			return that;
		}
	},
	// returns function that toggles an action for elements
	exclusiveToggle: function (f) {
		var that = this;
		var fInv = this.undo[f].inv;
		var flag = this.undo[f].flag;
		return function (elem, hook, container) {						
			that.toggle(f)(elem);			
			that[fInv](jQ(hook, container).filter(flag).not(elem));
			return that;
		}
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