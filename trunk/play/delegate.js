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

(function (jQuery, delegator, target) {	
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
	$.fn.delegate = function (selector, event, data, func) {				
		delegator = this;		
		// make sure we've got the right func
		if (typeof data === 'function') func = data;
		
		// hook up the delegator
		return delegator.bind(event, data, function (e) {
			if (delegator.e !== e) { // make sure we have a new event **why? **** I think maybe we need this when we do custom events?
				delegator.e = e;
				// calculate targetControl element				
				target = $(e.target).parents(selector);
				if ($(e.target).is(selector)) { // e.target matches selector
					delegator.target = e.target;					
				} else if (target.length > 0) { // e.target is inside an element that matches selector **how do you know we're still inside the delegator? ****doesn't matter? This could be a feature! Hmmmm...
					delegator.target = target;				
				} else { // no match
					delegator.target = false;
				}
				console.debug('target', delegator.target);
				
				
				if (delegator.target) {					
					func.call(delegator.target, e, delegator, data);
				}
			}
		});	
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


