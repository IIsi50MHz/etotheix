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
item = control

*/

// Setup jQuery so it's $ function doesn't conflict with Mochikit's
jQuery.noConflict();
// Use jQ instead
var jQ = jQuery;

// MG -- encapsulate some functionality specific to Mongoose  **INCOMPLETE
// **NOTE: Stopped in the middle of writing this, so it's pretty messed up.
// EXAMPLES: 
//	To mark and event as rogue
//		MG.event(eventElement).rogue()
//
var MG = function () {
	// helper functions
	function select(element) {
		jQ(element).addClass("selected")
	};
	// helper variables (**none yet)
	
	// core MG object
	var core = {
		// MG.event(element) wraps element with functionality needed for Mongoose events (shots, misses, etc.)
		event: function () {									
			var objProto = {
				element: "event id", // element is wrapped in the jQuery object
				rogue: function () {					
					this.element.toggleClass("rogue");
					// The loaded xml used by the XSL transformations needs to be updated too!
					// And, at some point, any modifications need to be sent back to the server so they.
					// are reflected in the .session file.
				},
				zoom: function () {
					//alert(this.element.attr("id"));
					//mongooseLoadControlNow('eventLog', '/mongoose/' + mongooseSessionID + '/' + mongooseSessionType + '/review/eventLog/event_log_control/zoom-event/' + id);
				}
			};
			
			var objMaker = function (element) {
				var obj = proto(objProto);
				// make the element a jQuery object
				obj.element = jQ(element);
				return obj;
			};
			
			return objMaker;			
		}(),
		target: {
			current: "target id",
			zoom: function () {
				//alert(this.current);
				//mongooseLoadControlNow('targetList', '/mongoose/' + mongooseSessionID + '/' + mongooseSessionType + '/review/targetList/target_list_control/zoom-target/' + id);
			}
		}
	}	
	return core;
}();

/////////////////////////////// **Should move to global.js
function proto(o) {
	function F() {}
	F.prototype = o;
	return new F();
}
///////////// ** Should move to global.js
// The purpose of the transform object is to transform xml/html file using an xsl file
/////////////
// Might be nice to extend the jQuery object with this this stuff... not sure if it's a good idea. Maybe it's a good idea. Hmmm.
var Transform = function () {	
	var transformProto = {	
		responseXML: "",
		responseXSL: "",
		
		// **Should probably (definitely)  create a maker function so that any new transform objects have their own XSLTProcessor,
		// If you're transforming muliple xml files, things could get really messed up if they all shared the same processor
		// ****Made transform() into a maker function.
		//XSLT: "",//new XSLTProcessor,
		
		// Get an xml or xsl document. Takes a url as its argument.
		// The result can be passed to the xml or xsl methods.
		get: function (xml) { //** need to fix this so we can to this asycnronously
			return jQ.ajax({url: xml, async: false}).responseXML; 
		},
		
		// import the xml doc (takes a url or responseXML from an XMLHttpRequest object. I don't really understand exactly what the responseXML is...)
		// **rename to setXML?
		xml: function (xml) {
			if (typeof xml !== "string") {
				this.responseXML = xml || this.responseXML;
			} else {
				this.responseXML = this.get(xml);
			}					
			return this;
		},
		
		// import the xsl doc (takes a url or responseXML from an XMLHttpRequest object. I don't really understand exactly what the responseXML is...)
		// **rename to setXSL?
		xsl: function (xsl) {
			if (typeof xsl !== "string") {
				this.responseXSL = xsl || this.responseXSL;
			} else {
				this.responseXSL = this.get(xsl);
			}
			this.XSLT.reset();	
			this.XSLT.importStylesheet(this.responseXSL);
			return this;
		},
		
		// set parameters to pass to xsl transform		
		param: function (values) {	
			for (var param in values) {
				this.XSLT.setParameter(null, param, values[param]);			
			}					
			return this;
		},
		
		// transform the xml document
		transform: function () {
			if (this.responseXML && this.responseXSL) {
				return this.XSLT.transformToFragment(this.responseXML, document);
			}					
		}
	};
	// return new Transform object
	return function () {
		var obj = proto(transformProto);
		obj.XSLT = new XSLTProcessor;
		return obj;
	}
}();		

// Function for animating scroll. 
var animateScroll = function (container, finalScrollTop) {	
	// make sure another scoll animation isn't already running
	if(!(animateScroll.running)) {
		animateScroll.running = true;
		// Get current scroll position
		currentScrollTop = container[0].scrollTop;
		
		// Calculate total amount to scroll	
		scrollBy = finalScrollTop - currentScrollTop;	
		// set frame rate
		var frameRate = 30/1000; // 30 frames per sec
		// Time to animate scroll in ms
		var t = 5000/30;
		// Calculate px per frame (this will move scroll at constant rate)
		var dpx = scrollBy/Math.round(frameRate*t);	
		
		// Number of frames
		// NOTE: if frameRate*t must be an integer if you want to scroll to exactly the right pixel
		var frameTotal = Math.round(frameRate*t); 
		var frameCount = 0;
		
		// create function for animating scroll
		function move(newScrollTop) {
			// Make sure we're not done scrolling			
			if (frameCount <= frameTotal) {
				container[0].scrollTop = newScrollTop;
				setTimeout(function (newScrollTop) {				
					move(currentScrollTop + frameCount*dpx)
				}, 1/frameRate);
			} else {
				animateScroll.running = false;	
			}
			frameCount++;
		}
		// animate the scroll
		move(currentScrollTop);
	}
}
animateScroll.running = false;

// Function for scrolling element to center of scroll area
// NOTE: arguments (container and element) must be wrapped in jQuery object. (May want to change this later)
function scrollToCenter(container, element) {
	var currentScrollTop = container[0].scrollTop;
	scrollHeight = container[0].scrollHeight;
	
	// Calculate amount to scroll by to center element within container element
	var tc = container.offset().top + currentScrollTop; // top of container element
	var te = element.offset().top; // top of element
	var hc = container.innerHeight(); // height of container element
	var he = element.height(); // height of element
	var scrollBy = (te + he/2) - (tc + hc/2);
	
	// Calutlate new scroll top
	newScrollTop = currentScrollTop + scrollBy;	
	// Do the scroll
	animateScroll(container, newScrollTop);
}

// GENERIC SELECTOR OBJECT **incomplete 
// **NOTE: This isn't used anywhere yet
// Use this to associate a button or tab with a pane. 		
// 	Selector is made of buttons and panes. 
//	Each button can be associated with one pane
//	Each pane can be associated with many buttons
//		To associate a button with a particular pane, use the button's href attribute
//		Example: 
//			<a href="#paneId">button</a>
//			<div id="paneId">pane</div>
//		NOTE: The selectors *must* be wrapped in a single selector container. The panes, however, don't need to be wrapped in anything.
//	**Should this functionallity be added to eventDelegator?
//	**This restricts selectors to anchor elements. Should make more general. 
//		- All elements with class selector?
//		- All first children of class selectorContainer?
//		- Either? Both?
//	**Need to make more general. May have a whole list of functions that need to be executed when a thing is selected.
var Selector = function (containerId) {
	// create a selector object
	// use like this:
	//	Selector("anId").funcs = [doThis, doThat, function(e) {doSomeOtherStuff();}]
	var selectorProto = {		
		select: function (e) {
			var cId = "#" + e.data.containerId;	
			var newSelector = e.target;	
			if (newSelector.nodeName === "A") {
				var currentSelector = jQ(cId + " a.selected")[0];			
				// if tab clicked and not already selected, select it			
				if (currentSelector !== newSelector) {		
					var currentHref = jQ(currentSelector).attr("href");	
					var newHref = jQ(newSelector).attr("href");			
					
					jQ(currentSelector).removeClass('selected');
					jQ(currnetHref).removeClass('selected');
					
					currentSelector = currentHref;		
					currnetHref = newHref;		
					
					jQ(currentSelector).addClass('selected');
					jQ(currnetHref).addClass('selected');										
				}
			}
		}		
	};	
	return function (containerId) {
		var obj = proto(selectorProto);		
		// When a selector is clicked, the "selected" class should be added to the click selector class AND its assiciated pane		
		jQ("#" + containerId).bind("click", {containerId: containerId}, function (e) {
			for(var f in obj) {
				obj[f](e); // Watch out if order functions execute matters!!!
			}
		});
	}	
}();

// DELEGATOR OBJECT **Not sure this is a very goode name. But may expand functionality of this object so it makes more sense.
// Wraps event delegating functionality around an element
// Use this when you have a bunch of selectable items with internal structure and you want to delagate event handling to some higher level container.
// The element that does the event delegation should contain the selectable elements and nothing else. (**maybe, or maybe not)
// **Need to add some functionality to this object
//	way to bind one or more event types to delegator. Or maybe just one event type. Should create a new object for each event type event if delegator element is the same?
//	way to identify the lowest level container that contains the (potentially composite) elements to delegate to
//	way to identify the (potentially composite) elements that need to be delagated to
//	 function that handles event. Maybe an array of functions?
// Example:	
//	var ding = makeDelegator("#delegator").container("#container").item(".ding");
//	ding.bind("click", function(e) {
//		//do stuff
//		ding.selectOne();
//		alert(ding.e.target);
//		alert(e.target);
//	});
//	...
//
//	// by default container is same as delegator
var makeDelegator = function () {
	var delegatorProto = {
		// jQuery expression that identifies delegator element
		_delegator: "",
		// jQuery expression that identifies container element(s). If not set, is the same as _delegator.
		_container: "",
		// jQuery expression that identifies item element(s)
		_item: "", 		
		
		// holds current event - set by event()
		e: "",		
		// holds target element - set by event()
		// NOTE: The target element is calulated by event(). It will be an element that matches the expression held by _item 
		// and will be inside an element that matches the expression held by _container.
		// For example, if _item is set to ".ding", target will be an element of class "ding"
		target: "",
		// sets event e and calculates target element
		event: function (e) {
			this.e = e;
			// calculate target element
			var targ = jQ(e.target);
			// make sure the event target is inside the container element (container element is parent of e.target)
			// **Why? Isn't the container element redunant? why do we need a container and a delegator?
			/*
			// how about this
			var targParent = targ.parents(this._item);	
			if (targ.is(this._item)) {
				this.target = jQ(targ[0])
			 } else if (targParent.length > 0) {
			 	this.target = jQ(targParent[0])
			 } else {
				this.target = false;
			 }
			 // or this (short but really hard to read)
			 var elem = targ.is(this._item) ? targ[0] : targ.parents(this._item)[0];
			this.target = elem && jQ(elem);			 
			*/
			if (targ.parents(this._container)[0] === jQ(this._container)[0]) {
				// grab the item element
				var elem = targ.is(this._item) ? targ[0] : targ.parents(this._item)[0];
				this.target = jQ(elem);
			} else {
				// if the event target is not inside the container element, return false
				this.target = false;
			}			
			return this;
		},
	
		// Set _container to expr
		container: function (expr) {
			this._container = expr;
			return this;
		},		
		// Set _item to expr		
		item: function (expr) {
			this._item = expr;
			return this;
		},	
		// bind a function to delegator element
		bind: function (type, data, fn) {
			jQ(this._delegator).bind(type, data, fn);
			return this;
		},

		// ** haven't tried this one out
		select: function () {
			jQ(this.target).addClass("selected");
			return this;
		},
		// ** haven't tried this one out
		deselect: function () {
			jQ(this.target).removeClass("selected");
			return this;
		},
		// ** haven't tried this one out
		toggle: function () {
			jQ(this.target).toggleClass("selected");
			return this;
		},
		// Select one element and deselect everything else. Selecting the same element twice in a row does nothing.
		selectOne: function () {
			newElem = this.target;
			// get currently selected elements (if any). Exclude the new element (in case already selected item was selected).
			oldElem = jQ(".selected", this._delegator).filter(this._item).filter(function () {
				return this !== newElem[0];
			});
			// select new element
			newElem.addClass("selected");
			// deselect old elements
			oldElem.removeClass("selected");
			return this;
		}
	};
	// return a function that makes a delegator object
	return function (expr) {
		var obj = proto(delegatorProto);
		obj._delegator = expr;
		obj._container = expr;
		obj.elem = expr; // get rid of this
		return obj;
	};
}();

/////////////////////// 
// "onload" 
//   **Seems like there's might be too much going on here. A lot of the code here could probably be used other places. 
//	Need write some general purpose functions/objects and use them instead.
jQ(function () {
	// disable the selection of any text (we will need to change this for some things later)
	// ** NOTE: This is already in global.js, but is not working on this page for some reason.
	// 	I'm pretty sure jQuery's onload handling function is messing up mongooseAddOnLoadHandler somehow.
	//	They seem to be incompatible. Need to figure out what's going on with this.
	document.onselectstart = function(e) { // ie
		try {
			if (e.originalTarget.tagName == 'INPUT' ||
				hasElementClass(e.originalTarget, 'selectable'))
				return true;
		}
		catch(err) {
			return true;
		}
		return false;
	} 
	document.onmousedown = function(e) { // mozilla
		try {
			if (e.originalTarget.tagName == 'INPUT' ||
				hasElementClass(e.originalTarget, 'selectable'))
				return true;
		}
		catch(err) {
			return true;
		}
		return false;
	} 
	

	// TARGET LIST
	var targetLogPrimaryPane = jQ('#targets_pane > .primary');
	var targetListSecondaryPane = jQ("#targets_pane > div.secondary");
	var targetList = makeDelegator("#targets_pane > .primary").container("#targetList").item("li.target");
	targetList.bind("click", function (e) {
		// get list item clicked element is inside of
		var targetClicked = targetList.event(e).target;		 
		if (targetClicked !== false) {
			/////
			// PRIMARY PANE
			/////
			// select clicked target
			targetList.selectOne();
			// scroll selected target to center
			scrollToCenter(targetLogPrimaryPane, targetClicked);	
			
			/////
			// SECONDARY PANE
			/////
			// clear the secondary target list pane
			targetListSecondaryPane.empty();
			// Add target info to top of secondary pane
			var targetClickedClone = targetClicked.clone();
			targetListSecondaryPane.html(jQ(".primary, .secondary", targetClickedClone));
			// get all the event id's for the clicked target... 
			jQ(".eventList > li", targetClicked[0]).each(function (i) {			
				//...take each event id, use them to find more info, and spit the info into the secondary pane				
				targetListSecondaryPane.append(targetListSecondary.param({eventId: this.innerHTML}).transform());					
			});
			
			/////
			// ZOOM
			/////
			// If zoom button is clicked, zoom! ** THIS IS NOT WORKING YET
			if (jQ(targetList.e.target).attr("class").match("zoom") !== null) {				
				MG.target.zoom();
			}
		}
	});
	
	// EVENT LOG
	var eventLogPrimaryPane = jQ('#events_pane > .primary');
	var eventLogSecondaryPane = jQ("#events_pane > div.secondary");
	var eventList = makeDelegator("#events_pane > .primary").container("#eventList").item("li.event");	
	eventList.bind("click", function (e) {	
		var eventClicked = eventList.event(e).target;
		if (eventClicked !== false) {
			/////
			// PRIMARY PANE
			/////
			// select clicked target
			eventList.selectOne();
			// Scroll selected event to center 
			scrollToCenter(eventLogPrimaryPane, eventClicked);
			
			/////
			// SECONDARY PANE
			/////
			// clear the secondary event list pane
			eventLogSecondaryPane.empty();			
			// Check if event clicked is a shot; add rogue button if it is
			// **Should write a better way to check if event is a shot
			var isShot = jQ(".zoom", eventClicked[0]).length >= 1 ? true : false;
			if (isShot) {					
				eventLogSecondaryPane.append("<div id='eventRogue' href='#'" + eventClicked[0].id + ">rogue</div>");
			}
			// Add event info to top of secondary pane
			var eventClickedClone = eventClicked.clone();
			eventLogSecondaryPane.append(jQ(".primary, .secondary", eventClickedClone));
			
			/////
			// ZOOM
			/////
			// If zoom button is clicked, zoom! ** THIS IS NOT WORKING YET
			if (jQ(eventList.e.target).attr("class").match("zoom") !== null) {
				MG.event.zoom();
			}	
			
			/////
			// TIMELINE
			/////
			// **Should not have to calculate scenarioLength on each click. Should be able to move outside of click handler
			// **Can't move outside though because if we do, the element we're looking for won't exist yet. Hmmm
			var scenarioLength = jQ("//[@id=eventList]/li:last/[@class*=timestamp]").text();
			// Get time of selected event
			var timestamp = jQ(".timestamp", eventClicked[0]).text();
			var formattedTimestamp = jQ(".formattedTimestamp", eventClicked[0]).text();
			// Calculate new time line marker location
			newMarkerLocation = timestamp/scenarioLength*timelineWidth;
			// Update numerical time display
			jQ("#timelineInfo").text(formattedTimestamp);							
			// Adjust timeline marker				
			timelineMarker.animate({left: newMarkerLocation + timelineLeft - halfMarkerWidth}, 50);						
		}
	});
	
	// SCORECARD SELECTION 
	jQ('#scorecards_pane').bind("click", function (e) {
		var selectedScorecard = jQ(e.target).filter(".scorecardThumb");
		if (selectedScorecard.length !== 0) {
			var index = selectedScorecard.attr("index");
			//alert(index);
			scorecardPopup.show();
			mongooseLoadControlNow("scorecardMain", scorecard_form.xml + 'set-selected-trainee/' + index);				
			return false;
		}
	});		
	
	// TAB SELECTION **Need to write a single, dedicated handler function for buttons and tabs**	
	var evalationf_string = "This evaluation form applies to";				
	jQ('#reviewSessionTabs').bind("click", function (e) {
		var selectedTabjQ = jQ("#reviewSessionTabs a.selected");
		var selectedPanejQ = jQ(selectedTabjQ.attr("href"));
		var selectedTabElem = e.target;	
		var selectedTabElemHref = jQ(selectedTabElem).attr("href");		
		// if tab clicked and not already selected, select it			
		if (selectedTabElem.nodeName === "A" && selectedTabElemHref !== selectedTabjQ.attr("href")) {				
			selectedTabjQ.removeClass('selected');
			selectedPanejQ.removeClass('selected');
			
			selectedTabjQ = jQ(selectedTabElem);		
			selectedPanejQ = jQ(selectedTabElemHref);		
			
			selectedTabjQ.addClass('selected');
			selectedPanejQ.addClass('selected');
			// Change scorecards, evaluation, and events views.
			if (selectedTabElemHref === "#all_pane") {
				jQ("#scorecards_pane > div.primary").html(scorecardsAll.transform());
				jQ("#events_pane > div.primary").html(eventLog.transform());
				jQ("#evaluation_pane > div.primary").html("This evaluation form applies to all trainees.");													
			} else {
				jQ("#scorecards_pane > div.primary").html(scorecardsPerTrainee.param({traineeIndex: selectedTabElemHref.slice(1)}).transform());
				jQ("#evaluation_pane > div.primary").html("This evaluation form applies only to the currently selected trainee.");					
				jQ("#events_pane > div.primary").html(eventLogPerTrainee.param({traineeIndex: selectedTabElemHref.slice(1)}).transform());					
			}
		}			
	});
	
	// BUTTON SELECTION (targets, scorcards, evaluation, events)  **Need to write a single, dedicated handler function for buttons and tabs**
	jQ('#sessionViewButtons').bind("click", function (e) {	
		var selectedViewButtonjQ = jQ("#sessionViewButtons a.selected");	
		var selectedViewPanejQ = jQ(selectedViewButtonjQ.attr("href"));
		var selectedViewButtonElem = e.target;	
		var selectedViewButtonElemHref = jQ(selectedViewButtonElem).attr("href");			
		if (selectedViewButtonElem.nodeName === "A" && selectedViewButtonElemHref !== selectedViewButtonjQ.attr("href")) {				
			selectedViewButtonjQ.removeClass('selected');
			selectedViewPanejQ.removeClass('selected');
			
			selectedViewButtonjQ = jQ(selectedViewButtonElem);		
			selectedViewPanejQ = jQ(selectedViewButtonElemHref);		
			
			selectedViewButtonjQ.addClass('selected');
			selectedViewPanejQ.addClass('selected');	
		}			
	});
	
	// TAB SCROLL BUTTONS **Need to write a single handler for left and right scroll**
	var tTabs = jQ("#traineeTabs");
	var tabOffset = parseInt(tTabs.css("left"));
	var tabWidth = 1*jQ("#traineeTabs li:first-child").width();
	var tabPosition = 0;		
	jQ('#tabScroll a.right').bind("click", function (e) {
		var numTabs = jQ("#traineeTabs a").length;
		if (tabPosition < numTabs - 1) {
			tabPosition += 1;						
			tabOffset -= tabWidth;			
			tTabs.animate({left: tabOffset}, 90);
		}
	});
	jQ('#tabScroll a.left').bind("click", function (e) {					
		if (tabPosition > 0) {				
			tabPosition -= 1;				
			tabOffset += tabWidth;
			tTabs.animate({left: tabOffset}, 90);
		}
	});
	
	// TIMELINE
	// format time **Should move function definition outside "onload"
	function formatTime(timeInSec) {		
		hr = Math.floor(timeInSec/360).toString();
		min = (Math.floor(timeInSec/60)%60).toString();
		sec = (timeInSec%60).toFixed(2); // round seconds to nearest 100th
		// pad if needed
		var isSingleDigit = /^\d{1}$|^\d{1}\./; // single digit or single digit followed by decimal point
		hr = isSingleDigit.test(hr)? "0" + hr : hr;
		min = isSingleDigit.test(min)? "0" + min : min;
		sec = isSingleDigit.test(sec)? "0" + sec : sec;
		return hr + ":" + min + ":" + sec;
	}
	var timeline = jQ('#timeline');
	var timelineLeft = timeline.offset().left;		
	var timelineMarker = jQ("#timelineMarker");
	var timelineWidth = timeline.width();		
	var halfMarkerWidth = timelineMarker.width()/2;
		timeline.bind("click", function (e) {
		var scenarioLength = jQ("//[@id=eventList]/li:last/[@class*=timestamp]").text();
		var clickX = e.clientX;
		// Update numerical time display
		var time = (clickX - timelineLeft)/timelineWidth*scenarioLength;				
		jQ("#timelineInfo").text(formatTime(time));				
		// Adjust time marker
		timelineMarker.animate({left: clickX - halfMarkerWidth}, 50);			
	});	
	
	// ROGUE BUTTON
	var eventRogueButton = jQ("#eventRogue")
	eventRogueButton.bind("click", function (e) {
		var eventId = eventRogueButton.attr("href");
		MG.event(eventId).rogue();
	});	
})







