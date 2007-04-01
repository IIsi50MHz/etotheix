// The protoControl object
// 	With the help of protoControl, you can use simple html markup create a control definition that lays out the behavior of 
//	an individual control or a whole class of controls.  If you define controls (or a class of controls) on elements created 
//	dynamically, don't worry, they'll still work fine. This is because the event handlers are not directly bound to the control 
//	element; instead, they are bound to the parent element of the control definition. (In the code, this parent element is refered to as the delegator.)
/*
 	**TO DO -- Add the following to comments:
		explain toggle and exclusive attributes
		explain use of anchors added directly inside controls instead of control definition
		explain when ties of the form "#id .class" are appropriate
		explain structure of control definitions 
			<dl class="controlDef">
			<dt>
			<dd>
			<a class="directTie">
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
				tie
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
				<dd>{tie:".ding", event:"click", action:"select", exclusive:"true"}</dd>
				<dd>{tie:"#dong", event:"click", action:"show", toggle:"true"}</dd>				
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
			<dd>{tie:"#boo", event:"click", action:"select", toggle:"true"}</dd>
			<dd>{tie:"#eek", event:"click", action:"show", toggle:"true"}</dd>				
		</dl>
		<h1 id="boo">BOO!</h1>
		<p class="scare" id="eek">EEK!</p>

		<!-- EXAMPLE 3: Tab control expample -->					
		<!-- tab control definition -->
		<dl class="controlDef">
			<dt>{control:'.tab', delegator:'#tabs'}</dt>
			<dd>{tie:".tab", event:"click", action:"select", toggle:"true", exclusive:"true"}</dd>			
			<dd>{tie:"#panes .pane", event:"click", action:"show", exclusive:"true"}</dd>					
		</dl>
		<!-- the tabs -->
		<ul id="tabs">
			<li class="tab">do
				<!-- tie tab to a specific pane -->
				<a class="directTie">#do</a>
			</li>
			<li class="tab">re
				<a class="directTie">#re</a>
			</li>
			<li class="tab">mi
				<a class="directTie">#mi</a>
			</li>
			<li class="tab">fa
				<a class="directTie">#fa</a>
			</li>
			<li class="tab">so
				<a class="directTie">#so</a>
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
			<a tie=".ding" event="click" action="select"></a>
			<a tie="#dong" event="click" action="toggleShow"></a>
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
	delegator: "",
	// jQuery expression that identifies the control element(s),
	control: "", 	
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
			var targetControl = eventTarget.parents(this.control);			
			if (eventTarget.is(this.control)) {
				this.targetControl = jQ(eventTarget[0]);
				this.otherControls = jQ(this.control, this.delegator).not(this.targetControl[0]); //** get rid of this?
			} else if (targetControl.length > 0) {
				this.targetControl = jQ(targetControl[0]);
				this.otherControls = jQ(this.control, this.delegator).not(this.targetControl[0]); //** get rid of this?
			} else {
				this.targetControl = false;
				this.otherControls = false;	//** get rid of this?	
			}
		}
		return this;
	},
	
	// bind()
	// binds a action to the delegator element
	// used by init()
	bind: function (type, data, action) {		
		var that = this;
		action = action || data;		
		// **need to add ability to use data parameter and make sure it works		
		jQ(this.delegator).bind(type, data, function (e) {			
			// don't call event() if custom event
			//**need a better way to do this
			if (e.currentTarget) {
				that.event(e);
			}			
			if (that.targetControl !== false) {
				action();
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
		obj.delegator = jQ(delegator);
		obj.control = control;
		return obj;
	},
	// init()
	// initializes all delegator controls that are within the context node (default is document)
	init: function (context) {		
		// gather all control definitions		
		var controlDefs = jQ("dl.controlDef", context || document);
		
		// set up event handlers for each control
		controlDefs.each(function () {
			var controlDef = jQ(this);		
			var dt = jQ("dt:first-child", this).text() || "{}";
			dt = eval("(" + dt + ")");
			
			var delegator = dt.delegator || controlDef.next();
			var control = dt.control || "#" + jQ(delegator).attr("id");			
			var controlObj = protoControl.make(delegator, control);
			
			// get all the definitions inside this control definition list						
			var dds = jQ("dd", this);					
			// for each definition (<dd> element), bind the appropriate event handler to the delegator element
			dds.each(function () {				
				var dd = eval("(" + jQ(this).text() + ")");			
				var container;
				var targetContainer;					
				
				// Check if container id was inclued as part of the tie				
				//**TODO: I think the "hook" attribute should be renamed to "connection"... how about "tie"?
				var tie = dd.tie || controlObj.control;				
				tie = tie.split(/\s+/);
				if (tie.length === 2) {
					container = targetContainer = tie[0];
					tie = tie[1];
				} else {
					targetContainer = controlObj.delegator;
					container = document;
					tie = tie[0];
				}
							
				var event = dd.event || "click";	//**user should be able set default event and action for page to something else		
				var action = dd.action || "select";
				var toggle = dd.toggle || dd.toggle === "true"; // both true and "true" valid
				var exclusive = dd.exclusive || dd.exclusive === "true"; // both true and "true" valid
				
				// check for custom version of action 
				var actionName;				
				if (!controlObj[tie + " " + action]) {						
					actionName = action;
				} else {								
					actionName = tie + " " + action;
				}
				
				// create action variation -- toggle/exclusive/both/none
				var actionVary;								
				if (exclusive && toggle) {
					actionVary = controlObj.exclusiveToggle(actionName); 
				} else if (toggle) {					
					actionVary = controlObj.toggle(actionName);				
				} else if (exclusive) {						
					actionVary = controlObj.exclusive(actionName);
				} else {
					actionVary = controlObj.identity(actionName);
				}			
				
				// bind the appropriate event handler to the delegator element
				controlObj.bind(event, function() {					
					// find any control anchors inside the target control					
					var directTies = jQ("a.directTie", controlObj.targetControl);										
					// get elements tied to by inner anchors
					var ties = [];
					directTies.each(function(i) {
						// get tie values, (will be a list of id's)
						ties[i] = jQ(this).text();						
					})
					
					// get the actual elements associated with each tie... 
					// ...keep only elements that match the control anchor's tie
					ties = ties.join();					
					var tiedElems; 
					if (ties) {
						// ...keep only elements that match the control anchor's tie						
						tiedElems = jQ(ties).filter(tie);
					} else {						
						// if there are no direct ties, make one up						
						//	 get the index of the target control
						//	** Not sure this makes sense if control is an id selector. Should only do this if it's class selector?						
						var elem = controlObj.targetControl[0];												
						var index = jQ(controlObj.control, controlObj.delegator).index(elem);
						// 	get the element in container that matches tie and has the same index as the target control
						tiedElems = jQ(tie, container).eq(index);						
					}			
					
					// apply action to appropriate element(s)
					// case 1: action applies to target control itself					
					if (controlObj.targetControl.filter(tie).length > 0) {						
						actionVary(controlObj.targetControl, tie, container);						
					// case 2: action applies to an element refered to by an anchor inside the target control
					} else if (tiedElems.length > 0) {
						actionVary(tiedElems, tie, container);						
					// case 3: action applies directly to tie element(s)
					} else {							
						actionVary(tie);						
					}					
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
		return this;
	},
	// hide elements
	hide: function (expr) {		
		jQ(expr).hide();
		return this;
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
			var tie;
			var action;
			if (arr.length > 1) {
				tie = arr[0];
				action = arr[1];
			} else {
				action = arr[0]
			}
			// check there is a default version of the custom action that is paired
			// if there is, pair the new action
			if (tie && pairs[action]) {
				pairs[i] = {};
				var potentialInv = tie + " " + pairs[action].inv;				
				// if there was an inverse action created to pair with the new action, use it.
				if (obj[potentialInv]) {
					pairs[i].inv = tie + " " + pairs[action].inv;					
				// if there isn't a new inverse the action, use the default inverse action
				} else {					
					pairs[i].inv = pairs[action].inv;
				}
				// use the same flag as the default action
				pairs[i].flag = pairs[action].flag;
			}
		}
		return this;
	},
	// identity() -- used to make "this" operator work with action functions
	identity: function (action) {
		var that = this;
		return function (elem) {
			that[action](elem);
			return that;
		}
	},	
	// exclusive() -- takes an action makes it exclusive (by exlusive, I mean exclusive like XOR is exclusive)
	// For example, passing the select function returns a function that selects one element and delselects all
	// similar elements.
	// action is a string
	exclusive: function (action) {
		var that = this;		
		try {
			var inv = this.pairs[action].inv;
			var flag = this.pairs[action].flag;
			return function (elem, tie, container) {		
				that[action](elem);			
				that[inv](jQ(tie, container).filter(flag).not(elem));
				return that;
			}
		} catch (err) {
			//console.warn("can't use exclusive with action:", action);	
		}
	},
	// toggle()
	// returns function that toggles an action for elements
	// action is a string
	toggle: function (action) {				
		var that = this;	
		try {
			var inv = this.pairs[action].inv;
			var flag = this.pairs[action].flag;		
			return function (elem, tie, container) {					
				jQ(elem).is(flag) ? that[inv](elem, tie) : that[action](elem, tie);
				return that;
			}
		} catch (err) {
			//console.warn("can't use toggle with action:", action);			
		}
	},
	// exclusiveToggle()
	// action is a string
	exclusiveToggle: function (action) {
		var that = this;		
		try {
			var inv = this.pairs[action].inv;
			var flag = this.pairs[action].flag;
			return function (elem, tie, container) {						
				that.toggle(action)(elem);			
				that[inv](jQ(tie, container).filter(flag).not(elem));
				return that;
			}
		} catch (err) {
			//console.warn("can't use exclusiveToggle with action:", action);	
		}
	}	
}
