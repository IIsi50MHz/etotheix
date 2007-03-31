// The protoControl object
// 	With the help of protoControl, you can use simple html markup create a control definition that lays out the behavior of 
//	an individual control or a whole class of controls.  If you define controls (or a class of controls) on elements created 
//	dynamically, don't worry, they'll still work fine. This is because the event handlers are not directly bound to the control 
//	element; instead, they are bound to the parent element of the control definition. (In the code, this parent element is refered to as the delegator.)
/*
 	**TO DO -- Add the following to comments:
		explain toggle and exclusive attributes
		explain use of anchors added directly inside controls instead of control definition
		explain when hooks of the form "#id .class" are appropriate
		explain structure of control definitions 
			<dl class="controlDef">
			<dt>
			<dd>
			<a class="directHook">
			JSON
 		add an more detailed overview of the use and consepts behinde the protoControl object
			why was it written?
			what's it for?
				high level control definition
					relationships between control elements and other elements
					doesn't define what controls look like			
			what can you do with it?
			when should you use it?
			when should you not use it?
			describe what sorts of values each of the these attributes can have
				hook
				action
				event
				toggle
				exclusive
				control
				delegator
*/
// **Does there need to be a css file that hides the textless span and anchor elements in the control definitions?
/*
How to automate control creation:
	javascript code: 
		// do this on page load
		protoControl.init();
	markup:
		<!-- Use markup like this to define the behavior for a control or a class of controls. -->
		<!-- NOTE: -->
			<!-- Both control and delegator elements default to the next sibling element after the control definition list  -->
			<!-- The control element of a control definition must have an id -->
			<!-- The delgator element of a control definition doesn't need an id -->
			<!-- If the definition markup is for a class of controls, they must be contained within delegator element -->
			<!-- If if a delegator element is destroyed, you're screwed... -->
			<!-- ...You can, however, create and destroy any control elements you like (as long as they are not also delegator elements). -->			
			
		<!-- EXAMPLE 1: Setting up behavior for a class of controls -->		
		<div id="controlContainerBlah">
			<!-- control definition -->
			<!-- delegator element defaults to #classDingControls -->
			<dl class="controlDef">
				<dt>{control:".ding"}</dt>
				<dd>{hook:".ding", event:"click", action:"select", exclusive:"true"}</dd>
				<dd>{hook:"#dong", event:"click", action:"show", toggle:"true"}</dd>				
			</dl>
			<ul id="classDingControls"> 				
				<li class="ding">do</li>
				<li class="ding">re</li>
				<li class="ding">mi</li>
				<li class="ding">fa</li>
				<li class="ding">so</li>
				<!-- if you dynamically add more class ding controls here (say, "la" and "ti") they will just work -->
			</ul>
		</div>
		<h1 id="dong">DONG!</h1>
			
		<!-- EXAMPLE 2: Setting up behavior for a stand-alone control -->
		<!-- when the "boo" control is clicked, select it and show or hide the element with id="dong" -->
		<!-- both control and delegator elements default to #boo -->
		<dl class="controlDef">						
			<dd>{hook:"#boo", event:"click", action:"select", toggle:"true"}</dd>
			<dd>{hook:"#eek", event:"click", action:"show", toggle:"true"}</dd>				
		</dl>
		<h1 id="boo">BOO!</h1>
		<p class="scare" id="eek">EEK!</p>

		<!-- EXAMPLE 3: Tab control expample -->					
		<!-- tab control definition -->
		<dl class="controlDef">
			<dt>{control:'.tab', delegator:'#tabs'}</dt>
			<dd>{hook:".tab", event:"click", action:"select", toggle:"true", exclusive:"true"}</dd>			
			<dd>{hook:"#panes .pane", event:"click", action:"show", exclusive:"true"}</dd>					
		</dl>
		<!-- the tabs -->
		<ul id="tabs">
			<li class="tab">do
				<!-- connect tab to a specific pane -->
				<a class="directHook">#do</a>
			</li>
			<li class="tab">re
				<a class="directHook">#re</a>
			</li>
			<li class="tab">mi
				<a class="directHook">#mi</a>
			</li>
			<li class="tab">fa
				<a class="directHook">#fa</a>
			</li>
			<li class="tab">so
				<a class="directHook">#so</a>
			</li>
		</ul>		

		<div id="panes">
			<div class="pane" id="do">DO!</div>
			<div class="pane" id="re">RE!</div>
			<div class="pane" id="mi">MI!</div>
			<div class="pane" id="fa">FA!</div>
			<div class="pane" id="so">SO!</div>
		</div>	

How to create custom actions that override default actions:
	javascript code:
		protoControl.extend({
			// overrides default select action for class "ding" elements only
			".ding select": function () {
				alert("Don't do default select for .ding controls; pop up this alert instead.");
			},
			// creates a new default select action for all elements
			select: function () {
				alert("Pop up this alert instead for all elements");
			}
		});
	markup:
		<!-- markup is same as before, but now clicking on a ding element sends up an alert -->
		<span control=".ding">
			<a hook=".ding" event="click" action="select"></a>
			<a hook="#dong" event="click" action="toggleShow"></a>
		</span>	
*/
// Setup jQuery so it's $ function doesn't conflict with Mochikit's
jQuery.noConflict();
// Use jQ instead
var jQ = jQuery;

// proto() is an exact copy of Douglas Crockford's object() operator
function proto(o) {
	var F = function F() {};
	F.prototype = o;
	return new F();
}

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
	otherControls: null, // **might want to get rid of this? Not using anymore. If you get rid of it, remember to take it out of event() too!
	
	// event()
	// sets event e and calculates targetControl element
	// used by bind()
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
				this.otherControls = jQ(this._control, this._delegator).not(this.targetControl[0]); //** get rid of this?
			} else if (targetControl.length > 0) {
				this.targetControl = jQ(targetControl[0]);
				this.otherControls = jQ(this._control, this._delegator).not(this.targetControl[0]); //** get rid of this?
			} else {
				this.targetControl = false;
				this.otherControls = false;	//** get rid of this?	
			}
		}
		return this;
	},
	
	// bind()
	// binds a function to the delegator element
	// used by init()
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
	// make()
	// makes a new control object
	// the delegator argument can be an id selector (example: "#ding"), an element, or a jQuery wrapped element
	// the control argument should be a class or an id selector (examples: "#dong", ".thingy")
	// used by init()
	make: function (delegator, control) {
		var obj = proto(this);
		obj._delegator = jQ(delegator);
		obj._control = control;
		return obj;
	},
	// init()
	// initializes all delegator controls that are within the context node (default is document)
	init: function (context) {
		//**console.log("protoControl.init() called!");
		// gather all control definitions
		//**OLD var controlDefs = jQ("span[@control]", context || document);
		var controlDefs = jQ("dl.controlDef", context || document);
		
		// set up event handlers for each control
		controlDefs.each(function () {
			var controlDef = jQ(this);
			
			//**NEW
			var dt = jQ("dt:first-child", this).text() || "{}";
			dt = eval("(" + dt + ")");					
			var delegator = dt.delegator || controlDef.next();
			var control = dt.control || "#" + jQ(delegator).attr("id");
			//**console.log("delegator:", delegator, ", control:", control);
			
			//**OLD var controlObj = protoControl.make(controlDef.attr("delegator") || controlDef.parent(), controlDef.attr("control"));			
			var controlObj = protoControl.make(delegator, control);
			
			// get all the control anchors inside this control			
			//**OLD var controlAnchors = jQ("a", this);
			var controlAnchors = jQ("dd", this);			
			
			// for each control anchor, hook the appropriate event handler to the delegator element
			controlAnchors.each(function () {
				var controlAnchor = jQ(this);				
				var container;
				var targetContainer;
				
				//**NEW
				var dd = eval("(" + controlAnchor.text() + ")");			
				
				// Check if container id was inclued as part of the hook				
				//**OLD var hook = controlAnchor.attr("hook") || controlObj._control;
				var hook = dd.hook || controlObj._control;				
				hook = hook.split(/\s+/);
				if (hook.length === 2) {
					container = targetContainer = hook[0];
					hook = hook[1];
				} else {
					targetContainer = controlObj._delegator;
					container = document;
					hook = hook[0];
				}
				//**OLD
				/*
				var event = controlAnchor.attr("event") || "click";	//**user should be able set default event and action for page to something else		
				var action = controlAnchor.attr("action") || "select";
				var toggle = controlAnchor.attr("toggle") === "true";
				var exclusive = controlAnchor.attr("exclusive") === "true";	
				*/				
				var event = dd.event || "click";	//**user should be able set default event and action for page to something else		
				var action = dd.action || "select";
				var toggle = dd.toggle || dd.toggle === "true"; // both true and "true" valid
				var exclusive = dd.exclusive || dd.exclusive === "true"; // both true and "true" valid
				
				var funcName;						
				// check for custom version of action 
				// **not sure this is the best way to do custom actions
				// **WHY? because it depends on hook being simple class or id selector. Might want more complex hooks at some point.
				//	 ****UPDATE: this is not a problem anymore for hooks of the form "#id .class"
				if (!controlObj[hook + " " + action]) {						
					funcName = action;
				} else {								
					funcName = hook + " " + action;
				}
				
				// toggle action? exclusive action? both?
				var modFunc;								
				if (exclusive && toggle) {
					modFunc = controlObj.exclusiveToggle(funcName); 
				} else if (toggle) {
					modFunc = controlObj.toggle(funcName);				
				} else if (exclusive) {						
					modFunc = controlObj.exclusive(funcName); 				
				} 			
				
				//**console.log(event, controlObj);
				controlObj.bind(event, function() {					
					// find any control anchors inside the target control
					//**OLD var innerAnchors = jQ("a[@hook]", controlObj.targetControl);
					var innerAnchors = jQ("a.directHook", controlObj.targetControl);										
					// get elements hooked to by inner anchors
					var hooks = [];
					innerAnchors.each(function(i) {
						// get hook values, (will be a list of id's)
						//**OLD hooks[i] = jQ(this).attr("hook");
						hooks[i] = jQ(this).text();
						//**console.log(hooks[i]);
					})
					
					//** Not sure how well this has been tested...
					// get the actual elements associated with each hook... 
					// ...keep only elements that match the control anchor's hook
					hooks = hooks.join();
					//** OLD var hookedElems = hooks ? jQ(hooks).filter(hook) : [];
					//**NEW					
					var hookedElems; 
					if (hooks) {
						// ...keep only elements that match the control anchor's hook						
						hookedElems = jQ(hooks).filter(hook);
					} else {
						//**console.log("no direct hook");
						// if there are no direct hooks, make one up						
						//	 get the index of the target control
						var elem = controlObj.targetControl[0];
						var index = false;
						//** Not sure this makes sense if _control is an id selector. Should only do this if it's class selector?
						//**console.log("control:", controlObj._control, "delegator:", controlObj._delegator);
						jQ(controlObj._control, controlObj._delegator).each(function(i) {
							//**console.log("this:", this, "targetControl:", elem);
						    if (this === elem) {
						        index = i;
						    }
						})
						// 	get the element in container that matches hook and has the same index as the target control
						hookedElems = jQ(hook, container).eq(index);
						//**console.log(hook, container, index, " -- artificial hook:", hookedElems);
					}
					//**END NEW
					
					// **We need to be able to apply the action to one element only...
					// ** ...This could be a control, or it could be some other element that is part of a group of elements.
					// All cases beleow use a modified function (modFunc) if available. 
					// case 1: action applies to target control itself					
					if (controlObj.targetControl.filter(hook).length > 0) {						
						//**console.log("target control itself");
						(modFunc || controlObj[funcName])(controlObj.targetControl, hook, container);						
					// case 2: action applies to an element refered to by an anchor inside the target control
					} else if (hookedElems.length > 0) {
						//**console.log("direct hook in control");					
						(modFunc || controlObj[funcName])(hookedElems, hook, container);						
					// case 3: action applies directly to hook element(s)
					} else {	
						//**console.log("hook");					
						(modFunc || controlObj[funcName])(hook);						
					}
					//**console.log("done");
				});
			});			
		});
		return this;
	},	
	/////
	// action functions
	/////
	// select elements -- expr is a jQuery expression
	select: function (expr) {
		//**console.log("called select");
		jQ(expr).addClass("selected");		
		return this;
	},
	// deselect elements
	deselect: function (expr) {		
		//**console.log("called deselect");
		jQ(expr).removeClass("selected");
		return this;
	},
	// show elements
	show: function (expr) {
		//**console.log("called show", expr);
		jQ(expr).show();
	},
	// hide elements
	hide: function (expr) {
		//**console.log("called hide", expr);
		jQ(expr).hide();
	},
	/////
	// action enhancement aids
	/////
	// pairs
	// pairs relates actions to their opposites (selecte/deselect, hide/show, etc.)
	// used by exclusive() and toggle() and toggleExclusive(), and pair()
	// **need to explain what flag if for
	pairs: {
		"select": 	{
			inv: "deselect", 
			flag: ".selected"
		},
		"show": {
			inv: "hide", 
			flag: ":visible"	
		}
	},
	// pair()
	// Used to pair custom functions
	// NOTE: flag is optional, but should be included if possible.	
	// action, inv, and flag ar all strings
	// used by... user.
	pair: function (action, inv, flag) {
		flag = flag || "*";
		this.pairs[action] = {
			inv: inv,
			flag: flag,
		};
		return this;
	},	
	// extend() 
	// extends control object with custom actions	
	// can be used to overwrite default actions...
	// ...or they can override the default actions for specific controls or elements	
	// attemps to pair custom actions to make them optionally toggleable and exclusive
	extend: function (obj) {
		for (var i in obj) {
			this[i] = obj[i];
		}
		// Attempt to pair new functions to make them usable by toggle() and exclusive()
		var pairs = this.pairs;		
		for (var i in obj) {
			// find out if action might be a custom version of an existing action (i == ".ding select", for example)
			var arr = i.split(/\s+/);
			var hook;
			var action;
			if (arr.length > 1) {
				hook = arr[0];
				action = arr[1];
			} else
				action = arr[0]
			}
			// check there is a default version of the custom action that is paired
			// if there is, pair the new, custom action
			if (hook && pairs[action]) {
				pairs[i] = {};
				var potentialInv = hook + " " + pairs[action].inv;				
				// if there was an inverse action created to pair with the new action, use it.
				if (obj[potentialInv]) {
					pairs[i].inv = hook + " " + pairs[action].inv;					
				// if there isn't a new inverse the action, use the default inverse action
				} else {					
					pairs[i].inv = pairs[action].inv;
				}
				// use the same flag as the default action
				pairs[i].flag = pairs[action].flag;
		}
		return this;
	},
	// exclusive() -- takes an action makes it exclusive (by exlusive, I mean exclusive like XOR is exclusive)
	// For example, passing the select function returns a function that selects one element and delselects all
	// similar elements.
	// action is a string
	exclusive: function (action) {
		var that = this;		
		var inv = this.pairs[action].inv;
		var flag = this.pairs[action].flag;
		return function (elem, hook, container) {		
			that[action](elem);			
			that[inv](jQ(hook, container).filter(flag).not(elem));
			return that;
		}		
	},
	// toggle()
	// returns function that toggles an action for elements
	// action is a string
	toggle: function (action) {				
		var that = this;
		var inv = this.pairs[action].inv;
		var flag = this.pairs[action].flag;		
		return function (elem, hook, container) {					
			jQ(elem).is(flag) ? that[inv](elem, hook) : that[action](elem, hook);
			return that;
		}
	},
	// exclusiveToggle()
	// action is a string
	exclusiveToggle: function (action) {
		var that = this;
		var inv = this.pairs[action].inv;
		var flag = this.pairs[action].flag;
		return function (elem, hook, container) {						
			that.toggle(action)(elem);			
			that[inv](jQ(hook, container).filter(flag).not(elem));
			return that;
		}
	}	
}
