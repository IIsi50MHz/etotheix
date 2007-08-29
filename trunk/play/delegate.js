/* 
delegate plugin for jQuery
*/
(function (jQuery, selectorMap) {
	// local variables
	selectorMap = {" ": "parents", ">": "parent", "+": "prev", "~": "prevSiblings"};
	// local functions **need to comment these better
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
	function trigger(type, elem) { //**this probably doesn't work in IE
		var e = document.createEvent("MouseEvents");
		e.initEvent(type, true, true);
		elem.dispatchEvent(e);
	}
	// extending jQuery
	$.fn.extend({
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
		dispatch: function (event) { //**this probably doesn't work in IE
			this.each(function () {
				trigger(event, this);
			})
			return this;
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
		}	
	});	
})($);