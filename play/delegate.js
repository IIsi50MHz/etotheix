/* 
delegate plugin for jQuery
*/
(function (jQuery, selectorMap) {
	// local variables
	selectorMap = {" ": "parents", ">": "parent", "+": "prev", "~": "prevSiblings"};
	// local functions **need to comment these better
	// Handle complex selectors (but not comma separated ones) like this: "#ding > a"
	function complexSelector(that, selector) {  // **this does not handle comma separated selctors yet! ****created multiSelector() for this. See below.
		var splitSelector = selector.replace(/\s*([\s|>|\+])\s*/g, ",$1,").split(",");		
		var length = splitSelector.length;
		var elem = $(that).filter(splitSelector[length - 1]);		
		if (!elem.length) return false; // not a match!		
		for (var i = length - 2; i > 0; i = i -= 2) {						
			elem = elem[selectorMap[splitSelector[i]]](splitSelector[i - 1])
			if (!elem.length) return false; // not a match!			
		}		
		return elem.length > 0;
	}
	// Handle comma separated selectors
	function multiSelector(that, selector) {		
		var splitSelector = selector.split(/\s*,\s*/);
		var length = splitSelector.length;
		var elem = $(that);
		var results = $().filter();
		for (var i = 0; i < length; i++) {
			results = results.add(elem.filter(function () {
				return complexSelector(that, splitSelector[i]);					
			}));
		}		
		return results.length > 0;
	}	
	function trigger(elem, eventType, options) { //**this probably works in firefox only
		options = $.extend({canBubble: true, cancelable:true, eventTypeType: "Event"}, options);
		var e = document.createEvent(options.eventTypeType);		
		e.initEvent(eventType, options.canBubble, options.cancelable);	
		elem.dispatchEvent(e);		
	}	
	// extending jQuery
	$.fn.extend({
		// jQuery's filter() function only works with simple selectors. complexFilter() works with selectors likw this: "a, div > .blah, .ding + .dong"
		complexFilter: function (selector) {
			return this.filter(function () {
				return multiSelector(this, selector);
			});
		},
		prevSiblings: function (selector) { //**works only for first elements. ****this is fixed now.
			var results = $().filter();
			var siblings;
			this.each(function () {			
				selector = selector || "*";			
				siblings = $(this).parent().children();			
				results = results.add(siblings.slice(0, siblings.index(this)).filter(selector));						
			});
			return results;
		}, 		
		delegate: function (selector, event, data, func) {
			// save a reference to the delegator (a jQuery object) to hang things on
			var delegator = this;		
			// make sure we've got the right func
			if (typeof data === 'function') func = data;		
			// hook up the delegator
			delegator.bind(event, data, function (e) {		
				if (delegator.e !== e) { // make sure we have a new event **why? **** I think maybe we need this when we do custom events?
					delegator.e = e;				
					// e.target matches selector				
					if ($(e.target).complexFilter(selector).length) {					
						delegator.target = e.target;												
					// see if e.target is inside an element that matches selector 
					} else {										
						delegator.target = $(e.target).parents().complexFilter(selector)[0]; //** this only works for simple selectors. Need to come up with something better (use xpath???) ****created jQuery.fn.complexFilter to handle complex selectors
					}				
					// delegate!
					if (delegator.target) {					
						func.call(delegator.target, e, delegator, data);
					}
				}
			});
			return this;
		},
		// for triggering custom events that bubble. **don't try to use this with mouse or keyboard events yet! custom events only for now!
		dispatch: function (eventType) { //**this probably doesn't work in IE ****It shouldn't be to hard to make this work with IE... See Flanagan's Javascript book.			
			this.each(function () {				
				trigger(this, eventType);			
			})
			return this;
		}
	});	
})($);