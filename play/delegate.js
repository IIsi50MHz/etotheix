/* dialog
- should wrap all dialogs in a single div
- don't auto generate any dialog contents
- do auto generate background and stuff...
- assume only one dialog visible at a time? only for modal... which will be most (all dialgos)
- make dialog container the background... then you don't have to auto generate anything...
- dialogs are selected and are only visible when selected.
- bringing up a dialog involves an exclusive select of the dialog, and making the dialog contiainer visible
- all children div's of dialog container are styled as dialogs...
- How do you hook up buttons? 
	1) Give buttons classes or attributes that say what they are for? "hides"
	2) use protoControl?
*/

var complexSelectorMatch;
(function (jQuery, delegator, target) {
	$.fn.prevSiblings = function (selector) { // works only for first elements		
		var results = $().filter();
		var siblings;
		this.each(function () {			
			selector = selector || "*";			
			siblings = $(this).parent().children();			
			results = results.add(siblings.slice(0, siblings.index(this)).filter(selector));						
		});
		return results;
	};
	var selectorMap = {" ": "parents", ">": "parent", "+": "prev", "~": "prevSiblings"};
	complexSelector = function (selector) {  // **this does not handle comma separated slectors yet!	
		var splitSelector = selector.replace(/\s*([\s|>|\+])\s*/g, ",$1,").split(",");
		var length = splitSelector.length;
		var elem = $(this).filter(splitSelector[length - 1]);		
		
		if (!elem.length) return false; // not a match!
		for (var i = length - 2; i > 0; i = i -= 2) {			
			//console.debug(i, elem, elem[selectorMap[splitSelector[i]]](), "; op:", selectorMap[splitSelector[i]], "; sel:", splitSelector[i - 1]);
			elem = elem[selectorMap[splitSelector[i]]](splitSelector[i - 1])
			if (!elem.length) return false; // not a match!
			//console.debug(i, elem);
		}		
		return elem.length > 0;
	}
	$.fn.delegate = function (selector, event, data, func) {				
		// save a reference to the delegator (a jQuery object) to hang things on
		delegator = this;		
		// make sure we've got the right func
		if (typeof data === 'function') func = data;		
		
		// hook up the delegator
		return delegator.bind(event, data, function (e) {
			hey = $(e.target).parents();
			ding = selector;
			console.debug("parents", selector, $(e.target).parents().filter(selector));
			if (delegator.e !== e) { // make sure we have a new event **why? **** I think maybe we need this when we do custom events?
				delegator.e = e;				
				// e.target matches selector
				if ($(e.target).is(selector)) {
					delegator.target = e.target;												
				// see if e.target is inside an element that matches selector 
				} else {					
					delegator.target = $(e.target).parents(selector).filter(complexSelector(selector))[0]; //** this only works for simple selectors. Need to come up with something better (use xpath???)				
				}				
				// delegate!
				if (delegator.target) {					
					func.call(delegator.target, e, delegator, data);
				}
			}
		});	
	}
// EXPERIMENTING...
	function trigger(type, elem) {
		var e = document.createEvent("MouseEvents");
		e.initEvent(type, true, true);
		elem.dispatchEvent(e);
	}
	$.fn.dispatch = function (event) {
		this.each(function () {
			trigger(event, this);
		})
		return this;
	} 
	// create a key event
	$.fn.pressKey = function (key) {
		
		console.debug("key0", key, this);	
		var event = document.createEvent("KeyboardEvent");
		console.debug("key1", key, this);	
		event.initKeyEvent(                                                                                      
			"keypress",        //  in DOMString typeArg,                                                           
			true,             //  in boolean canBubbleArg,                                                        
			true,             //  in boolean cancelableArg,                                                       
			null,             //  in nsIDOMAbstractView viewArg,  Specifies UIEvent.view. This value may be null.     
			false,            //  in boolean ctrlKeyArg,                                                               
			false,            //  in boolean altKeyArg,                                                        
			false,            //  in boolean shiftKeyArg,                                                      
			false,            //  in boolean metaKeyArg,                                                       
			0,               //  in unsigned long keyCodeArg,                                                      
			key				//  in unsigned long charCodeArg
		);
		console.debug("key2", key, this);	
		this.each(function () {
			console.debug("key3", key, this);	
			this.dispatchEvent(event);
		});
		return this;
	}
})($);


